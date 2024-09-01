import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowsScene)
        let splashViewController = SplashViewController()
        window?.rootViewController = UINavigationController(rootViewController: splashViewController)
        window?.makeKeyAndVisible()
    }
}

