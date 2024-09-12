import UIKit

protocol TaskRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}

class TaskRouter: TaskRouterProtocol {
    static func createModule() -> UIViewController {
        let viewController = TaskViewController()
        let presenter = TaskPresenter()
        let coreDataService = CoreDataService()
        let apiService = APIService()
        let interactor = TaskInteractor(coreDataService: coreDataService, apiService: apiService)
        let router: TaskRouterProtocol = TaskRouter()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        return viewController
    }
}
