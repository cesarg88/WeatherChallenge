//
//  Composer.swift
//  WeatheriOS
//
//  Created by César González on 29/12/21.
//

import Foundation
import WeatherChallenge
import UIKit

public final class UIComposer {
    private init() {}
    
    public static func composeWith(loader: WeatherLoader) -> ViewController {
        var presenter: PresenterProtocol = Presenter(loader: MainQueueDispatchDecorator(loader))
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "viewController",
                                                                  creator: { coder in
            return ViewController(coder: coder,
                                  presenter: presenter)
        })
        presenter.view = viewController
        
        return viewController
    }
}


final class MainQueueDispatchDecorator: WeatherLoader {
    private let decoratee: WeatherLoader
    
    init(_ decoratee: WeatherLoader) {
        self.decoratee = decoratee
    }
    
    func loadWeatherFor(locationType: LocationType, completion: @escaping (WeatherLoader.Result) -> Void) {
        decoratee.loadWeatherFor(locationType: locationType) { result in
            guaranteeMainThread {
                completion(result)
            }
        }
    }
}

func guaranteeMainThread(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}
