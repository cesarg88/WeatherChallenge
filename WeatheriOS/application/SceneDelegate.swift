//
//  SceneDelegate.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import UIKit
import WeatherChallenge

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let configuration = URLSessionConfiguration.ephemeral
            let client = URLSessionHTTPClient(session: URLSession(configuration: configuration))
            let loader = RemoteWeatherLoader(client: client)
            let vc = UIComposer.composeWith(loader: loader)
            window.rootViewController = vc
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
