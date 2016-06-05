//
//  NumberSlider.swift
//  NumberSlider
//
//  Created by Claude Montpetit on 16-06-04.
//  Copyright © 2016 Claude Montpetit. All rights reserved.
//

import UIKit

public class NumberSliderView: UIView {

    @IBOutlet var view: UIView!
    
    public var listener: NumberSliderChangeListener! {
        didSet {
            currentValue = listener.initialValue
        }
    }
    
    private var graceDelay = 0.5
    private var incStartDelay = 0.5
    private var incCurrentDelay = 0.5
    private var timer: NSTimer?
    private var increments = [-10000, -10000, -1000, -100, -10, -1, 0, 0, 1, 10, 100, 1000, 10000, 10000]
    private var lastIndex = 0
    private var inFirstTimer = false
    private var inFirstOfNextTimers = false
    
    private var currentValue: Int = 0 {
        didSet {
            listener.onChanged(currentValue)
        }
    }
    
    private var defaultIndex: Int {
        get {
            // todo, compute the "9"
            for i in 9..<increments.count {
                let inc = increments[i]
                if (inc != 0 && currentValue % inc > 0) {
                    return i-1
                }
            }
            return 8
        }
    }
    
    private var currentIndex: Int {
        get {
            return Int(ceil(slider.value)) + Int(increments.count/2) - 1
        }
    }
    
    @IBOutlet weak var incLabelNegative: UILabel! {
        didSet {
            incLabelNegative.text = "\(abs(increments[defaultIndex]) * -1)"
        }
    }
    @IBOutlet weak var incLabelPositive: UILabel! {
        didSet {
            incLabelPositive.text = "+\(abs(increments[defaultIndex]))"
        }
    }
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.minimumValue = Float(increments.count / 2 * -1) + 0.001
            slider.maximumValue = Float(increments.count / 2) - 0.001
            slider.value = 0
            lastIndex = defaultIndex
        }
    }
    
    func afterFirstTimer() {
        assert(inFirstTimer)
        timer?.invalidate()
        inFirstTimer = false
        inFirstOfNextTimers = true
        timer = NSTimer.scheduledTimerWithTimeInterval(incStartDelay, target: self, selector: #selector(onNextTimers), userInfo: nil, repeats: false)
    }
    
    func afterPauseTimer() {
        timer?.invalidate()
        inFirstOfNextTimers = true
        timer = NSTimer.scheduledTimerWithTimeInterval(incStartDelay, target: self, selector: #selector(onNextTimers), userInfo: nil, repeats: false)
    }
    
    func onNextTimers() {
        
        let index = currentIndex
        
        if (!inFirstOfNextTimers && index != lastIndex) {
            // pause when changing increment
            incCurrentDelay = incStartDelay
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(incStartDelay, target: self, selector: #selector(afterPauseTimer), userInfo: nil, repeats: false)
        } else {
            let inc = increments[index]
            if (inc != 0) {
                currentValue = ((currentValue + inc) / inc) * inc
            }
        }
        
        if (inFirstOfNextTimers) {
            incCurrentDelay = incStartDelay
        } else {
            incCurrentDelay = max(incCurrentDelay * 0.8, 0.05)
        }
        inFirstOfNextTimers = false
        lastIndex = index
        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(incCurrentDelay, target: self, selector: #selector(onNextTimers), userInfo: nil, repeats: false)
        
        // update left-right labels
        // hide either the left or right
        if (increments[index] > 0) {
            incLabelPositive.hidden = false
            incLabelPositive.text = "+\(increments[index])"
            incLabelNegative.hidden = true
        } else if (increments[index] < 0) {
            incLabelPositive.hidden = true
            incLabelNegative.hidden = false
            incLabelNegative.text = "\(increments[index])"
        } else {
            incLabelPositive.hidden = false
            incLabelPositive.text = "0"
            incLabelNegative.hidden = false
            incLabelNegative.text = "0"
        }
    }
    
    @IBAction func onSliderTouchDown(sender: AnyObject) {
        
        // first timer, first delay
        assert(timer == nil)
        inFirstTimer = true
        timer = NSTimer.scheduledTimerWithTimeInterval(graceDelay, target: self, selector: #selector(afterFirstTimer), userInfo: nil, repeats: false)
        
        // update left-right labels
        // show both sides
        let index = currentIndex
        if (increments[index] != 0) {
            let inc = abs(increments[index])
            incLabelPositive.hidden = false
            incLabelPositive.text = "+\(inc)"
            incLabelNegative.hidden = false
            incLabelNegative.text = "\(inc * -1)"
        }
    }
    
    @IBAction func onSliderTouchUpOutside(sender: AnyObject) {
        onSliderTouchUp(false)
    }
    
    @IBAction func onSliderTouchUpInside(sender: AnyObject) {
        onSliderTouchUp(true)
    }
    
    private func onSliderTouchUp(inside: Bool) {
        
        
        // swip-increment-decrement ?
        if (inFirstTimer) {
            let index = currentIndex
            // use the last increment if up inside,
            // and use + or - according to side
            var inc = abs(increments[lastIndex])
            if (inc != 0) {
                if (increments[index] < 0) {
                    inc = inc * -1
                }
                currentValue = ((currentValue + inc) / inc) * inc
            }
        } else if (increments[lastIndex] == 0) {
            currentValue = 0
        }
        
        slider.value = 0
        timer?.invalidate()
        timer = nil
        
        // update left-right labels
        // show both sides.
        // If the last was 0, reset to default
        if (increments[lastIndex] == 0) {
            lastIndex = defaultIndex
        }
        let inc = abs(increments[lastIndex])
        incLabelPositive.hidden = false
        incLabelPositive.text = "+\(inc)"
        incLabelNegative.hidden = false
        incLabelNegative.text = "\(inc * -1)"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: String(self.dynamicType), bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil)
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY , metrics: nil, views: ["view": view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["view": view]))
    }
}

public protocol NumberSliderChangeListener {
    func onChanged(value: Int)
    var initialValue: Int { get }
}
