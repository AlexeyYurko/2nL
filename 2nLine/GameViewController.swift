//
//  GameViewController.swift
//  2nLine
//
//  Created by Alexey Yurko on 29.03.16.
//  Copyright (c) 2016 Alexey Yurko. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, NLineDelegate, UIGestureRecognizerDelegate {
    
    var level: Level!
    var scene: GameScene!
    var nLine: NLine!
    
    // pause flag
    var isPause: Bool = false
    
    //preload sounds
    let bombSound = SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false)
    let levelupSound = SKAction.playSoundFileNamed("levelup.mp3", waitForCompletion: false)
    let gameoverSound = SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false)
    let dropSound = SKAction.playSoundFileNamed("drop.mp3", waitForCompletion: false)
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
        
    @IBOutlet weak var circleGraph: CircleGraphView!
    
    var panPointReference:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        //workaround for quick taps
        let tap = SingleDoubleTapGestureRecognizer(target: self, singleAction: #selector(GameViewController.singleTap(_:)), doubleAction: #selector(GameViewController.doubleTap(_:)))
        tap.duration = 0.2
        view.addGestureRecognizer(tap)
        
        //device recognition
        let device = UIDevice.current.deviceType
        print(device)
        
        //level init
        level = Level()
                
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.lightGray
        
        scene.level = level!
        scene.tick = didTick
        scene.circleTimer = didCircle
        
        nLine = NLine()
        nLine.delegate = self
        
        // beginGame()
        nLine.beginGame()
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
    }
    
    // colour shift
    @IBAction func pressedShift() {
        if !isPause {
        nLine.colorShift()
        }
    }
    
    // new game
    @IBAction func pressedNewGame() {
       // view.userInteractionEnabled = false
        scene.stopTimer()
        scene.animateCollapsingLines(nLine.removeBlocksWhenNewGamePressed()) {
            self.nLine.beginGame() }
    }
    
    
    // pause
    @IBAction func pressedPause() {
        isPause = !isPause

        if isPause {
            scene.timer.invalidate()
        } else {
            scene.unPauseTimer()
        }
        
        scene.view?.isPaused = isPause
        
    }
    
    // one tap for rotate
    @objc func singleTap(_ sender: AnyObject?) {
        if !isPause {
        nLine.rotateShape()
        }
    }
    
    // two taps for placing
    @objc func doubleTap(_ sender: AnyObject?) {
        if !isPause {
        nLine.dropShape()
        }
    }
    
    // moving
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {

        if !isPause {
        
        var direction = true // 1 - horizontal, 0 - vertical
            
        let currentPoint = sender.translation(in: self.view)
         
        if let originalPoint = panPointReference {
            
            if (abs(currentPoint.y - originalPoint.y)) > (abs(currentPoint.x - originalPoint.x)) {
                direction = false
            } else {
                direction = true}

            if !direction {
            
            if (abs(currentPoint.y - originalPoint.y) > (BlockSize * 1.05)) {

                if sender.velocity(in: self.view).y > CGFloat(0) {
                    nLine.moveShapeUp()
                    panPointReference = currentPoint
                } else {
                    nLine.moveShapeDown()
                    panPointReference = currentPoint
                    }
                }
            } else {
            if (abs(currentPoint.x - originalPoint.x) > (BlockSize * 1.05)) {
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    nLine.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    nLine.moveShapeLeft()
                    panPointReference = currentPoint
                        }
                    }
                }
            } else if sender.state == .began {
                    panPointReference = currentPoint
                    }
        }
        
    }
    
    func gameDidBegin(_ nLine: NLine) {
        
        levelLabel.text = "\(nLine.round)"
        scoreLabel.text = "\(nLine.score)"
        scene.timeInSeconds = TickLengthLevelOne
        
        // Drawing the field
        let newField = level.newField()
        scene.showField(newField)
        view.isUserInteractionEnabled = true

        // The following is false when restarting a new game
        if nLine.nextShape != nil && nLine.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(nLine.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    // Drawing the timer
    func didCircle(_ inputTick: CGFloat) {
        let time = inputTick
        circleGraph.endArc = CGFloat(time)
        circleGraph.isPie = false
    }
    
    //ticks
    func didTick() {
        nLine.dropShape()
    }
    
    // next figure
    func nextShape() {
        let newShapes = nLine.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {

        self.view.isUserInteractionEnabled = true
         
        self.scene.startTimer()
        }
    }
  
    // end of game - nowhere to put the figure
    func gameDidEnd(_ nLine: NLine) {
        view.isUserInteractionEnabled = false
        
        scene.stopTimer()
        
        scene.shakeCamera(0.5)
        scene.playSound(gameoverSound)
        scene.animateCollapsingLines(nLine.removeAllBlocks()) {
            nLine.beginGame() }
        }
   
    // placing a figure on the field, checking for matching lines
    func gameShapeDidLand(_ nLine: NLine) {
        
        scene.stopTimer()
        
        self.view.isUserInteractionEnabled = false
      
        let removedLines = nLine.removeMatches()
        if removedLines.count > 0 {
            self.scoreLabel.text = "\(nLine.score)"
            scene.playSound(bombSound)
            scene.animateMatchedTiles(removedLines) {}
        }
        
   //     scene.shakeCamera(0.1) // looks not very good
            nextShape()
    }
    
    // work out how to move the figure
    func gameShapeDidMove(_ nLine: NLine) {
    scene.redrawShapeFast(nLine.fallingShape!) {}
    }
        
    func gameShapeDidDrop(_ nLine: NLine) {
        
        if !isPause {
        
        scene.playSound(dropSound)
            
        scene.stopTimer()
            
        scene.redrawShape(nLine.fallingShape!) {
            nLine.letShapeFall()
            }
            
        }
    }
    
    func colorShiftMake(_ nLine: NLine) {
        scene.redrawShapeFast(nLine.fallingShape!){}
    }

    func gameDidLevelUp(_ nLine: NLine) {
        levelLabel.text = "\(nLine.round)"
        
        if scene.timeInSeconds >= 2 {
            scene.timeInSeconds -= 0.25
        } else if scene.timeInSeconds < 2 {
            scene.timeInSeconds -= 0.15
        }
        
        scene.playSound(levelupSound)
        }
    
  /*  override func shouldAutorotate() -> Bool {
        return true
    } */

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
