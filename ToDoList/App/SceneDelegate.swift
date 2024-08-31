import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowsScene)
        let taskModule = TaskRouter.createModule()
        window?.rootViewController = UINavigationController(rootViewController: taskModule)
        window?.makeKeyAndVisible()
        
    }
}

