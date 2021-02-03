//
//  live_wrapper.cpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#include "live_wrapper.hpp"
#include <map>
#include <future>

namespace hilive {
namespace livesdk {

static std::mutex g_mutex;
static std::map<LiveInterface*, std::shared_ptr<LiveWrapper>> g_wrappers;

LiveInterface* LiveInterface::Create() {
  auto wrapper = std::make_shared<LiveWrapper>();

  std::unique_lock<std::mutex> lock(g_mutex);
  g_wrappers[wrapper.get()] = wrapper;
  return wrapper.get();
}

void LiveInterface::Release(LiveInterface* interface) {
  std::unique_lock<std::mutex> lock(g_mutex);
  g_wrappers.erase(interface);
}

LiveWrapper::LiveWrapper() {

}

LiveWrapper::~LiveWrapper() {

}

void LiveWrapper::JoinRoom() {}
void LiveWrapper::StartLive() {}
void LiveWrapper::StopLive() {}
void LiveWrapper::StartPlay() {}
void LiveWrapper::StopPlay() {}
void LiveWrapper::LeaveRoom() {}

}
}
