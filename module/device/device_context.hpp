//
//  device_context.hpp
//  device
//
//  Created by cort xu on 2021/2/3.
//

#pragma once
#include <future>
#include "app_capture.hpp"

namespace hilive {
namespace device {

class DeviceContext {
 private:
  DeviceContext();

 public:
  ~DeviceContext();

 public:
  static std::shared_ptr<DeviceContext> Instance();

 public:
  std::shared_ptr<AppCapture> app_capture() { return app_capture_; }

 public:
  std::shared_ptr<AppCapture>   app_capture_;
};

}
}
