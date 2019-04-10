//
//  MotionDetectionViewController.h
//  TriggertrapSLR
//
//  Created by Ross Gibson on 17/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import "MotionDetectionViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIDevice+Camera.h"

@interface MotionDetectionViewController()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewBottomSpacing;
@property (nonatomic) float zoomGestureCurrentZoom;
@property (nonatomic) float zoomGestureLastScale;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@end

@implementation MotionDetectionViewController { 
}

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.zoomGestureCurrentZoom = 0.5;
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];

    if (![[UIDevice currentDevice] hasFrontCamera] || ![[UIDevice currentDevice] hasRearCamera]) {
        _rotationButton.hidden = YES;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        
        self.viewBottomSpacing.constant += bottomPadding;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupFilter];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    videoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Note: We need to stop camera capture before the view goes off the screen
    // in order to prevent a crash from the camera still sending frames.
    [videoCamera stopCameraCapture];
}

#pragma mark - Actions

- (IBAction)rotateCameraTapped:(id)sender {
    [videoCamera rotateCamera];
}

- (IBAction)updatedFilterFromSlider:(id)sender {
    [videoCamera resetBenchmarkAverage];
    [(GPUImageMotionDetector *)motionFilter setLowPassFilterStrength:[(UISlider *)sender value]];
}

#pragma mark - Private

- (void)setupFilter; {
    
    // By default show the back camera, otherwise show the front facing camera
    if ([[UIDevice currentDevice] hasRearCamera]) {
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition: AVCaptureDevicePositionBack];
    } else {
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition: AVCaptureDevicePositionFront];
    }
    
    videoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Force the front facing camera to show the image the same way as the standard iPhone camera
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;

    //create both the motion and zoom filters
    motionFilter = [[GPUImageMotionDetector alloc] init];
    zoomFilter = [[GPUImageCropFilter alloc] init];

    //route first through the zoom filter, then through the motion filter
    [videoCamera addTarget:zoomFilter];
    [zoomFilter addTarget:motionFilter];

    //set zoom to 1x by default
    [zoomFilter setCropRegion:CGRectMake(0,0,1,1)];

    //create the image view
    GPUImageView *filterView = (GPUImageView *)self.view;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    //route only the zoom filter to the view, we don't need to see motion
    [zoomFilter addTarget:filterView];
    
    __unsafe_unretained MotionDetectionViewController *weakSelf = self;
    
    [(GPUImageMotionDetector *) motionFilter setMotionDetectionBlock:^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(motionDetected:)]) {
                [weakSelf.delegate motionDetected:true];
            }
        });
    }];

    //add the zoom gesture recognizer
    [filterView addGestureRecognizer:self.pinchRecognizer];

    [videoCamera startCameraCapture];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the last scale
        self.zoomGestureLastScale = gestureRecognizer.scale;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // we have to jump through some hoops to clamp the scale in a way that makes the UX intuitive
        float scaleDeltaFactor = gestureRecognizer.scale/self.zoomGestureLastScale;
        float currentZoom = self.zoomGestureCurrentZoom;
        float newZoom = currentZoom * scaleDeltaFactor;
        // clamp to a min max
        float kMaxZoom = 1.5;
        float kMinZoom = 0.5;
        newZoom = MAX(kMinZoom,MIN(newZoom,kMaxZoom));

        // store for next time
        self.zoomGestureCurrentZoom = newZoom;
        self.zoomGestureLastScale = gestureRecognizer.scale;

        //we can't clamp to 0-1 so we do 0.5-1.5 and subtract 0.5 later
        newZoom -= 0.5;

        //center the crop region with the desired region and limit to a 0.9 scale factor
        if(newZoom <= 0.9){
            __unsafe_unretained MotionDetectionViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf->zoomFilter setCropRegion:CGRectMake(newZoom / 2, newZoom / 2, 1 - newZoom, 1 - newZoom)];
            });
        }

    }
}

@end
