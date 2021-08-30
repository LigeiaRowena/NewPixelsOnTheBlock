//
//  HomeViewController.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    lazy var presenter = HomePresenter(with: self)
    lazy var router = HomeRouter(with: navigationController)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapMeButton(_ sender: Any) {
        presenter.startGameButtonTapped()
    }

}

extension HomeViewController: HomePresenterView {
    
    func startNewGame() {
        router.routeToGame()
    }
    
}


