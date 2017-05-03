

import UIKit

open class ScrollableScaleView: UIView {

    var scaleContainerView: UIView =
    {
        let view = UIView(frame: CGRect.zero)
        
        return view
    }()
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var scaleScrollView: UIScrollView!
    @IBOutlet weak var indicatorImageViewWidthConstraint: NSLayoutConstraint!
    
    var numberOfUsedLines: Int = 10
    var minValue: Float = 0
    var maxValue: Float = 0
    var system: MeasurementSystem = .metric
    var lineWidth = 1
    var usedLinesColor = UIColor.black
    var unusedLinesColor = UIColor.lightGray
    var indicatorWidth: CGFloat = 1
    var linesSpacing = 4
    var scalingValue = 5
    var scaleLabelFont = UIFont(name: "Futura", size: 8)
    var scaleLabelColor = UIColor.green
    var numberOfUnusedLines: Int = Int(UIScreen.main.bounds.size.width/2)/5
    var mainLinesLabelPercentHeightValue = 0.5
    var subLinesLabelPercentHeightValue = 0.75
    
    var gotValueUsingOffset: ((_ currentValue: Float) -> Void)?
    
    var scaleLabels: [UILabel] = [UILabel]()
        
    var unusedLinesOffset: Double = 0
    {
        didSet
        {
            self.indicatorImageViewWidthConstraint.constant = self.indicatorWidth
        }
    }
    
    var indicatorColor: UIColor = UIColor.blue
    {
        didSet
        {
            self.indicatorImageView.backgroundColor = self.indicatorColor
        }
    }

    var linesWithSpaceWidth: Int
    {
        let width = self.lineWidth + self.linesSpacing
        return width
    }
    var shouldShowHorizontalScrollIndicator = false
    {
        didSet
        {
            self.scaleScrollView.showsHorizontalScrollIndicator = shouldShowHorizontalScrollIndicator
        }
    }
    
    var useBounces = false
    {
        didSet
        {
            self.scaleScrollView.bounces = useBounces
        }
    }
    
    //this bool only because of feet scale... custom label values...
    var useWeightScale: Bool = true
    
