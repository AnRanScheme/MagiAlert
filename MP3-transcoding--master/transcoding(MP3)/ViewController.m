//
//  ViewController.m
//  transcoding(MP3)
//
//  Created by xindong on 16/11/12.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "ViewController.h"
#import "XDRecorder.h"

@interface ViewController ()<UpdateValueDelegate>
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *transcodingButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.displayLabel.text = @"准备录音";
    [[XDRecorder sharedRecorder] setDelegate:self];
    
}

#pragma mark - UpdateValueDelegate
- (void)updateTextValue:(NSString *)text {
    self.displayLabel.text = text;
}

- (IBAction)clickedRecordButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) [XDRecorder starRecordingWithAutoTranscoding:NO];
    else [XDRecorder stopRecording];
}

- (IBAction)clickedTranscodingButton:(UIButton *)sender {
    [XDRecorder transcodingToMP3];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
