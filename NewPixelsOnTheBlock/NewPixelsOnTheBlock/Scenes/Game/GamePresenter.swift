//
//  GamePresenter.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import Foundation

protocol GamePresenterView: AnyObject {
}

class GamePresenter {
    
    weak var view: GamePresenterView?

    init(with view: GamePresenterView) {
        self.view = view
    }

}
