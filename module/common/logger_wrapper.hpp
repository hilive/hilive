//
//  logger_wrapper.hpp
//  common
//
//  Created by cort xu on 2021/2/6.
//

#ifndef logger_wrapper_hpp
#define logger_wrapper_hpp

namespace hilive {
namespace common {

enum LogLvl {
  kLogError,
  kLogWarn,
  kLogInfo,
  kLogDebug,
  kLogTrace,
};

class LoggerWrapper {
public:
    LoggerWrapper() {}
    virtual ~LoggerWrapper() {}
    
public:
    virtual void Logging(LogLvl lvl, const char* log) {}
};

void Logging(LoggerWrapper* logger_wrapper, LogLvl lvl, const char* func, int line, const char* fmt, ...);

#define LOGD(logger_wrapper, fmt, ...) Logging(logger_wrapper, kLogDebug, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)
#define LOGI(logger_wrapper, fmt, ...) Logging(logger_wrapper, kLogInfo, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)
#define LOGW(logger_wrapper, fmt, ...) Logging(logger_wrapper, kLogWarn, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)
#define LOGE(logger_wrapper, fmt, ...) Logging(logger_wrapper, kLogError, __FUNCTION__, __LINE__, fmt, ##__VA_ARGS__)

}
}

#endif /* logger_wrapper_hpp */
