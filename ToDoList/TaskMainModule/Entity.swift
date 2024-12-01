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
    var creationDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title = "todo"
        case isCompleted = "completed"
        case creationDate
    }

    init(id: Int, title: String, isCompleted: Bool, creationDate: Date? = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.creationDate = creationDate
    }
    
    init(from entity: TaskEntity) {
        self.id = Int(entity.id)
        self.title = entity.title ?? ""
        self.isCompleted = entity.isCompleted
        self.creationDate = entity.creationDate ?? Date()
    }
}

extension Task {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
    }
}
