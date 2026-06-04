#pragma once

#include <string>
#include <unordered_set>
#include <vector>
#include <mutex>

struct FilterRule {
    std::string pattern;
    bool is_exception = false;
    bool is_domain_anchored = false; // starts with ||
    bool is_third_party = false;
    std::string target_domain;       // e.g. domain.com from ||domain.com
};

class NativeAdBlocker {
public:
    static NativeAdBlocker* GetInstance();
    bool ShouldBlock(const std::string& request_url, const std::string& main_frame_url);
    void SetExceptions(const std::unordered_set<std::string>& exceptions);
    void UpdateRulesFromFiles();
    
private:
    NativeAdBlocker();
    void StartBackgroundDownload();
    void ParseRule(const std::string& line);
    bool MatchRule(const FilterRule& rule, const std::string& req_url, const std::string& req_host, bool is_third_party_req);
    
    std::vector<FilterRule> rules_;
    std::unordered_set<std::string> blocked_domains_; // fallback tracker list
    std::unordered_set<std::string> exceptions_;       // user-specified exclusions
    std::mutex mutex_;
};

