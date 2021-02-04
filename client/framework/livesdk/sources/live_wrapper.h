//
//  livesdk_wrapper.hpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#pragma once
#include "include/live_interface.h"

namespace hilive {
namespace livesdk {

class LiveWrapper final : public LiveInterface {
 public:
  LiveWrapper();
  virtual ~LiveWrapper();

 public:
  void JoinRoom(const char* parmas, LiveCallbacker* response_callbacker) override;
  void StartLive(const char* parmas, LiveCallbacker* response_callbacker) override;
  void StopLive(const char* parmas, LiveCallbacker* response_callbacker) override;
  void StartPlay(const char* parmas, LiveCallbacker* response_callbacker) override;
  void StopPlay(const char* parmas, LiveCallbacker* response_callbacker) override;
  void LeaveRoom(const char* parmas, LiveCallbacker* response_callbacker) override;
};

}
}
