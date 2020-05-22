/*
 Star Defenders
 GameScene.swift
 Created By: Kurt Campbell
 */

import SpriteKit
import UIKit

public class GameScene: SKScene, SKPhysicsContactDelegate {
    var score = Int()
    // Player Sprite Node
    var player = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "PlayerShip.png")))
    var scoreLabel = UILabel()
    // SpriteKit Spawn Nodes
    let redAlienSpawnNode = SKNode()
    let bulletSpawnNode = SKNode()
    let blueAlienSpawnNode = SKNode()
    // Spawn Time Frequencies
    var redAlienfrequency = 1.0
    var bulletFrequency = 0.2
    var blueAlienFrequency = 1.0
    // Game Over function variables 
    var gameOver = false
    var restartButton = UIButton()
    
    public override func didMove(to view: SKView) {
        // Background Sprite Node and Properties
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "16BitSpaceBackground.png")))
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bg)
        
        // Player Properties
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 6)
        player.size = CGSize(width: size.width * 0.05, height: size.width * 0.05)
        player.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.player.rawValue
        player.physicsBody?.contactTestBitMask = PhysicsCategories.redAlien.rawValue | PhysicsCategories.blueAlien.rawValue
        player.physicsBody?.isDynamic = false
        // Adds player as a child to the view
        self.addChild(player)
        
        // Spawn Bullets
        let bulletWait = SKAction.wait(forDuration: bulletFrequency)
        let bulletSpawn = SKAction.run(spawnBullets)
        bulletSpawnNode.run(SKAction.repeatForever(SKAction.sequence([bulletWait, bulletSpawn])))
        addChild(bulletSpawnNode)
        
        // Spawn Red Aliens
        let redAlienWait = SKAction.wait(forDuration: redAlienfrequency)
        let redAlienSpawn = SKAction.run(spawnRedAliens)
        redAlienSpawnNode.run(SKAction.repeatForever(SKAction.sequence([redAlienWait, redAlienSpawn])))
        self.addChild(redAlienSpawnNode)
        
        // Spawn Blue Aliens
        let blueAlienWait = SKAction.wait(forDuration: blueAlienFrequency)
        let blueAlienSpawn = SKAction.run(spawnBlueAliens)
        blueAlienSpawnNode.run(SKAction.repeatForever(SKAction.sequence([blueAlienWait, blueAlienSpawn])))
        self.addChild(blueAlienSpawnNode)
        
        // Score Label Properties
        scoreLabel.text = "\(score)"
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        scoreLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
        scoreLabel.textColor = UIColor.white
        // Sets the default score
        var scoreDefault = UserDefaults.standard
        var score = scoreDefault.value(forKey: "Score") as? NSInteger
        // Adds score label to a subview
        self.view?.addSubview(scoreLabel)
        /*The game has a contact delegate, so when two sprite nodes collide with each other, 
 it will perform the contact and collision. */
        physicsWorld.contactDelegate = self
    }
    
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let contactCategory: PhysicsCategories = [contact.bodyA.category, contact.bodyB.category]
        // Contact Categories contains these physics categories
        if contactCategory.contains([.redAlien, .bullet]) {
            if contact.bodyA.category == .redAlien {
                self.collisionWithBulletAndRedAlien(redAlien: contact.bodyA.node as? SKSpriteNode, bullet: contact.bodyB.node as? SKSpriteNode)
                // If either contact bodies is nil. It will return it.
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithBulletAndRedAlien(redAlien: contact.bodyB.node as? SKSpriteNode, bullet: contact.bodyA.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            }
        } else if contactCategory.contains([.blueAlien, .bullet]){
            if contact.bodyA.category == .blueAlien {
                self.collisionWithBulletAndBlueAlien(blueAlien: contact.bodyA.node as? SKSpriteNode, bullet: contact.bodyB.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithBulletAndBlueAlien(blueAlien: contact.bodyB.node as? SKSpriteNode, bullet: contact.bodyA.node as? SKSpriteNode)
                if (contact.bodyB.node == nil || contact.bodyA.node == nil) {
                    return 
                }
            }
        } else if contactCategory.contains([.redAlien, .player]) {
            if contact.bodyA.category == .redAlien {
                self.collisionWithPlayerAndRedAlien(redAlien: contact.bodyA.node as? SKSpriteNode, player: contact.bodyB.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithPlayerAndRedAlien(redAlien: contact.bodyB.node as? SKSpriteNode, player: contact.bodyA.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            }
        } else if contactCategory.contains([.blueAlien, .player]) {
            if contact.bodyA.category == .blueAlien {
                self.collisionWithPlayerAndBlueAlien(blueAlien: contact.bodyA.node! as! SKSpriteNode, player: contact.bodyB.node! as! SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithPlayerAndBlueAlien(blueAlien: contact.bodyB.node! as! SKSpriteNode, player: contact.bodyA.node! as! SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            }
        } else {
            preconditionFailure("Unexpected collision type: \(contactCategory)")
        }
    }
    // If the bullet colldies with red aliens, perform this function.
    func collisionWithBulletAndRedAlien(redAlien: SKSpriteNode?, bullet: SKSpriteNode?) {
        // Removes bullet and red aliens from view
        bullet?.removeFromParent()
        redAlien?.removeFromParent()
        // Score increments by 1
        score += 1
        // Score Label text is the score variable 
        scoreLabel.text = "\(score)"
        
        /* Changes spawn speed
         Some score ranges may have a random value be generated. */
        switch score {
        case 0...10:
            redAlienSpawnNode.speed = 1.5
        case 11...20:
            redAlienSpawnNode.speed = 2.0
        case 21...30:
            redAlienSpawnNode.speed = CGFloat(Int.random(in: 1...2))
        case 31...40:
            redAlienSpawnNode.speed = 3.0
        case 41...50:
            redAlienSpawnNode.speed = CGFloat(Int.random(in: 1...3))
        case 51...60:
            redAlienSpawnNode.speed = 4.0
        case 61...70:
            redAlienSpawnNode.speed = 4.5
        case 71...99:
            redAlienSpawnNode.speed = CGFloat(Int.random(in: 1...4))
        case 100...149:
            redAlienSpawnNode.speed = 5.0
        case 150...174:
            redAlienSpawnNode.speed = CGFloat(Int.random(in: 1...5))
        case 174...199:
            redAlienSpawnNode.speed = CGFloat(Int.random(in: 1...6))
        case 200...201:
            playerWon()
        default:
            return 
        }
    }
    
    // If bullet and blue aliens collide with each other. Perform this function.
    func collisionWithBulletAndBlueAlien(blueAlien: SKSpriteNode?, bullet: SKSpriteNode?) {
        // Removes blue alien and bullet from view
        bullet?.removeFromParent()
        blueAlien?.removeFromParent()
        // Score increments by 2
        score += 2
        
        scoreLabel.text = "\(score)"
        
        // Changes blue aliens spawn speed
        switch score {
            case 0...10:
                blueAlienSpawnNode.speed = 0.2
            case 11...20:
                blueAlienSpawnNode.speed = 0.3
            case 21...30:
                blueAlienSpawnNode.speed = 0.4
            case 31...40:
                blueAlienSpawnNode.speed = 0.5
            case 41...50:
                blueAlienSpawnNode.speed = 0.6
            case 51...60:
                blueAlienSpawnNode.speed = 0.7
            case 61...70:
                blueAlienSpawnNode.speed = 0.8
            case 71...99:
                blueAlienSpawnNode.speed = 0.9
            case 100...149:
                blueAlienSpawnNode.speed = 1.0
            case 150...199:
                blueAlienSpawnNode.speed = CGFloat(Int.random(in: 1...2))
            case 200...201:
                playerWon()
            default:
                return 
        }
    }
    // If player and red aliens collide with each other, perform this function.
    func collisionWithPlayerAndRedAlien(redAlien: SKSpriteNode?, player: SKSpriteNode?) {
        // Removes red aliens and player from the view
        redAlien?.removeFromParent()
        player?.removeFromParent()
        // Removes all children, actions, and score label from the view
        self.removeAllChildren()
        self.removeAllActions()
        scoreLabel.removeFromSuperview()
        // Performs game over function
        gameIsOver()
    }
    // If player and blue aliens collide with each other, perform this function. 
    func collisionWithPlayerAndBlueAlien(blueAlien: SKSpriteNode?, player: SKSpriteNode?) {
        // Removes blue alien and player from the parent view
        blueAlien?.removeFromParent()
        player?.removeFromParent()
        // Removes all children, actions, and score label from the view
        self.removeAllChildren()
        self.removeAllActions()
        scoreLabel.removeFromSuperview()
        // Performs game over function
        gameIsOver()
    }
    
    // If the game is over, perform this function.
    func gameIsOver() {
        // Sets background as the game background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "16BitSpaceBackground.png")))
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        // Adds background as a child view into the view
        addChild(bg)
        
        // Game Over is true
        gameOver = true
        // Adds Game Over Label to view
        let gameOverLabel = SKLabelNode(text: "Game Over")
        // Game Over Properties
        gameOverLabel.fontSize = 70.0
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = 3
        gameOverLabel.fontColor = .white
        addChild(gameOverLabel)
        // The finished Score Label when gameOver is triggered
        let finishedScoreLabel = SKLabelNode(text: "Score: \(score)")
        finishedScoreLabel.fontSize = 30.0
        finishedScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 70)
        finishedScoreLabel.zPosition = 4
        finishedScoreLabel.fontColor = .white
        addChild(finishedScoreLabel)

        // Restart Button Properties
        restartButton = UIButton(frame: CGRect(x: frame.midX, y: frame.midY - 50, width: view!.frame.size.width / 5, height: 50))
        restartButton.center.x = self.view!.center.x
        restartButton.center.y = (self.view!.center.y + 200)
        restartButton.setTitle("Restart", for: UIControl.State.normal)
        restartButton.setTitleColor(UIColor.white, for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        restartButton.backgroundColor = UIColor.blue
        restartButton.addTarget(self, action: #selector(restart), for: UIControl.Event.touchUpInside)
        // Adds restart button to a subview of the main view
        self.view?.addSubview(restartButton)
    }
    // If the player has reached the score of 200, perform the function.
    func playerWon() {
        self.removeAllChildren()
        self.removeAllActions()
        // Sets background as the game background
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "16BitSpaceBackground.png")))
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        // Adds background as a child view into the view
        addChild(bg)
        
        // Game Over is true
        gameOver = true
        // Created playerWon label
        let playerWonLabel = SKLabelNode(text: "You Saved the Stars!")
        // Game Over Properties
        playerWonLabel.fontSize = 70.0
        playerWonLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        playerWonLabel.zPosition = 3
        playerWonLabel.fontColor = .white
        // Adds playerWonLabel as a child to the view
        addChild(playerWonLabel)
        
        // Restart Button Properties
        restartButton = UIButton(frame: CGRect(x: frame.midX, y: frame.midY - 50, width: view!.frame.size.width / 5, height: 50))
        restartButton.center.x = self.view!.center.x
        restartButton.center.y = (self.view!.center.y + 200)
        restartButton.setTitle("Play Again", for: UIControl.State.normal)
        restartButton.setTitleColor(UIColor.white, for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        restartButton.backgroundColor = UIColor.blue
        restartButton.addTarget(self, action: #selector(restart), for: UIControl.Event.touchUpInside)
        // Adds restart button to a subview of the main view
        self.view?.addSubview(restartButton)
    }
    
    // Restarts game once restart button is tapped
    @objc func restart() {
        let scene = GameScene(size: UIScreen.main.bounds.size) 
        scene.scaleMode = .aspectFill
        let animation = SKTransition.crossFade(withDuration: 0.5) 
        self.view?.presentScene(scene, transition: animation)
        restartButton.removeFromSuperview()
        scoreLabel.removeFromSuperview()
    }
    
    // Spawn Bullets Function
    func spawnBullets() {
        // Bullet Sprite Node
        var bullet = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "PlayerBullet.png")))
        bullet.zPosition = -5
        bullet.position = CGPoint(x: player.position.x, y: player.position.y)
        // Performs SKAction once the game is started
        let action = SKAction.moveTo(y: self.size.height + 30, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([action, actionDone]))
        // Bullet Physics Body Properties
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.redAlien.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.blueAlien.rawValue
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = false
        // Adds bullet as a child to the view
        self.addChild(bullet)
    }
    // Spawn Red Aliens Function
     func spawnRedAliens() {
        // Red Alien Sprite Node
        var redAlien = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "RedAlien.png")))
        redAlien.size = CGSize(width: size.width * 0.03, height: size.width * 0.03)
        // Setting spawn point for red aliens
        var minValue = self.size.width / 10
        var maxValue = self.size.width
        var spawnPoint = UInt32(maxValue - minValue)
        redAlien.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
        // Sets actions for how the red alien should spawn into the view
        let action = SKAction.moveTo(y: -50, duration: 2.0)
        redAlien.run(SKAction.repeatForever(action))
        let actionDone = SKAction.removeFromParent()
        redAlien.run(SKAction.sequence([action, actionDone]))
        // Red Alien Physics Body Properties
        redAlien.physicsBody = SKPhysicsBody(rectangleOf: redAlien.size)
        redAlien.physicsBody?.categoryBitMask = PhysicsCategories.redAlien.rawValue
        redAlien.physicsBody?.contactTestBitMask = PhysicsCategories.bullet.rawValue
        redAlien.physicsBody?.affectedByGravity = false
        redAlien.physicsBody?.isDynamic = true
        redAlien.physicsBody?.collisionBitMask = 0
        // Adds red alien as a child to the view
        self.addChild(redAlien)
    }
    // Spawn Blue Aliens Function
    func spawnBlueAliens() {
        // Blue Alien Sprite Node
        var blueAlien = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "BlueAlien.png")))
        blueAlien.size = CGSize(width: size.width * 0.04, height: size.width * 0.04)
        // Setting spawn point for blue aliens
        var minValue = self.size.width / 12
        var maxValue = self.size.width
        var spawnPoint = UInt32(maxValue - minValue)
        blueAlien.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
        // Sets actions for how the blue alien should spawn into the view
        let action = SKAction.moveTo(y: -50, duration: 3.0)
        blueAlien.run(SKAction.repeatForever(action))
        let actionDone = SKAction.removeFromParent()
        blueAlien.run(SKAction.sequence([action, actionDone]))
        // Blue Aliens Physics Body properties
        blueAlien.physicsBody = SKPhysicsBody(rectangleOf: blueAlien.size)
        blueAlien.physicsBody?.categoryBitMask = PhysicsCategories.blueAlien.rawValue
        blueAlien.physicsBody?.contactTestBitMask = PhysicsCategories.bullet.rawValue
        blueAlien.physicsBody?.affectedByGravity = false
        blueAlien.physicsBody?.isDynamic = true
        blueAlien.physicsBody?.collisionBitMask = 0
        // Adds blue alien as a child to the view
        self.addChild(blueAlien)
    }
    // When user touch the screen, the player will start moving along the bottom x-axis.
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    
}

