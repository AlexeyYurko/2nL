//
//  GameScene.swift
//  2nLine
//
//  Created by Alexey Yurko on 29.03.16.
//  Copyright (c) 2016 Alexey Yurko. All rights reserved.
//

import SpriteKit

let BlockSize:CGFloat = 30

let TickLengthLevelOne = TimeInterval(5)

class GameScene: SKScene {
    
    //размер фишки в пойнтах
    let tileWidth: CGFloat = 30
    let tileHeight: CGFloat = 30
    
    var tick:(() -> ())?
    var circleTimer:((CGFloat) -> ())?
    
    // таймер
    var timer = Timer()
    let timeInterval:TimeInterval = 0.01

    var timeCount = TickLengthLevelOne
    var timeInSeconds = TickLengthLevelOne
    
    var level: Level!
    
    //определение слоев, один для "игры" (поверх фона, у меня пропущено), другой для блоков-фишек
    let gameLayer = SKNode()
    //поле
    let fieldLayer = SKNode()
    //блоки
    let blockLayer = SKNode()
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //вот ЗДЕСЬ* вставить фон
        
        
        //добавляем игровой слой
        addChild(gameLayer)
        
        //определяем место для блоков (позицию)
        let layerPosition = CGPoint(
        x: -tileWidth * CGFloat(NumColumns) / 2-CGFloat(NumColumns) / 2,
        y: -tileHeight * CGFloat(NumRows) / 2)
        
