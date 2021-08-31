#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMediaIO/CMIOHardwareObject.h>
#import <CoreAudio/CoreAudio.h>

OSStatus AddCameraListener(AVCaptureDevice* camera) {
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
    return CMIOObjectAddPropertyListenerBlock(connectionID, &propertyAddress, dispatch_get_main_queue(), listenerBlock);
}

OSStatus RemoveCameraListener(AVCaptureDevice* camera) {
    OSStatus status = 0;
    return status;
}

OSStatus AddMicListener(AVCaptureDevice* mic) {
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
    return AudioObjectAddPropertyListenerBlock(connectionID, &propertyAddress, dispatch_get_main_queue(), listenerBlock);
}

OSStatus RemoveMicListener(AVCaptureDevice* mic) {
    OSStatus status = 0;
    return status;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        for(AVCaptureDevice* camera in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
        {
            NSLog(@"Camera found: %s - %s\n",
                [camera.manufacturer UTF8String],
                [camera.localizedName UTF8String]
            );
            AddCameraListener(camera);
        }

        for(AVCaptureDevice* mic in [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio])
        {
            NSLog(@"Mic found: %s - %s\n",
                [mic.manufacturer UTF8String],
                [mic.localizedName UTF8String]
            );
            AddMicListener(mic);
        }

        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureDeviceWasConnectedNotification
            object:nil
            queue:[NSOperationQueue mainQueue]
            usingBlock:^(NSNotification *notification)
                {
                    AVCaptureDevice* device = [notification object];
                    if ([device hasMediaType:AVMediaTypeVideo]) {
                        NSLog(@"Camera connected: %s - %s\n",
                            [device.manufacturer UTF8String],
                            [device.localizedName UTF8String]
                        );
                        AddCameraListener(device);
                    }
                    if ([device hasMediaType:AVMediaTypeAudio]) {
                        NSLog(@"Mic connected: %s - %s\n",
                            [device.manufacturer UTF8String],
                            [device.localizedName UTF8String]
                        );
                        AddMicListener(device);
                    }
                }
        ];
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureDeviceWasDisconnectedNotification
            object:nil
            queue:[NSOperationQueue mainQueue]
            usingBlock:^(NSNotification *notification)
                {
                    AVCaptureDevice* device = [notification object];
                    if ([device hasMediaType:AVMediaTypeVideo]) {
                        NSLog(@"Camera disconected: %s - %s\n",
                            [device.manufacturer UTF8String],
                            [device.localizedName UTF8String]
                        );
                        RemoveCameraListener(device);
                    }
                    if ([device hasMediaType:AVMediaTypeAudio]) {
                        NSLog(@"Mic disconected: %s - %s\n",
                            [device.manufacturer UTF8String],
                            [device.localizedName UTF8String]
                        );
                        RemoveMicListener(device);
                    }
                }
        ];

        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
