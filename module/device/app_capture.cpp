//
//  app_capture.cpp
//  device
//
//  Created by cort xu on 2021/2/3.
//

#include "app_capture.hpp"
#include "../common/platform.h"
#if defined(PLATFORM_IOS)
#include "ios/app_capture_ios.h"
#elif defined(PLATFORM_MAC)
#elif defined(PLATFORM_ANDROID)
#elif defined(PLATFORM_WIN)
#endif

namespace hilive {
namespace device {

std::shared_ptr<AppCapture> AppCapture::Create() {
#if defined(PLATFORM_IOS)
  return std::shared_ptr<AppCaptureIos>(new AppCaptureIos());
#else
  return nullptr;
#endif
}

AppCapture::~AppCapture() {

}

AppCapture::AppCapture() {

}

}
}
