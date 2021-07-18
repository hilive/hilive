//
//  media_wrapper_context.cpp
//  mediasdk
//
//  Created by cort xu on 2021/2/6.
//

#include "media_wrapper_context.hpp"


namespace hilive {
namespace mediasdk {


std::shared_ptr<MediaContext> MediaContext::CreateContext(const char* base_dir) {
  return std::shared_ptr<MediaWrapperContext>(new MediaWrapperContext(base_dir));
}


MediaWrapperContext::MediaWrapperContext(const char* base_dir) {
}

MediaWrapperContext::~MediaWrapperContext() {
}

void MediaWrapperContext::Logging(LogLvl lvl, const char* log) {

}

std::shared_ptr<FileInputNode> MediaWrapperContext::CreateFileInput() {
  return nullptr;
}

}
}
