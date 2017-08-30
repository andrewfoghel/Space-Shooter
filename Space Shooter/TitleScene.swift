//
//  TitleScene.swift
//  Space Shooter
//
//  Created by Andrew Foghel on 8/9/17.
//  Copyright © 2017 andrewfoghel. All rights reserved.
//

import Foundation
import SpriteKit

var btnPlay: UIButton!
var gameTitle: UILabel!


class TitleScene: SKScene{
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = offBlackColor
        setupUI()
        
    }
    

    
    func setupUI(){
        btnPlay = UIButton(frame: CGRect(x: 100, y: 100, width: self.view!.frame.width, height: 100))
        btnPlay.center = CGPoint(x: view!.frame.midX, y: view!.frame.midY - 50)
        btnPlay.titleLabel?.font = UIFont(name: "Avenir Next", size: 60)
        btnPlay.setTitle("PLAY", for: .normal)
        btnPlay.setTitleColor(offWhiteColor, for: .normal)
        btnPlay.setTitleShadowColor(offBlackColor, for: .normal)
        btnPlay.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        self.view?.addSubview(btnPlay)
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: 100))
        gameTitle.textColor = offWhiteColor
        gameTitle.font = UIFont(name: "Avenir Next", size: 60)
        gameTitle.textAlignment = .center
        gameTitle.text = "GALAXY X"
        
        self.view?.addSubview(gameTitle)
        
        
    }
    
    @objc func handlePlay(){
        self.view?.presentScene(GameScene(), transition: SKTransition.doorway(withDuration: 0.5))
        
        btnPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene"){
            let skview = self.view! as SKView
            skview.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            skview.presentScene(scene)
        }
        
    }
    
    
}
