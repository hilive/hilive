//
//  media_node.hpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#ifndef media_node_hpp
#define media_node_hpp
#include <mediasdk/media_info.hpp>
#include <mediasdk/media_frame.hpp>
#include <mediasdk/media_buffer.hpp>
#include <mediasdk/media_result.hpp>
#include <future>
#include <unordered_map>

namespace hilive {
namespace mediasdk {

class MediaNode {
 protected:
  enum NodeType {
    kNodeTypeNone,
    kNodeTypeStreamInput,
    kNodeTypeFileInput,
    kNodeTypeDeviceInput,
    kNodeTypeRtmpInput,
    kNodeTypeHttpInput,

    kNodeTypeAudioGainFilter,
    kNodeTypeAudioDelayFilter,

    kNodeTypeFileOutput,
    kNodeTypeDeviceOutput,
  };

 public:
  MediaNode(NodeType node_type);
  virtual ~MediaNode();

 public:
  MediaResult AddNode(std::shared_ptr<MediaNode> node);
  MediaResult DelNode(std::shared_ptr<MediaNode> node);

 private:
  const NodeType get_node_type() { return node_type_; }
  const uint64_t get_node_id() { return node_id_; }

 private:
  NodeType      node_type_;
  uint64_t      node_id_;

 protected:
  std::unordered_map<uint64_t, std::shared_ptr<MediaNode>>  nodes_;
};

}
}

#endif /* media_node_hpp */
