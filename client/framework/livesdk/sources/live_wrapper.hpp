//
//  livesdk_wrapper.hpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#pragma once
#include "include/live_interface.hpp"

namespace hilive {
namespace livesdk {

class LiveWrapper final : public LiveInterface {
 public:
  LiveWrapper();
  virtual ~LiveWrapper();

 public:
  void JoinRoom() override;
  void StartLive() override;
  void StopLive() override;
  void StartPlay() override;
  void StopPlay() override;
  void LeaveRoom() override;
};

}
}
