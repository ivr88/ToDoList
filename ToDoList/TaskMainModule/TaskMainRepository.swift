import UIKit
import CoreData

protocol TaskRepositoryProtocol {
    func fetchTasks(completion: @escaping ([Task]) -> Void)
    func saveTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(withID id: Int)
}

class TaskRepository: TaskRepositoryProtocol {
    private let coreDataService: TaskServiceProtocol
    private let apiService: TaskAPIServiceProtocol

    init(coreDataService: TaskServiceProtocol, apiService: TaskAPIServiceProtocol) {
        self.coreDataService = coreDataService
        self.apiService = apiService
    }

    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        let tasks = coreDataService.fetchTasks()
        if tasks.isEmpty {
            apiService.fetchTasks { fetchedTasks in
                let tasksWithDate = fetchedTasks.map { task in
                    Task(id: task.id, title: task.title, isCompleted: task.isCompleted, creationDate: Date())
                }
                tasksWithDate.forEach { self.coreDataService.saveTask($0) }
                completion(tasksWithDate)
            }
        } else {
            completion(tasks)
        }
    }

    func saveTask(_ task: Task) {
        var taskWithDate = task
        taskWithDate.creationDate = Date()
        coreDataService.saveTask(taskWithDate)
    }

    func updateTask(_ task: Task) {
        coreDataService.updateTask(task)
    }

    func deleteTask(withID id: Int) {
        coreDataService.deleteTask(withID: id)
    }
}
