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
        case isActive  = "is_active"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        code      = try  c.decode(String.self, forKey: .code)
        name      = try  c.decode(String.self, forKey: .name)
        shortName = try? c.decode(String.self, forKey: .shortName)
        city      = try? c.decode(String.self, forKey: .city)
        district  = try? c.decode(String.self, forKey: .district)
        level     = try? c.decode(String.self, forKey: .level)
        isActive  = (try? c.decode(Bool.self,  forKey: .isActive)) ?? true
    }

    init(code: String, name: String, shortName: String? = nil,
         city: String? = nil, district: String? = nil,
         level: String? = nil, isActive: Bool = true) {
        self.code = code; self.name = name; self.shortName = shortName
        self.city = city; self.district = district
        self.level = level; self.isActive = isActive
    }
}

struct HospitalsResponse: Codable {
    let hospitals: [Hospital]
}

struct HospitalSearchResponse: Codable {
    let results: [Hospital]
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
            if city.contains("台北") || city.contains("臺北") { return .taipei }
            if city.contains("新北") { return .newTaipei }
            if city.contains("基隆") { return .keelung }
            if city.contains("桃園") { return .taoyuan }
            if city.contains("台中") || city.contains("臺中") { return .taichung }
            if city.contains("高雄") { return .kaohsiung }
            if city.contains("雲林") || city.contains("嘉義") || city.contains("台南") || city.contains("臺南") { return .yunjiaNan }
        }
        // Name-based fallback — check specific geography before generic hospital brands
        if name.contains("基隆") { return .keelung }
        if name.contains("雲林") || name.contains("嘉義") { return .yunjiaNan }
        if name.contains("高雄") || name.contains("鳳山") { return .kaohsiung }
        if name.contains("林口") || name.contains("桃園") { return .taoyuan }
        if name.contains("台中") || name.contains("臺中") || name.contains("豐原") { return .taichung }
        // New Taipei area (check before generic Taipei brands to avoid mis-classifying)
        // 台北慈濟 is in 汐止 (New Taipei); 臺北醫院 is in 蘆洲 (New Taipei)
        if name.contains("亞東") || name.contains("輔大") || name.contains("新北") ||
           name.contains("汐止") || name.contains("土城") || name.contains("淡水") ||
           name.contains("慈濟") || name.contains("臺北") { return .newTaipei }
        // Taipei
        if name.contains("台大") || name.contains("三軍") || name.contains("榮總") ||
           name.contains("長庚") || name.contains("國泰") || name.contains("馬偕") ||
           name.contains("新光") || name.contains("萬芳") || name.contains("振興") ||
           name.contains("台北") { return .taipei }
        return .other
    }
}
