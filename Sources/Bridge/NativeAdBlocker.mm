#include "NativeAdBlocker.h"
#import <Foundation/Foundation.h>
#import <os/log.h>

namespace {
    bool WildcardMatch(const char* pattern, const char* str) {
        while (*pattern) {
            if (*pattern == '*') {
                while (*pattern == '*') {
                    pattern++;
                }
                if (!*pattern) {
                    return true;
                }
                while (*str) {
                    if (WildcardMatch(pattern, str)) {
                        return true;
                    }
                    str++;
                }
                return false;
            } else if (*pattern == '?') {
                if (!*str) {
                    return false;
                }
                pattern++;
                str++;
            } else {
                if (std::tolower(static_cast<unsigned char>(*pattern)) != std::tolower(static_cast<unsigned char>(*str))) {
                    return false;
                }
                pattern++;
                str++;
            }
        }
        return *str == '\0';
    }
}

NativeAdBlocker* NativeAdBlocker::GetInstance() {
    static NativeAdBlocker* instance = new NativeAdBlocker();
    return instance;
}

NativeAdBlocker::NativeAdBlocker() {
    UpdateRulesFromFiles();
    StartBackgroundDownload();
}

void NativeAdBlocker::SetExceptions(const std::unordered_set<std::string>& exceptions) {
    std::lock_guard<std::mutex> lock(mutex_);
    exceptions_ = exceptions;
}

void NativeAdBlocker::ParseRule(const std::string& raw_line) {
    if (raw_line.empty()) return;
    
    // Trim spaces
    size_t start = raw_line.find_first_not_of(" \t\r\n");
    if (start == std::string::npos) return;
    size_t end = raw_line.find_last_not_of(" \t\r\n");
    std::string line = raw_line.substr(start, end - start + 1);
    
    if (line.empty()) return;
    if (line[0] == '!' || line[0] == '[') return; // Comment or header
    
    FilterRule rule;
    rule.is_exception = false;
    if (line.rfind("@@", 0) == 0) {
        rule.is_exception = true;
        line = line.substr(2);
    }
    
    // Parse options (e.g. $third-party)
    size_t dollar = line.find('$');
    if (dollar != std::string::npos) {
        std::string options = line.substr(dollar + 1);
        line = line.substr(0, dollar);
        
        // Split options by comma
        size_t pos = 0;
        while (pos < options.length()) {
            size_t next_comma = options.find(',', pos);
            std::string opt = options.substr(pos, (next_comma == std::string::npos ? std::string::npos : next_comma - pos));
            if (opt == "third-party") {
                rule.is_third_party = true;
            }
            if (next_comma == std::string::npos) break;
            pos = next_comma + 1;
        }
    }
    
    if (line.empty()) return;
    
    // Check if domain anchored (starts with ||)
    if (line.rfind("||", 0) == 0) {
        rule.is_domain_anchored = true;
        line = line.substr(2);
        
        // Find separator character to end of domain
        size_t sep = line.find_first_of("^/*");
        if (sep != std::string::npos) {
            rule.target_domain = line.substr(0, sep);
            rule.pattern = line.substr(sep);
        } else {
            rule.target_domain = line;
            rule.pattern = "";
        }
        
        // Lowercase the domain
        for (char &c : rule.target_domain) {
            c = std::tolower(static_cast<unsigned char>(c));
        }
    } else {
        rule.pattern = line;
    }
    
    // Clean rule.pattern: remove any leading/trailing '^' or '*' for simpler matching
    if (!rule.pattern.empty() && rule.pattern[0] == '*') {
        rule.pattern = rule.pattern.substr(1);
    }
    if (!rule.pattern.empty() && rule.pattern.back() == '*') {
        rule.pattern.pop_back();
    }
    if (!rule.pattern.empty() && rule.pattern.back() == '^') {
        rule.pattern.pop_back();
    }
    
    // Lowercase pattern for case-insensitive matching
    for (char &c : rule.pattern) {
        c = std::tolower(static_cast<unsigned char>(c));
    }
    
    rules_.push_back(rule);
}

