import Foundation

struct SimpleHospital: Identifiable, Hashable {
    let code: String          // 後端 API 用的醫院代碼（同 hospital_code）
    let vid: String           // 卡片唯一 ID（splits 後不再等於 code）
    let name: String          // 主名稱（如「三軍總醫院」）
    let branch: String?       // 院區（如「台北門診」），未拆分則為 nil
    let loc: String?          // 副標位置（如「台北 大安區」）
    let branchPrefix: String? // 科別 prefix（如「台北門」），用於過濾 dept

    var id: String { vid }

    var fullName: String {
        if let b = branch, !b.isEmpty { return "\(name) \(b)" }
        return name
    }

    var simpleRegion: SimpleRegion {
        if Self.northCodes.contains(code) { return .north }
        if Self.centralCodes.contains(code) { return .central }
        return .south
    }

    /// 轉成 `Hospital`（顯示用全名）以餵給沿用 `Hospital` 的 view / service。
    var asHospital: Hospital {
        Hospital(code: code, name: fullName)
    }
}

extension SimpleHospital {

    // MARK: - 區域分類（對齊 /simple/simple.js 的 REGIONS）

    static let northCodes: Set<String> = [
        "ntuh", "tsgh", "tpvgh", "changgung-taipei", "mackay-taipei", "cathay", "shinkong",
        "ntuh-cancer", "ntuh-children", "chgh", "femh", "tzuchi-taipei",
        "mackay-tamsui", "tph", "cathay-xizhi", "changgung-tucheng",
        "newtaipei-banqiao", "newtaipei-sanchong", "fjuh",
        "changgung-keelung", "changgung-linkou", "changgung-taoyuan", "wanfang",
    ]
    static let centralCodes: Set<String> = [
        "tcvgh", "fyh-mohw", "changgung-yunlin", "changgung-chiayi",
    ]
    static let southCodes: Set<String> = [
        "changgung-kaohsiung", "changgung-fengshan", "kaohsiung-united",
    ]

    // MARK: - 醫院位置（對齊 /simple/simple.js 的 HOSPITAL_LOC）

    static let locByCode: [String: String] = [
        "ntuh": "台北 中正區",
        "tsgh": "台北 內湖區",
        "tpvgh": "台北 北投區",
        "changgung-taipei": "台北 松山區",
        "mackay-taipei": "台北 中山區",
        "cathay": "台北 大安區",
        "shinkong": "台北 士林區",
        "ntuh-cancer": "台北 大安區",
        "ntuh-children": "台北 中正區",
        "chgh": "台北 北投區",
        "femh": "新北 板橋區",
        "tzuchi-taipei": "新北 新店區",
        "mackay-tamsui": "新北 淡水區",
        "tph": "新北 新莊區",
        "cathay-xizhi": "新北 汐止區",
        "changgung-tucheng": "新北 土城區",
        "newtaipei-banqiao": "新北 板橋區",
        "newtaipei-sanchong": "新北 三重區",
        "fjuh": "新北 泰山區",
        "changgung-keelung": "基隆 安樂區",
        "changgung-linkou": "桃園 龜山區",
        "changgung-taoyuan": "桃園 龜山區",
        "wanfang": "台北 文山區",
        "tcvgh": "台中 西屯區",
        "fyh-mohw": "台中 豐原區",
        "changgung-yunlin": "雲林 麥寮鄉",
        "changgung-chiayi": "嘉義 朴子市",
        "changgung-kaohsiung": "高雄 鳥松區",
        "changgung-fengshan": "高雄 鳳山區",
        "kaohsiung-united": "高雄 鼓山區",
    ]

    // MARK: - 院區拆分（對齊 /simple/simple.js 的 HOSPITAL_SPLITS）

    struct Split {
        let vid: String
        let main: String
        let branch: String
        let prefix: String
        let loc: String
    }

    static let splits: [String: [Split]] = [
        "tsgh": [
            Split(vid: "tsgh:內湖",   main: "三軍總醫院", branch: "內湖本院", prefix: "內湖",   loc: "台北 內湖區"),
            Split(vid: "tsgh:汀州",   main: "三軍總醫院", branch: "汀州院區", prefix: "汀州",   loc: "台北 中正區"),
            Split(vid: "tsgh:台北門", main: "三軍總醫院", branch: "台北門診", prefix: "台北門", loc: "台北 大安區"),
        ],
    ]

    /// 把後端回傳的 `[Hospital]` 展開為「顯示用院區卡片」陣列。
    static func expand(_ hospitals: [Hospital]) -> [SimpleHospital] {
        var out: [SimpleHospital] = []
        for h in hospitals {
            if let list = splits[h.code] {
                for s in list {
                    out.append(SimpleHospital(
                        code: h.code, vid: s.vid,
                        name: s.main, branch: s.branch,
                        loc: s.loc, branchPrefix: s.prefix
                    ))
                }
            } else {
                out.append(SimpleHospital(
                    code: h.code, vid: h.code,
                    name: h.name, branch: nil,
                    loc: locByCode[h.code], branchPrefix: nil
                ))
            }
        }
        return out
    }
}
