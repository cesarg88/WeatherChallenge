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
        var presenter: PresenterProtocol = Presenter(loader: loader)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "viewController", creator: { coder in
            return ViewController(coder: coder,
                                  presenter: presenter)
        })
        presenter.view = viewController
        
        return viewController
    }
}
