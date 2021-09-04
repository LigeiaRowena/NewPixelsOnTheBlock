//
//  NewPixelsOnTheBlockTests.swift
//  NewPixelsOnTheBlockTests
//
//  Created by Francesca Corsini on 29/08/21.
//

import XCTest
@testable import NewPixelsOnTheBlock

class NewPixelsOnTheBlockTests: XCTestCase {
    
    var gameModel = GameModel()

    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testPositionEquality() {
        let pos1 = Position(x: .three, y: .three)
        let pos2 = Position(x: .three, y: .three)
        XCTAssertEqual(pos1, pos2)
    }
    
    func testIntSubscript() {
        let block = gameModel[0]
        XCTAssertEqual(block?.position.x, .one)
        XCTAssertEqual(block?.position.y, .one)
    }
    
    func testPositionSubscript() {
        let block = gameModel[Position(x: .one, y: .one)]
        guard let index = gameModel.firstIndex(of: block) else {
            XCTFail()
            return
        }
        XCTAssertEqual(index, 0)
    }
    
    func testColouredBlocks() {
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .three))
        let colouredBlocks = gameModel.colouredBlocks()
        guard let block = colouredBlocks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(block.position.x, .three)
        XCTAssertEqual(block.position.y, .three)
    }
    
    func testWhiteBlocksWithScore() {
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .one))
        guard let block = gameModel.whiteBlocksWithScore().first else {
            XCTFail()
            return
        }
        XCTAssertEqual(block.position.x, .one)
        XCTAssertEqual(block.position.y, .one)
        
        _ = gameModel.setBlockColoured(at: Position(x: .four, y: .two))
        XCTAssertEqual(gameModel.whiteBlocksWithScore().count, 4)
    }
    
    func testBelowAColouredBlock() {
        let block = Block(position: Position(x: .five, y: .one))
        XCTAssertEqual(gameModel.isBelowAColouredBlock(block), false)
        
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .one))
        XCTAssertEqual(gameModel.isBelowAColouredBlock(Block(position: Position(x: .one, y: .one))), true)
        XCTAssertEqual(gameModel.isBelowAColouredBlock(Block(position: Position(x: .two, y: .one))), true)
    }
    
    func testAboveAColouredBlock() {
        let position = Position(x: .one, y: .one)
        XCTAssertEqual(gameModel.isAboveAColouredBlock(position).0, false)
        XCTAssertNil(gameModel.isAboveAColouredBlock(position).1)

        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .one))
        XCTAssertEqual(gameModel.isAboveAColouredBlock(Position(x: .two, y: .one)).0, true)
    }
    
    func testAboveANotColouredBlock() {
        let block = gameModel.setBlockColoured(at: Position(x: .three, y: .four))
        XCTAssertEqual(gameModel.isAboveANotColouredBlock(block), true)
        
        let anotherBlock = Block(position: Position(x: .one, y: .four))
        XCTAssertEqual(gameModel.isAboveANotColouredBlock(anotherBlock), false)
    }
    
    func testBetweenTwoColouredBLocks() {
        XCTAssertEqual(gameModel.isBetweenTwoColouredBlocks(Position(x: .two, y: .one)), false)

        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .one))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .three))
        XCTAssertEqual(gameModel.isBetweenTwoColouredBlocks(Position(x: .two, y: .two)), true)
    }
    
    func testTintBlock() {
        let block = gameModel.setBlockColoured(at: Position(x: .one, y: .one))
        XCTAssertEqual(block.isColoured, true)
        XCTAssertEqual(Block(position: Position(x: .two, y: .two)).isColoured, false)
    }

    func testFinalScoreSmaller() {
        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .one))
        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .one))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .two))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .four))
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .five))
        
        XCTAssertEqual(gameModel.isGameOver(), true)
        
        let finalScore = gameModel.finalScore()
        XCTAssertEqual(finalScore, 115)
    }
    
    func testFinalScoreBigger() {
        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .one, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .two, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .three, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .four, y: .three))
        _ = gameModel.setBlockColoured(at: Position(x: .four, y: .four))
        _ = gameModel.setBlockColoured(at: Position(x: .four, y: .five))
        _ = gameModel.setBlockColoured(at: Position(x: .five, y: .four))
        
        XCTAssertEqual(gameModel.isGameOver(), true)
        
        let finalScore = gameModel.finalScore()
        XCTAssertEqual(finalScore, 145)
    }
}
