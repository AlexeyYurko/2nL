//
//  UITap.swift
//  2nLine
//
//Created by Howard Yang on 08/22/2015.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import UIKit

public class SingleDoubleTapGestureRecognizer: UITapGestureRecognizer {
    var targetDelegate: SingleDoubleTapGestureRecognizerDelegate
    public var duration: CFTimeInterval = 0.3 {
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
    
    func fakeAction(g: UITapGestureRecognizer) {
        tapCount = tapCount + 1
        if tapCount == 1 {
            delayHelper(duration, task: {
                if self.tapCount == 1 {
                    NSThread.detachNewThreadSelector(self.singleAction, toTarget:self.target, withObject: g)
                }
                else if self.tapCount == 2 {
                    NSThread.detachNewThreadSelector(self.doubleAction, toTarget:self.target, withObject: g)
                }
                self.tapCount = 0
            })
        }
    }
    typealias DelayTask = (cancel : Bool) -> ()
    
    func delayHelper(time:NSTimeInterval, task:()->()) ->  DelayTask? {
        
        func dispatch_later(block:()->()) {
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(time * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue(),
                block)
        }
        
        var closure: dispatch_block_t? = task
        var result: DelayTask?
        
        let delayedClosure: DelayTask = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    dispatch_async(dispatch_get_main_queue(), internalClosure);
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(cancel: false)
            }
        }
        
        return result;
    }
    
    func cancel(task:DelayTask?) {
        task?(cancel: true)
    }
}