//
//  ViewController.m
//  YNCameraManager
//
//  Created by liyangly on 2019/2/1.
//  Copyright © 2019 liyang. All rights reserved.
//

#import "ViewController.h"
#import "YNCameraManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect rect = [[UIScreen mainScreen] bounds];
    [[YNCameraManager share] configCameraWith:self andSetLayer:^(AVCaptureVideoPreviewLayer *previewLayer) {
        previewLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        previewLayer.backgroundColor = UIColor.whiteColor.CGColor;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:previewLayer];
    }];
    [[YNCameraManager share] sessionStart];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.backgroundColor = UIColor.redColor;
    startBtn.frame = CGRectMake(0, 0, 48, 48);
    startBtn.layer.cornerRadius = 24;
    startBtn.center = CGPointMake(self.view.center.x, rect.size.height - 44);
    [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.backgroundColor = UIColor.yellowColor;
    changeBtn.frame = CGRectMake(0, 0, 48, 48);
    changeBtn.layer.cornerRadius = 24;
    changeBtn.center = CGPointMake(self.view.center.x + 96, rect.size.height - 44);
    [changeBtn addTarget:self action:@selector(changeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];
    
     
}

- (void)startBtnClick {
    // if session is running, take photo; else restart session
    if ([YNCameraManager share].isSessionRunning) {
        [[YNCameraManager share] cameraBtnClick:^(NSData *imgData) {
            //
        }];
    } else {
        [[YNCameraManager share] sessionStart];
    }
    
}

- (void)changeBtnClick {
    // change Camera
    [[YNCameraManager share] changeCamera];
}

@end
