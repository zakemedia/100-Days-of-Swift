//
//  GameScene.swift
//  Project29
//
//  Created by Welby Jennings on 2/10/20.
//  https://www.hackingwithswift.com/100/94
    // Video 2 - https://www.hackingwithswift.com/read/29/2/building-the-environment-sktexture-and-filling-a-path
    // Video 3 - https://www.hackingwithswift.com/read/29/3/mixing-uikit-and-spritekit-uislider-and-skview
    // Video 4 - https://www.hackingwithswift.com/read/29/4/unleash-the-bananas-spritekit-texture-atlases
    // Video 5 - https://www.hackingwithswift.com/read/29/5/destructible-terrain-presentscene

import SpriteKit

// 1 - Video 2
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene {
    var buildings = [BuildingNode]()
    weak var viewConroller: GameViewController? // 6 - Video 3
    
    // 12 - Video 4
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    
    override func didMove(to view: SKView) {
        // 4 - Video 2
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        // move horiz of screen filling it with buildings
        
        createPlayers()
    }
    
    // 5 - Video 2
    func createBuildings() {
        var currentX: CGFloat = -15 // just off screen
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2 // move along x value + 2 more
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            // move half of width
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    // 15 - Video 4
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10
        let radians = deg2rad(degrees: angle)
        
        // safety so only 1 banana in scene
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue // buildings or players
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue // buildings or players
        banana.physicsBody?.usesPreciseCollisionDetection = true // used since precise
        addChild(banana)
        
        // position banana above player whos throwing
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20 //spinning
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm]) // throw sequence
            player1.run(sequence) // run animation on player
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse) // push in that direction
        } else {
                banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
                banana.physicsBody?.angularVelocity = 20 //spinning
                
                let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
                let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
                let pause = SKAction.wait(forDuration: 0.15)
                let sequence = SKAction.sequence([raiseArm, pause, lowerArm]) // throw sequence
                player2.run(sequence) // run animation on player
                
                let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * -speed) // flip it for player 2 so we use -speed
                banana.physicsBody?.applyImpulse(impulse) // push in that direction
        }
    }
    
    // 13 - Video 4
    func createPlayers() {
        // player 1
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue // bounce off bananas
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue // tell us about collision types banana
        player1.physicsBody?.isDynamic = false // dont let them be moved
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        // get full height of building and / 2 and the player's height / 2 and place player at top of building
        addChild(player1)
        
        // player 2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue // bounce off bananas
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue // tell us about collision types banana
        player2.physicsBody?.isDynamic = false // dont let them be moved
        
        let player2Building = buildings[buildings.count - 2] // second last building
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    // 14 - Video 4
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180 // convert degress and radians
    }
}
