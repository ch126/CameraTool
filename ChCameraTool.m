/*
Created by Chelsea Huang on 2017/4/25.
https://github.com/ch126
*/


#import "ChCameraTool.h"

@interface ChCameraTool ()
@property (strong) AVCaptureSession *currentSession;
@property (strong) AVCaptureDevice *currentDevice;   
@end

@implementation ChCameraTool

#pragma mark - Device setting
+(instancetype)cameraWithPreviewView:(UIView*)cameraPreviewView Position:(AVCaptureDevicePosition)cameraPosition{
    
    ChCameraTool * instance = [[ChCameraTool alloc] init];
    
    instance.currentSession = [[AVCaptureSession alloc] init];
    instance.currentSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    [instance setCameraPreviewView:cameraPreviewView];
    [instance setCameraPosition:cameraPosition];
    [instance setCameraWithFPS:CAMERA_FPS];
    
    return instance;
}

-(void)setCameraPreviewView:(UIView *)cameraPreviewView{
    AVCaptureVideoPreviewLayer *previewlayer = [AVCaptureVideoPreviewLayer layerWithSession:_currentSession];
    
    previewlayer.frame = CGRectMake(0, 0, cameraPreviewView.frame.size.width, cameraPreviewView.frame.size.height);
    previewlayer.videoGravity = AVLayerVideoGravityResize;
    
    [cameraPreviewView.layer addSublayer:previewlayer];
}

-(void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == cameraPosition) {
//            device.automaticallyEnablesLowLightBoostWhenAvailable = YES;
            _currentDevice = device;
        }
    }
}

-(void)setCameraWithFPS:(float)cameraFPS{
    NSError *error;
    AVCaptureDeviceInput *deviceinput = [[AVCaptureDeviceInput alloc] initWithDevice:_currentDevice error:&error];
    
    AVCaptureVideoDataOutput *videooutput = [[AVCaptureVideoDataOutput alloc] init];
    [videooutput setAlwaysDiscardsLateVideoFrames:YES];
    [videooutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    videooutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    [_currentSession beginConfiguration];
    [_currentSession addInput:deviceinput];
    [_currentSession addOutput:videooutput];
    [_currentSession commitConfiguration];
    
    if ([_currentDevice lockForConfiguration:nil]) {
        [_currentDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, cameraFPS)];
        [_currentDevice setActiveVideoMinFrameDuration:CMTimeMake(1, cameraFPS)];
    }
    
    [_currentDevice unlockForConfiguration];
}

- (AVCaptureDevice *)currentCamera{
    return _currentDevice;
}

- (BOOL)getCameraPermissionStatus{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return YES;
        case AVAuthorizationStatusNotDetermined:
            return NO;
        case AVAuthorizationStatusDenied:
            return NO;
        default:
            return NO;
    }
}

#pragma mark Device control
-(void)startCamera{
    [_currentSession startRunning];
}

-(void)stopCamera{
    [_currentSession stopRunning];
}

#pragma mark - 曝光 Exposure
-(void)setCameraExposreMode:(AVCaptureExposureMode)exposureMode{
   
    if (![_currentDevice lockForConfiguration:nil]) {
        [_currentDevice unlockForConfiguration];
        return;
    }
    
    switch (exposureMode) {
        case AVCaptureExposureModeLocked:
            if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [_currentDevice setExposureMode:AVCaptureExposureModeLocked];
            }
            break;
        case AVCaptureExposureModeAutoExpose:
            if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                [_currentDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            break;
            
        case AVCaptureExposureModeContinuousAutoExposure:
            if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            break;

        case AVCaptureExposureModeCustom:
            if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeCustom]) {
                [_currentDevice setExposureMode:AVCaptureExposureModeCustom];
            }
            break;
    }
    [_currentDevice unlockForConfiguration];

}


-(void)setCameraExposureWithDuration:(float)cameraDuration ISO:(float)cameraISO completionHandler:(void (^)(CMTime syncTime))handler{
    if ([_currentDevice lockForConfiguration:nil]) {
        [_currentDevice setExposureModeCustomWithDuration:CMTimeMake(1, CAMERA_FPS) ISO:cameraISO completionHandler:handler];
        [_currentDevice unlockForConfiguration];
    }
}

#pragma mark - 白平衡 White Balance
-(void)serCameraWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode{
    if ([_currentDevice lockForConfiguration:nil]) {
        switch (whiteBalanceMode) {
            case AVCaptureWhiteBalanceModeLocked:
                if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
                    [_currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                }
                break;
            case AVCaptureWhiteBalanceModeAutoWhiteBalance:
                if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                    [_currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
                }
                break;
            case AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance:
                if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                    [_currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                }
                break;
        }
    }
    [_currentDevice unlockForConfiguration];
}


-(void)setCameraWhiteBalanceWithTemperature:(float)cameraTemp Tint:(float)cameraTint{
    if ([_currentDevice lockForConfiguration:nil]) {
        if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {

            AVCaptureWhiteBalanceGains cameraWhiteBalanceGains;
            AVCaptureWhiteBalanceTemperatureAndTintValues cameraWhiteBalanceTempAndTint;
            
            cameraWhiteBalanceTempAndTint.temperature = cameraTemp;
            cameraWhiteBalanceTempAndTint.tint = cameraTint;
            cameraWhiteBalanceGains = [_currentDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:cameraWhiteBalanceTempAndTint];
            [_currentDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:cameraWhiteBalanceGains completionHandler:nil];
        }
    }
    [_currentDevice unlockForConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{


}


@end
