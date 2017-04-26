/*
 Created by Chelsea Huang on 2017/4/25.
 https://github.com/ch126
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/*
 記得加入info.plist
 
 <key>NSCameraUsageDescription</key>
 <string>Camera usage description</string>
 */



#define CAMERA_FPS 30

@interface ChCameraTool : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
#pragma mark - Device setting
+(instancetype)cameraWithPreviewView:(UIView*)cameraPreviewView Position:(AVCaptureDevicePosition)cameraPosition;
- (AVCaptureDevice *)currentCamera;
- (BOOL)getCameraPermissionStatus;

#pragma mark Device control
-(void)startCamera;
-(void)stopCamera;

#pragma mark - 曝光 Exposure
-(void)setCameraExposreMode:(AVCaptureExposureMode)exposureMode;
-(void)setCameraExposureWithDuration:(float)cameraDuration ISO:(float)cameraISO completionHandler:(void (^)(CMTime syncTime))handler;

#pragma mark - 白平衡 White Balance
-(void)serCameraWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;
-(void)setCameraWhiteBalanceWithTemperature:(float)cameraTemp Tint:(float)cameraTint;
@end
