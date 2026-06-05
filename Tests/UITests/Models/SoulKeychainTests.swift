import XCTest
@testable import Soul

final class SoulKeychainTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Ensure the keychain environment variable is enabled for tests to verify the API
        // WARNING: Modifying process environment might not reflect securely in SecItem functions in tests
        // But we will test the logical wrapper structure.
        setenv("SOUL_USE_REAL_KEYCHAIN", "1", 1)
    }
    
    override func tearDown() {
        // Clean up test items
        SoulKeychain.shared.deletePassword(account: "test_user_account")
        unsetenv("SOUL_USE_REAL_KEYCHAIN")
        super.tearDown()
    }
    
    func testSaveAndReadPassword() {
        let keychain = SoulKeychain.shared
        
        let account = "test_user_account"
        let password = "super_secure_password_123!"
        
        // Save password
        let saved = keychain.savePassword(account: account, password: password)
        XCTAssertTrue(saved, "Failed to save password to keychain")
        
        // Read password
        let retrieved = keychain.readPassword(account: account)
        XCTAssertEqual(retrieved, password, "Retrieved password does not match saved password")
        
        // Delete password
        let deleted = keychain.deletePassword(account: account)
        XCTAssertTrue(deleted, "Failed to delete password from keychain")
        
        // Read again to ensure it's gone
        let retrievedAfterDelete = keychain.readPassword(account: account)
        XCTAssertNil(retrievedAfterDelete, "Password should be nil after deletion")
    }
    
    func testMockFallback() {
        // Disable real keychain
        unsetenv("SOUL_USE_REAL_KEYCHAIN")
        unsetenv("MORI_USE_REAL_KEYCHAIN")
        
        let keychain = SoulKeychain.shared
        let account = "mock_test_account"
        let password = "mock_password"
        
        // In mock mode, save returns true but actually reading returns nil
        let saved = keychain.savePassword(account: account, password: password)
        XCTAssertTrue(saved, "Mock save should return true")
        
        let retrieved = keychain.readPassword(account: account)
        XCTAssertNil(retrieved, "Mock read should always return nil as per current implementation")
    }
}
