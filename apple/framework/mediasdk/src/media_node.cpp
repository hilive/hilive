//
//  media_node.cpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#include "media_node.hpp"

namespace hilive {
namespace mediasdk {

MediaNode::MediaNode(NodeType node_type)
    : node_type_(node_type), node_id_(reinterpret_cast<uint64_t>(this)) {
}

MediaNode::~MediaNode() {

}

MediaResult MediaNode::AddNode(std::shared_ptr<MediaNode> node) {
  return MediaResult();
}

MediaResult MediaNode::DelNode(std::shared_ptr<MediaNode> node) {
  return MediaResult();
}

}
}
