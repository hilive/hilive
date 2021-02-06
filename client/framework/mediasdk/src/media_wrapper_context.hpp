//
//  media_wrapper_context.hpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#ifndef media_wrapper_context_hpp
#define media_wrapper_context_hpp
#include "media_context.hpp"
#include <deque>
#include "logger_wrapper.hpp"

using namespace hilive::common;

namespace hilive {
namespace mediasdk {

class MediaWrapperContext : public MediaContext, public LoggerWrapper {
 public:
  MediaWrapperContext(const char* base_dir);
  virtual ~MediaWrapperContext();

 public:
  void Logging(LogLvl lvl, const char* log) override;

 public:
  std::shared_ptr<FileInputNode> CreateFileInput() override;

 private:
  std::deque<std::shared_ptr<MediaNode>>    hold_nodes_;
};

}
}

#endif /* media_wrapper_context_hpp */
