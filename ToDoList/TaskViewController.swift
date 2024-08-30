import UIKit
import CoreData

class TaskViewController: UIViewController {
    
    private var tasks: [Task] = []
    private let tableView = UITableView()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTasksFromCoreData()
        fetchTasks()
    }

    private func setupUI() {
        title = "Tasks"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(addTask))
    }
    
    private func loadTasksFromCoreData() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            tasks = entities.map { Task(from: $0) }
            tableView.reloadData()
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
    
    private func deleteTaskFromCoreData(at indexPath: IndexPath) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", tasks[indexPath.row].id)
        
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
    
    private func fetchTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let count = try? context.count(for: request)
        
        if count ?? 0 > 0 {
            return
        }
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
                        self?.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            task.resume()
        }
    }
    
    @objc private func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            
            DispatchQueue.global(qos: .background).async {
                let newTask = Task(id: (self?.tasks.count ?? 0) + 1, title: title, isCompleted: false)
                self?.tasks.append(newTask)
                self?.saveTaskToCoreData(newTask)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func editTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            
            DispatchQueue.global(qos: .background).async {
                self?.tasks[indexPath.row].title = newTitle
                self?.updateTaskInCoreData(self!.tasks[indexPath.row])
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.deleteTaskFromCoreData(at: indexPath)
            self?.tasks.remove(at: indexPath.row)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.tasks[indexPath.row].isCompleted.toggle()
            self?.updateTaskInCoreData(self!.tasks[indexPath.row])
            
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            self?.editTask(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteTask(at: indexPath)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleTaskCompletion(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
