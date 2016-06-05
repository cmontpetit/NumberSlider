

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var numberSliderView: NumberSliderView!
    @IBOutlet weak var numberSliderLabel: UILabel!
    
    class NumberSliderChangeListenerClass: NumberSliderChangeListener {
        var controller: ViewController!
        var initialValue: Int = 0
        func onChanged(value: Int) {
            controller.numberSliderLabel.text = "\(value)"
        }
        init(controller: ViewController){
            self.controller = controller
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberSliderView.listener = NumberSliderChangeListenerClass(controller: self)
    }
}