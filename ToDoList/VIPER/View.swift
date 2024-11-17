import UIKit

protocol TaskViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
}

class TaskViewController: UIViewController {
    
    var presenter: TaskPresenterProtocol?
    
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var isSearching = false
    
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
    
    private func getTask(at indexPath: IndexPath) -> Task {
        return isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
    }
    
    func editTask(at indexPath: IndexPath) {
        let task = getTask(at: indexPath)
        
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
        let task = getTask(at: indexPath)
        if let originalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            presenter?.deleteTask(at: originalIndex)
        }
    }
    
    func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = getTask(at: indexPath)
        if let originalIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            presenter?.toggleTaskCompletion(at: originalIndex)
        }
    }
}

extension TaskViewController: TaskViewProtocol {
    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks
        if isSearching {
            updateFilteredTasks(for: searchController.searchBar.text)
        } else {
            tableView.reloadData()
        }
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = getTask(at: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let creationDate = dateFormatter.string(from: task.creationDate ?? Date())
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        let titleText = NSAttributedString(string: task.title, attributes: titleAttributes)
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let dateText = NSAttributedString(string: "\n\(creationDate)", attributes: dateAttributes)
        
        let combinedText = NSMutableAttributedString()
        combinedText.append(titleText)
        combinedText.append(dateText)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.attributedText = combinedText
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
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension TaskViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateFilteredTasks(for: searchController.searchBar.text)
    }
    
    private func updateFilteredTasks(for query: String?) {
        guard let query = query, !query.isEmpty else {
            DispatchQueue.main.async {
                self.isSearching = false
                self.filteredTasks = []
                self.tableView.reloadData()
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = self.tasks.filter { $0.title.lowercased().contains(query.lowercased()) }
            DispatchQueue.main.async {
                self.isSearching = true
                self.filteredTasks = filtered
                self.tableView.reloadData()
            }
        }
    }
}
