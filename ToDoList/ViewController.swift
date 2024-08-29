import UIKit

class TaskViewController: UIViewController {
    
    private var tasks: [Task] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTasks()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(addTask))
    }
    
    private func fetchTasks() {
        let url = URL(string: "https://dummyjson.com/todos")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                self?.tasks = decodedResponse.todos
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    @objc private func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            
            let newTask = Task(id: self?.tasks.count ?? 0, title: title, isCompleted: false)
            self?.tasks.append(newTask)
            self?.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?[0].text, !newTitle.isEmpty else { return }
            
            self?.tasks[indexPath.row].title = newTitle
            self?.tableView.reloadData()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.tasks.remove(at: indexPath.row)
            self?.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
