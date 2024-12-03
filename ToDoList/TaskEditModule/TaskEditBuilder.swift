import UIKit

final class TaskEditBuilder {
    static func createModule(with task: Task) -> UIViewController {
        let viewController = TaskEditViewController()
        let presenter = TaskEditPresenter()
        let repository = TaskRepository(coreDataService: CoreDataService(), apiService: APIService())
        let interactor = TaskEditInteractor(repository: repository)
        let router = TaskEditRouter()

        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        presenter.setTask(task)
        presenter.view = viewController
        viewController.router = router
        return viewController
    }
}
