//
//  EGFloatingTextField.swift
//  EGFloatingTextField
//
//  Created by Enis Gayretli on 26.05.2015.
//
//
import UIKit
import Foundation
import PureLayout

public enum EGFloatingTextFieldValidationType {
    case Email
    case Number
}

@IBDesignable

public class EGFloatingTextField: UITextField {
    
    private typealias EGFloatingTextFieldValidationBlock = ((text:String,inout message:String)-> Bool)!
    
    public var validationType : EGFloatingTextFieldValidationType!
    
    @IBInspectable var validator: String!{
        didSet{
            switch validator{
            case "@":
                self.validationType = EGFloatingTextFieldValidationType.Email
                break
            case "0":
                self.validationType = EGFloatingTextFieldValidationType.Number
                break
            default:
                break
            }
        }
    }
    
    @IBInspectable public var IBPlaceholder: String?{
        didSet{
            if (IBPlaceholder != nil) {
                setPlaceHolder(IBPlaceholder!)
            }
        }
    }
    
    private var emailValidationBlock  : EGFloatingTextFieldValidationBlock
    private var numberValidationBlock : EGFloatingTextFieldValidationBlock
    
    let kDefaultInactiveColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    let kDefaultActiveColor = UIColor.blueColor()
    let kDefaultErrorColor = UIColor.redColor()
    let kDefaultLineHeight = CGFloat(22)
    let kDefaultLabelTextColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    
    public var floatingLabel : Bool! = true
    var label : UILabel!
    var labelFont : UIFont!
    var labelTextColor : UIColor!
    var activeBorder : UIView!
    var floating : Bool!
    var active : Bool!
    var hasError : Bool!
    var errorMessage : String!
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit(){
        
        self.emailValidationBlock = ({(text:String, inout message: String) -> Bool in
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@" , emailRegex)
            
            let  isValid = emailTest.evaluateWithObject(text)
            if !isValid {
                message = "Invalid Email Address"
            }
            return isValid;
        })
        self.numberValidationBlock = ({(text:String,inout message: String) -> Bool in
            let numRegex = "[0-9.+-]+";
            let numTest = NSPredicate(format:"SELF MATCHES %@" , numRegex)
            
            let isValid =  numTest.evaluateWithObject(text)
            if !isValid {
                message = "Invalid Number"
            }
            return isValid;
            
        })
        self.floating = false
        self.hasError = false
        
        self.labelTextColor = kDefaultLabelTextColor
        self.label = UILabel(frame: CGRectZero)
        self.label.font = self.labelFont
        self.label.textColor = self.labelTextColor
        self.label.textAlignment = NSTextAlignment.Left
        self.label.numberOfLines = 1
        self.label.layer.masksToBounds = false
        self.addSubview(self.label)
        
        
        self.activeBorder = UIView(frame: CGRectZero)
        self.activeBorder.backgroundColor = kDefaultActiveColor
        self.activeBorder.layer.opacity = 0
        self.addSubview(self.activeBorder)
        
        self.label.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: self)
        self.label.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: self)
        self.label.autoMatchDimension(ALDimension.Width, toDimension: ALDimension.Width, ofView: self)
        self.label.autoMatchDimension(ALDimension.Height, toDimension: ALDimension.Height, ofView: self)
        
        self.activeBorder.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: self)
        self.activeBorder.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: self)
        self.activeBorder.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Right, ofView: self)
        self.activeBorder.autoSetDimension(ALDimension.Height, toSize: 2)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textDidChange:"), name: "UITextFieldTextDidChangeNotification", object: self)
    }
    
    public func setPlaceHolder(placeholder:String){
        self.label.text = placeholder
    }
    
    override public func becomeFirstResponder() -> Bool {
        
        if self.floatingLabel! {
            
            if !self.floating! || self.text!.isEmpty {
                self.floatLabelToTop()
                self.floating = true
            }
        } else {
            self.label.textColor = kDefaultActiveColor
            self.label.layer.opacity = 0
        }
        self.showActiveBorder()
        return super.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool {
        
        if self.floatingLabel! {
            
            if self.floating! && self.text!.isEmpty {
                self.animateLabelBack()
                self.floating = false
            }
        } else {
            if self.text!.isEmpty {
                self.label.layer.opacity = 1
            }
        }
        self.label.textColor = kDefaultInactiveColor
        self.showInactiveBorder()
        self.validate()
        return super.resignFirstResponder()
        
    }
    
    override public func drawRect(rect: CGRect){
        super.drawRect(rect)
        
        var borderColor = self.hasError! ? kDefaultErrorColor : kDefaultInactiveColor
        var sView: UIView? = superview
        while sView != nil {
            if let effectView = sView as? UIVisualEffectView{
                if effectView.effect is UIVibrancyEffect {
                    borderColor = UIColor.whiteColor()
                }
                break
            }else{
                sView = sView!.superview
            }
        }
        let textRect = self.textRectForBounds(rect)
        let context = UIGraphicsGetCurrentContext()
        let borderlines : [CGPoint] = [CGPointMake(0, CGRectGetHeight(textRect) - 1),
                                       CGPointMake(CGRectGetWidth(textRect), CGRectGetHeight(textRect) - 1)]
        
        if  self.enabled  {
            
            CGContextBeginPath(context);
            CGContextAddLines(context, borderlines, 2);
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextStrokePath(context);
            
        } else {
            
            CGContextBeginPath(context);
            CGContextAddLines(context, borderlines, 2);
            CGContextSetLineWidth(context, 1.0);
            let  dashPattern : [CGFloat]  = [2, 4]
            CGContextSetLineDash(context, 0, dashPattern, 2);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextStrokePath(context);
            
        }
    }
    
    func textDidChange(notif: NSNotification){
        self.validate()
    }
    
    public func setDefaultText(string: String){
        text = string
        floatLabelToTop()
        floating = true
        showInactiveBorder()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.label.textColor = self.kDefaultInactiveColor
        }
    }
    
    func floatLabelToTop() {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.label.textColor = self.kDefaultActiveColor
        }
        
        let anim2 = CABasicAnimation(keyPath: "transform")
        let fromTransform = CATransform3DMakeScale(CGFloat(1.0), CGFloat(1.0), CGFloat(1))
        var toTransform = CATransform3DMakeScale(CGFloat(0.5), CGFloat(0.5), CGFloat(1))
        toTransform = CATransform3DTranslate(toTransform, -CGRectGetWidth(self.label.frame)/2, -CGRectGetHeight(self.label.frame), 0)
        anim2.fromValue = NSValue(CATransform3D: fromTransform)
        anim2.toValue = NSValue(CATransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim2]
        animGroup.duration = 0.3
        animGroup.fillMode = kCAFillModeForwards;
        animGroup.removedOnCompletion = false;
        self.label.layer.addAnimation(animGroup, forKey: "_floatingLabel")
        self.clipsToBounds = false
        CATransaction.commit()
    }
    
    func showActiveBorder() {
        
        self.activeBorder.layer.transform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
        self.activeBorder.layer.opacity = 1
        CATransaction.begin()
        self.activeBorder.layer.transform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
        let anim2 = CABasicAnimation(keyPath: "transform")
        let fromTransform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
        let toTransform = CATransform3DMakeScale(CGFloat(1.0), CGFloat(1.0), 1)
        anim2.fromValue = NSValue(CATransform3D: fromTransform)
        anim2.toValue = NSValue(CATransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim2.fillMode = kCAFillModeForwards
        anim2.removedOnCompletion = false
        self.activeBorder.layer.addAnimation(anim2, forKey: "_activeBorder")
        CATransaction.commit()
    }
    
    func animateLabelBack() {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.label.textColor = self.kDefaultInactiveColor
        }
        
        let anim2 = CABasicAnimation(keyPath: "transform")
        var fromTransform = CATransform3DMakeScale(0.5, 0.5, 1)
        fromTransform = CATransform3DTranslate(fromTransform, -CGRectGetWidth(self.label.frame)/2, -CGRectGetHeight(self.label.frame), 0);
        let toTransform = CATransform3DMakeScale(1.0, 1.0, 1)
        anim2.fromValue = NSValue(CATransform3D: fromTransform)
        anim2.toValue = NSValue(CATransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim2]
        animGroup.duration = 0.3
        animGroup.fillMode = kCAFillModeForwards;
        animGroup.removedOnCompletion = false;
        
        self.label.layer.addAnimation(animGroup, forKey: "_animateLabelBack")
        CATransaction.commit()
    }
    
    func showInactiveBorder() {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.activeBorder.layer.opacity = 0
        }
        let anim2 = CABasicAnimation(keyPath: "transform")
        let fromTransform = CATransform3DMakeScale(1.0, 1.0, 1)
        let toTransform = CATransform3DMakeScale(0.01, 1.0, 1)
        anim2.fromValue = NSValue(CATransform3D: fromTransform)
        anim2.toValue = NSValue(CATransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim2.fillMode = kCAFillModeForwards
        anim2.removedOnCompletion = false
        self.activeBorder.layer.addAnimation(anim2, forKey: "_activeBorder")
        CATransaction.commit()
    }
    
    func performValidation(isValid:Bool,message:String){
        if !isValid {
            self.hasError = true
            self.errorMessage = message
            self.labelTextColor = kDefaultErrorColor
            self.activeBorder.backgroundColor = kDefaultErrorColor
            self.setNeedsDisplay()
        } else {
            self.hasError = false
            self.errorMessage = nil
            self.labelTextColor = kDefaultActiveColor
            self.activeBorder.backgroundColor = kDefaultActiveColor
            self.setNeedsDisplay()
        }
    }
    
    func validate(){
        
        if self.validationType != nil {
            var message : String = ""
            
            if self.validationType! == .Email {
                
                let isValid = self.emailValidationBlock(text: self.text!, message: &message)
                
                performValidation(isValid,message: message)
                
            } else {
                let isValid = self.numberValidationBlock(text: self.text!, message: &message)
                
                performValidation(isValid,message: message)
            }
        }
    }
}

extension EGFloatingTextField {
    
}
