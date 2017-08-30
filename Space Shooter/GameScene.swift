//
//  GameScene.swift
//  Space Shooter
//
//  Created by Andrew Foghel on 8/9/17.
//  Copyright © 2017 andrewfoghel. All rights reserved.
//

import SpriteKit
import GameplayKit

var player = SKSpriteNode()
var projectile = SKSpriteNode()
var enemy = SKSpriteNode()
var star = SKSpriteNode()

var scoreLabel = SKLabelNode()
var mainLabel = SKLabelNode()

var playerSize = CGSize(width: 50, height: 70)
var projectileSize = CGSize(width: 10, height: 10)
var enemySize = CGSize(width: 65, height: 65)
var starSize = CGSize()

var offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
var offWhiteColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
var orageCustomColor = UIColor.orange

var fireProjectileRate = 0.2
var projectileSpeed = 0.9

var enemySpeed = 3.1
var enemySpawnRate = 0.4

var isAlive = true

var score = 0

var touchLocation = CGPoint()

struct physicsCategory{
    static let player: UInt32 = 0
    static let projectile: UInt32 = 1
    static let enemy: UInt32 = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    

    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        resetGameVariables()
        spawnPlayer()
        spawnMainLabel()
        spawnScoreLabel()
        
        fireProjectile()
        timerSpawnEnemies()
        timerStarsSpawn()

        
    }
    
    func resetGameVariables(){
        isAlive = true
        score = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            touchLocation = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            touchLocation = touch.location(in: self)
            if isAlive == true{
                movePlayerOnTouch()
            }
        }
    }
    
    func movePlayerOnTouch(){
        player.position.x = touchLocation.x
    }
    
    func spawnPlayer(){
        player = SKSpriteNode(imageNamed: "player")
        player.size = playerSize
        player.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 100)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        
        player.name = "playerName"
        
        self.addChild(player)
    }

    func spawnProjectile(){
        projectile = SKSpriteNode(color: offWhiteColor, size: projectileSize)
        projectile.size = projectileSize
        projectile.position = CGPoint(x: player.position.x, y: player.position.y)
        
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projectile.physicsBody?.isDynamic = false
        
        projectile.name = "projectileName"
        projectile.zPosition = -1
        
        moveProjectileToTop()
        
        self.addChild(projectile)
    }
    
    func moveProjectileToTop(){
        let moveForward = SKAction.moveTo(y: 1000, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()
        
        projectile.run(SKAction.sequence([moveForward,destroy]))
    }
    
    func spawnEnemy(){
        let minX = Int(self.frame.minX + 50)
        let maxX = Int(self.frame.maxX - 50)
        
        let randomX = Int(arc4random_uniform(UInt32(maxX - minX + 1))) + minX
        
        enemy = SKSpriteNode(imageNamed: "spaceship")
        enemy.size = enemySize
        enemy.position = CGPoint(x: randomX, y: 1000)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = physicsCategory.projectile
        
        enemy.name = "enemyName"
        
        moveEnemyToFloor()
        
        self.addChild(enemy)
    }
    
    func moveEnemyToFloor(){
        let moveTo = SKAction.moveTo(y: self.frame.minY - 100, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([moveTo, destroy]))
    }
    
    func spawnStars(){
        let randomSize = Int(arc4random_uniform(4)+1)
        
        let minX = Int(self.frame.minX + 50)
        let maxX = Int(self.frame.maxX - 50)
        
        let randomX = Int(arc4random_uniform(UInt32(maxX - minX + 1))) + minX

        starSize = CGSize(width: randomSize, height: randomSize)
        star = SKSpriteNode(color: offWhiteColor, size: starSize)
        star.size = starSize
        star.position = CGPoint(x: randomX, y: 1000)
        
        starMove()
        
        self.addChild(star)
    }
    
    func starMove(){
        let randomTime = Int(arc4random_uniform(10))
        let doubleRandomTime : Double = (Double(randomTime) / 10) + 2
        let moveTo = SKAction.moveTo(y: self.frame.minY - 100, duration: doubleRandomTime)
        let destory = SKAction.removeFromParent()
        star.run(SKAction.sequence([moveTo,destory]))
        
    }
    
    func spawnMainLabel(){
        mainLabel = SKLabelNode(fontNamed: "Avenir Next")
        mainLabel.fontSize = 100
        mainLabel.fontColor = offWhiteColor
        mainLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 200)
        mainLabel.text = "Game Over"
    }
    
    func spawnScoreLabel(){
        scoreLabel = SKLabelNode(fontNamed: "Avenir Next")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = offWhiteColor
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 30)
        
        scoreLabel.text = "Score: \(score)"
        self.addChild(scoreLabel)
    }
    
    func fireProjectile(){
        let timer = SKAction.wait(forDuration: fireProjectileRate)
        let spawn = SKAction.run {
            if isAlive == true{
                self.spawnProjectile()
            }
        }
        
        let sequence = SKAction.sequence([timer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func timerSpawnEnemies(){
        let wait = SKAction.wait(forDuration: enemySpawnRate)
        let spawn = SKAction.run {
            if isAlive{
                self.spawnEnemy()
            }
        }
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
        
    }
    
    func timerStarsSpawn(){
        let wait = SKAction.wait(forDuration: 0.2)
        let spawn = SKAction.run {
            if isAlive == true{
                self.spawnStars()
                self.spawnStars()
                self.spawnStars()
            }
        }
       
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.projectile)) || (firstBody.categoryBitMask == physicsCategory.projectile) && (secondBody.categoryBitMask == physicsCategory.enemy){
            
            spawnExplosion(enemyTemp: firstBody.node as! SKSpriteNode)
            enemyProjectileCollision(contactA: firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player)) || (firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy){
            playerEnemyCollision(contactA: firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
        }
    }
    
    func enemyProjectileCollision(contactA: SKSpriteNode, contactB: SKSpriteNode){
        if contactA.name == "enemyName" && contactB.name == "projectileName"{
            score = score + 1

            let destroy = SKAction.removeFromParent()
            
            contactA.run(SKAction.sequence([destroy]))
            
            contactB.removeFromParent()
            updateScore()
        }
        
        if contactB.name == "enemyName" && contactA.name == "projectileName"{
            score = score + 1
            
            let destroy = SKAction.removeFromParent()
            
            contactB.run(SKAction.sequence([destroy]))
            
            contactA.removeFromParent()
           updateScore()
        }
        
 
    }
    
    func playerEnemyCollision(contactA: SKSpriteNode, contactB: SKSpriteNode){
        if contactA.name == "enemyName" && contactB.name == "playerName"{
            isAlive = false
            gameOverLogic()
        }
        
        if contactB.name == "enemyName" && contactA.name == "playerName"{
            isAlive = false
            gameOverLogic()
        }
    }
    
    func spawnExplosion(enemyTemp: SKSpriteNode){
        let explosionEmmiterPath = Bundle.main.path(forResource: "particleSpark", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmmiterPath! as String) as! SKEmitterNode
        
        explosion.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        self.addChild(explosion)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        
        self.run(SKAction.sequence([wait,removeExplosion]))
    }
    

    func gameOverLogic(){
        spawnMainLabel()
        resetTheGame()
    }
    
    func resetTheGame(){
       self.view?.presentScene(TitleScene(), transition: SKTransition.doorway(withDuration: 0.5))
        
        btnPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        
        if let scene = TitleScene(fileNamed: "TitleScene"){
            let skview = self.view! as SKView
            scene.scaleMode = .aspectFill
            skview.presentScene(scene)
        }
        
        /* let wait = SKAction.wait(forDuration: 1)
        let theTitleScene = TitleScene(fileNamed: "TitleScene")
        theTitleScene?.scaleMode = .aspectFill
        let theTransition = SKTransition.doorway(withDuration: 0.5)
        
        let changeScene = SKAction.run {
            self.scene?.view?.presentScene(theTitleScene!, transition: theTransition)
        }
        
        let sequence = SKAction.sequence([SKAction.sequence([wait, changeScene])])
        self.run(sequence)*/
        
    }
    
    func updateScore(){
        scoreLabel.text = "Score: \(score)"
    }
    
    func movePlayerOffScreen(){
        player.position.x = 1000
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isAlive == false{
            movePlayerOffScreen()
            resetTheGame()
            mainLabel.run(SKAction.removeFromParent())
        }
        
    }
}
