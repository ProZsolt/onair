#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMediaIO/CMIOHardwareObject.h>
#import <CoreAudio/CoreAudio.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        for(AVCaptureDevice* camera in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
        {
            NSLog(@"Camera found: %s - %s\n",
                [camera.manufacturer UTF8String],
                [camera.localizedName UTF8String]
            );
            UInt32 connectionID = (UInt32) [camera performSelector:NSSelectorFromString(@"connectionID") withObject:nil];
            CMIOObjectPropertyAddress propertyAddress = {
                .mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere,
                .mScope = kAudioObjectPropertyScopeGlobal,
                .mElement = kAudioObjectPropertyElementMaster,
            };
            CMIOObjectPropertyListenerBlock listenerBlock =
            ^(UInt32 inNumberAddresses, const CMIOObjectPropertyAddress addresses[])
            {
                UInt32 isActive = -1;
                UInt32 isActiveSize = sizeof(isActive);
                CMIOObjectPropertyAddress propertyAddress = {
                    .mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere,
                    .mScope = kAudioObjectPropertyScopeGlobal,
                    .mElement = kAudioObjectPropertyElementMaster,
                };
                CMIOObjectGetPropertyData(connectionID, &propertyAddress, 0, NULL, sizeof(kAudioDevicePropertyDeviceIsRunningSomewhere), &isActiveSize, &isActive);
                if(isActive == YES)
                {
                    NSLog(@"Camera active\n");
                } else {
                    NSLog(@"Camera inactive\n");
                }

            };
            CMIOObjectAddPropertyListenerBlock(connectionID, &propertyAddress, dispatch_get_main_queue(), listenerBlock);
        }

        for(AVCaptureDevice* mic in [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio])
        {
            NSLog(@"Mic found: %s - %s\n",
                [mic.manufacturer UTF8String],
                [mic.localizedName UTF8String]
            );
            UInt32 connectionID = (UInt32) [mic performSelector:NSSelectorFromString(@"connectionID") withObject:nil];
            AudioObjectPropertyAddress propertyAddress = {
                .mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere,
                .mScope = kAudioObjectPropertyScopeGlobal,
                .mElement = kAudioObjectPropertyElementMaster,
            };
            AudioObjectPropertyListenerBlock listenerBlock =
            ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress addresses[])
            {
                UInt32 isActive = -1;
                UInt32 isActiveSize = sizeof(isActive);
                AudioObjectPropertyAddress propertyAddress = {
                    .mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere,
                    .mScope = kAudioObjectPropertyScopeGlobal,
                    .mElement = kAudioObjectPropertyElementMaster,
                };
                AudioObjectGetPropertyData(connectionID, &propertyAddress, 0, NULL, &isActiveSize, &isActive);
                if(isActive == YES)
                {
                    NSLog(@"Mic active\n");
                } else {
                    NSLog(@"Mic inactive\n");
                }

            };
            AudioObjectAddPropertyListenerBlock(connectionID, &propertyAddress, dispatch_get_main_queue(), listenerBlock);
        }

        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
