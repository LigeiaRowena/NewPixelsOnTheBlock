//
//  GamePresenter.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import Foundation

protocol GamePresenterView: AnyObject {
    
    /// Animates the tapped BlockView by flashing it in blue colour
    /// - Parameters:
    ///   - sender: The tapped BlockView
    ///   - completion: Completion execute after the animation is done
    func presentAnimation(_ sender: BlockView, completion: @escaping () -> Void)
    
    
    /// Stops the previous animation
    /// - Parameter sender: The BlockView where the animations stops
    func stopAnimation(_ sender: BlockView)
    
    /// Returns a BlockView at a specific position
    /// - Parameter position: The given position
    /// - Returns: The BlockView at a specific position, if any
    func blockViewAt(_ position: Position) -> BlockView?
    
    /// Shows the final score on the screen
    /// - Parameter finalScore: The final score
    func presentFinalScore(finalScore: Int)
}

typealias GamePresenterDelegate = GamePresenterView & GameViewController

class GamePresenter {
    
    weak var view: GamePresenterDelegate?
    var model = GameModel()

    init(with view: GamePresenterDelegate) {
        self.view = view
    }
    
    func tapBlockView(_ sender: BlockView) {
        guard let startingPosition = sender.position,
              let index = X.allCases.firstIndex(of: startingPosition.x) else {
            fatalError("The model of starting BlockView is nil")
        }
        
        // Animate the starting block and then calculate where it falls down
        view?.presentAnimation(sender, completion: {
            let availablePositions = Array(X.allCases.prefix(upTo: index).reversed())
            for x in availablePositions {
                guard let blockView = self.view?.blockViewAt(Position(x: x, y: startingPosition.y)),
                      let position = blockView.position else {
                    fatalError("No BlockView found")
                }
                
                // Check if the animation is over
                if (position.x == .one || self.model.isAboveAColouredBlock(position).0 || self.model.isBetweenTwoColouredBlocks(position)) {
                    self.view?.stopAnimation(blockView)
                    _ = self.model.setBlockColoured(at: position)
                    break
                }
            }
            
            // Check if game is over
            if self.model.isGameOver() {
                let finalScore = self.model.finalScore()
                self.view?.presentFinalScore(finalScore: finalScore)
            }
        })
        
    }
}
