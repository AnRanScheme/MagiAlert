//
//  XDRecorder.h
//  transcoding(MP3)
//
//  Created by xindong on 16/11/12.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateValueDelegate <NSObject>

- (void)updateTextValue:(NSString *)text;

@end

@interface XDRecorder : NSObject

@property (nonatomic, weak) id<UpdateValueDelegate>delegate;

+ (XDRecorder *)sharedRecorder;

//开始录音, autoTranscoding 设置为YES则边录边转码
+ (void)starRecordingWithAutoTranscoding:(BOOL)autoTranscoding;

+ (void)stopRecording;

//录音结束后, 一次性转码
+ (void)transcodingToMP3;

@end
