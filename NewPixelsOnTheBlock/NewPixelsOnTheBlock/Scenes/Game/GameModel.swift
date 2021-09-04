//
//  GameModel.swift
//  NewPixelsOnTheBlock
//
//  Created by Francesca Corsini on 29/08/21.
//

import Foundation

/// Enum referred to the horizontal position (aka the row) of the single block within the entire matrix.
/// The offset starts from the very top-left position of the matrix.
enum X: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four
    case five
}

/// Enum referred to the vertical position (aka the column) of the single block within the entire matrix.
/// The offset starts from the very top-left position of the matrix.
enum Y: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four
    case five
}

/// Struct referred to the position of the block in the matrix in (x,y) coordinates
struct Position: Equatable {
    var x: X
    var y: Y
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

/// Struct referred to the single block of the matrix.
struct Block: Equatable {
    var position: Position
    var isColoured: Bool = false
    var score: Int = 0
    
    static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.position == rhs.position && lhs.isColoured == rhs.isColoured && lhs.score == rhs.score
    }
}

/// The model engine of Game scene. It's a custom collection.
struct GameModel: Collection {
    
    //MARK: Collection properties and required functions
 
    /// The array of data types used by the custom collection, it's a matrix of 25 blocks.
    private var matrix: [Block]
    
    /// The position of the first element in the collection
    var startIndex: Int {
        return 0
    }
    
    /// The position of the last element in the collection
    var endIndex: Int {
        return matrix.endIndex
    }
    
    /// Returns the position immediately after the given index
    /// - Parameter i: The given index
    /// - Returns: The position just after the given index
    func index(after i: Int) -> Int {
        return matrix.index(after: i)
    }
    
    init() {
        self.matrix = [Block]()
        X.allCases.forEach { x in
            Y.allCases.forEach { y in
                let block = Block(position: Position(x: x, y: y))
                matrix.append(block)
            }
        }
    }
    
    //MARK: Collection subscript functions
    
    /// Utility subscript function that uses the default index position
    /// - Parameter index: The default index position of blocks array
    subscript(index: Int) -> Block? {
        get {
            return index < endIndex ? matrix[index] : nil
        }
    }
    
    /// Utility subscript function that uses the position in (x,y) coordinates
    /// - Parameter index: The position in (x,y) coordinates
    subscript(position: Position) -> Block {
        get {
            guard let block = matrix.first(where: { $0.position == position }) else {
                fatalError("The given Position doesn't return any valid Block element within matrix collection")
            }
            return block
        }
        set(newValue) {
            guard let index = matrix.firstIndex(of: self[position]) else {
                fatalError("The given Position doesn't return any valid Block element within matrix collection")
            }
            matrix.remove(at: index)
            matrix.insert(newValue, at: index)
        }
    }
    
    //MARK: Public utility functions
        
    /// Returns an array of only coloured Block elements
    /// - Returns: An array of Block elements with isColoured = true
    public func colouredBlocks() -> [Block] {
        return matrix.filter{ $0.isColoured == true }
    }
    
    /// Returns an array of only not coloured Block elements for the entire matrix of blocks, each one located below a coloured Block element
    /// According to the business logic of this game, a not coloured block below a coloured one has score = .ten
    /// - Returns: An array of Block elements with isColoured = false and each one below a Block element with isColoured = true
    public func whiteBlocksWithScore() -> [Block] {
        return matrix.filter{ $0.isColoured == false && isBelowAColouredBlock($0)}
    }
    
    /// Returns true if a Block element is below a coloured one recursively, so even by skipping other not coloured blocks on the same Y position
    /// - Parameter block: The given Block element
    /// - Returns: True if a Block element is below a coloured one recursively
    public func isBelowAColouredBlock(_ block: Block) -> Bool {
        guard let index = X.allCases.firstIndex(of: block.position.x) else {
            fatalError("The given Block doesn't have a proper X position")
        }
        let availableXPositions = Array(X.allCases.suffix(from: index))
        for x in availableXPositions {
            // Edge case: the given Block element is located at the very top, so there's no other block above it
            guard let nextX = X(rawValue: x.rawValue + 1) else {
                return false
            }
            let anotherBlock = self[Position(x: nextX, y: block.position.y)]
            if anotherBlock.isColoured {
                return true
            }
        }
        return false
    }
    
