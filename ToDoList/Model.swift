import Foundation

struct TodoResponse: Codable {
    let todos: [Task]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Task: Codable {
    let id: Int
    var title: String
    var isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "todo"
        case isCompleted = "completed"
    }
}
