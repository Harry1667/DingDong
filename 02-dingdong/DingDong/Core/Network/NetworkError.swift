import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case serverError(statusCode: Int)
    case decodingError(Error)
    case offline

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "網址格式錯誤"
        case .noData:                   return "無資料"
        case .serverError(let code):    return "伺服器錯誤（\(code)）"
        case .decodingError:            return "資料格式錯誤，請稍後再試"
        case .offline:                  return "網路連線中斷，顯示最後資料"
        }
    }
}