    /// Returns true if a Block element is above a coloured one
    /// - Parameter block: The given Block element
    /// - Returns: A tuple with a flag=true if a Block element is above a coloured one, and the coloured block itself if any
    public func isAboveAColouredBlock(_ block: Block) -> (Bool, Block?) {
        // Edge case: the given Block element is located at the very bottom, so there's no other block below it
        guard let previousX = X(rawValue: block.position.x.rawValue - 1) else {
            return (false, nil)
        }
        let anotherBlock = self[Position(x: previousX, y: block.position.y)]
        let isAboveAColouredBlock = anotherBlock.isColoured
        return (isAboveAColouredBlock, isAboveAColouredBlock ? anotherBlock : nil)
    }
    
    /// Returns true if a Block element is above a not coloured one
    /// - Parameter block: The given Block element
    /// - Returns: True if a Block element is above a not coloured one
    public func isAboveANotColouredBlock(_ block: Block) -> Bool {
        // Edge case: the given Block element is located at the very bottom, so there's no other block below it
        guard let previousX = X(rawValue: block.position.x.rawValue - 1) else {
            return false
        }
        let anotherBlock = self[Position(x: previousX, y: block.position.y)]
        return !anotherBlock.isColoured
    }
    
    /// Returns true if a Block element is between two coloured ones
    /// - Parameter block: The given Block element
    /// - Returns: True if a Block element is between two coloured ones
    public func isBetweenTwoColouredBlocks(_ block: Block) -> Bool {
        // Edge case: the given Block element is located at the very right side or at the very left side, so the block is not between two coloured ones
        guard let previousY = Y(rawValue: block.position.y.rawValue - 1),
              let nextY = Y(rawValue: block.position.y.rawValue + 1) else {
            return false
        }
        let previousBlock = self[Position(x: block.position.x, y: previousY)]
        let nextBlock = self[Position(x: block.position.x, y: nextY)]
        return previousBlock.isColoured && nextBlock.isColoured
    }
    
    /// Sets a specific Block element with isColoured = true
    /// - Parameter position: The position of the given Block element
    /// - Returns: The just coloured Block element
    public mutating func setBlockColoured(at position: Position) -> Block {
        var block = self[position]
        block.isColoured = true
        self[position] = block
        return block
    }

    /// Returns true if there are at least 10 coloured blocks: in this case the game is over
    /// - Returns: True if there are at least 10 coloured blocks
    public func isGameOver() -> Bool {
        return colouredBlocks().count >= GameModelConstants.gameOverBlocksCount
    }
    
    /// Returns the final score when the game is over
    /// - Returns: The final score
    public mutating func finalScore() -> Int {
        var score: Int = 0
        
        // First we calcolate the partial score from the coloured blocks
        colouredBlocks().forEach { block in
            var copy = block
            switch block.position.x {
            case .one:
                copy.score += GameModelConstants.unitScore
            case .two, .three, .four, .five:
                if isAboveANotColouredBlock(copy) {
                    copy.score += GameModelConstants.unitScore
                } else if let colouredBlock = isAboveAColouredBlock(copy).1 {
                    copy.score += colouredBlock.score + GameModelConstants.unitScore
                }
            }
            self[block.position] = copy
        }
                
        // Then we calculate the partial score from the not coloured blocks
        whiteBlocksWithScore().forEach { block in
            var copy = block
            copy.score = GameModelConstants.notColouredBlocksScore
            self[block.position] = copy
        }

        let scores = matrix.map{ $0.score }
        score = scores.reduce(0, +)
        return score
    }
    
}

