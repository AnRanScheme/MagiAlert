//
//  MagiAlert.swift
//  ZuberAlert
//
//  Created by 安然 on 2017/3/31.
//  Copyright © 2017年 duzhe. All rights reserved.
//

import UIKit
let Magi_SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.size.width
let Magi_SCREEN_HEIGHT:CGFloat = UIScreen.main.bounds.size.height
let Magi_MAIN_COLOR = UIColor(red: 52/255.0, green: 197/255.0, blue: 170/255.0, alpha: 1.0)
class MagiAlert: UIViewController {

    let kBackgroundTansperancy: CGFloat = 0.7
    let kHeightMargin: CGFloat = 10.0
    let KTopMargin: CGFloat = 10.0
    let kWidthMargin: CGFloat = 10.0
    let kAnimatedViewHeight: CGFloat = 70.0
    let kMaxHeight: CGFloat = 300.0
    var kContentWidth: CGFloat = 300.0
    let kButtonHeight: CGFloat = 35.0
    var textViewHeight: CGFloat = 90.0
    let kTitleHeight:CGFloat = 20.0
    var contentView = UIView()
    let kLineViewHeight: CGFloat = 1.0 / UIScreen.main.scale
    var lineView = UIView()
    var titleLabel: UILabel = UILabel()
    var cancelLabel = UILabel()
    var priceLabel = UILabel()
    var tipLabel = UILabel()
    var contentLabel = UILabel()
    var subTitleTextView = UITextView()
    var buttons: [UIButton] = []
    var strongSelf:MagiAlert?
    var userAction:((_ button: UIButton) -> Void)? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = UIScreen.main.bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.3)
        self.view.addSubview(contentView)
        //强引用 不然按钮点击不能执行
        strongSelf = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -初始化
    fileprivate func setupContentView() {
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(tipLabel)
        contentView.addSubview(contentLabel)
        contentView.backgroundColor = UIColor(hex: 0xFFFFFF)
        contentView.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
        view.addSubview(contentView)
    }
    
    
    fileprivate func setupTitleLabel() {
        titleLabel.text = ""
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Helvetica", size:14)
        titleLabel.textColor = UIColor(hex: 0x575757)
        titleLabel.sizeToFit()
    }
    
    fileprivate func setupCancelLabel() {
        cancelLabel.text = "取消"
        cancelLabel.numberOfLines = 1
        cancelLabel.textAlignment = .right
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.font = UIFont(name: "Helvetica", size:14)
        cancelLabel.textColor = UIColor.red
    }
    
    fileprivate func setuplineView() {
        lineView.backgroundColor = UIColor.red
    }
    
    fileprivate func setupPriceLabel() {
        priceLabel.text = ""
        priceLabel.numberOfLines = 1
        priceLabel.textAlignment = .center
        priceLabel.font = UIFont(name: "Helvetica", size:18)
        priceLabel.textColor = UIColor.orange
    }
    
    fileprivate func setupTipLabel() {
        tipLabel.text = "支付方式: 账户余额"
        tipLabel.numberOfLines = 1
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont(name: "Helvetica", size:16)
        tipLabel.textColor = UIColor(hex: 0x575757)
    }
    
    fileprivate func setupContentLabel() {
        contentLabel.text = ""
        contentLabel.numberOfLines = 1
        contentLabel.textAlignment = .center
        contentLabel.font = UIFont(name: "Helvetica", size:14)
        contentLabel.textColor = UIColor(hex: 0x575757)
    }
    
    //MARK: - 布局
    fileprivate func resizeAndRelayout() {
        let mainScreenBounds = UIScreen.main.bounds
        self.view.frame.size = mainScreenBounds.size
        let x: CGFloat = kWidthMargin + 40
        var y: CGFloat = KTopMargin
        let width: CGFloat = kContentWidth - (kWidthMargin * 2) - 80
        
        // Title
        if self.titleLabel.text != nil {
            titleLabel.frame = CGRect(x: x,
                                      y: y,
                                      width: width,
                                      height: kTitleHeight)
            contentView.addSubview(titleLabel)
            y += kTitleHeight + kHeightMargin
        }
        
        // cancelLabel
        cancelLabel.frame = CGRect(x: kContentWidth - kWidthMargin - 60,
                                   y: KTopMargin,
                                   width: 60,
                                   height: kTitleHeight)
        contentView.addSubview(cancelLabel)
        
        // LineView
        
        lineView.frame = CGRect(x: 0,
                                y: y,
                                width: kContentWidth,
                                height: kLineViewHeight)
        contentView.addSubview(lineView)
        y += kLineViewHeight + kHeightMargin
        
        // priceLabel
        
        priceLabel.frame = CGRect(x: kWidthMargin,
                                  y: y,
                                  width: kContentWidth - (kWidthMargin * 2),
                                  height: 30)
        contentView.addSubview(priceLabel)
        y = priceLabel.frame.maxY + kHeightMargin

        // tipLabel
        
        tipLabel.frame = CGRect(x: kWidthMargin,
                                y: y,
                                width: kContentWidth - (kWidthMargin * 2),
                                height: 30)
        contentView.addSubview(tipLabel)
        y = tipLabel.frame.maxY
        
        // contentLabel
        
        contentLabel.frame = CGRect(x: kWidthMargin,
                                    y: y,
                                    width: kContentWidth - (kWidthMargin * 2),
                                    height: 20)
        contentView.addSubview(contentLabel)
        y = contentLabel.frame.maxY + kHeightMargin
        
        var buttonRect:[CGRect] = []
        for button in buttons {
            let string = button.title(for: UIControlState())! as NSString
            buttonRect.append(string.boundingRect(with: CGSize(width: width, height:0.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:[NSFontAttributeName:button.titleLabel!.font], context:nil))
        }
        
        var totalWidth: CGFloat = 0.0
        if buttons.count == 2 {
            totalWidth = buttonRect[0].size.width + buttonRect[1].size.width + kWidthMargin + 40.0
        } else {
            totalWidth = buttonRect[0].size.width + 20.0
        }
        y += kHeightMargin
        var buttonX = (kContentWidth - totalWidth ) / 2.0
        for i in 0 ..< buttons.count {
            
            buttons[i].frame = CGRect(x: buttonX, y: y, width: buttonRect[i].size.width + 20.0, height: buttonRect[i].size.height + 10.0)
            buttonX = buttons[i].frame.origin.x + kWidthMargin + buttonRect[i].size.width + 20.0
            buttons[i].layer.cornerRadius = 5.0
            self.contentView.addSubview(buttons[i])
            
        }
        y += kHeightMargin + buttonRect[0].size.height + 10.0
        if y > kMaxHeight {
            let diff = y - kMaxHeight
            let sFrame = subTitleTextView.frame
            subTitleTextView.frame = CGRect(x: sFrame.origin.x,
                                            y: sFrame.origin.y,
                                            width: sFrame.width,
                                            height: sFrame.height - diff)
            
            for button in buttons {
                let bFrame = button.frame
                button.frame = CGRect(x: bFrame.origin.x,
                                      y: bFrame.origin.y - diff,
                                      width: bFrame.width,
                                      height: bFrame.height)
            }
            
            y = kMaxHeight
        }
        
        contentView.frame = CGRect(x: (mainScreenBounds.size.width - kContentWidth) / 2.0,
                                   y: (mainScreenBounds.size.height - y) / 2.0,
                                   width: kContentWidth,
                                   height: y + 20)
        contentView.clipsToBounds = true
        
        //进入时的动画
        contentView.transform = CGAffineTransform(translationX: 0,
                                                  y: -Magi_SCREEN_HEIGHT/2)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

}

extension MagiAlert{
    
    //MARK: -alert 方法主体
    func showAlert(_ title: String, price: String?, content: String?, buttonTitle: String ,otherButtonTitle:String?,action:@escaping ((_ OtherButton: UIButton) -> Void)) {
        userAction = action
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.addSubview(view)
        window.bringSubview(toFront: view)
        view.frame = window.bounds
        self.setupContentView()
        self.setupTitleLabel()
        self.setupCancelLabel()
        self.setuplineView()
        self.setupPriceLabel()
        self.setupTipLabel()
        self.setupContentLabel()
        self.titleLabel.text = title
        if price != nil {
            self.priceLabel.text = price
        }
        if content != nil {
            self.contentLabel.text = content
        }
        
        let tapGR1 = UITapGestureRecognizer(target: self, action: #selector(MagiAlert.doCancel(_:)))
        self.cancelLabel.addGestureRecognizer(tapGR1)
        
        buttons = []
        if buttonTitle.isEmpty == false {
            let button: UIButton = UIButton()
            button.setTitle(buttonTitle, for: UIControlState())
            button.backgroundColor = Magi_MAIN_COLOR
            button.isUserInteractionEnabled = true
            button.addTarget(self, action: #selector(MagiAlert.doCancel(_:)), for: UIControlEvents.touchUpInside)
            button.tag = 0
            buttons.append(button)
        }
        
        if otherButtonTitle != nil && otherButtonTitle!.isEmpty == false {
            let button: UIButton = UIButton(type: UIButtonType.custom)
            button.setTitle(otherButtonTitle, for: UIControlState())
            button.backgroundColor = UIColor.orange
            button.addTarget(self, action: #selector(MagiAlert.pressed(_:)), for: UIControlEvents.touchUpInside)
            
            button.tag = 1
            buttons.append(button)
        }
        resizeAndRelayout()
    }
    
    //MARK: -取消
    func doCancel(_ sender:UIButton){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.view.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0,
                                                           y: Magi_SCREEN_HEIGHT)
            
        }) { (Bool) -> Void in
            self.view.removeFromSuperview()
            self.cleanUpAlert()
            self.strongSelf = nil
        }
    }
    
    fileprivate func cleanUpAlert() {
        self.contentView.removeFromSuperview()
        self.contentView = UIView()
    }
    func pressed(_ sender: UIButton!) {
        if userAction !=  nil {
            userAction!(sender)
        }
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF
        let a = 0xFF
        
        self.init(red: CGFloat(r) / 0xFF,  green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: CGFloat(a) / 0xFF)
        
    }
    
    convenience init(hexString: String) {
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        
    }
    
}

