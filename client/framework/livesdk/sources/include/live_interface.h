//
//  live_interface.hpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#pragma once
#include <livesdk/live_callbacker.h>

namespace hilive {
namespace livesdk {

class LiveInterface {
 protected:
  LiveInterface() {}
  virtual ~LiveInterface() {}

 public:
  static LiveInterface* Create(const char* base_dir, LiveCallbacker* notify_callbacker);
  static void Release(LiveInterface* interface);

 public:
  virtual void JoinRoom(const char* parmas, LiveCallbacker* response_callbacker) = 0;
  virtual void StartLive(const char* parmas, LiveCallbacker* response_callbacker) = 0;
  virtual void StopLive(const char* parmas, LiveCallbacker* response_callbacker) = 0;
  virtual void StartPlay(const char* parmas, LiveCallbacker* response_callbacker) = 0;
  virtual void StopPlay(const char* parmas, LiveCallbacker* response_callbacker) = 0;
  virtual void LeaveRoom(const char* parmas, LiveCallbacker* response_callbacker) = 0;
};

}
}

