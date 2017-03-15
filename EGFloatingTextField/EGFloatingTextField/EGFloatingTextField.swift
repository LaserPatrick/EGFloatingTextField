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


public enum EGFloatingTextFieldValidationType: String {
    case Default
    case Email
    case Integer
    case Decimal
    case PhoneNumber
    case WebURL
}

@IBDesignable

open class EGFloatingTextField: UITextField {
    
    open override var text: String?{
        didSet{
            if !isFirstResponder{
                if !(text ?? "").isEmpty && (oldValue ?? "").isEmpty{
                    floatLabelToTop(active: false, animated: false)
                    floating = true
                }else if (text ?? "").isEmpty && !(oldValue ?? "").isEmpty{
                    animateLabelBack()
                    floating = false
                }
            }
        }
    }
    
    fileprivate typealias EGFloatingTextFieldValidationBlock = ((_ text:String,_ message:inout String)-> Bool)!
    
    open var validationType : EGFloatingTextFieldValidationType!{
        didSet{
            if validationType != nil{
            switch validationType! {
            case .Email:
                keyboardType = .emailAddress
                autocapitalizationType = .none
                autocorrectionType = .no
            case .Decimal:
                keyboardType = .decimalPad
                autocapitalizationType = .none
                autocorrectionType = .no
            case .Integer:
                keyboardType = .numberPad
                autocapitalizationType = .none
                autocorrectionType = .no
            case .PhoneNumber:
                keyboardType = .phonePad
                autocapitalizationType = .none
                autocorrectionType = .no
            case .WebURL:
                keyboardType = .URL
                autocapitalizationType = .none
                autocorrectionType = .no
            default:
                keyboardType = .default
                autocapitalizationType = .sentences
                autocorrectionType = .default
                break
                }
            }
        }
    }
    
    @IBInspectable var validationTypeAdapter: String {
        get {
            return validationType.rawValue
        }
        set(shapeIndex) {
            self.validationType = EGFloatingTextFieldValidationType(rawValue: shapeIndex) ?? .Default
        }
    }
    
    @IBInspectable open var IBPlaceholder: String?{
        didSet{
            if (IBPlaceholder != nil) {
                setPlaceHolder(IBPlaceholder!)
            }
        }
    }
    
    fileprivate var emailValidationBlock  : EGFloatingTextFieldValidationBlock
    fileprivate var integerValidationBlock : EGFloatingTextFieldValidationBlock
    fileprivate var decimalValidationBlock : EGFloatingTextFieldValidationBlock
    fileprivate var phoneNumberValidationBlock : EGFloatingTextFieldValidationBlock
    fileprivate var urlValidationBlock : EGFloatingTextFieldValidationBlock
    
    let kDefaultInactiveColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    let kDefaultActiveColor = UIColor.blue
    let kDefaultErrorColor = UIColor.red
    let kDefaultLineHeight = CGFloat(22)
    let kDefaultLabelTextColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    
    open var floatingLabel : Bool! = true
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
        
        self.emailValidationBlock = ({(text:String, message: inout String) -> Bool in
            let emailRegex = "([A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6})?"
            let emailTest = NSPredicate(format:"SELF MATCHES %@" , emailRegex)
            let  isValid = emailTest.evaluate(with: text)
            if !isValid {
                message = "Invalid Email address"
            }
            return isValid
        })
        self.integerValidationBlock = ({(text:String,message: inout String) -> Bool in
            let numRegex = "^([+-]?[0-9]+)?$"
            let numTest = NSPredicate(format:"SELF MATCHES %@" , numRegex)
            let isValid =  numTest.evaluate(with: text)
            if !isValid {
                message = "Invalid integer number"
            }
            return isValid
        })
        self.decimalValidationBlock = ({(text:String,message: inout String) -> Bool in
            let numRegex = "^([+-]?[0-9]+([,|.]+[0-9]+|))?$"
            let numTest = NSPredicate(format:"SELF MATCHES %@" , numRegex)
            let isValid =  numTest.evaluate(with: text)
            if !isValid {
                message = "Invalid decimal number"
            }
            return isValid
        })
        self.phoneNumberValidationBlock = ({(text:String,message: inout String) -> Bool in
            let numRegex = "^([+]?[0-9]+)?$"
            let numTest = NSPredicate(format:"SELF MATCHES %@" , numRegex)
            let isValid =  numTest.evaluate(with: text)
            if !isValid {
                message = "Invalid phone number"
            }
            return isValid
        })
        self.urlValidationBlock = ({(text:String,message: inout String) -> Bool in
            let regex = try! NSRegularExpression(pattern: "^(((http|https):\\/\\/)?((\\w)*|([0-9]*)|([-|_])*)+([\\/.|\\/]((\\w)*|([0-9]*)|([-|_])*))+)?$", options: [.caseInsensitive])
            let isValid = regex.firstMatch(in: text, options:[], range: NSMakeRange(0, (text as NSString).length)) != nil
            if !isValid {
                message = "Invalid url"
            }
            return isValid
        })
        
        self.floating = false
        self.hasError = false
        
        self.labelTextColor = kDefaultLabelTextColor
        self.label = UILabel(frame: CGRect.zero)
        self.label.font = self.labelFont
        self.label.textColor = self.labelTextColor
        self.label.textAlignment = NSTextAlignment.left
        self.label.numberOfLines = 1
        self.label.layer.masksToBounds = false
        self.addSubview(self.label)
        
