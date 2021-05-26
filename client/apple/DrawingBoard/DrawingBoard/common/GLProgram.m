//
//  GLProgram.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/22.
//

#import "GLProgram.h"

@implementation GLProgram {
  GLuint _ready;
  GLuint _programId;
}

@synthesize ready = _ready;
@synthesize programId = _programId;

- (void)dealloc {
  [self detach];
}

- (BOOL)attach:(const char*)vShader fragShader:(const char*)fShader {
  do {
    if (_ready) {
      break;
    }
    
    GLuint vHandle = 0;
    if (![self compileShader:vShader type:GL_VERTEX_SHADER handle:vHandle]) {
      break;
    }
    
    GLuint fHandle = 0;
    if (![self compileShader:fShader type:GL_FRAGMENT_SHADER handle:fHandle]) {
      break;
    }
    
    _programId = glCreateProgram();
    glAttachShader(_programId, vShader);
    glAttachShader(_programId, fShader);
    glLinkProgram(_programId);
    
    glValidateProgram(_programId);
    const uint32_t kLogSize = 1024;
    GLchar message[kLogSize + 1] = {0};
    glGetProgramiv(handle, kLogSize, 0, message);
    printf("Program compile log: %s\r\n", message);
    
    GLint status = 0;
    glGetProgramiv(filterProgram, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
      break;
    }
    
    _ready = YES;
  } while (false);
  return _ready;
}

- (void)use {
  if (!_ready) {
    return;
  }
  
  glUseProgram(_programId);
}

- (GLint)getAttribLocation:(const char*)name {
    if (!_ready) {
        return -1;
    }

    return glGetAttribLocation(_programId, name);
}

- (GLint)getUniformLocation:(const char*)name {
    if (!_ready) {
        return -1;
    }

    return glGetUniformLocation(_programId, name);
}

- (void)detach {
  if (_programId) {
    glDeleteProgram(_programId);
    _programId = 0;
  }
}

- (BOOL)compileShader:(const char*)shaderData type:(GLenum)type handle:(GLuint&)handle {
  if (!shaderData) {
    return NO;
  }
  
  // create ID for shader
  handle = glCreateShader(type);
  if (handle == 0 || handle == GL_INVALID_ENUM) {
    return NO;
  }
  
  // define shader text
  glShaderSource(handle, 1, &shaderData, NULL);
  
  // compile shader
  glCompileShader(handle);
  
  const uint32_t kLogSize = 1024;
  GLchar message[kLogSize + 1] = {0};
  glGetShaderInfoLog(handle, kLogSize, 0, message);
  printf("Shader compile log: %s\r\n", message);
  
  // verify the compiling
  GLint sucess = 0;
  glGetShaderiv(handle, GL_COMPILE_STATUS, &sucess);
  
  return sucess != GL_FALSE ? YES : NO;
}

@end
