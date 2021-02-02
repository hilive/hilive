//
//  device_context.cpp
//  device
//
//  Created by cort xu on 2021/2/3.
//

#include "device_context.hpp"
#include <future>

namespace hilive {
namespace device {

DeviceContext::DeviceContext() {}

DeviceContext::~DeviceContext() {}

DeviceContext* DeviceContext::Instance() {
  static std::shared_ptr<DeviceContext> context;
  static std::once_flag onceflag;
  std::call_once(onceflag, [&] {
    context = std::shared_ptr<DeviceContext>(new DeviceContext());
  });

  return context.get();
}

}
}
