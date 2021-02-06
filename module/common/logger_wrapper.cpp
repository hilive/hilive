//
//  logger_wrapper.cpp
//  common
//
//  Created by cort xu on 2021/2/6.
//

#include "logger_wrapper.hpp"
#include <stdio.h>
#include <stdarg.h>

namespace hilive {
namespace common {

void Logging(LoggerWrapper* logger_wrapper, LogLvl lvl, const char* func, int line, const char* fmt, ...) {
  if (!logger_wrapper) {
    return;
  }

  const uint32_t kLogBuffSize = 2048;
  char log_buff[kLogBuffSize + 1] = {0};
  va_list vl;
  va_start(vl, fmt);
  snprintf(log_buff, kLogBuffSize, "[%d][%s][%d] ", lvl, func, line);
  uint32_t head_size = (uint32_t)strlen(log_buff);
  vsnprintf(log_buff + head_size, kLogBuffSize - head_size, fmt, vl);
  va_end(vl);

  logger_wrapper_->Logging(lvl, log_buff);
}

}
}
