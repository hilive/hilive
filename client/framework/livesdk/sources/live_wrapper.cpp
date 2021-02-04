//
//  live_wrapper.cpp
//  livesdk
//
//  Created by cort xu on 2021/2/4.
//

#include "live_wrapper.h"
#include <map>
#include <future>

namespace hilive {
namespace livesdk {

static std::mutex g_mutex;
static std::map<LiveInterface*, std::shared_ptr<LiveWrapper>> g_wrappers;

LiveInterface* LiveInterface::Create(const char* base_dir, LiveCallbacker* notify_callbacker) {
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

void LiveWrapper::JoinRoom(const char* parmas, LiveCallbacker* response_callbacker) {}
void LiveWrapper::StartLive(const char* parmas, LiveCallbacker* response_callbacker) {}
void LiveWrapper::StopLive(const char* parmas, LiveCallbacker* response_callbacker) {}
void LiveWrapper::StartPlay(const char* parmas, LiveCallbacker* response_callbacker) {}
void LiveWrapper::StopPlay(const char* parmas, LiveCallbacker* response_callbacker) {}
void LiveWrapper::LeaveRoom(const char* parmas, LiveCallbacker* response_callbacker) {}

}
}
