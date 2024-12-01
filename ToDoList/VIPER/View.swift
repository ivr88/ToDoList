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
    private let bottomView = UIView()
    private let addButton = UIButton()
    private let taskCountLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setupUI()
        setupSearchController()
        presenter?.viewDidLoad()
        setupTitle()
    }

    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.backgroundColor = .black

        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .customGray
        bottomView.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.tintColor = .customTellow
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        bottomView.addSubview(taskCountLabel)
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        taskCountLabel.textColor = .white
        taskCountLabel.font = UIFont.systemFont(ofSize: 12)

        setupConstraints()
    }
    
    private func setupConstraints() {
       NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
       ])

       NSLayoutConstraint.activate([
        bottomView.heightAnchor.constraint(equalToConstant: view.bounds.height / 10),
           bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
       ])

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -8),
            addButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
        ])
   }
    
    private func setupTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.sizeToFit()

        let leftAlignedView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        titleLabel.frame.origin = CGPoint(x: 0, y: (leftAlignedView.bounds.height - titleLabel.bounds.height) / 2)
        leftAlignedView.addSubview(titleLabel)
        navigationItem.titleView = leftAlignedView
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
        searchController.searchBar.tintColor = .customTellow
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
        
        let alert = UIAlertController(
            title: "Удалить задачу?",
            message: "Вы уверены, что хотите удалить задачу \"\(task.title)\"?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            if let originalIndex = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.presenter?.deleteTask(at: originalIndex)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func sendTask(_ task: Task) {
        let activityViewController = UIActivityViewController(activityItems: [task.title], applicationActivities: nil)
        present(activityViewController, animated: true)
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
        taskCountLabel.text = "\(tasks.count) Задач"
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = getTask(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                self?.editTask(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteTask(at: indexPath)
            }
            
            let sendAction = UIAction(title: "Отправить", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.sendTask(task)
            }
            
            return UIMenu(title: "", children: [editAction, sendAction, deleteAction])
        }
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
