//
//  RecorderTool.swift
//  Recorder
//
//  Created by yebaojia on 16/3/9.
//  Copyright © 2016年 mjia. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderTool: NSObject {
    var recorder :AVAudioRecorder?
    var player: AVAudioPlayer!
    
    var recorderSeetingDic :[String : AnyObject]? //硬件设置
    var volumeTimer:Timer! //定时器线程，循环监测录音的音量大小
    var aacPath:String? //录音存储路径
    
    var mp3Path:String? //转换录音存储路径
    
    var mp3Pathjia:String?
    
    var audioArr:[[String:String]] = [[:]] //录音信息数组
    var seconds:Float = 0   //记录录音时间
    static let tool:RecorderTool = RecorderTool()
    override init() {
        super.init()
    }
    //单例
    class func getTool() -> RecorderTool
    {
        return tool
    }
    func startRecord(){
        let  session = AVAudioSession.sharedInstance();
        //设置录音类型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true);
        }catch
        {
            print("session 设置失败")
        }
        
        //获取Document目录
        let docDir: AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask, true)[0] as AnyObject
        //组合录音文件路径
        aacPath = (docDir as! String) + "/play1.pcm"
        mp3Path = (docDir as! String) + "/play1.mp3"
        //初始化字典并添加设置参数
        recorderSeetingDic =
            [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),//声音采样率
                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM) as Int32),//编码格式
                AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),//采集音轨
                AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.low.rawValue) as Int32),
                AVLinearPCMBitDepthKey: NSNumber(value: 16 as Int32)]//音频质量
        recorder =  try! AVAudioRecorder(url: URL(string: aacPath!)!,
            settings: recorderSeetingDic!)
        
        //开启仪表计数功能
        recorder!.isMeteringEnabled = true
        //准备录音
        recorder!.prepareToRecord()
        //开始录音
        recorder!.record()
        //启动定时器，定时更新录音音量
        volumeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
            selector: #selector(RecorderTool.levelTimer), userInfo: nil, repeats: true)
        //计时
        seconds = 0
    }
    func stopRecord(){
        
        recorder?.stop()
        //录音器释放
        recorder = nil
        
        //暂停定时器
        volumeTimer.invalidate()
        volumeTimer = nil
    }
    func playRecord(_ aduioPath:String){
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true);
            player = try AVAudioPlayer(contentsOf: URL(string: aduioPath)!)
        }
        catch {
            print("播放失败")
        }
        if player == nil {
            print("播放失败")
        } else {
            player.prepareToPlay()
            player.play()
        }
    }
    func stopPlayRecord(_ aduioPath:String)
    {
        do {
            player = try AVAudioPlayer(contentsOf: URL(string: aduioPath)!)//(contentsOfURL: NSURL(string: aacPath!))
        }
        catch
        {
            print("播放失败")
        }
        if player == nil {
            print("播放失败")
        }else{
            player.stop()
        }
        
    }
    //保存文件
    func saveRecord(){
        let docDir: AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask, true)[0] as AnyObject
        //组合录音文件路径
        //
        let date : Date = Date()
        let timeInterval =  date.timeIntervalSince1970*1000
        let timeStr = String(format:"%f",timeInterval)
        let saveAacPath = (docDir as! String) + "/audio/" + timeStr + ".pcm"
        mp3Pathjia = (docDir as! String) + "/audio/" + timeStr + ".mp3"
        //
        let fileManager = FileManager.default
        //创建另存为路径
        let isDirExist = fileManager.fileExists(atPath: (docDir as! String) + "/audio")
        if !isDirExist{
            do
            {
                try fileManager.createDirectory(atPath: (docDir as! String) + "/audio", withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        
        if fileManager.fileExists(atPath: aacPath!)
        {
            
            do
            {
                try fileManager.copyItem(atPath: aacPath!, toPath: saveAacPath)
                let userDefault:UserDefaults = UserDefaults.standard
                var audioDict = [String:String]()
                var arr = [[String :String]]()
              
                if let a = userDefault.object(forKey: "audio")
                {
                    arr = a as! [[String : String]]
                }
                do{
                    let dict = try fileManager.attributesOfItem(atPath: saveAacPath)
                    let fileSize = dict[.size] as! CGFloat
                    audioDict = ["path" : saveAacPath,"second":String(seconds/10),"size":String(format: "%.2f",fileSize/(1024.0*1024.0)),"time":getTodayTime()]
                }
                catch
                {
                    audioDict = ["path" : saveAacPath,"second":String(seconds/10),"size":"0","time":getTodayTime()]
                    
                }
                
                arr += [audioDict]
                print("arr is %@",arr)
                userDefault.set(arr, forKey: "audio")
                userDefault.synchronize()
                
            }
            catch
            {
                print("复制失败")
            }
            
        }
    }
    // delete record
    func deleteRecord(_ filePath : String ){
        //删除配置
        
        let fileManager = FileManager.default
        
        do
        {
            try fileManager.removeItem(atPath: filePath)
        }
        catch
        {
            
        }
        
        
    }
    
    //定时检测录音音量
    func levelTimer(){
        recorder!.updateMeters() // 刷新音量数据
        seconds += 1
        
    }
    //获取时间
    func getTodayTime() ->String{
        let curDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd"
        return timeFormatter.string(from: curDate)
    }
    
}
