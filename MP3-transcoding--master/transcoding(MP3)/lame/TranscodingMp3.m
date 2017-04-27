//
//  TranscodingMp3.m
//  transcoding(MP3)
//
//  Created by 安然 on 2017/4/24.
//  Copyright © 2017年 xindong. All rights reserved.
//

#import "TranscodingMp3.h"
#import "lame.h"

// 采样率
typedef NS_ENUM(NSInteger, AudioSample) {
    AudioSampleRateLow = 8000,
    AudioSampleRateMedium = 44100, //音频CD采样率
    AudioSampleRateHigh = 96000
};

@implementation TranscodingMp3

+ (TranscodingMp3 *)sharedTranscoding {
    static TranscodingMp3 *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [[self alloc] init];
    });
    return recorder;
}


// 录音结束后一次性转码
- (void)transcoding:(NSString *) autoPath toMP3:(NSString *) mp3Path {
    @try {
        int read, write;
        
        FILE *pcm = fopen([autoPath cStringUsingEncoding:1], "rb");//source
        fseek(pcm, 4*1024, SEEK_CUR);                                           //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb");     //output
        
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
        NSString *textValue = [NSString stringWithFormat:@"转换成功：%@", mp3Path];
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
