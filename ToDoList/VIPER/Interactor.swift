import UIKit
import CoreData

protocol TaskInteractorProtocol: AnyObject {
    var presenter: TaskInteractorOutputProtocol? { get set }
    func fetchTasks()
    func addTask(withTitle title: String)
    func editTask(at index: Int, withTitle title: String)
    func deleteTask(at index: Int)
    func toggleTaskCompletion(at index: Int)
}

class TaskInteractor: TaskInteractorProtocol {
    
    weak var presenter: TaskInteractorOutputProtocol?
    private let coreDataService: TaskServiceProtocol
    private let apiService: TaskAPIServiceProtocol
    private var tasks: [Task] = []
    
    init(coreDataService: TaskServiceProtocol, apiService: TaskAPIServiceProtocol) {
        self.coreDataService = coreDataService
        self.apiService = apiService
    }

    func fetchTasks() {
        tasks = coreDataService.fetchTasks()
        if tasks.isEmpty {
            tasks = apiService.fetchTasks()
            tasks.forEach { coreDataService.saveTask($0) }
        }
        presenter?.didFetchTasks(tasks)
    }
    
    func addTask(withTitle title: String) {
        let newTaskID = (tasks.map { $0.id }.max() ?? 0) + 1
        let newTask = Task(id: newTaskID, title: title, isCompleted: false)
        addOrUpdateTask(newTask)
    }
    
    func editTask(at index: Int, withTitle title: String) {
        tasks[index].title = title
        coreDataService.updateTask(tasks[index])
        presenter?.didFetchTasks(tasks)
    }
    
    func deleteTask(at index: Int) {
        coreDataService.deleteTask(withID: tasks[index].id)
        tasks.remove(at: index)
        presenter?.didFetchTasks(tasks)
    }
    
    func toggleTaskCompletion(at index: Int) {
        tasks[index].isCompleted.toggle()
        coreDataService.updateTask(tasks[index])
        presenter?.didFetchTasks(tasks)
    }
    
    private func addOrUpdateTask(_ newTask: Task) {
        if let existingTaskIndex = tasks.firstIndex(where: { $0.id == newTask.id }) {
            tasks[existingTaskIndex] = newTask
            coreDataService.updateTask(newTask)
        } else {
            tasks.append(newTask)
            coreDataService.saveTask(newTask)
        }
        presenter?.didFetchTasks(tasks)
    }
}
