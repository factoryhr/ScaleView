//
//  ViewController.swift
//  ScaleView
//
//  Created by Dejan Kraguljac on 21/04/2017.
//  Copyright © 2017 Dejan Kraguljac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var minValueTextField: UITextField!
    @IBOutlet weak var maxValuetextField: UITextField!
    @IBOutlet weak var scrollToValueTextField: UITextField!
    @IBOutlet weak var lineWidthtextField: UITextField!
    @IBOutlet weak var linesSpacingtextField: UITextField!
    @IBOutlet weak var currentValueLabel: UILabel!
    
    @IBOutlet weak var testScrollableView: ScrollableScaleView!
    var scrollableView = ScrollableScaleView()
    
    //MARK: viewDidLoad
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.scrollableView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(scrollableView)
        
        self.testScrollableView.scalingValue = 6
        
        self.scrollableView.gotValueUsingOffset = { [unowned self] value in
            
            let dividedValue = value/12
            let additionalValue = 12*(dividedValue - Float(Int(dividedValue)))
            self.currentValueLabel.text = "\(Int(dividedValue))'" + "\(Int(additionalValue))\""
        }
        
        self.testScrollableView.gotValueUsingOffset = { [unowned self] value in
            
            self.currentValueLabel.text = "\(value)"
            
        }
        let horizontalConstraint = NSLayoutConstraint(item: scrollableView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: scrollableView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.containerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: scrollableView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: containerView.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: scrollableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: containerView.frame.size.height)
       
        
        self.containerView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        self.scrollableView.system = .implerial
        self.scrollableView.useWeightScale = false
        self.scrollableView.scalingValue = 6
        self.scrollableView.shouldShowHorizontalScrollIndicator = false
        self.scrollableView.reloadScaleData()
    }
    
    //MARK: Actions
    
    @IBAction func applyChangesButtonTapped(_ sender: Any)
    {
        guard let minTFValue = Float(minValueTextField.text!),
            let maxTFValue = Float(maxValuetextField.text!),
            let lineWidth = Int(lineWidthtextField.text!),
            let lineSpacing = Int(linesSpacingtextField.text!) else
        {
            return
        }
        
        self.applyLayoutChangesWith(minValue: minTFValue, maxValue: maxTFValue, lineWidth: lineWidth, lineSpacing: lineSpacing)
        
    }
    
    @IBAction func scrollButtonAction(_ sender: Any)
    {
        
        guard let scrollValue = Int(scrollToValueTextField.text!) else {
            return
        }
        self.scrollableView.scrollToValue(value: Float(scrollValue))
    }
    
    //MARK: layout changes
    
    func applyLayoutChangesWith(minValue min: Float, maxValue max: Float, lineWidth width: Int, lineSpacing spacing: Int)
    {
        guard min > 0, min < max, width > 0, spacing > 0
            else
        {
            return
        }
        
        testScrollableView.minValue = min
        testScrollableView.maxValue = max
        testScrollableView.numberOfUsedLines = Int(max - min)
        testScrollableView.lineWidth = width
        testScrollableView.indicatorWidth = CGFloat(3)
        testScrollableView.linesSpacing = spacing
        testScrollableView.indicatorColor =  UIColor.init(red: 118.0/255.0, green: 221.0/255.0, blue: 251.0/255.0, alpha: 1)
        testScrollableView.usedLinesColor = UIColor.init(red: 23.0/255.0, green: 39.0/255.0, blue: 81.0/255.0, alpha: 0.12)
        testScrollableView.unusedLinesColor = UIColor.init(red: 23.0/255.0, green: 39.0/255.0, blue: 81.0/255.0, alpha: 0.05)
        testScrollableView.shouldShowHorizontalScrollIndicator = false
        testScrollableView.reloadScaleData()
        
        testScrollableView.updateScaleLabelsWith(newFont: UIFont(name: "Futura", size: 10)!, newColor: UIColor.init(red: 23.0/255.0, green: 39.0/255.0, blue: 81.0/255.0, alpha: 0.12))
        
        self.scrollableView.minValue = min
        self.scrollableView.maxValue = max
        self.scrollableView.numberOfUsedLines = Int(max - min)
        self.scrollableView.lineWidth = width
        self.scrollableView.indicatorWidth = CGFloat(width)
        self.scrollableView.linesSpacing = spacing
        self.scrollableView.reloadScaleData()
        
    }
    @IBAction func bouncesSwitchValueChanged(_ sender: UISwitch)
    {
        self.scrollableView.useBounces = sender.isOn
        self.scrollableView.reloadScaleData()
    }
    
    @IBAction func blueButtonTapped(_ sender: Any)
    {
        self.scrollableView.unusedLinesColor = UIColor.blue
        self.scrollableView.indicatorColor = UIColor.red
        self.scrollableView.usedLinesColor = UIColor.blue
        
        self.scrollableView.updateScaleLabelsWith(newFont: UIFont(name: "HelveticaNeue", size: 12)!, newColor: UIColor.purple)
        //        self.scrollableView.reloadScaleData()
    }
    
    @IBAction func yellowbuttonTapped(_ sender: Any)
    {
        self.scrollableView.unusedLinesColor = UIColor.yellow
        self.scrollableView.indicatorColor = UIColor.blue
        self.scrollableView.usedLinesColor = UIColor.orange
        self.scrollableView.subLinesLabelPercentHeightValue = 0.75
        self.scrollableView.mainLinesLabelPercentHeightValue = 0.5
        self.scrollableView.reloadScaleData()
    }

    @IBAction func greenButtonmTapped(_ sender: Any)
    {
        self.scrollableView.unusedLinesColor = UIColor.green
        self.scrollableView.indicatorColor = UIColor.orange
        self.scrollableView.usedLinesColor = UIColor.green
        self.scrollableView.subLinesLabelPercentHeightValue = 0.75
        self.scrollableView.mainLinesLabelPercentHeightValue = 0.4
        self.scrollableView.reloadScaleData()
    }
}


enum MeasurementSystem
{
    case implerial
    case metric
}

enum Unit
{
    case mass(system: MeasurementSystem)
    case lenght(system: MeasurementSystem)
    
    var symbol: String
    {
        switch self
        {
            
        case .mass(system: let system):
            return system == .metric ? "kg" : "lbs"
        case .lenght(system: let system):
            return system == .metric ? "cm" : "feet"
        }
    }
}
