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
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var tasks: [Task] = []
    
    func fetchTasks() {
        loadTasksFromCoreData()
        if tasks.isEmpty {
            fetchTasksFromAPI()
        } else {
            presenter?.didFetchTasks(tasks)
        }
    }
    
    func addTask(withTitle title: String) {
        let newTaskID = (tasks.map { $0.id }.max() ?? 0) + 1
        let newTask = Task(id: newTaskID, title: title, isCompleted: false)
        addOrUpdateTask(newTask)
    }
    
    func editTask(at index: Int, withTitle title: String) {
        tasks[index].title = title
        updateTaskInCoreData(tasks[index])
        presenter?.didFetchTasks(tasks)
    }
    
    func deleteTask(at index: Int) {
        deleteTaskFromCoreData(at: index)
        tasks.remove(at: index)
        presenter?.didFetchTasks(tasks)
    }
    
    func toggleTaskCompletion(at index: Int) {
        tasks[index].isCompleted.toggle()
        updateTaskInCoreData(tasks[index])
        presenter?.didFetchTasks(tasks)
    }
    
    private func loadTasksFromCoreData() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            tasks = entities.map { Task(from: $0) }
        } catch {
            print("Error loading tasks from Core Data: \(error)")
        }
    }
    
    private func saveTaskToCoreData(_ task: Task) {
        let entity = TaskEntity(context: context)
        entity.id = Int64(task.id)
        entity.title = task.title
        entity.isCompleted = task.isCompleted
        saveContext()
    }
    
    private func deleteTaskFromCoreData(at index: Int) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", tasks[index].id)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
            }
        } catch {
            print("Error deleting task from Core Data: \(error)")
        }
    }
    
    private func updateTaskInCoreData(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.title = task.title
                entity.isCompleted = task.isCompleted
                saveContext()
            }
        } catch {
            print("Error updating task in Core Data: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving Core Data context: \(error)")
        }
    }
    
    private func fetchTasksFromAPI() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let url = URL(string: "https://dummyjson.com/todos") else {return}
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.tasks = decodedResponse.todos
                        self?.tasks.forEach { self?.saveTaskToCoreData($0) }
                        self?.presenter?.didFetchTasks(self?.tasks ?? [])
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            task.resume()
        }
    }
    
    private func addOrUpdateTask(_ newTask: Task) {
        if let existingTaskIndex = tasks.firstIndex(where: { $0.id == newTask.id }) {
            tasks[existingTaskIndex] = newTask
            updateTaskInCoreData(newTask)
        } else {
            tasks.append(newTask)
            saveTaskToCoreData(newTask)
        }
        presenter?.didFetchTasks(tasks)
    }
}
