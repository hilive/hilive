//
//  app_capture.hpp
//  device
//
//  Created by cort xu on 2021/2/3.
//
#pragma once
#include <future>
#include "device_info.h"

namespace hilive {
namespace device {

class AppCapture {
 public:
  static std::shared_ptr<AppCapture> Create();
  virtual ~AppCapture();

 protected:
  AppCapture();
};

}
}
