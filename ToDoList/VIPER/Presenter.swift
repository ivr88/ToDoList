import Foundation

protocol TaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func addTask(withTitle title: String)
    func editTask(at index: Int, withTitle title: String)
    func deleteTask(at index: Int)
    func toggleTaskCompletion(at index: Int)
}

protocol TaskInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [Task])
}

class TaskPresenter: TaskPresenterProtocol {

    weak var view: TaskViewProtocol?
    var interactor: TaskInteractorProtocol?
    var router: TaskRouterProtocol?
    
    func viewDidLoad() {
        interactor?.fetchTasks()
    }
    
    func addTask(withTitle title: String) {
        interactor?.addTask(withTitle: title)
    }
    
    func editTask(at index: Int, withTitle title: String) {
        interactor?.editTask(at: index, withTitle: title)
    }
    
    func deleteTask(at index: Int) {
        interactor?.deleteTask(at: index)
    }
    
    func toggleTaskCompletion(at index: Int) {
        interactor?.toggleTaskCompletion(at: index)
    }
}

extension TaskPresenter: TaskInteractorOutputProtocol {
    func didFetchTasks(_ tasks: [Task]) {
        view?.displayTasks(tasks)
    }
}
