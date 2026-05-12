import Foundation

extension Date {
    var relativeString: String {
        let seconds = Int(Date().timeIntervalSince(self))
        if seconds < 60 { return "剛剛更新" }
        if seconds < 3600 { return "\(seconds / 60) 分鐘前更新" }
        return "\(seconds / 3600) 小時前更新"
    }
}
