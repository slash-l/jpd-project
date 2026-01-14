import Foundation

class VulnerableCode {
    // 1. 硬編碼的密碼和 API Keys (Secrets Detection)
    let apiKey = "AKIAIOSFODNN7EXAMPLE"  // AWS Access Key
    let password = "P@ssw0rd123456"
    let apiSecret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    let githubToken = "ghp_1234567890abcdefghijklmnopqrstuvwxyz"
    let privateKey = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA1234567890\n-----END RSA PRIVATE KEY-----"
    
    // 2. SQL 注入漏洞 (SAST)
    func getUserData(userId: String) -> String {
        let query = "SELECT * FROM users WHERE id = '\(userId)'"  // 不安全的字串拼接
        return query
    }
    
    // 3. 命令注入漏洞 (SAST)
    func executeCommand(userInput: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "ls " + userInput]  // 命令注入風險
        task.launch()
    }
    
    // 4. 路徑遍歷漏洞 (SAST)
    func readFile(fileName: String) -> String? {
        let filePath = "/var/data/" + fileName  // 不安全的路徑拼接
        return try? String(contentsOfFile: filePath)
    }
    
    // 5. 不安全的加密 (SAST)
    func weakEncryption(data: String) -> String {
        // 使用過時的 MD5 算法
        return data.md5()
    }
    
    // 6. 硬編碼的資料庫連接字串 (Secrets Detection)
    let dbConnection = "mongodb://admin:MySecretPassword123@localhost:27017/mydb"
    let mysqlConn = "jdbc:mysql://localhost:3306/mydb?user=root&password=root123"
    
    // 7. 不安全的隨機數生成 (SAST)
    func generateToken() -> Int {
        return Int.random(in: 0...999999)  // 使用不安全的隨機數生成
    }
    
    // 8. 敏感資料記錄 (SAST)
    func logCredentials(username: String, password: String) {
        print("User: \(username), Password: \(password)")  // 記錄敏感資料
    }
    
    // 9. XML 外部實體注入 (XXE) (SAST)
    func parseXML(xmlString: String) {
        let parser = XMLParser(data: xmlString.data(using: .utf8)!)
        parser.parse()  // 沒有禁用外部實體
    }
    
    // 10. 不安全的反序列化 (SAST)
    func deserializeData(data: Data) -> Any? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
    }
    
    // 11. CORS 設定不當 (SAST)
    func setupCORS() -> [String: String] {
        return ["Access-Control-Allow-Origin": "*"]  // 允許所有來源
    }
    
    // 12. 不安全的 SSL/TLS 設定 (SAST)
    func disableSSLValidation() {
        // 禁用 SSL 憑證驗證
        URLSession.shared.configuration.urlCredentialStorage = nil
    }
}

// MD5 extension (不安全的雜湊函數)
extension String {
    func md5() -> String {
        // 簡單的 MD5 實作示例
        return "md5_hash_of_\(self)"
    }
}