void NativeAdBlocker::UpdateRulesFromFiles() {
    std::vector<FilterRule> new_rules;
    std::unordered_set<std::string> new_blocked_domains;
    
    @autoreleasepool {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString* appSupport = paths.firstObject;
        NSString* soulDir = [appSupport stringByAppendingPathComponent:@"SoulBrowser"];
        
        NSArray* fileNames = @[@"easylist.txt", @"easyprivacy.txt"];
        bool loadedAny = false;
        
        for (NSString* fileName in fileNames) {
            NSString* filePath = [soulDir stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                if (content.length > 0) {
                    NSArray* lines = [content componentsSeparatedByString:@"\n"];
                    for (NSString* line in lines) {
                        std::string lineStr(line.UTF8String);
                        // Temporarily push to class rules_ so ParseRule works as designed
                        rules_.clear();
                        ParseRule(lineStr);
                        if (!rules_.empty()) {
                            new_rules.push_back(rules_.back());
                        }
                    }
                    loadedAny = true;
                }
            }
        }
        
        // Fallback to bundled trackers.txt
        if (!loadedAny) {
            NSString* path = [[NSBundle mainBundle] pathForResource:@"trackers" ofType:@"txt"];
            if (path) {
                NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                NSArray* lines = [content componentsSeparatedByString:@"\n"];
                for (NSString* line in lines) {
                    NSString* trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (trimmed.length > 0 && ![trimmed hasPrefix:@"#"]) {
                        std::string domain(trimmed.lowercaseString.UTF8String);
                        new_blocked_domains.insert(domain);
                        
                        // Also treat as a domain-anchored filter rule
                        std::string ruleStr = "||" + domain;
                        rules_.clear();
                        ParseRule(ruleStr);
                        if (!rules_.empty()) {
                            new_rules.push_back(rules_.back());
                        }
                    }
                }
                os_log(OS_LOG_DEFAULT, "NativeAdBlocker: Loaded fallback trackers.txt with %zu domains", new_blocked_domains.size());
            }
        }
    }
    
    std::lock_guard<std::mutex> lock(mutex_);
    rules_ = std::move(new_rules);
    blocked_domains_ = std::move(new_blocked_domains);
    os_log(OS_LOG_DEFAULT, "NativeAdBlocker: Rules updated, total rules count: %zu", rules_.size());
}

void NativeAdBlocker::StartBackgroundDownload() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString* appSupport = paths.firstObject;
            NSString* soulDir = [appSupport stringByAppendingPathComponent:@"SoulBrowser"];
            
            // Create directories if missing
            [[NSFileManager defaultManager] createDirectoryAtPath:soulDir withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSArray* urls = @[
                @{@"url": @"https://easylist.to/easylist/easylist.txt", @"file": @"easylist.txt"},
                @{@"url": @"https://easylist.to/easylist/easyprivacy.txt", @"file": @"easyprivacy.txt"}
            ];
            
            for (NSDictionary* item in urls) {
                NSURL* url = [NSURL URLWithString:item[@"url"]];
                NSString* fileName = item[@"file"];
                NSString* destPath = [soulDir stringByAppendingPathComponent:fileName];
                
                NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                    if (error) {
                        os_log_error(OS_LOG_DEFAULT, "NativeAdBlocker download error: %{public}s", error.localizedDescription.UTF8String);
                        return;
                    }
                    if (data) {
                        [data writeToFile:destPath atomically:YES];
                        os_log(OS_LOG_DEFAULT, "NativeAdBlocker downloaded %{public}s successfully", fileName.UTF8String);
                        // Trigger update when done
                        this->UpdateRulesFromFiles();
                    }
                }];
                [task resume];
            }
        }
    });
}