        self.activeBorder = UIView(frame: CGRect.zero)
        self.activeBorder.backgroundColor = kDefaultActiveColor
        self.activeBorder.layer.opacity = 0
        self.addSubview(self.activeBorder)
        
        self.label.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: self)
        self.label.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self)
        self.label.autoMatch(ALDimension.width, to: ALDimension.width, of: self)
        self.label.autoMatch(ALDimension.height, to: ALDimension.height, of: self)
        
        self.activeBorder.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self)
        self.activeBorder.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self)
        self.activeBorder.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self)
        self.activeBorder.autoSetDimension(ALDimension.height, toSize: 2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: self)
    }
    
    open func setPlaceHolder(_ placeholder:String){
        self.label.text = placeholder
    }
    
    override open func becomeFirstResponder() -> Bool {
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
    
    override open func resignFirstResponder() -> Bool {
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
    
    override open func draw(_ rect: CGRect){
        super.draw(rect)
        var borderColor = self.hasError! ? kDefaultErrorColor : kDefaultInactiveColor
        var sView: UIView? = superview
        while sView != nil {
            if let effectView = sView as? UIVisualEffectView{
                if effectView.effect is UIVibrancyEffect {
                    borderColor = UIColor.white
                }
                break
            }else{
                sView = sView!.superview
            }
        }
        let textRect = self.textRect(forBounds: rect)
        if let context = UIGraphicsGetCurrentContext(){
            let borderlines : [CGPoint] = [CGPoint(x: 0, y: textRect.height - 1),
                                           CGPoint(x: textRect.width, y: textRect.height - 1)]
            if  self.isEnabled  {
                context.beginPath()
                context.addLines(between: borderlines)
                context.setLineWidth(1.0)
                context.setStrokeColor(borderColor.cgColor)
                context.strokePath()
            } else {
                context.beginPath()
                context.addLines(between: borderlines)
                context.setLineWidth(1.0)
                let  dashPattern : [CGFloat]  = [2, 4]
                context.setLineDash(phase: 0, lengths: dashPattern)
                context.setStrokeColor(borderColor.cgColor)
                context.strokePath()
            }
        }
    }
    
    func textDidChange(_ notif: Notification){
        self.validate()
    }
    
    func floatLabelToTop(active: Bool = true, animated: Bool = true) {
        label.layoutIfNeeded()
        CATransaction.begin()
        if active {
            CATransaction.setCompletionBlock { () -> Void in
                self.label.textColor = self.kDefaultActiveColor
            }
        }
        let anim2 = CABasicAnimation(keyPath: "transform")
        let fromTransform = CATransform3DMakeScale(CGFloat(1.0), CGFloat(1.0), CGFloat(1))
        var toTransform = CATransform3DMakeScale(CGFloat(0.5), CGFloat(0.5), CGFloat(1))
        toTransform = CATransform3DTranslate(toTransform, -label.frame.width/2, -label.frame.height, 0)
        anim2.fromValue = NSValue(caTransform3D: fromTransform)
        anim2.toValue = NSValue(caTransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim2]
        animGroup.duration = animated ? 0.3 : 0.0
        animGroup.fillMode = kCAFillModeForwards
        animGroup.isRemovedOnCompletion = false
        self.label.layer.add(animGroup, forKey: "_floatingLabel")
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
        anim2.fromValue = NSValue(caTransform3D: fromTransform)
        anim2.toValue = NSValue(caTransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim2.fillMode = kCAFillModeForwards
        anim2.isRemovedOnCompletion = false
        self.activeBorder.layer.add(anim2, forKey: "_activeBorder")
        CATransaction.commit()
    }
    
    func animateLabelBack() {
        label.layoutIfNeeded()
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.label.textColor = self.kDefaultInactiveColor
        }
        let anim2 = CABasicAnimation(keyPath: "transform")
        var fromTransform = CATransform3DMakeScale(0.5, 0.5, 1)
        fromTransform = CATransform3DTranslate(fromTransform, -self.label.frame.width/2, -self.label.frame.height, 0)
        let toTransform = CATransform3DMakeScale(1.0, 1.0, 1)
        anim2.fromValue = NSValue(caTransform3D: fromTransform)
        anim2.toValue = NSValue(caTransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim2]
        animGroup.duration = 0.3
        animGroup.fillMode = kCAFillModeForwards
        animGroup.isRemovedOnCompletion = false
        
        self.label.layer.add(animGroup, forKey: "_animateLabelBack")
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
        anim2.fromValue = NSValue(caTransform3D: fromTransform)
        anim2.toValue = NSValue(caTransform3D: toTransform)
        anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim2.fillMode = kCAFillModeForwards
        anim2.isRemovedOnCompletion = false
        self.activeBorder.layer.add(anim2, forKey: "_activeBorder")
        CATransaction.commit()
    }
    
    func performValidation(_ isValid:Bool,message:String){
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
            switch self.validationType!{
            case .Email:
                let isValid = self.emailValidationBlock(self.text!, &message)
                performValidation(isValid,message: message)
            case .Integer:
                let isValid = self.integerValidationBlock(self.text!, &message)
                performValidation(isValid,message: message)
            case .Decimal:
                let isValid = self.decimalValidationBlock(self.text!, &message)
                performValidation(isValid,message: message)
            case .PhoneNumber:
                let isValid = self.phoneNumberValidationBlock(self.text!, &message)
                performValidation(isValid,message: message)
            case .WebURL:
                let isValid = self.urlValidationBlock( self.text!,  &message)
                performValidation(isValid,message: message)
            default:
                break
            }
        }
    }
}

