//
//  live_interface.hpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#pragma once
#include <stdint.h>

namespace hilive {
namespace livesdk {

class LiveInterface {
 protected:
  LiveInterface() {}
  virtual ~LiveInterface() {}

 public:
  static LiveInterface* Create();
  static void Release(LiveInterface* interface);

 public:
  virtual void JoinRoom() = 0;
  virtual void StartLive() = 0;
  virtual void StopLive() = 0;
  virtual void StartPlay() = 0;
  virtual void StopPlay() = 0;
  virtual void LeaveRoom() = 0;
};

}
}

