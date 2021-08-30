//
//  HomePresenter.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import Foundation

protocol HomePresenterView: AnyObject {
    func startNewGame()
}

class HomePresenter {
    
    weak var view: HomePresenterView?

    init(with view: HomePresenterView) {
        self.view = view
    }
    
    func startGameButtonTapped() {
        //TODO: some model operations e.g. choose kind of game
        view?.startNewGame()
    }
}
