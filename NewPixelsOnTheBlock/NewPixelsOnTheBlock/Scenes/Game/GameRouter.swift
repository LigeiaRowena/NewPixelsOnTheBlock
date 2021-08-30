//
//  GameRouter.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 30/08/21.
//

import Foundation
import UIKit

class GameRouter {
    
    weak var navigationController: UINavigationController?

    init(with navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createViewController() -> UIViewController {
        return GameViewController(nibName: "GameViewController", bundle: nil)
    }
    
}
