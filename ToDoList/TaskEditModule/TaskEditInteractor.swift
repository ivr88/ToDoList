import UIKit

protocol TaskEditInteractorProtocol: AnyObject {
    func updateTask(_ task: Task)
}

class TaskEditInteractor: TaskEditInteractorProtocol {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func updateTask(_ task: Task) {
        repository.updateTask(task)
    }
}
