import UIKit

protocol TaskViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
}

class TaskViewController: UIViewController {
    
    var presenter: TaskPresenterProtocol?
    
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var isSearchActive: Bool = false
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        presenter?.viewDidLoad()
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
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            self?.presenter?.addTask(withTitle: title)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func editTask(at indexPath: IndexPath) {
        let task = isSearchActive ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self?.presenter?.editTask(at: indexPath.row, withTitle: newTitle)
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func deleteTask(at indexPath: IndexPath) {
        presenter?.deleteTask(at: indexPath.row)
    }
    
    private func getTask(at indexPath: IndexPath) -> Task {
        return isSearchActive ? filteredTasks[indexPath.row] : tasks[indexPath.row]
    }
    
    func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = getTask(at: indexPath)
        
        if let originalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            
            presenter?.toggleTaskCompletion(at: originalIndex)
            
            if isSearchActive {
                updateFilteredTasks(for: searchController.searchBar.text)
            } else {
                tableView.reloadData()
            }
        }
    }
}

extension TaskViewController: TaskViewProtocol {
    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks
        self.filteredTasks = tasks
        tableView.reloadData()
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = isSearchActive ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleTaskCompletion(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
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

extension TaskViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateFilteredTasks(for: searchController.searchBar.text)
    }
    
    private func updateFilteredTasks(for query: String?) {
        guard let query = query, !query.isEmpty else {
            isSearchActive = false
            filteredTasks.removeAll()
            tableView.reloadData()
            return
        }
        isSearchActive = true
        filteredTasks = tasks.filter { $0.title.lowercased().contains(query.lowercased()) }
        tableView.reloadData()
    }
}
