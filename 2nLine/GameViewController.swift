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
    
    // флаг паузы
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
        skView.multipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        //workaround for quick taps
        let tap = SingleDoubleTapGestureRecognizer(target: self, singleAction: #selector(GameViewController.singleTap(_:)), doubleAction: #selector(GameViewController.doubleTap(_:)))
        tap.duration = 0.2
        view.addGestureRecognizer(tap)
        
        //device recognition
        let device = UIDevice.currentDevice().deviceType
        print(device)
        
        //level init
        level = Level()
                
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.lightGrayColor()
        
        scene.level = level!
        scene.tick = didTick
        scene.circleTimer = didCircle
        
        nLine = NLine()
        nLine.delegate = self
        
        // beginGame()
        nLine.beginGame()
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
    }
    
    //сдвиг цвета
    @IBAction func pressedShift() {
        if !isPause {
        nLine.colorShift()
        }
    }
    
    //новая игра
    @IBAction func pressedNewGame() {
       // view.userInteractionEnabled = false
        scene.stopTimer()
        scene.animateCollapsingLines(nLine.removeBlocksWhenNewGamePressed()) {
            self.nLine.beginGame() }
    }
    
    
    //пауза
    @IBAction func pressedPause() {
        isPause = !isPause

        if isPause {
            scene.timer.invalidate()
        } else {
            scene.unPauseTimer()
        }
        
        scene.view?.paused = isPause
        
    }
    
    //одно нажатие - вращаем
    func singleTap(sender: AnyObject?) {
        if !isPause {
        nLine.rotateShape()
        }
    }
    
    //два нажатия - ставим
    func doubleTap(sender: AnyObject?) {
        if !isPause {
        nLine.dropShape()
        }
    }
    
    //двигаем, 
    @IBAction func didPan(sender: UIPanGestureRecognizer) {

        if !isPause {
        
        var direction = true // 1 - horizontal, 0 - vertical
            
        let currentPoint = sender.translationInView(self.view)
         
        if let originalPoint = panPointReference {
            
            if (abs(currentPoint.y - originalPoint.y)) > (abs(currentPoint.x - originalPoint.x)) {
                direction = false
            } else {
                direction = true}

            if !direction {
            
            if (abs(currentPoint.y - originalPoint.y) > (BlockSize * 1.05)) {

                if sender.velocityInView(self.view).y > CGFloat(0) {
                    nLine.moveShapeUp()
                    panPointReference = currentPoint
                } else {
                    nLine.moveShapeDown()
                    panPointReference = currentPoint
                    }
                }
            } else {
            if (abs(currentPoint.x - originalPoint.x) > (BlockSize * 1.05)) {
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    nLine.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    nLine.moveShapeLeft()
                    panPointReference = currentPoint
                        }
                    }
                }
            } else if sender.state == .Began {
                    panPointReference = currentPoint
                    }
        }
        
    }
    
    //начало игры, делегат NLine класс
    func gameDidBegin(nLine: NLine) {
        
        levelLabel.text = "\(nLine.round)"
        scoreLabel.text = "\(nLine.score)"
        scene.timeInSeconds = TickLengthLevelOne
        
        //рисуем поле
        let newField = level.newField()
        scene.showField(newField)
        view.userInteractionEnabled = true

        // The following is false when restarting a new game
        if nLine.nextShape != nil && nLine.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(nLine.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    //рисуем время
    func didCircle(inputTick: CGFloat) {
        let time = inputTick
        circleGraph.endArc = CGFloat(time)
        circleGraph.isPie = false
    }
    
    //ticks
    func didTick() {
        nLine.dropShape()
    }
    
    //следуюшая фигура
    func nextShape() {
        let newShapes = nLine.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {

        self.view.userInteractionEnabled = true
         
        self.scene.startTimer()
        }
    }
  
    // конец игры - некуда поставить фигуру
    func gameDidEnd(nLine: NLine) {
        view.userInteractionEnabled = false
        
        scene.stopTimer()
        
        scene.shakeCamera(0.5)
        scene.playSound(gameoverSound)
        scene.animateCollapsingLines(nLine.removeAllBlocks()) {
            nLine.beginGame() }
        }
   
    // постановка фигуры на поле, проверка на совпадающие линии
    func gameShapeDidLand(nLine: NLine) {
        
        scene.stopTimer()
        
        self.view.userInteractionEnabled = false
      
        let removedLines = nLine.removeMatches()
        if removedLines.count > 0 {
            self.scoreLabel.text = "\(nLine.score)"
            scene.playSound(bombSound)
            scene.animateMatchedTiles(removedLines) {}
        }
        
   //     scene.shakeCamera(0.1) //смотрится плохо
            nextShape()
    }
    
    // отработка перемещения фигуры
    func gameShapeDidMove(nLine: NLine) {
    scene.redrawShapeFast(nLine.fallingShape!) {}
    }
        
    func gameShapeDidDrop(nLine: NLine) {
        
        if !isPause {
        
        scene.playSound(dropSound)
            
        scene.stopTimer()
            
        scene.redrawShape(nLine.fallingShape!) {
            nLine.letShapeFall()
            }
            
        }
    }
    
    func colorShiftMake(nLine: NLine) {
        scene.redrawShapeFast(nLine.fallingShape!){}
    }

    func gameDidLevelUp(nLine: NLine) {
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

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
