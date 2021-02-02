//
//  device_context.hpp
//  device
//
//  Created by cort xu on 2021/2/3.
//

#pragma once
#include "device_info.h"

namespace hilive {
namespace device {

class DeviceContext {
 private:
  DeviceContext();
  ~DeviceContext();

 public:
  static DeviceContext* Instance();

 public:
  DeviceCode StartSysCapture();
  void StopSysCapture();

  DeviceCode StartAppCapture();
  void StopAppCapture();

  DeviceCode StartMicCapture();
  void StopMicCapture();

  DeviceCode StartCameraCapture();
  void StopCameraCapture();
};

}
}
