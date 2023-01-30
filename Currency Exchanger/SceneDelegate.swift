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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private func prepareCurrencies(dataBase: Realm) {
        let data: [[String: String]] = [
            ["id": "EUR"],
            ["id": "USD"],
            ["id": "GPB"]
        ]
        guard dataBase.objects(Currency_DB.self).isEmpty else {
            return
        }
        dataBase.bulkWrite(writeOperation: {
            let items: [Currency_DB] = data.map { itemData in
                let item = Currency_DB()
                item.id = itemData["id"] ?? ""
                return item
            }
            dataBase.add(items)
        })
    }
    
    private func prepareUser(dataBase: Realm) -> User_DB {
        dataBase.bulkWrite(writeOperation: {
            let user = User_DB()
            user.id = "MAIN"
            let initialBalance: [CurrencyBalance_DB] = {
                let eur = CurrencyBalance_DB()
                eur.id = "EUR"
                eur.balance = 1000
                return [eur]
            }()
            user.currencyBalance.append(objectsIn: initialBalance)
            let existing = dataBase.object(ofType: User_DB.self, forPrimaryKey: "MAIN")
            if existing == nil {
                dataBase.add(user)
            }
        })
        
        return dataBase.object(ofType: User_DB.self, forPrimaryKey: "MAIN")!
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let wScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: wScene)
        let db = try! Realm()
        prepareCurrencies(dataBase: db)
        let user = prepareUser(dataBase: db)
        let vm = ConverterSceneVM(database: db, user: user)
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
    
    
}

