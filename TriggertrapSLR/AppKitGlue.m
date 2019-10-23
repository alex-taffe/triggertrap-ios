//
//  AppKitGlue.m
//  TriggertrapSLR Mac
//
//  Created by Alex Taffe on 10/23/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//

#import "AppKitGlue.h"

@implementation AppKitGlue

+(Float32)defaultVolumeOutputLevel {

    NSString *pluginPath = [NSBundle.mainBundle.builtInPlugInsPath stringByAppendingPathComponent:@"AppKitGlue.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:pluginPath];
    [bundle load];

    id volumeChecker = [bundle classNamed:@"TTVolumeLevelChecker"];
    return [volumeChecker defaultVolumeOutputLevel];

}

@end
