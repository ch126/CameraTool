# CameraTool

```Objective-C


    CameraTool * myCamera = [CameraTool cameraWithPreviewView:self.view Position:AVCaptureDevicePositionBack];
    [myCamera setCameraWhiteBalanceWithTemperature:5000 Tint:-10];
    [myCamera setCameraExposureWithDuration:CAMERA_FPS ISO:400 completionHandler:nil];
    
    [myCamera startCamera];
    
    
   ```
