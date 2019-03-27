//
//  JRCameraVideoViewController.m
//  JRVideoClipDemo
//
//  Created by 丁嘉睿 on 2019/3/8.
//  Copyright © 2019 djr. All rights reserved.
//

#import "JRRecordVideoViewController.h"
#import "UIImage+JRBundle.h"

@interface JRRecordVideoViewController () < AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate>
{
    dispatch_queue_t _movieWritingQueue;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsControl;
@property (weak, nonatomic) IBOutlet UIButton *slowRecordBtn;

@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval startTime;
/** bottomView的bottom约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomFromLayoutConstraint;

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
//@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

//照片输出流
//@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic) AVCaptureSessionPreset sessionPreset;

@end

@implementation JRRecordVideoViewController


#pragma mark - VC Life And Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.recordBtn.selected = self.slowRecordBtn.selected = NO;
    [self.recordBtn setImage:[[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"ShutterButton1@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:(UIControlStateNormal)];
    [self.recordBtn setImage:[[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"ShutterButtonStop@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:(UIControlStateSelected)];
    [self.slowRecordBtn setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"outer_normal@2x"] forState:(UIControlStateNormal)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottom = 0.f;
    
    CGFloat top = CGRectGetMaxY(self.navigationController.navigationBar.frame);

    if (@available(iOS 11.0, *)) {
        bottom += self.view.safeAreaInsets.bottom;
        top = self.view.safeAreaInsets.top;
    } else {
        top += 20.f;
    }
    
    self.bottomViewBottomFromLayoutConstraint.constant = bottom;
    
    self.previewLayer.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.movieFileOutput.isRecording) {
        [self.movieFileOutput stopRecording];
    }
    [self.timer invalidate];
    self.timer = nil;
    self.timeLab.text = @"00:00:00";
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)dealloc
{
    self.session = nil;
    self.input = nil;
    self.output = nil;
    [self.previewLayer removeFromSuperlayer];
}

/** 隐藏状态栏 */
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

/** 只允许竖屏 */
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset
{
//    [self.session stopRunning];
    _sessionPreset = sessionPreset;
//    self.session.sessionPreset = _sessionPreset;
//    [self.session startRunning];
}

#pragma mark - Public Methods
- (instancetype)initWithFPS:(JRRecordVideoViewControllerFPSType)fps sessionPreset:(AVCaptureSessionPreset)sessionPreset
{
    self = [super init];
    if (self) {
        self.sessionPreset = sessionPreset;
        [self _createCameraTools];
        [self _setCaremaFPSWithType:fps];
    } return self;
}

#pragma mark - Class Methods
#pragma mark- 检测相机权限,自动跳到设置里。
- (BOOL)_checkCameraPermission
{
    //相机权限
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //麦克风权限
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];

    
    if ((audioStatus == videoStatus) && (videoStatus == AVAuthorizationStatusAuthorized)) {
        return YES;
    } else {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Camera permission" message:@"Setting-Privacy-Camera" preferredStyle:(UIAlertControllerStyleAlert)];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Go" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertCon animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Private Methods

- (void)_createCameraTools
{
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    //使用设备初始化
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput Error : %@", error.localizedDescription);
        return;
    }
    /** 生成输出对象 */
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    /** 工程操作空间 */
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = self.sessionPreset;
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"AVCaptureSession Error : can't add AVCaptureDeviceInput");
        return;
    }
    
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    } else {
        NSLog(@"AVCaptureSession Error : can't add AVCaptureMetadataOutput");
        return;
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:self.movieFileOutput]) {
        [self.session addOutput:self.movieFileOutput];
    } else {
        NSLog(@"AVCaptureSession Error : can't add AVCaptureMovieFileOutput");
        return;
    }
    //开始启动
    [self.session startRunning];
}

- (BOOL)_startRecord
{
    
    NSURL *mediaURL = nil;
    mediaURL = self.saveURL;
    if (mediaURL) {
        /** 删除文件，不然无法保存视频 */
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:[self.saveURL path]]) {
            [fm removeItemAtURL:self.saveURL error:nil];
        }
        if (self.movieFileOutput && !self.movieFileOutput.isRecording) {
            [self.movieFileOutput startRecordingToOutputFileURL:mediaURL recordingDelegate:self];
        }
        return YES;
    } else {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Error" message:@"Video Output Error" preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alertCon animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertCon dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
    return NO;
}

