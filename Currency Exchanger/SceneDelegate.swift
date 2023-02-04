//
//  SceneDelegate.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import UIKit
import SwiftUI
import RealmSwift
import DevTools
import Swinject
import DevToolsRealm
import Moya
import DevToolsNetworking

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
        
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let wScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: wScene)
        prepareInitialData()
        check()
        let container = DependencyManager.mainContainer
        let vm = ConverterSceneVM(balanaceRepository:  container.resolve(CurrencyBalanceRepositoryProtocol.self)!,
                                  currencyRepository: container.resolve(CurrencyRepositoryProtocol.self)!,
                                  currencyConverter: container.resolve(CurrencyCoverterProtocol.self)!)
        let view = ConverterSceneView(viewModel: vm)
        let vc = UIHostingController(rootView: view)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func check() {
        let container = DependencyManager.mainContainer
        sanityCheck {
            // Check user
            let user = container.resolve(User.self)!
            let userRepo = container.resolve(UserRepositoryProtocol.self)!
            print("User:")
            print(userRepo.getUser(id: user.id)!)
            
            // Check balance
            let curBalanceRepo = container.resolve(CurrencyBalanceRepositoryProtocol.self)!
            print("Balance:")
            print(curBalanceRepo.getBalance())
            
            // Check currencies
            let currencyRepo = container.resolve(CurrencyRepositoryProtocol.self)!
            print("Currencies:")
            print(currencyRepo.getCurrencies())
            
            // Check rates
            print("Rates:")
            print(currencyRepo.getRates().count)
        }
    }
    
    private func prepareInitialData() {
        let container = DependencyManager.mainContainer
        let user = container.resolve(User.self)!
        let userRepo = container.resolve(UserRepositoryProtocol.self)!
        guard userRepo.getUser(id: user.id) == nil else {
            // User already created
            return
        }
        // Add main user
        userRepo.addOrUpdate(user: user)
        
        // Add initial balance
        let curBalanceRepo = container.resolve(CurrencyBalanceRepositoryProtocol.self)!
        curBalanceRepo.setBalance([.init(id: "EUR", balance: 1000)])
    }
}

