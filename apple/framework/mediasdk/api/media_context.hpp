//
//  media_context.hpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#ifndef media_context_hpp
#define media_context_hpp
#include <mediasdk/file_input_node.hpp>
#include <mediasdk/stream_input_node.hpp>
#include <mediasdk/device_input_node.hpp>
#include <mediasdk/rtmp_input_node.hpp>
#include <mediasdk/http_input_node.hpp>
#include <mediasdk/file_output_node.hpp>
#include <mediasdk/device_output_node.hpp>


namespace hilive {
namespace mediasdk {

class MediaContext {
 public:
  static std::shared_ptr<MediaContext> CreateContext(const char* base_dir);

 protected:
  MediaContext() {}

 public:
  virtual ~MediaContext() {}

 public:
  virtual std::shared_ptr<FileInputNode> CreateFileInput() = 0;
};

}
}

#endif /* media_context_hpp */