- (void)_stopRecord {
    if (self.movieFileOutput && self.movieFileOutput.isRecording) {
        [self.movieFileOutput stopRecording];
    }
}

- (IBAction)_cancelCameraAction:(id)sender {
    if ([self.recordDelegate respondsToSelector:@selector(didCancelRecordVideoVC:)]) {
        [self.recordDelegate didCancelRecordVideoVC:self];
    }
}

- (IBAction)_recordAction:(id)sender {
    // REC START
    if (!self.movieFileOutput.isRecording) {
        
        if([self _startRecord]) {
            self.recordBtn.selected = YES;

            // change UI
            self.fpsControl.enabled = NO;
            
            // timer start
            self.startTime = [[NSDate date] timeIntervalSince1970];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(_timerHandler:)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    }
    // REC STOP
    else {
        
        self.recordBtn.selected = NO;
        [self _stopRecord];

        [self.timer invalidate];
        self.timer = nil;
        self.timeLab.text = @"00:00:00";
        self.fpsControl.enabled = YES;
    }

}

- (IBAction)changCameraFPSAction:(id)sender {
    UISegmentedControl *fpsControl = (UISegmentedControl *)sender;
    CGFloat desiredFps = 0.0;
    switch (fpsControl.selectedSegmentIndex) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            desiredFps = 60.f;
        }
            break;
        case 2:
        {
            desiredFps = 120.f;
        }
            break;
        case 3:
        {
            desiredFps = 240.f;
        }
            break;
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"switching fps ..." preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:actionSheet animated:YES completion:^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if (desiredFps > 0.0) {
                /** 调整帧率 */
                [self _switchFormatWithDesiredFPS:desiredFps];
            }
            else {
                [self _resetFormat];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (desiredFps >= 120.0) {
                    [self.slowRecordBtn setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"outer_slow@2x"] forState:(UIControlStateNormal)];
                }
                else {
                    [self.slowRecordBtn setImage:[UIImage jr_getImgFromJRVideoEditingBundleWithName:@"outer_normal@2x"] forState:(UIControlStateNormal)];
                }
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            });
        });
    }];

    
}

- (void)_setCaremaFPSWithType:(JRRecordVideoViewControllerFPSType)type
{
    CGFloat desiredFPS = 0.f;
    switch (type) {
        case JRRecordVideoViewControllerFPS30:
            desiredFPS = 30.f;
            break;
        case JRRecordVideoViewControllerFPS60:
            desiredFPS = 60.f;
            break;
        case JRRecordVideoViewControllerFPS120:
            desiredFPS = 120.f;
            break;
        case JRRecordVideoViewControllerFPS240:
            desiredFPS = 240.f;
            break;
    }
    [self _switchFormatWithDesiredFPS:desiredFPS];
}

- (void)_switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
    BOOL isRunning = self.session.isRunning;
    
    if (isRunning) {
        [self.session stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth && format.videoZoomFactorUpscaleThreshold > 1.0) {
                
                if (range.maxFrameRate >= frameRateRange.maxFrameRate) {
                    selectedFormat = format;
                    frameRateRange = range;
                    maxWidth = width;
                }
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    if (isRunning) {
        [self.session startRunning];
    }
}

- (void)_resetFormat {
    
    BOOL isRunning = self.session.isRunning;
    
    if (isRunning) {
        [self.session stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    [videoDevice unlockForConfiguration];
    if (isRunning) {
        [self.session startRunning];
    }
}


- (void)_timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - self.startTime;
    
    self.timeLab.text = [NSString stringWithFormat:@"%.2f", recorded];
}

- (void)_didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    if ([self.recordDelegate respondsToSelector:@selector(didFinishRecordVideoVC:url:error:)]) {
        [self.recordDelegate didFinishRecordVideoVC:self url:outputFileURL error:error];
    }
}


#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
       fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
   didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                       fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self _didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

@end