bool NativeAdBlocker::MatchRule(const FilterRule& rule, const std::string& req_url, const std::string& req_host, bool is_third_party_req) {
    if (rule.is_third_party && !is_third_party_req) {
        return false;
    }
    
    if (rule.is_domain_anchored) {
        bool host_matches = (req_host == rule.target_domain);
        if (!host_matches && req_host.length() > rule.target_domain.length()) {
            size_t diff = req_host.length() - rule.target_domain.length();
            if (req_host[diff - 1] == '.' && req_host.compare(diff, rule.target_domain.length(), rule.target_domain) == 0) {
                host_matches = true;
            }
        }
        if (!host_matches) {
            return false;
        }
        
        if (rule.pattern.empty()) {
            return true;
        }
    }
    
    // Check pattern match (lowercase req_url)
    std::string lower_req_url = req_url;
    for (char &c : lower_req_url) {
        c = std::tolower(static_cast<unsigned char>(c));
    }
    
    if (rule.pattern.find('*') == std::string::npos && rule.pattern.find('?') == std::string::npos) {
        return lower_req_url.find(rule.pattern) != std::string::npos;
    } else {
        return WildcardMatch(rule.pattern.c_str(), lower_req_url.c_str());
    }
}

bool NativeAdBlocker::ShouldBlock(const std::string& urlStr, const std::string& main_frame_url) {
    std::lock_guard<std::mutex> lock(mutex_);
    
    if (rules_.empty() && blocked_domains_.empty()) return false;
    
    std::string req_host = "";
    std::string main_host = "";
    
    @autoreleasepool {
        NSURL* reqUrl = [NSURL URLWithString:@(urlStr.c_str())];
        if (reqUrl) {
            req_host = std::string(reqUrl.host.lowercaseString.UTF8String);
        }
        
        if (!main_frame_url.empty()) {
            NSURL* mainUrl = [NSURL URLWithString:@(main_frame_url.c_str())];
            if (mainUrl) {
                main_host = std::string(mainUrl.host.lowercaseString.UTF8String);
            }
        }
    }
    
    if (req_host.empty()) return false;
    
    // Check user-defined exceptions first
    if (!main_host.empty() && exceptions_.find(main_host) != exceptions_.end()) {
        return false;
    }
    
    // Third-party check
    bool is_third_party_req = false;
    if (!main_host.empty() && req_host != main_host) {
        // If main_host is not a suffix of req_host
        if (req_host.length() > main_host.length()) {
            size_t diff = req_host.length() - main_host.length();
            if (!(req_host[diff - 1] == '.' && req_host.compare(diff, main_host.length(), main_host) == 0)) {
                is_third_party_req = true;
            }
        } else {
            is_third_party_req = true;
        }
    }
    
    // 1. Exception rules (whitelist overrides)
    for (const auto& rule : rules_) {
        if (rule.is_exception) {
            if (MatchRule(rule, urlStr, req_host, is_third_party_req)) {
                return false;
            }
        }
    }
    
    // 2. Blocking rules
    for (const auto& rule : rules_) {
        if (!rule.is_exception) {
            if (MatchRule(rule, urlStr, req_host, is_third_party_req)) {
                os_log(OS_LOG_DEFAULT, "🛡️ Soul AdBlocker: Blocked request to %{public}s matching EasyList rule %{public}s", urlStr.c_str(), rule.pattern.c_str());
                return true;
            }
        }
    }
    
    // 3. Fallback to blocked domains exact/subdomain match
    if (blocked_domains_.find(req_host) != blocked_domains_.end()) {
        os_log(OS_LOG_DEFAULT, "🛡️ Soul AdBlocker: Blocked tracker request to %{public}s (fallback)", req_host.c_str());
        return true;
    }
    
    size_t pos = req_host.find('.');
    while (pos != std::string::npos) {
        std::string parent = req_host.substr(pos + 1);
        if (blocked_domains_.find(parent) != blocked_domains_.end()) {
            os_log(OS_LOG_DEFAULT, "🛡️ Soul AdBlocker: Blocked tracker request to %{public}s (matched parent fallback %{public}s)", req_host.c_str(), parent.c_str());
            return true;
        }
        pos = req_host.find('.', pos + 1);
    }
    
    return false;
}
