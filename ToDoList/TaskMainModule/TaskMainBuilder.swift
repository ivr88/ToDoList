import UIKit

final class TaskBuilder {
    static func createModule() -> UIViewController {
        let viewController = TaskViewController()
        let presenter = TaskPresenter()
        let repository = TaskRepository(coreDataService: CoreDataService(), apiService: APIService())
        let interactor = TaskInteractor(repository: repository)
        let router = TaskRouter()

        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return viewController
    }
}
