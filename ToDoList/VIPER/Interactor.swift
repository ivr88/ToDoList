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
    private let repository: TaskRepositoryProtocol
    private var tasks: [Task] = []

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func fetchTasks() {
        repository.fetchTasks { [weak self] fetchedTasks in
            guard let self = self else { return }
            self.tasks = fetchedTasks
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(self.tasks)
            }
        }
    }

    func addTask(withTitle title: String) {
        let newTaskID = (tasks.map { $0.id }.max() ?? 0) + 1
        let newTask = Task(id: newTaskID, title: title, isCompleted: false)
        tasks.append(newTask)
        repository.saveTask(newTask)
        presenter?.didFetchTasks(tasks)
    }

    func editTask(at index: Int, withTitle title: String) {
        tasks[index].title = title
        repository.updateTask(tasks[index])
        presenter?.didFetchTasks(tasks)
    }

    func deleteTask(at index: Int) {
        let taskID = tasks[index].id
        tasks.remove(at: index)
        repository.deleteTask(withID: taskID)
        presenter?.didFetchTasks(tasks)
    }

    func toggleTaskCompletion(at index: Int) {
        tasks[index].isCompleted.toggle()
        repository.updateTask(tasks[index])
        presenter?.didFetchTasks(tasks)
    }
}
