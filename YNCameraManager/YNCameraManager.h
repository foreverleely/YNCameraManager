//
//  YNCameraManager.h
//  YNCameraManager
//
//  Created by liyangly on 2019/2/15.
//  Copyright © 2019 liyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void(^YNCameraLayoutBlock)(AVCaptureVideoPreviewLayer *previewLayer);
typedef void(^YNCamerClickaBlock)(NSData *imgData);

NS_ASSUME_NONNULL_BEGIN

@interface YNCameraManager : NSObject

@property (nonatomic, assign, readonly) BOOL isSessionRunning;

+ (YNCameraManager *)share;

- (void)configCameraWith:(UIViewController *)vc andSetLayer:(YNCameraLayoutBlock)layerBlock;

- (void)sessionStart;

- (void)sessionStop;

- (void)cameraBtnClick:(YNCamerClickaBlock)complete;

- (void)changeCamera;

@end

NS_ASSUME_NONNULL_END
