import Foundation
import SwiftyJSON

struct EntryObject {
    let dic: [String: JSON]
    init(json: JSON, keys: [String]) {
        var _dic = [String: JSON]()
        keys.forEach { (key) in
            _dic[key] = json["gsx$\(key)"]["$t"]
        }
        self.dic = _dic
    }
}
