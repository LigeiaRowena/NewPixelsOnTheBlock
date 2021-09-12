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
                
        // Animate the starting block
        view?.presentAnimation(sender, completion: {
            
            // Check if we tapped on a block above a coloured one, if yes keep it coloured there without let it fall down
            if self.model.isAboveAColouredBlock(startingPosition).0 {
                self.view?.stopAnimation(sender)
                _ = self.model.setBlockColoured(at: startingPosition)
            // Check if we tapped on a block between two coloured ones, if yes keep it coloured there without let it fall down
            } else if self.model.isBetweenTwoColouredBlocks(startingPosition) {
                self.view?.stopAnimation(sender)
                _ = self.model.setBlockColoured(at: startingPosition)
            } else {
                // Calculate where the block falls down
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
            }
                        
            // If the user tapped on position x=one just keep the block coloured there without any business other logic
            if index == 0 {
                self.view?.stopAnimation(sender)
                _ = self.model.setBlockColoured(at: startingPosition)
            }
            
            // Check if game is over
            if self.model.isGameOver() {
                let finalScore = self.model.finalScore()
                self.view?.presentFinalScore(finalScore: finalScore)
            }
        })
        
    }
}
