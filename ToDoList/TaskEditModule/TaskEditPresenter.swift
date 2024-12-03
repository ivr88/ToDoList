import Foundation

protocol TaskEditPresenterProtocol: AnyObject {
    func viewDidLoad()
    func saveTask(title: String)
}

final class TaskEditPresenter: TaskEditPresenterProtocol {
    
    weak var view: TaskEditViewProtocol?
    var interactor: TaskEditInteractorProtocol?
    var router: TaskEditRouterProtocol?
    
    private var task: Task?
    
    func viewDidLoad() {
        if let task = task {
            let formattedDate = formatDate(task.creationDate ?? Date())
            view?.displayTask(title: task.title, date: formattedDate)
        }
    }
    
    func saveTask(title: String) {
        if var task = task {
            task.title = title
            interactor?.updateTask(task)
        }
    }
    
    func setTask(_ task: Task) {
        self.task = task
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
