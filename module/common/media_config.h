//
//  media_config.h
//  common
//
//  Created by cort xu on 2021/2/3.
//

#pragma once
#include <stdint.h>

namespace hilive {
namespace common {

enum MediaFormat {
  kMediaFormatNone = -1,

  kMediaFormatVideoYuvBegin = 0,
  kMediaFormatVideoYuv420p = 1,
  kMediaFormatVideoYuvJ420p,
  kMediaFormatVideoNv12,
  kMediaFormatVideoNv21,
  kMediaFormatVideoYuvEnd,

  kMediaFormatVideoPixelBegin = 50,
  kMediaFormatVideoRgb24,
  kMediaFormatVideoBgr24,
  kMediaFormatVideoRgba32,
  kMediaFormatVideoBgra32,
  kMediaFormatVideoArgb32,
  kMediaFormatVideoAbgr32,
  kMediaFormatVideoPixelEnd,

  kMediaFormatAudioBegin = 100,
  kMediaFormatAudioS16,//signed 16 bits
  kMediaFormatAudioS32,//signed 32 bits
  kMediaFormatAudioFlt,//float
  kMediaFormatAudioDbl,//double
  kMediaFormatAudioS16p,//signed 16 bits, planar
  kMediaFormatAudioS32p,//signed 32 bits, planar
  kMediaFormatAudioFltp,//float, planar
  kMediaFormatAudioDblp,//double, planar
  kMediaFormatAudioEnd,
};

enum FrameType {
  kFrameTypeNone  = -1,
  kFrameTypeIDR = 0,
  kFrameTypeI,
  kFrameTypeB,
  kFrameTypeP,
};

enum MediaType {
  kMediaTypeNone = -1,
  kMediaTypeAudio = 0,
  kMediaTypeVideo,
};

enum CaptureType {
  kCaptureTypeNone = -1,

  kCaptureTypeMicAudio = 0,
  kCaptureTypeAppAudio,
  kCaptureTypeCameraVideo,
  kCaptureTypeAppVideo
};

}
}
