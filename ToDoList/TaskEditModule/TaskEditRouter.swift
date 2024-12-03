import UIKit

protocol TaskEditRouterProtocol: AnyObject {
    func navigateBackToTaskList(from viewController: UIViewController)
}

final class TaskEditRouter: TaskEditRouterProtocol {
    func navigateBackToTaskList(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
