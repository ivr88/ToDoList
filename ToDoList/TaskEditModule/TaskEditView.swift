import UIKit

protocol TaskEditViewProtocol: AnyObject {
    func displayTask(title: String, date: String)
}

protocol TaskEditDelegate: AnyObject {
    func didUpdateTask()
}

class TaskEditViewController: UIViewController {
    
    var presenter: TaskEditPresenterProtocol?
    weak var delegate: TaskEditDelegate?
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = true
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        setupBackButton()
        view.backgroundColor = .black
        
        view.addSubview(dateLabel)
        view.addSubview(titleTextView)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBackButton() {
        view.backgroundColor = .black
        
        let backButton = UIButton(type: .system)
            
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 5
        config.title = "Назад"
        config.baseForegroundColor = .customTellow
        config.contentInsets = .zero
        
        backButton.configuration = config
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let customBackButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    @objc private func backButtonTapped() {
        if let title = titleTextView.text {
            presenter?.saveTask(title: title)
            delegate?.didUpdateTask() 
        }
        navigationController?.popViewController(animated: true)
    }
}

extension TaskEditViewController: TaskEditViewProtocol {
    func displayTask(title: String, date: String) {
        titleTextView.text = title
        dateLabel.text = date
    }
}
