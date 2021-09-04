//
//  GameViewController.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import UIKit

class GameViewController: UIViewController {
    
    //MARK: Properties
    
    lazy var presenter = GamePresenter(with: self)
    lazy var router = GameRouter(with: navigationController)
    @IBOutlet weak var matrixView: UIStackView!
    var blockViews = [BlockView]()
    
    //MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMatrix()
    }
    
    //MARK: Private
    
    /// Setups the arranged subviews of the matrix StackView
    private func setupMatrix() {
        matrixView.layer.borderWidth = 1
        matrixView.layer.borderColor = UIColor.black.cgColor
                
        Array(X.allCases.reversed()).forEach { x in
            let horizontalStack = UIStackView(frame: .zero)
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .fill
            horizontalStack.distribution = .fillEqually
            Y.allCases.forEach { y in
                let blockView = BlockView(presenter: presenter, position: Position(x: x, y: y))
                blockViews.append(blockView)
                horizontalStack.addArrangedSubview(blockView)
            }
            matrixView.addArrangedSubview(horizontalStack)
        }
    }
}

extension GameViewController: GamePresenterView {
    
    func presentAnimation(_ sender: BlockView, completion: @escaping () -> Void) {
        matrixView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            sender.backgroundColor = .blue
        } completion: { _ in
            sender.backgroundColor = .white
            completion()
        }
    }
    
    func blockViewAt(_ position: Position) -> BlockView? {
        return blockViews.first(where: { $0.position == position })
    }
    
    func stopAnimation(_ sender: BlockView) {
        matrixView.isUserInteractionEnabled = true
        sender.isColoured()
    }
    
    func presentFinalScore(finalScore: Int) {
        matrixView.isUserInteractionEnabled = false
        let alert = UIAlertController(title: "Game over!", message: "Your final score is \(finalScore)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.router.routeToHome()
        }))
        present(alert, animated: true)
    }

}

/// The view referred to the single Block element of the game
class BlockView: UIView {
    
    var position: Position?
    weak var presenter: GamePresenter?
    
    init(presenter: GamePresenter, position: Position) {
        super.init(frame: .zero)
        self.position = position
        self.presenter = presenter
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        setTapGesture()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func isColoured() {
        backgroundColor = .blue
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
        presenter?.tapBlockView(self)
    }
    
}
