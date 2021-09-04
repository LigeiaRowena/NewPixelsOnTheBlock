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
    var model = GameModel()
    @IBOutlet weak var matrixView: MatrixView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        matrixView.setupBlocks(delegate: self, model: model)
    }
    
    /// Set selected a given BlockView permanently (at the end of the game)
    /// - Parameters:
    ///   - selected: If true the block is selected
    ///   - block: The given block
    func setViewBlockSelected(_ selected: Bool, block: BlockView) {
        block.isSelected(selected)
    }
    
    /// Animates the touched block and then falls down
    /// - Parameter startingBlock: The touched block
    func animateBlocks(_ startingBlock: BlockView) {
        matrixView.isUserInteractionEnabled = false
        guard let startingBlockModel = startingBlock.model,
              let index = X.allCases.firstIndex(of: startingBlockModel.position.x) else {
            fatalError("The model of starting BlockView is nil")
        }
        
        // Animate the starting block and then calculate where it falls down
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            startingBlock.backgroundColor = .blue
        } completion: { _ in
            startingBlock.backgroundColor = .white
            
            let availablePositions = Array(X.allCases.prefix(upTo: index))
            let reversedPositions = Array(availablePositions.reversed())
            for x in reversedPositions {
                guard let blockView = self.matrixView.blockAt(Position(x: x, y: startingBlockModel.position.y)),
                      let block = blockView.model else {
                    fatalError("No BlockView found")
                }
                
                // Check if the animation is over
                if (block.position.x == .one || self.model.isAboveAColouredBlock(block).0 || self.model.isBetweenTwoColouredBlocks(block)) {
                    self.matrixView.isUserInteractionEnabled = true
                    self.setViewBlockSelected(true, block: blockView)
                    _ = self.model.setBlockColoured(at: block.position)
                    print(self.model.colouredBlocks())
                    break
                }
            }
            
            // Check if game is over
            if self.model.isGameOver() {
                self.matrixView.isUserInteractionEnabled = false
                self.showFinalScore()
            }
        }
    }
    
    func showFinalScore() {
        let finalScore = model.finalScore()
        let alert = UIAlertController(title: "Game over!", message: "Your final score is \(finalScore)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.router.routeToHome()
        }))
        present(alert, animated: true)
    }
}

extension GameViewController: GamePresenterView {
}

extension GameViewController: BlockViewProtocol {
    func tapBlockView(_ block: BlockView) {
        animateBlocks(block)
    }
}

/// The view referred to the entire Matrix of 25 Block elements.
/// Basically it's a vertical stackView containing 5 horizontal stackViews as arrangedSubviews
class MatrixView: UIStackView {
    
    /// Setups the arranged subviews of the Matrix StackView
    /// - Parameters:
    ///   - delegate: The protocol for the single BlockView
    ///   - model: The model
    public func setupBlocks(delegate: BlockViewProtocol, model: GameModel) {
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
                
        Array(X.allCases.reversed()).forEach { x in
            let horizontalStack = UIStackView(frame: .zero)
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .fill
            horizontalStack.distribution = .fillEqually
            Y.allCases.forEach { y in
                let block = model[Position(x: x, y: y)]
                let blockView = BlockView(delegate: delegate, model: block)
                horizontalStack.addArrangedSubview(blockView)
            }
            addArrangedSubview(horizontalStack)
        }
    }
    
    /// Returns a BlockView at a specific position
    /// - Parameter position: The given position
    /// - Returns: The BlockView at a specific position, if any
    public func blockAt(_ position: Position) -> BlockView? {
        guard let horizontalStackViews = arrangedSubviews as? [UIStackView] else {
            return nil
        }
        for horizontalStackView in horizontalStackViews {
            if let blockViews = horizontalStackView.arrangedSubviews as? [BlockView] {
                if let blockView = blockViews.first(where: { $0.model?.position == position }) {
                    return blockView
                }
            }
        }
        return nil
    }
}

/// Protocol that describes any interaction between the single BlockView and GameViewController
protocol BlockViewProtocol: AnyObject {
    func tapBlockView(_ block: BlockView)
}

/// The view referred to the single Block element of the game
class BlockView: UIView {
    
    weak var delegate: BlockViewProtocol?
    var model: Block?
    
    //temp
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    init(delegate: BlockViewProtocol, model: Block) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.model = model
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        setTapGesture()
        setConstraints()
        
        //temp
        label.text = "x=\(model.position.x.rawValue) \ny=\(model.position.y.rawValue)"
        addSubview(label)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: centerXAnchor),
            centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func isSelected(_ selected: Bool) {
        backgroundColor = selected ? .blue : .white
    }
    
    private func setConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: GameViewConstants.blockSize),
            heightAnchor.constraint(equalToConstant: GameViewConstants.blockSize)
        ])
    }
    
    private func setTapGesture() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(tapGestureRecognizer:))))
    }
    
    @objc
    private func tapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.tapBlockView(self)
    }
    
}
