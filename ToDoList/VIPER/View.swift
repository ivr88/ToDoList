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
        setupNavigationBarAppearance()
        setupUI()
        setupSearchController()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        title = "Задачи"
        view.backgroundColor = .black

        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTask)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemYellow
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .systemYellow
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
        let editViewController = TaskEditRouter.createModule(withTask: task)
        
        if let editVC = editViewController as? TaskEditViewController {
            editVC.delegate = self 
        }
        
        navigationController?.pushViewController(editViewController, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = getTask(at: indexPath)
        cell.configure(with: task)
        cell.backgroundColor = .black
        cell.selectionStyle = .none
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

extension TaskViewController: TaskEditDelegate {
    func didUpdateTask() {
        presenter?.viewDidLoad()
    }
}