        blockLayer.position = layerPosition
        fieldLayer.position = layerPosition
        gameLayer.addChild(fieldLayer)
        gameLayer.addChild(blockLayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // запуск таймера, с обнулением счётчика
    func startTimer() {
        timeCount = timeInSeconds
        if !timer.isValid{ //prevent more than one timer on the thread
                timer = Timer.scheduledTimer(timeInterval: timeInterval,
                target: self,
                selector: #selector(GameScene.timerDidEnd),
                userInfo: nil,
                repeats: true) //repeating timer in the second iteration
        }
    }
    
    // остановка таймера
    func stopTimer() {
        timer.invalidate()
    }
    
    // снятие паузы, без обнуления счетчика = продолжение таймера !!! УРА!!!
    func unPauseTimer() {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                           target: self,
                                                           selector: #selector(GameScene.timerDidEnd),
                                                           userInfo: nil,
                                                           repeats: true)
        }
    }
    
    // таймер короткого интервала отработал, отсчитываем "тик", если в полном цикле ушли в ноль - бросаем фигуру, иначе просто перерисовываем круг
    @objc func timerDidEnd(_ timer:Timer){
            timeCount = timeCount - timeInterval
            if timeCount <= 0 {  //test for target time reached.
                timer.invalidate()
                tick?()
            } else { //update the time on the clock if not reached
                let times = CGFloat(1 - (timeCount / timeInSeconds))
                circleTimer?(times)
            }
        }
    
    override func didMove(to view: SKView) {
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
              
    }  
    
    //очищаем все блоки на сцене
    func removeAllBlocksSprites() {
        blockLayer.removeAllChildren()
    }
   
    //добавляем превью
    func addPreviewShapeToScene(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = SKSpriteNode(imageNamed: imageName(block.tile))
            sprite.position = pointForColumn(block.column, row:block.row - 2)
            blockLayer.addChild(sprite)
            block.sprite = sprite
            let moveAction = SKAction.move(to: pointForColumn(block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut

            sprite.run(SKAction.group([moveAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    //переносим превью на поле
    func movePreviewShape(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.1)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction]))
          }
        run(SKAction.wait(forDuration: 0.1), completion: completion)
    }
    
    //определение координат для вывода спрайта
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        let newRow = row - 1
        let newColumn = Double(column) + 0.5
        
        return CGPoint(
            x: CGFloat(newColumn)*tileWidth+CGFloat(column),
            y: CGFloat(newRow)*tileHeight+CGFloat(row))
        
      /*  return CGPoint(
            x: CGFloat(column)*tileWidth+CGFloat(column),
            y: CGFloat(newRow)*tileHeight+CGFloat(newRow)) */
    }
    
    //вывод поля из набора, что приходит при вызове (set<Field>) для поля
    func showField(_ tiles: Set<Field>) {
        fieldLayer.removeAllChildren()
        for block in tiles {
            let sprite = SKSpriteNode(imageNamed: fieldName(block.isSpawn))
            sprite.position = pointForColumn(block.column, row:block.row)
            fieldLayer.addChild(sprite)
            block.sprite = sprite
        }
    }
   
    //стираем совпадающие блоки
    func animateMatchedTiles(_ lines: Set<Line>, completion: @escaping () -> ()) {
        for line in lines {
            for tile in line.tiles {
                if let sprite = tile.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let newPosition = pointForColumn(randomMove(), row: randomMove())
                        let moveAround = SKAction.move(to: newPosition, duration: 0.2)
                        moveAround.timingMode = .easeIn
                        let scaleAction = SKAction.scale(to: 5, duration: 0.2)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([moveAround, scaleAction, SKAction.removeFromParent()]),
                                         withKey:"removing")
                    }
                }
            }
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    // для анимации стирания
    func randomMove() -> Int {
       return Int(arc4random_uniform(15))-Int(arc4random_uniform(15))
    }
    
    //анимация перемещения фигуры
    func redrawShape(_ shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    //перерисовываем спрайты при сдвиге цвета, при перемещении, !без анимации! с удалением!!! и новым созданием, криво, но быстро, при замене texture почему-то некрасиво
    func redrawShapeFast(_ shape:Shape, completion:() -> ()) {
        for block in shape.blocks {
            var sprite = block.sprite!
            sprite.run(SKAction.removeFromParent())
            sprite = SKSpriteNode(imageNamed: imageName(block.tile))
            sprite.position = pointForColumn(block.column, row:block.row)
            blockLayer.addChild(sprite)
            block.sprite = sprite
         }
    }
    
    //shake screen
   func shakeCamera(_ duration:CGFloat) {
            let amplitudeX:CGFloat = 10;
            let amplitudeY:CGFloat = 6;
            let numberOfShakes = duration / 0.04;
            var actionsArray:[SKAction] = [];
            for _ in 1...Int(numberOfShakes) {
                // build a new random shake and add it to the list
                let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2);
                let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2);
                let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02);
                shakeAction.timingMode = SKActionTimingMode.easeOut;
                actionsArray.append(shakeAction);
                actionsArray.append(shakeAction.reversed());
            }
            
            let actionSeq = SKAction.sequence(actionsArray);
            gameLayer.run(actionSeq);
        }
    
    //рисуем падение блоков
    func animateCollapsingLines(_ linesToRemove: Array<TileType>, completion:@escaping () -> ()) {
        for tile in linesToRemove {
            if let sprite = tile.sprite {
                if sprite.action(forKey: "removing") == nil {
                    let time = Double((arc4random_uniform(10))/8)
             //       let scaleAction = SKAction.scaleTo(0.1, duration: time)
                    let newPosition = pointForColumn(tile.column, row: -15)
                    let moveDown = SKAction.move(to: newPosition, duration: time)
            //        scaleAction.timingMode = .EaseOut
                    moveDown.timingMode = .easeOut
                    sprite.run(SKAction.sequence([moveDown, SKAction.removeFromParent()]),
                                     withKey:"removing")
                }
            }
        }
        run(SKAction.wait(forDuration: 0.1), completion:completion)
    }
   
    //проигрываем звук
    func playSound(_ sound: SKAction) {
        run(sound)
    }
      
}

// определение названия файла спрайта (вместо enum)
func imageName(_ block: Int) -> String {
    switch block {
    case 1: return "blue"
    case 2: return "green"
    case 3: return "purple"
    case 4: return "red"
    case 5: return "white"
    case 6: return "yellow"
    default: return "blue"
    }
}

//определение плитки
    func fieldName(_ spawn: Bool) -> String {
        switch spawn {
        case true: return "spawn"
        case false: return "free"
        }
    }

