//
//  H264Encoder.m
//  RealLive
//
//  Created by cort xu on 2021/1/29.
//

#import "H264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface H264EncoderImpl()
@end

@implementation H264EncoderImpl {
    VTCompressionSessionRef session;
    dispatch_queue_t        queue;
}

- (instancetype)init {
    if (self = [super init]) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }

    return self;
}

- (void)dealloc {
}

static void H264CompressCallback(
        void * CM_NULLABLE outputCallbackRefCon,
        void * CM_NULLABLE sourceFrameRefCon,
        OSStatus status,
        VTEncodeInfoFlags infoFlags,
        CM_NULLABLE CMSampleBufferRef sampleBuffer ) {
    BOOL isValid = CMSampleBufferIsValid(sampleBuffer);
    BOOL isReady = CMSampleBufferDataIsReady(sampleBuffer);
    if (!isValid || !isReady) {
        return;
    }

    H264EncoderImpl* impl = (__bridge H264EncoderImpl*)outputCallbackRefCon;

    // Check if we have got a key frame first
    CFArrayRef sampleArrayRef = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    bool keyframe = !CFDictionaryContainsKey((CFDictionaryRef)CFArrayGetValueAtIndex(sampleArrayRef, 0), kCMSampleAttachmentKey_NotSync);
    
    if (keyframe) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
       
        size_t spsSize = 0, spsSetCnt = 0;
        const uint8_t* spsSet = NULL;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &spsSet, &spsSize, &spsSetCnt, 0 );
        if (statusCode == noErr) {
            size_t ppsSize = 0, ppsCnt;
            const uint8_t* ppsSet = NULL;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &ppsSet, &ppsSize, &ppsCnt, 0 );
            if (statusCode == noErr) {
                [impl->_delegate onSps:spsSet size:spsSize];
                [impl->_delegate onPps:ppsSet size:ppsSize];
            }
        }
    }
    
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char* dataPointer = NULL;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(blockBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // Convert the length value from Big-endian to Little-endian
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            [impl->_delegate onFrame:(uint8_t*)(dataPointer + bufferOffset + AVCCHeaderLength) size:NALUnitLength keyFrame:keyframe];
            
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    }
}


- (void) start:(int)width height:(int)height fps:(int)fps gop:(int)gop bitrate:(int)bitrate {
    dispatch_sync(queue, ^{
        CFMutableDictionaryRef sessionAttributes = CFDictionaryCreateMutable(
                                                                             NULL,
                                                                             0,
                                                                             &kCFTypeDictionaryKeyCallBacks,
                                                                             &kCFTypeDictionaryValueCallBacks);

        // bitrate 只有当压缩frame设置的时候才起作用，有时候不起作用，当不设置的时候大小根据视频的大小而定
//        int fixedBitrate = 2000 * 1024; // 2000 * 1024 -> assume 2 Mbits/s
//        CFNumberRef bitrateNum = CFNumberCreate(NULL, kCFNumberSInt32Type, &fixedBitrate);
//        CFDictionarySetValue(sessionAttributes, kVTCompressionPropertyKey_AverageBitRate, bitrateNum);
//        CFRelease(bitrateNum);
        
        // CMTime CMTimeMake(int64_t value,     int32_t timescale)当timescale设置为1的时候更改这个参数就看不到效果了
//        float fixedQuality = 1.0;
//        CFNumberRef qualityNum = CFNumberCreate(NULL, kCFNumberFloat32Type, &fixedQuality);
//        CFDictionarySetValue(sessionAttributes, kVTCompressionPropertyKey_Quality, qualityNum);
//        CFRelease(qualityNum);
        
        //貌似没作用
//        int DataRateLimits = 2;
//        CFNumberRef DataRateLimitsNum = CFNumberCreate(NULL, kCFNumberSInt8Type, &DataRateLimits);
//        CFDictionarySetValue(sessionAttributes, kVTCompressionPropertyKey_DataRateLimits, DataRateLimitsNum);
//        CFRelease(DataRateLimitsNum);
        
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, sessionAttributes, NULL, NULL, H264CompressCallback, (__bridge void *)(self),  &self->session);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);

        if (status != 0) {
            return;
        }

        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
/*
        // 设置关键帧（GOPsize)间隔
        CFNumberRef  gopRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &gop);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_MaxKeyFrameInterval, gopRef);

        //设置期望帧率
        CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);

        //设置码率，均值，单位是byte
        //int bitRate = width * height * 3 * 4 * 8;
        CFNumberRef bitrateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitrate);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_AverageBitRate, bitrateRef);

        //设置码率，上限，单位是bps
    //    int bitRateLimit = width * height * 3 * 4;
        int bitrateLimit = bitrate * 2;
        CFNumberRef bitrateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitrateLimit);
        VTSessionSetProperty(self->session, kVTCompressionPropertyKey_DataRateLimits, bitrateLimitRef);
*/
        //start encode
        VTCompressionSessionPrepareToEncodeFrames(self->session);
    });
}

- (void) encode:(CMSampleBufferRef )sampleBuffer {
    dispatch_sync(queue, ^{
        // Get the CV Image buffer
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        VTEncodeInfoFlags flags;
        OSStatus statusCode = VTCompressionSessionEncodeFrame(self->session,
                                                              imageBuffer,
                                                              pts,
                                                              kCMTimeInvalid,
                                                              NULL, NULL, &flags);
        if (statusCode != noErr) {
            return;
        }
    });
}

- (void) stop {
    dispatch_sync(queue, ^{
        if (!self->session) {
            return;
        }

        VTCompressionSessionCompleteFrames(self->session, kCMTimeInvalid);

        // End the session
        VTCompressionSessionInvalidate(self->session);
        CFRelease(self->session);
        self->session = nil;
    });
}

@end


