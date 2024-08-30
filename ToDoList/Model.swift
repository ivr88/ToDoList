import Foundation
import CoreData

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
    
    init(id: Int, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
    
    init(from entity: TaskEntity) {
        self.id = Int(entity.id)
        self.title = entity.title ?? ""
        self.isCompleted = entity.isCompleted
    }
}
