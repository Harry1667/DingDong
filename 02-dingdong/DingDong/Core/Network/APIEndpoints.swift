import Foundation

enum APIEndpoints {
    static let baseURL = "https://dd.dl-app.com"

    static func hospitals() -> String {
        "\(baseURL)/api/hospitals"
    }

    static func hospitalsStatus() -> String {
        "\(baseURL)/api/hospitals/status"
    }

    static func progress(hospitalCode: String) -> String {
        "\(baseURL)/api/progress/\(hospitalCode)"
    }

    static func departments(hospitalCode: String) -> String {
        "\(baseURL)/api/departments/\(hospitalCode)"
    }

    static func doctors(hospitalCode: String, department: String? = nil) -> String {
        var url = "\(baseURL)/api/doctors/\(hospitalCode)"
        if let dept = department {
            let encoded = dept.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? dept
            url += "?department=\(encoded)"
        }
        return url
    }

    static func searchHospital(query: String) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return "\(baseURL)/api/search/hospital?q=\(encoded)&limit=20"
    }

    static func trackStart() -> String {
        "\(baseURL)/api/track/start"
    }

    static func trackStop(trackId: Int) -> String {
        "\(baseURL)/api/track/\(trackId)/stop"
    }
}
