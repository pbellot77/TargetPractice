//
//  Scene.swift
//  Project2a
//
//  Created by Patrick Bellot on 10/13/17.
//  Copyright © 2017 Polestar Interactive LLC. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
  
  let remainingLabel = SKLabelNode()
  var timer: Timer?
  var targetsCreated = 0
  var targetCount = 0 {
    didSet {
      remainingLabel.text = "Remaining: \(targetCount)"
    }
  }
  let startTime = Date()
  
  override func didMove(to view: SKView) {
    remainingLabel.fontSize = 36
    remainingLabel.fontName = "AmericanTypewriter"
    remainingLabel.color = .white
    remainingLabel.position = CGPoint(x: 0, y: view.frame.midY - 50)
    addChild(remainingLabel)
    targetCount = 0
    
    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
      self.createTarget()
    }
  }
  
  func createTarget() {
    if targetsCreated == 20 {
      timer?.invalidate()
      timer = nil
      return
    }
    targetsCreated += 1
    targetCount += 1
    
    //find the scene view we are drawing into
    guard let sceneView = self.view as? ARSKView else { return }
    
    //get access to a random number generator
    let random = GKRandomSource.sharedRandom()
    
    //create a random x rotation
    let xRotation = matrix_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 1, 0, 0))
    
    //create a random y rotation
    let yRotation = matrix_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 0, 1, 0))
    
    //combine
    let rotation = simd_mul(xRotation, yRotation)
    
    //move forward 1.5 meters into the screen
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -1.5
    
    //combine that with our rotation
    let transform = simd_mul(rotation, translation)
    
    //create an anchor at the finished position
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)
  }
  
  override func update(_ currentTime: TimeInterval) {
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    let location = touch.location(in: self)
    let hit = nodes(at: location)
    
    if let sprite = hit.first {
      let scaleOut = SKAction.scale(to: 2, duration: 0.2)
      let fadeOut = SKAction.fadeOut(withDuration: 0.2)
      let group = SKAction.group([scaleOut, fadeOut])
      let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
      sprite.run(sequence)
      targetCount -= 1
      
      if targetsCreated == 20 && targetCount == 0 {
        gameOver()
      }
    }
  }

  func gameOver() {
    remainingLabel.removeFromParent()
    
    let gameOver = SKSpriteNode(imageNamed: "gameOver")
    addChild(gameOver)
    
    let timeTaken = Date().timeIntervalSince(startTime)
    let timeLabel = SKLabelNode(text: "Time taken: \(Int(timeTaken)) seconds")
    
    timeLabel.fontSize = 36
    timeLabel.fontName = "AmericanTypeWriter"
    timeLabel.color = .white
    timeLabel.position = CGPoint(x: 0, y: -view!.frame.midY + 50)
    
    addChild(timeLabel)
  }
}
