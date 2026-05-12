import Foundation

struct Hospital: Codable, Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let shortName: String?
    let city: String?
    let district: String?
    let level: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case code, name, city, district, level
        case shortName = "short_name"
        case isActive = "is_active"
    }
}

struct HospitalsResponse: Codable {
    let hospitals: [Hospital]
}

struct HospitalSearchResponse: Codable {
    let hospitals: [Hospital]
}

// 地區分類
enum HospitalArea: String, CaseIterable {
    case taipei    = "台北市"
    case newTaipei = "新北市"
    case keelung   = "基隆"
    case taoyuan   = "桃園"
    case taichung  = "台中"
    case yunjiaNan = "雲嘉南"
    case kaohsiung = "高雄"
    case other     = "其他"

    static func classify(_ hospital: Hospital) -> HospitalArea {
        let name = hospital.name
        if let city = hospital.city {
            if city.contains("台北") { return .taipei }
            if city.contains("新北") { return .newTaipei }
            if city.contains("基隆") { return .keelung }
            if city.contains("桃園") { return .taoyuan }
            if city.contains("台中") { return .taichung }
            if city.contains("高雄") { return .kaohsiung }
            if city.contains("雲林") || city.contains("嘉義") || city.contains("台南") { return .yunjiaNan }
        }
        // city 為 nil 時用醫院名稱推測
        if name.contains("亞東") || name.contains("輔大") || name.contains("慈濟") { return .newTaipei }
        if name.contains("林口") || name.contains("桃園") { return .taoyuan }
        if name.contains("台中") || name.contains("中榮") || name.contains("豐原") { return .taichung }
        if name.contains("高雄") || name.contains("鳳山") { return .kaohsiung }
        if name.contains("台大") || name.contains("三軍") || name.contains("榮總") ||
           name.contains("長庚") || name.contains("國泰") || name.contains("馬偕") ||
           name.contains("新光") || name.contains("萬芳") || name.contains("振興") { return .taipei }
        return .other
    }
}
