import UIKit

protocol TaskEditRouterProtocol: AnyObject {
    static func createModule(withTask task: Task) -> UIViewController
}

final class TaskEditRouter: TaskEditRouterProtocol {
    static func createModule(withTask task: Task) -> UIViewController {
        let viewController = TaskEditViewController()
        let presenter = TaskEditPresenter()
        let interactor = TaskEditInteractor(repository: TaskRepository(coreDataService: CoreDataService(), apiService: APIService()))
        let router = TaskEditRouter()
        
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        presenter.setTask(task)
        
        viewController.presenter = presenter
        
        return viewController
    }
}
