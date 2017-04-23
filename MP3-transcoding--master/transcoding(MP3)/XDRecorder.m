//
//  XDRecorder.m
//  transcoding(MP3)
//
//  Created by xindong on 16/11/12.
//  Copyright © 2016年 xindong. All rights reserved.
//
// lame download:    http://lame.sourceforge.net/download.php
// lame buildScript: https://github.com/kewlbear/lame-ios-build.git

#import "XDRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

// 采样率
typedef NS_ENUM(NSInteger, AudioSample) {
    AudioSampleRateLow = 8000,
    AudioSampleRateMedium = 44100, //音频CD采样率
    AudioSampleRateHigh = 96000
};


@interface XDRecorder () {
    BOOL isStopRecording;
}

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSString *originalDataPath;
@property (nonatomic, strong) NSString *mp3DataPath;

@end

@implementation XDRecorder

static inline NSString* GetAudioDirectoryPathWithAudioName(NSString *audioName) {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *directoryPath = [path stringByAppendingPathComponent:@"com.xindong.audio"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isCreateSuccess = [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (isCreateSuccess) return [directoryPath stringByAppendingPathComponent:audioName];
    return nil;
}

- (NSString *)originalDataPath {
    if (!_originalDataPath) {
        _originalDataPath = GetAudioDirectoryPathWithAudioName(@"originalAudio");
    }
    return _originalDataPath;
}

- (NSString *)mp3DataPath {
    if (!_mp3DataPath) {
        _mp3DataPath = GetAudioDirectoryPathWithAudioName(@"translatedAudio.mp3");
    }
    return _mp3DataPath;
}

+ (XDRecorder *)sharedRecorder {
    static XDRecorder *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [[self alloc] init];
        [recorder configureSession];
        [recorder configureRecorder];
    });
    return recorder;
}

- (void)configureSession {
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [_audioSession setActive:YES error:nil];
    [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

- (void)configureRecorder {
    _settings = [NSMutableDictionary dictionary];
    [_settings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [_settings setObject:@(AudioSampleRateMedium) forKey:AVSampleRateKey];
    [_settings setObject:@(2) forKey:AVNumberOfChannelsKey]; //双声道
    [_settings setValue:@(16) forKey:AVLinearPCMBitDepthKey];
    [_settings setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
}

+ (void)starRecordingWithAutoTranscoding:(BOOL)autoTranscoding {
    NSError *error = nil;
    XDRecorder *_self = [XDRecorder sharedRecorder];
    _self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_self.originalDataPath] settings:_self.settings error:&error];
    _self.recorder.meteringEnabled = YES;
    [_self.recorder prepareToRecord];
    BOOL isRecordSuccess = [_self.recorder record];
    if (isRecordSuccess) {
        NSString *textValue = [NSString stringWithFormat:@"开始录音：%@", _self.originalDataPath];
        NSLog(@"%@", textValue);
        [_self excuteDelegateMethod:@"正在录音..."];
        if (autoTranscoding) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_self transcodingWhileRecording];
            });            
        }
    }
    else {
        NSLog(@"录音失败：%@", error);
        [_self excuteDelegateMethod:@"录音失败"];
    }
}

+ (void)stopRecording {
    XDRecorder *_self = [XDRecorder sharedRecorder];
    [_self.recorder stop];
    _self.recorder = nil;
    _self->isStopRecording = YES;
    [_self excuteDelegateMethod:@"录音结束"];
}

+ (void)transcodingToMP3 {
    [[XDRecorder sharedRecorder] startTranscoding];
}


// 边录边转码(要在子线中进行)
- (void)transcodingWhileRecording {
    @try {
        int read, write;
        
        FILE *pcm = fopen([self.originalDataPath cStringUsingEncoding:1], "rb");//source
        fseek(pcm, 4*1024, SEEK_CUR);                                           //skip file header
        FILE *mp3 = fopen([self.mp3DataPath cStringUsingEncoding:1], "wb");     //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, AudioSampleRateMedium);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long currentPosition;
        do {
            currentPosition = ftell(pcm);     //文件读到当前位置
            long startPosition = ftell(pcm);  //起始点
            fseek(pcm, 0, SEEK_END);          //将文件指针指向结束位置,为了获取结束点
            long endPosition = ftell(pcm);    //结束点
            long length = endPosition - startPosition; //获得文件长度
            fseek(pcm, currentPosition, SEEK_SET);//再将文件指针复位
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                NSLog(@"转码中...");
            }
            else {
                //让当前线程睡眠一小会,等待音频数据增加时,再继续转码
                [NSThread sleepForTimeInterval:0.02];
                NSLog(@"等待中...");
            }
            
        } while (!isStopRecording);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSString *textValue = [NSString stringWithFormat:@"转换成功：%@", self.mp3DataPath];
        NSLog(@"%@", textValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self excuteDelegateMethod:@"转码成功"];
        });
    }

}


// 录音结束后一次性转码
- (void)startTranscoding {
    @try {
        int read, write;
        
        FILE *pcm = fopen([self.originalDataPath cStringUsingEncoding:1], "rb");//source
        fseek(pcm, 4*1024, SEEK_CUR);                                           //skip file header
        FILE *mp3 = fopen([self.mp3DataPath cStringUsingEncoding:1], "wb");     //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, AudioSampleRateMedium);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSString *textValue = [NSString stringWithFormat:@"转换成功：%@", self.mp3DataPath];
        NSLog(@"%@", textValue);
        [self excuteDelegateMethod:@"转码成功"];
    }
}


- (void)excuteDelegateMethod:(NSString *)textValue {
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateTextValue:)]) {
        [self.delegate updateTextValue:textValue];
    }
}


@end
