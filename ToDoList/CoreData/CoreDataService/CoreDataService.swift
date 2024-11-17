import UIKit
import CoreData

protocol TaskServiceProtocol {
    func fetchTasks() -> [Task]
    func saveTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(withID id: Int)
}

class CoreDataService: TaskServiceProtocol {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { Task(from: $0) }
        } catch {
            print("Error loading tasks from Core Data: \(error)")
            return []
        }
    }
    
    func saveTask(_ task: Task) {
        let entity = TaskEntity(context: context)
        entity.id = Int64(task.id)
        entity.title = task.title
        entity.isCompleted = task.isCompleted
        entity.creationDate = task.creationDate
        saveContext()
    }
    
    func updateTask(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.title = task.title
                entity.isCompleted = task.isCompleted
                saveContext()
            }
        } catch {
            print("Error updating task in Core Data: \(error)")
        }
    }
    
    func deleteTask(withID id: Int) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
            }
        } catch {
            print("Error deleting task from Core Data: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving Core Data context: \(error)")
        }
    }
}
