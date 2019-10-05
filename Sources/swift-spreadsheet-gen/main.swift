import Foundation
import Commander
import Dispatch

let main = command(
    Argument<String>("id", description: "Your spread sheet id"),
    Argument<Int>("sheet_number", description: "Your sheet number"),
    Argument<String>("unique_key", description: "Get the value of unique key"),
    Option<String>("value_keys", default: "", description: "Get the value of key, comma separated")
) { (id, sheetNumber, unique_key, value_keys) in
    print("id: \(id)")
    print("sheet_number: \(sheetNumber)")
    print("unique_key: \(unique_key)")
    print("value_key: \(value_keys)")
    var keys: [String] = [unique_key]
    if !value_keys.isEmpty {
        keys.append(contentsOf: value_keys.components(separatedBy: ","))
    }
    let request = SpreadsheetRequest(id: id, sheetNumber: sheetNumber)
    let client = APIClient()
    client.send(request) { (result) in
        switch result {
        case .success(let value):
            let objects = value.map({ EntryObject(json: $0, keys: keys)})
            print("Result: \(objects)")
            exit(0)
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    dispatchMain()
}
main.run("0.0.1")
