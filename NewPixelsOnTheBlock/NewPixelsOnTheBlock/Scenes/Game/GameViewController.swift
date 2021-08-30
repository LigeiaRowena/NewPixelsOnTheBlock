//
//  GameViewController.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import UIKit

class GameViewController: UIViewController {
    
    lazy var presenter = GamePresenter(with: self)
    lazy var router = GameRouter(with: navigationController)

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension GameViewController: GamePresenterView {
    
}
