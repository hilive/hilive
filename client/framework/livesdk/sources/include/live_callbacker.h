//
//  live_callbacker.h
//  livesdk
//
//  Created by cort xu on 2021/2/5.
//

#pragma once

namespace hilive {
namespace livesdk {

class LiveCallbacker {
 public:
  LiveCallbacker() {}
  virtual ~LiveCallbacker() {}

 public:
  virtual void Call(const char* parmas);
};

}
}
