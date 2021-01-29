//
//  ViewController.m
//  RealLive
//
//  Created by cort xu on 2021/1/28.
//

#import "ViewController.h"
#import <ReplayKit/RPScreenRecorder.h>
#import "H264Encoder.h"

@interface ViewController() <H264EncoderDelegate> {
}
@property (nonatomic, strong) H264EncoderImpl* encoder;
@end

@implementation ViewController {
    FILE*   fph264;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [docDir stringByAppendingPathComponent:@"test.h264"];

    remove([path UTF8String]);

    fph264 = fopen([path UTF8String], "wb");
    
    self.encoder = [[H264EncoderImpl alloc] init];
    self.encoder.delegate = self;
    [self.encoder start:1920 height:886 fps:60 gop:60 bitrate:3000];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)onTimer {
    static uint32_t loop = 0;
    loop ++;
    if (loop % 20 == 0) {
        [self.view setBackgroundColor:UIColor.blueColor];
    } else {
        [self.view setBackgroundColor:UIColor.whiteColor];
    }
    
}

- (IBAction)onTestClick:(id)sender {
    if (![[RPScreenRecorder sharedRecorder] isAvailable]) {
        return;
    }

    [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

        [self.encoder encode:sampleBuffer];
    } completionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)onSps:(const uint8_t*)data size:(size_t)size {
    if (!fph264) {
        return;
    }

    const char hdr[] = "\x00\x00\x00\x01";
    fwrite(hdr, 1, 4, fph264);
    fwrite(data, 1, size, fph264);
    fflush(fph264);
}

- (void)onPps:(const uint8_t*)data size:(size_t)size {
    if (!fph264) {
        return;
    }

    const char hdr[] = "\x00\x00\x00\x01";
    fwrite(hdr, 1, 4, fph264);
    fwrite(data, 1, size, fph264);
    fflush(fph264);
}

- (void)onFrame:(const uint8_t*)data size:(size_t)size keyFrame:(BOOL)keyFrame {
    if (!fph264) {
        return;
    }

    const char hdr[] = "\x00\x00\x00\x01";
    fwrite(hdr, 1, 4, fph264);
    fwrite(data, 1, size, fph264);
    fflush(fph264);
}

@end
