//
//  TTVolumeLevelChecker.m
//  AppKitGlue
//
//  Created by Alex Taffe on 10/23/19.
//  Copyright © 2019 Triggertrap Limited. All rights reserved.
//
@import CoreAudio;
@import CoreAudioTypes;
@import AudioToolbox;
#import "TTVolumeLevelChecker.h"

@implementation TTVolumeLevelChecker


+(float)defaultVolumeOutputLevel {
    return [[self class] volume] * (![[self class] mute]);
}

+(AudioDeviceID)defaultOutputDeviceID{
    AudioDeviceID   outputDeviceID = kAudioObjectUnknown;
    // get output device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA))
    {
        NSLog(@"Cannot find default output device!");
        return outputDeviceID;
    }
    propertySize = sizeof(AudioDeviceID);
    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID);
    if(status)
    {
        NSLog(@"Cannot find default output device!");
    }
    return outputDeviceID;
}

+(float)volume
{
    Float32         outputVolume;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    propertySize = sizeof(Float32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    if (outputVolume < 0.0 || outputVolume > 1.0) return 0.0;
    return outputVolume;
}

+(bool)mute
{
    UInt32 mute;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [[self class] defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    propertySize = sizeof(UInt32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute);
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    return mute;
}

@end
