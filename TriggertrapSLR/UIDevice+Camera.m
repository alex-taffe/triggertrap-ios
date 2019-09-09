//
//  UIDevice+Camera.m
//  TTLibrary
//
//  Created by Ross Gibson on 27/01/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import "UIDevice+Camera.h"

@implementation UIDevice (Camera)

- (BOOL)hasCamera {
    return ([self hasRearCamera] || [self hasFrontCamera]);
}

- (BOOL)hasFrontCamera {
    return  [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)hasRearCamera {
    return  [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear];
}

@end
