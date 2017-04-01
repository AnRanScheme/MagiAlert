//
//  ViewController.swift
//  MagiAlert
//
//  Created by 安然 on 2017/4/1.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tanChu(_ sender: UIButton) {
        
        MagiAlert().showAlert("选择支付方式",
                              price: "¥1.00",
                              content: "可用余额12.5元",
                              buttonTitle: "取消",
                              otherButtonTitle: "确认支付") { (sender) -> Void in
                                print("执行了确认")
        }
    }


}

