import Foundation

protocol FileCreatable {
    func write() throws
}

enum OutputForm: String {
    case strings
}

enum FileError: Error {
    case pathNotFound
    case dataNotFound
}
