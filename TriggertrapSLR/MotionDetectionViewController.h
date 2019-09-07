//
//  MotionDetectionViewController.h
//  TriggertrapSLR
//
//  Created by Ross Gibson on 17/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#if !TARGET_OS_MACCATALYST
#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class MotionDetectionViewController;

@protocol MotionDelegate <NSObject>

@required

- (void)motionDetected:(BOOL)detected;

@end

@interface MotionDetectionViewController : UIViewController <GPUImageVideoCameraDelegate> {
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
//    UIView *boundsView;
}

@property (weak) IBOutlet UISlider *slider;
@property (weak) IBOutlet UIButton *rotationButton;
@property (nonatomic, weak) id <MotionDelegate> delegate;

@end

#endif
