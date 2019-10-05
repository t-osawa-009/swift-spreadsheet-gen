import Foundation
import SwiftyJSON

public struct SpreadsheetRequest: APIRequest {
    var path: String {
        return "\(id)/\(sheetNumber.description)/public/values"
    }
    
    var parameters: [String : Any]? {
        return ["alt": "json"]
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw APIError.noData
        }
        
        let json = try JSON(data: data)
        
        guard let arrayObject = json["feed"]["entry"].array else {
            throw APIError.missingKeyPath("feed/entry")
        }

        return arrayObject
    }
    
    typealias Response = [JSON]
    private let id: String
    private let sheetNumber: Int
    init(id: String, sheetNumber: Int) {
        self.id = id
        self.sheetNumber = sheetNumber
    }
}