    // MARK:init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    func loadViewFromNib()
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ScrollableScaleView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }

    
    // MARK:draw
    override open func draw(_ rect: CGRect)
    {
        guard rect != CGRect.zero,
            self.minValue <= self.maxValue,
            self.minValue >= 0,
            self.linesSpacing > 0
        else {
            
            return
        }
        
        self.resetScaleView()
        
        self.indicatorImageView.backgroundColor = self.indicatorColor
        self.numberOfUsedLines = Int(self.maxValue - self.minValue)
        self.indicatorImageViewWidthConstraint.constant = self.indicatorWidth
        self.numberOfUnusedLines = Int(self.frame.size.width/2)/linesWithSpaceWidth
        let unusedLinesMultiplier: Int = self.scaleScrollView.bounces == true ? 4 : 2
        
        for index in 0 ... (numberOfUnusedLines + numberOfUsedLines*unusedLinesMultiplier + numberOfUsedLines%self.scalingValue)
        {
            drawScaleLine(offset: linesWithSpaceWidth*(index) + Int(self.bounds.size.width/2), color:(index > numberOfUsedLines) ? unusedLinesColor : usedLinesColor, addLabel:numberOfUsedLines >= index, bigLine: (index + Int(minValue))%self.scalingValue == 0)
        }
        
        for index in 1 ... numberOfUnusedLines*unusedLinesMultiplier
        {
            drawScaleLine(offset: Int(self.bounds.size.width/2) - linesWithSpaceWidth*(index), color:unusedLinesColor, addLabel: false, bigLine: (index + self.scalingValue - Int(minValue))%self.scalingValue == 0)
        }
        
        self.scaleContainerView.setNeedsDisplay()
        self.scaleContainerView.layoutIfNeeded()
        
        self.scaleContainerView.frame = CGRect(x: 0, y: 0, width: linesWithSpaceWidth*numberOfUsedLines + Int(self.frame.size.width), height: Int(self.frame.size.height))
        
        scaleScrollView.addSubview(self.scaleContainerView)
        scaleScrollView.contentSize = self.scaleContainerView.frame.size
        
    }
    
    // MARK:draw lines
    
    fileprivate func drawScaleLine(offset: Int, color: UIColor, addLabel: Bool, bigLine: Bool)
    {
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        
        path.move(to: CGPoint(x: offset, y: Int(self.frame.size.height)))
        
        if bigLine == false
        {
            path.addLine(to: CGPoint(x: offset, y: Int(Double(self.frame.size.height)*self.subLinesLabelPercentHeightValue)))
        }
        else
        {
            path.addLine(to: CGPoint(x: offset, y: Int(Double(self.frame.size.height)*self.mainLinesLabelPercentHeightValue)))
            
            if addLabel == true
            {
                let label = UILabel(frame: CGRect(x: offset-10, y: Int(Double(self.frame.size.height) - 10.0 - Double(self.frame.size.height)*(1.0-self.mainLinesLabelPercentHeightValue)), width: 20, height: Int((self.scaleLabelFont?.pointSize)!)))
                label.text = self.getScaleLabelTextForSystem(forOffset: offset)
                label.textAlignment = .center
                label.font = self.scaleLabelFont
                label.textColor = self.scaleLabelColor
                scaleContainerView.addSubview(label)
                
                self.scaleLabels.append(label)
            }
        }
        
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = CGFloat(self.lineWidth)
        shapeLayer.strokeColor = color.cgColor
        scaleContainerView.layer.addSublayer(shapeLayer)
    }
    
    // MARK:get label text,  added this because of custom label values
    
    func getScaleLabelTextForSystem(forOffset offset: Int) -> String
    {
        if (system == .metric || useWeightScale)
        {
            return "\(Int(minValue) + offset/linesWithSpaceWidth - numberOfUnusedLines)"
        }
        else if (system == .implerial && !useWeightScale)
        {
            let mainValue : Int = (Int(minValue) + offset/linesWithSpaceWidth - numberOfUnusedLines)/12
            let additionalValue: Int = (Int(minValue) + offset/linesWithSpaceWidth - numberOfUnusedLines)%12 < 6 ? 0 : 6
            return "\(mainValue)'" + "\(additionalValue)\""
        }
        else
        {
            return ""
        }
    }
    
    
    
    // MARK: feature to scroll to entered value
    func scrollToValue(value: Float)
    {
        guard value <= self.maxValue, value >= self.minValue else {
            return
        }
        
        let newOffset = self.getOffsetForValue(value: value)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        
                        self.scaleScrollView.contentOffset = CGPoint(x: Int(newOffset), y: 0)
                        
        }, completion: nil)
    }
    
    
    // MARK:helpers
    
    public func getOffsetForValue(value: Float) -> Float
    {
        guard value <= self.maxValue  else {
            return 0
        }
        
        return Float(linesWithSpaceWidth)*(value - self.minValue)
    }

    
    func resetScaleView()
    {
        self.scaleContainerView.removeFromSuperview()
        self.scaleLabels.removeAll()
        
        guard self.scaleContainerView.layer.sublayers != nil else
        {
            return
        }
        
        for scaleLayer in self.scaleContainerView.layer.sublayers!
        {
            if scaleLayer is CAShapeLayer
            {
                scaleLayer.removeFromSuperlayer()
            }
            
        }
        
        for scaleLabel in self.scaleContainerView.subviews
        {
            if scaleLabel is UILabel
            {
                scaleLabel.removeFromSuperview()
            }
        }

    }
    
    func reloadScaleData()
    {
        draw(self.frame)
    }
    
    func updateScrollViewWith(newMin min: Int, newMax max: Int)
    {
        guard min > 0, min < max
            else
        {
            return
        }
        
        self.minValue = Float(min)
        self.maxValue = Float(max)
        self.numberOfUsedLines = (max-min)
        
    }
    
    func updateScaleLabelsWith(newFont font: UIFont, newColor color: UIColor)
    {
        for label in self.scaleLabels
        {
            label.textColor = color
            label.font = font
            label.frame = CGRect(x:Int(label.frame.origin.x), y: Int(Double(self.frame.size.height) - Double(font.pointSize + 2.0) - Double(self.frame.size.height)*(1.0-self.mainLinesLabelPercentHeightValue)), width: 20, height: Int(font.pointSize))
            
            //+2 so the label wont be stuck on the line
        }
    }
}

extension ScrollableScaleView: UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let scrollOffsetPercentage: Float = (Float(scrollView.contentOffset.x)/Float(self.scaleScrollView.contentSize.width - self.frame.size.width))
        
        let value = self.minValue + (self.maxValue - self.minValue)*scrollOffsetPercentage
        
        if let block = self.gotValueUsingOffset, value >= self.minValue, value <= self.maxValue
        {
            block(value)
        }
        else if let block = self.gotValueUsingOffset, value < self.minValue
        {
            block(self.minValue)
        }
        else if let block = self.gotValueUsingOffset, value > self.maxValue
        {
            block(self.maxValue)
        }
    }
}


