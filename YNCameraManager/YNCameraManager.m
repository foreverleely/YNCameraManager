//
//  YNCameraManager.m
//  YNCameraManager
//
//  Created by liyangly on 2019/2/15.
//  Copyright © 2019 liyang. All rights reserved.
//

#import "YNCameraManager.h"


@interface YNCameraManager ()

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureDeviceInput *input;

@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) BOOL isSessionRunning;

@end

@implementation YNCameraManager

+ (YNCameraManager *)share {
    static YNCameraManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YNCameraManager new];
    });
    return manager;
}

#pragma mark - Config

- (void)configCameraWith:(UIViewController *)vc andSetLayer:(YNCameraLayoutBlock)layerBlock {
    
    if ([self canUserCamearWith:vc]) {
        [self configOutPut];
        [self configSession];
        [self configLayer];
        layerBlock(self.previewLayer);
    }
    
}

- (void)configOutPut {
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureMetadataOutput alloc]init];
    
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
}

- (void)configSession {
    
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    
    self.isSessionRunning = NO;
}

- (void)configLayer {
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
//    self.previewLayer.frame = CGRectMake(0, 0, 100, 100);
//    self.previewLayer.cornerRadius = 50;
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:self.previewLayer];
}

#pragma mark - Action

- (void)sessionStart {
    
    if (!self.session) {
        return;
    }

    [self.session startRunning];
    self.isSessionRunning = YES;
    
    if (!self.device) {
        return;
    }
    if ([_device lockForConfiguration:nil]) {
        // Flash Auto
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        // WhiteBalance Auto
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

- (void)sessionStop {
    
    if (self.session) {
        [self.session stopRunning];
        self.isSessionRunning = NO;
    }
}

// Take Photo
- (void)cameraBtnClick:(YNCamerClickaBlock)complete {
    
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    __weak typeof(self) weakself = self;
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        complete(imageData);
        
        __strong typeof(self) strongself = weakself;
        [strongself.session stopRunning];
        strongself.isSessionRunning = NO;
    }];
}

// Change Camera
- (void)changeCamera {
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
        
    }
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (BOOL)canUserCamearWith:(UIViewController *)vc {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        
        NSDictionary *tempInfoDict = [[NSBundle mainBundle] infoDictionary];
        
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"We Would Like to Access Your Camera" message:[tempInfoDict objectForKey:@"NSCameraUsageDescription"] preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Enable" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }]];
        [vc presentViewController:alertCtrl animated:YES completion:nil];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

@end
