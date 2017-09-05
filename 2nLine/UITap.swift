//
//  UITap.swift
//  2nLine
//
//Created by Howard Yang on 08/22/2015.
//

import UIKit

open class SingleDoubleTapGestureRecognizer: UITapGestureRecognizer {
    var targetDelegate: SingleDoubleTapGestureRecognizerDelegate
    open var duration: CFTimeInterval = 0.3 {
        didSet {
            self.targetDelegate.duration = duration
        }
    }
    public init(target: AnyObject, singleAction: Selector, doubleAction: Selector) {
        targetDelegate = SingleDoubleTapGestureRecognizerDelegate(target: target, singleAction: singleAction, doubleAction: doubleAction)
        super.init(target: targetDelegate, action: #selector(SingleDoubleTapGestureRecognizerDelegate.fakeAction(_:)))
        numberOfTapsRequired = 1
    }
}
class SingleDoubleTapGestureRecognizerDelegate: NSObject {
    var target: AnyObject
    var singleAction: Selector
    var doubleAction: Selector
    var duration: CFTimeInterval = 0.2
    var tapCount = 0
    
    init(target: AnyObject, singleAction: Selector, doubleAction: Selector) {
        self.target = target
        self.singleAction = singleAction
        self.doubleAction = doubleAction
    }
    
    func fakeAction(_ g: UITapGestureRecognizer) {
        tapCount = tapCount + 1
        if tapCount == 1 {
            delayHelper(duration, task: {
                if self.tapCount == 1 {
                    Thread.detachNewThreadSelector(self.singleAction, toTarget:self.target, with: g)
                }
                else if self.tapCount == 2 {
                    Thread.detachNewThreadSelector(self.doubleAction, toTarget:self.target, with: g)
                }
                self.tapCount = 0
            })
        }
    }
    typealias DelayTask = (_ cancel : Bool) -> ()
    
    func delayHelper(_ time:TimeInterval, task: @escaping ()->()) ->  DelayTask? {
        
        func dispatch_later(_ block:@escaping ()->()) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                execute: block)
        }
        
        var closure: ()->() = task
        var result: DelayTask?
        
        let delayedClosure: DelayTask = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    DispatchQueue.main.async(execute: internalClosure);
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result;
    }
    
    func cancel(_ task:DelayTask?) {
        task?(true)
    }
}
