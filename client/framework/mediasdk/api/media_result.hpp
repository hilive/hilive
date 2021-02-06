//
//  media_result.hpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#ifndef media_result_h
#define media_result_h

#include "media_info.hpp"
#include <string>

namespace hilive {
namespace mediasdk {

class MediaResult {
 public:
  MediaResult(MediaCode code, const char* desc) : code_(code), desc_(desc) {}
  MediaResult(MediaCode code, const std::string& desc) : code_(code), desc_(desc) {}
  MediaResult() : code_(kMediaCodeSuccess) {}
  ~MediaResult() {}

 public:
  bool operator == (MediaCode code) {
    return code_ == code;
  }

  bool operator != (MediaCode code) {
    return code_ != code;
  }

  operator bool () {
    return code_ == kMediaCodeSuccess;
  }

 public:
  void operator = (MediaCode code) {
    code_ = code;
  }

  void operator = (const char* desc) {
    desc_.assign(desc);
  }

  void operator = (const std::string& desc) {
    desc_ = desc;
  }

 public:
  const MediaCode get_code() { return code_; }
  const std::string&  get_desc() { return desc_; }

 private:
  MediaCode   code_;
  std::string desc_;
};

}
}

#endif /* media_result_h */
