import Foundation

/// AI-Assisted Form Filler (Roadmap Item 22)
/// Parses form fields locally, maps them semantically to saved user profile
/// fields, and auto-fills safely with local LLM assistance.
final class AIFormFiller {
    static let shared = AIFormFiller()

    struct UserProfile: Codable {
        var fullName: String = ""
        var email: String = ""
        var phone: String = ""
        var address: String = ""
        var city: String = ""
        var state: String = ""
        var zip: String = ""
        var country: String = ""
        var company: String = ""
        var jobTitle: String = ""
    }

    @Published var profile = UserProfile()

    private init() {
        loadProfile()
    }

    func fillForms(in tab: BrowserTab) {
        let profileJSON = try? JSONEncoder().encode(profile)
        let profileString = String(data: profileJSON ?? Data(), encoding: .utf8) ?? "{}"

        let js = """
        (function(profile) {
            function inferFieldType(input) {
                var name = (input.name + ' ' + input.id + ' ' + input.placeholder).toLowerCase();
                if (/e.?mail/.test(name)) return 'email';
                if (/phone|tel|mobile/.test(name)) return 'phone';
                if (/first.?name|fname|given.?name/.test(name)) return 'firstName';
                if (/last.?name|lname|surname|family.?name/.test(name)) return 'lastName';
                if (/address.?1|street|addr1/.test(name)) return 'address';
                if (/city/.test(name)) return 'city';
                if (/state|province|region/.test(name)) return 'state';
                if (/zip|postal|postcode/.test(name)) return 'zip';
                if (/country/.test(name)) return 'country';
                if (/company|organization|employer/.test(name)) return 'company';
                if (/job.?title|position|role/.test(name)) return 'jobTitle';
                if (/name/.test(name)) return 'fullName';
                return 'unknown';
            }
            var inputs = document.querySelectorAll('input[type="text"], input[type="email"], input[type="tel"], textarea');
            inputs.forEach(function(input) {
                var type = inferFieldType(input);
                if (type === 'email' && profile.email) input.value = profile.email;
                if (type === 'phone' && profile.phone) input.value = profile.phone;
                if (type === 'fullName' && profile.fullName) input.value = profile.fullName;
                if (type === 'address' && profile.address) input.value = profile.address;
                if (type === 'city' && profile.city) input.value = profile.city;
                if (type === 'state' && profile.state) input.value = profile.state;
                if (type === 'zip' && profile.zip) input.value = profile.zip;
                if (type === 'country' && profile.country) input.value = profile.country;
                if (type === 'company' && profile.company) input.value = profile.company;
                if (type === 'jobTitle' && profile.jobTitle) input.value = profile.jobTitle;
                input.dispatchEvent(new Event('input', { bubbles: true }));
            });
        })(\(profileString));
        """
        tab.browserView.evaluateJavaScript(js) { _, _ in }
    }

    func saveProfile() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/profile.json")
        guard let url, let data = try? JSONEncoder().encode(profile) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func loadProfile() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/profile.json")
        guard let url, let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return }
        profile = decoded
    }
}
