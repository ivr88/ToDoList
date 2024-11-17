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
        DispatchQueue.global(qos: .userInitiated).async {
            self.repository.fetchTasks { [weak self] fetchedTasks in
                guard let self = self else { return }
                self.tasks = fetchedTasks
                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(self.tasks)
                }
            }
        }
    }

    func addTask(withTitle title: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let newTaskID = (self.tasks.map { $0.id }.max() ?? 0) + 1
            let newTask = Task(id: newTaskID, title: title, isCompleted: false, creationDate: Date())
            self.tasks.append(newTask)
            self.repository.saveTask(newTask)
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(self.tasks)
            }
        }
    }

    func editTask(at index: Int, withTitle title: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.tasks[index].title = title
            self.repository.updateTask(self.tasks[index])
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(self.tasks)
            }
        }
    }

    func deleteTask(at index: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            let taskID = self.tasks[index].id
            self.tasks.remove(at: index)
            self.repository.deleteTask(withID: taskID)
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(self.tasks)
            }
        }
    }

    func toggleTaskCompletion(at index: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.tasks[index].isCompleted.toggle()
            self.repository.updateTask(self.tasks[index])
            DispatchQueue.main.async {
                self.presenter?.didFetchTasks(self.tasks)
            }
        }
    }
}
