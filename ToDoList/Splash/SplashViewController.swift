import UIKit

final class SplashViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Splash"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        setupShow()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(logoImageView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupShow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showMainApp()
        }
    }
    
    private func showMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        
        let taskModule = TaskRouter.createModule()
        let navigationController = UINavigationController(rootViewController: taskModule)
        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }

}
