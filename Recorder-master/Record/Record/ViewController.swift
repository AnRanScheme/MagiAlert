//
//  ViewController.swift
//  Record
//
//  Created by yebaojia on 16/3/19.
//  Copyright © 2016年 mjia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // 使用 先录音 然后在停止录音，然后才播放
    override func viewDidLoad() {
        super.viewDidLoad()
        let recordBtn  = UIButton.init(frame: CGRect(x: 20,
                                                     y: 40,
                                                     width: 100,
                                                     height: 100))
        recordBtn.backgroundColor = UIColor.black
        recordBtn.setTitle("record", for: UIControlState())
        recordBtn.addTarget(self,
                            action: #selector(ViewController.startRecord),
                            for: UIControlEvents.touchUpInside)
        self.view.addSubview(recordBtn)
        let stopRecordBtn = UIButton.init(frame: CGRect(x: 20,
                                                        y: 150,
                                                        width: 100,
                                                        height: 100))
        stopRecordBtn.setTitle("stopRecord", for: UIControlState())
        stopRecordBtn.addTarget(self,
                                action: #selector(ViewController.stopRecord),
                                for: UIControlEvents.touchUpInside)
        self.view.addSubview(stopRecordBtn)
        stopRecordBtn.backgroundColor = UIColor.black
        let playBtn = UIButton.init(frame: CGRect(x: 20,
                                                  y: 260,
                                                  width: 100,
                                                  height: 100))
        playBtn.setTitle("play", for: UIControlState())
        playBtn.addTarget(self,
                          action: #selector(ViewController.playRecord),
                          for: UIControlEvents.touchUpInside)
        self.view.addSubview(playBtn)
        playBtn.backgroundColor = UIColor.black
        let stopPlayBtn = UIButton.init(frame: CGRect(x: 20,
                                                      y: 370,
                                                      width: 100,
                                                      height: 100))
        stopPlayBtn.setTitle("stopPlay", for: UIControlState())
        stopRecordBtn.addTarget(self,
                                action: #selector(ViewController.stopPlay),
                                for: UIControlEvents.touchUpInside)
        self.view.addSubview(stopPlayBtn)
        stopPlayBtn.backgroundColor = UIColor.black
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func startRecord(){
        RecorderTool.getTool().startRecord()
    }
    
    func stopRecord(){
        RecorderTool.getTool().stopRecord()
        RecorderTool.getTool().saveRecord()
    }
    
    func playRecord(){
        let userdefault = UserDefaults.standard
        var arr = [[String : String]]()
        if let a = userdefault.object(forKey: "audio")
        {
            arr = a as! [[String : String]]
            //获取最后一首录音
            var dict = arr[arr.count - 1]
            RecorderTool.getTool().playRecord(dict["path"]!)
        }
    }
    func stopPlay(){
        let userdefault = UserDefaults.standard
        var arr = [[String : String]]()
        if let a = userdefault.object(forKey: "audio")
        {
            arr = a as! [[String : String]]
            //获取最后一首录音
            var dict = arr[arr.count - 1]
            RecorderTool.getTool().stopPlayRecord(dict["path"]!);
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

