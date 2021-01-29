//
//  H264Encoder.h
//  RealLive
//
//  Created by cort xu on 2021/1/29.
//

#ifndef H264Encoder_h
#define H264Encoder_h

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>

@protocol H264EncoderDelegate <NSObject>
- (void)onSps:(const uint8_t*)data size:(size_t)size;
- (void)onPps:(const uint8_t*)data size:(size_t)size;
- (void)onFrame:(const uint8_t*)data size:(size_t)size keyFrame:(BOOL)keyFrame;
@end


@interface H264EncoderImpl : NSObject
@property (weak, nonatomic) id<H264EncoderDelegate> delegate;

- (void) start:(int)width height:(int)height fps:(int)fps gop:(int)gop bitrate:(int)bitrate;
- (void) encode:(CMSampleBufferRef )sampleBuffer;
- (void) stop;

@end


#endif /* H264Encoder_h */
