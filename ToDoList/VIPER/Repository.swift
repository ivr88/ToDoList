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
                fetchedTasks.forEach { self.coreDataService.saveTask($0) }
                completion(fetchedTasks)
            }
        } else {
            completion(tasks)
        }
    }

    func saveTask(_ task: Task) {
        coreDataService.saveTask(task)
    }

    func updateTask(_ task: Task) {
        coreDataService.updateTask(task)
    }

    func deleteTask(withID id: Int) {
        coreDataService.deleteTask(withID: id)
    }
}
