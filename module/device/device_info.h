//
//  device_info.h
//  device
//
//  Created by cort xu on 2021/2/3.
//
#pragma once
#include <stdint.h>

namespace hilive {
namespace device {

enum DeviceCode {
  kDeviceCodeSuccess = 0,
  kDeviceCodeFailed = 1,
};

struct DeviceConfig {
  struct Video {
    uint32_t  width = 0;
    uint32_t  height = 0;
    uint32_t  fps = 0;
  };
};

}
}
