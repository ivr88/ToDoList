import UIKit

protocol TaskRouterProtocol: AnyObject {
    func navigateToTaskEditScreen(from viewController: UIViewController, with task: Task)
}

final class TaskRouter: TaskRouterProtocol {
    func navigateToTaskEditScreen(from viewController: UIViewController, with task: Task) {
        let taskEditViewController = TaskEditBuilder.createModule(with: task)
        viewController.navigationController?.pushViewController(taskEditViewController, animated: true)
    }
}
