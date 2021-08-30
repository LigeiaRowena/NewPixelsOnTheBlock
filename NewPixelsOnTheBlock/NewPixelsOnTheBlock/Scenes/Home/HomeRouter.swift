//
//  HomeRouter.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 30/08/21.
//

import Foundation
import UIKit

class HomeRouter {
    
    weak var navigationController: UINavigationController?

    init(with navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createViewController() -> UIViewController {
        return HomeViewController(nibName: "HomeViewController", bundle: nil)
    }
    
    func routeToGame() {
        let gameViewController = GameRouter.createViewController()
        navigationController?.pushViewController(gameViewController, animated: true)
    }
}
