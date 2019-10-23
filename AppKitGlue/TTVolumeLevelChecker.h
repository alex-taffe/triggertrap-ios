//
//  TTVolumeLevelChecker.h
//  AppKitGlue
//
//  Created by Alex Taffe on 10/23/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVolumeLevelChecker : NSObject


/// Finds the current volume level for the system for the default output
/// Return: the system volume level, -1 if there was an error
+(Float32)defaultVolumeOutputLevel;

@end

NS_ASSUME_NONNULL_END
