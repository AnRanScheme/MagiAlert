//
//  TranscodingMp3.h
//  transcoding(MP3)
//
//  Created by 安然 on 2017/4/24.
//  Copyright © 2017年 xindong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateValueDelegate <NSObject>

- (void)updateTextValue:(NSString *)text;

@end

@interface TranscodingMp3 : NSObject

@property (nonatomic, weak) id<UpdateValueDelegate>delegate;

+ (TranscodingMp3 *)sharedTranscoding;

- (void)transcoding:(NSString *)autoPath toMP3:(NSString *)mp3Path;

@end
