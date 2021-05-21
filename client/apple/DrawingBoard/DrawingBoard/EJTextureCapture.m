//
//  EJTextureCapture.m
//  WAOpenGL
//
//  Created by cort xu on 2021/4/24.
//  Copyright © 2021 eldwinwang. All rights reserved.
//
#import "EJTextureCapture.h"
#import <UIKit/UIKit.h>

#define HILIVEINFO(format, ...) WXLog(@"[hilive] %@", [NSString stringWithFormat:format, ##__VA_ARGS__])

#define SHADER_SOURCE(NAME, ...) const char * const NAME = #__VA_ARGS__;

SHADER_SOURCE(VertexShader,
              attribute vec3 position;
              attribute vec2 texcoord;
              varying vec2 v_texcoord;
              void main() {
  gl_Position=vec4(position,1.0);
  v_texcoord=texcoord;
}
              );

SHADER_SOURCE(PresentFragmentsShader,
              precision highp float;
              varying highp vec2 v_texcoord;
              uniform sampler2D my_texture;
              void main() {
  gl_FragColor=texture2D(my_texture,v_texcoord);
}
              );

SHADER_SOURCE(FlipFragmentsShader,
              precision highp float;
              varying highp vec2 v_texcoord;
              uniform sampler2D my_texture;
              void main() {
  vec2 flip = vec2(v_texcoord.x, 1.0-v_texcoord.y);
  gl_FragColor = texture2D(my_texture,flip);
}
              );

@interface StatusHolder : NSObject

@end

@implementation StatusHolder {
  EAGLContext* currContext;
  GLint currActiveTexture;
  GLint currTextureId;
  GLint currFrameBuffer;
  GLint currRenderBuffer;
  GLint currProgram;
  GLint curVAO;
  GLint curVBO;
  GLint curEBO;
  GLint currArrayBuffer;
  GLint currElementArrayBuffer;
  GLint currVertexArray;
  GLint currViewPort[4];
}

- (void) dealloc {
  [self leave];
}

- (void)join:(EAGLContext*)context {
  if (EAGLContext.currentContext) {
    currContext = EAGLContext.currentContext;
    glGetIntegerv( GL_ACTIVE_TEXTURE, &currActiveTexture);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &currTextureId);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &currFrameBuffer);
    glGetIntegerv(GL_RENDERBUFFER_BINDING, &currRenderBuffer);
    glGetIntegerv(GL_CURRENT_PROGRAM, &currProgram);
    glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &curVAO);
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &curVBO);
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &curEBO);
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &currArrayBuffer);
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &currElementArrayBuffer);
    glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &currVertexArray);
    glGetIntegerv(GL_VIEWPORT, currViewPort);
  }
  
  [EAGLContext setCurrentContext:context];
}

- (void)leave {
  if (!currContext) {
    return;
  }
  
  [EAGLContext setCurrentContext:currContext];
  currContext = nil;
  
  glBindRenderbuffer(GL_RENDERBUFFER, currRenderBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, currFrameBuffer);
  glActiveTexture(currActiveTexture);
  glBindTexture(GL_TEXTURE_2D, currTextureId);
  glUseProgram(currProgram);
  glBindVertexArrayOES(curVAO);
  glBindBuffer(GL_ARRAY_BUFFER, curVBO);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, curEBO);
  glBindBuffer(GL_ARRAY_BUFFER, currArrayBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, currElementArrayBuffer);
  glBindVertexArrayOES(currVertexArray);
  glViewport(currViewPort[0], currViewPort[1], currViewPort[2], currViewPort[3]);
}

@end


@interface EJTextureHolder : NSObject
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, readonly) GLint width;
@property (nonatomic, readonly) GLint height;
@property (nonatomic, readonly) GLuint textureId;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, readonly) NSMutableData* nsData;
@end

@implementation EJTextureHolder {
  CVOpenGLESTextureCacheRef   texture_cache;
  GLint                       pixel_width;
  GLint                       pixel_height;
  GLuint                      texture_id;
  CVPixelBufferRef            pixel_buffer;
}

@synthesize ready;
@synthesize width = pixel_width;
@synthesize height = pixel_height;
@synthesize textureId = texture_id;
@synthesize pixelBuffer = pixel_buffer;

- (instancetype)initWithCache:(CVOpenGLESTextureCacheRef)cache {
  if (self = [super init]) {
    texture_cache = cache;
  }
  
  return self;
}

- (void) dealloc {
  if (pixel_buffer) {
    CFRelease(pixel_buffer);
    pixel_buffer = nil;
  }
}

- (NSMutableData*) nsData {
  if (!self.ready || !pixel_buffer) {
    return nil;
  }
  
  CVPixelBufferLockBaseAddress(pixel_buffer, 0);
  void* addr = CVPixelBufferGetBaseAddress(pixel_buffer);
  size_t size = CVPixelBufferGetDataSize(pixel_buffer);
  NSMutableData* data = [NSMutableData dataWithBytes:addr length:size];
  CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
  return data;
}

- (void)resize:(GLint)w height:(GLint)h {
  do {
    if (!texture_cache || !w || !h || (ready && pixel_width == w && pixel_height == h)) {
      break;
    }
    
    ready = NO;
    
    if (pixel_buffer) {
      CFRelease(pixel_buffer);
      pixel_buffer = nil;
    }
    
    NSDictionary *pixelAttribs = @{ (id)kCVPixelBufferIOSurfacePropertiesKey: @{} };
    CVReturn errCode = CVPixelBufferCreate(kCFAllocatorDefault, w, h, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttribs, &pixel_buffer);
    if (errCode != kCVReturnSuccess) {
      break;
    }
    
    CVOpenGLESTextureRef pixelTexture = nil;
    errCode = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           texture_cache,
                                                           pixel_buffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RGBA,
                                                           w,
                                                           h,
                                                           GL_BGRA,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &pixelTexture);
    if (errCode != kCVReturnSuccess) {
      break;
    }
    
    texture_id = CVOpenGLESTextureGetName(pixelTexture);
    CFRelease(pixelTexture);
    pixelTexture = nil;
    
    pixel_width = w;
    pixel_height = h;
    ready = YES;
  } while (false);
}

- (void)active {//custom context
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, texture_id);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

@end

@interface MyProgram : NSObject
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint position;
@property (nonatomic, assign) GLuint coords;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) GLuint vao;
@property (nonatomic, assign) GLuint vbo;
@property (nonatomic, assign) GLuint ebo;
@end

@implementation MyProgram

- (void) dealloc {
  [self destroy];
}

- (BOOL)create:(const char*)vShader fragmentsShader:(const char*)fShader {
  GLuint vertexShader = [self compileShader:vShader withType:GL_VERTEX_SHADER];
  GLuint fragmentShader = [self compileShader:fShader withType:GL_FRAGMENT_SHADER];
  
  _program = glCreateProgram();
  glAttachShader(_program, vertexShader);
  glAttachShader(_program, fragmentShader);
  glLinkProgram(_program);
  
  GLint linkSuccess = 0;
  glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
  if (linkSuccess == GL_FALSE) {
    GLchar message[256] = {0};
    glGetProgramInfoLog(_program, sizeof(message), 0, &message[0]);
    NSString* messageStr = [NSString stringWithUTF8String:message];
    return NO;
  }
  
  glUseProgram(_program);
  _position = glGetAttribLocation(_program, "position");
  _coords = glGetAttribLocation(_program, "texcoord");
  _texture = glGetUniformLocation(_program, "my_texture");
  
  glGenVertexArraysOES(1, &_vao);
  glGenBuffers(1, &_vbo);
  glGenBuffers(1, &_ebo);
  
  // Set up vertex data (and buffer(s)) and attribute pointers
  
  GLfloat vertices[] = {
    // Positions    // Texture Coords
    -1.0f,  -1.0f, 0.0f, 0.0f, 0.0f, // Bottom Left
    1.0f, -1.0f, 0.0f, 1.0f, 0.0f, // Bottom Right
    1.0f, 1.0f, 0.0f, 1.0f, 1.0f, // Top Right
    -1.0f,  1.0f, 0.0f, 0.0f, 1.0f  // Top Left
  };
  
  glBindVertexArrayOES(_vao);
  
  glBindBuffer(GL_ARRAY_BUFFER, _vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  
  const GLushort indices[] = { 0, 1, 2, 2, 3, 0 };
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
  
  // Position attribute
  glEnableVertexAttribArray(_position);
  glVertexAttribPointer(_position, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
  
  // TexCoord attribute
  glEnableVertexAttribArray(_coords);
  glVertexAttribPointer(_coords, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
  return YES;
}

- (void)use {
  glUseProgram(_program);
  glUniform1i(_texture, 0);
  glBindVertexArrayOES(_vao);
  glBindBuffer(GL_ARRAY_BUFFER, _vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
}

- (void)destroy {
  if (_vao) {
    glDeleteVertexArraysOES(1, &_vao);
    _vao = 0;
  }
  
  if (_vbo) {
    glDeleteBuffers(1, &_vbo);
    _vbo = 0;
  }
  
  if (_ebo) {
    glDeleteBuffers(1, &_ebo);
    _ebo = 0;
  }
  
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
}

- (GLuint)compileShader:(const char*)shaderData withType:(GLenum)shaderType {
  // create ID for shader
  GLuint shaderHandle = glCreateShader(shaderType);
  
  // define shader text
  int shaderLength = (int)strlen(shaderData);
  glShaderSource(shaderHandle, 1, &shaderData, &shaderLength);
  
  // compile shader
  glCompileShader(shaderHandle);
  
  // verify the compiling
  GLint compileSucess;
  glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSucess);
  if (compileSucess == GL_FALSE)
  {
    GLchar message[256];
    glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
    NSString *messageStr = [NSString stringWithUTF8String:message];
    NSLog(@"----%@", messageStr);
    return 0;
  }
  
  return shaderHandle;
}
@end

@interface WAEJTextureCapture()
@property (nonatomic, strong) EJTextureHolder* presentTexture;
@property (nonatomic, strong) EJTextureHolder* outputTexture;
@property (nonatomic, readonly) EAGLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, strong) MyProgram* program1;
@property (nonatomic, strong) MyProgram* program2;
@property (nonatomic, strong) StatusHolder* holder;
@end

@implementation WAEJTextureCapture {
  BOOL                        available;
  GLint                       view_width;
  GLint                       view_height;
  GLint                       buff_width;
  GLint                       buff_height;
  
  uint32_t                    present_count;
  uint32_t                    flip_count;
  uint32_t                    capture_count;
  
  CVOpenGLESTextureCacheRef   textureCache;
}

@synthesize textureId;
@synthesize viewWidth = view_width, viewHeight = view_height;
@synthesize buffWidth = buff_width, buffHeight = buff_height;

- (id)initWithContext:(EAGLContext*)context {
  if (self = [super init]) {
    [self setup:context];
  }
  
  return self;
}

- (void)dealloc {
  [_holder join:_context];
  
  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
  }
  
  [_program1 destroy];
  _program1 = nil;
  
  [_program2 destroy];
  _program2 = nil;
  
  _presentTexture = nil;
  _outputTexture = nil;
  
  _context = nil;
  
  if (textureCache) {
    CVOpenGLESTextureCacheFlush(textureCache, 0);
    CFRelease(textureCache);
    textureCache = nil;
  }
  
  [_holder leave];
}

- (GLint)textureId {
  return _presentTexture.textureId;
}

- (CVPixelBufferRef)pixelBuffer {
  return _outputTexture.pixelBuffer;
}

- (BOOL)ready {
  return _outputTexture.ready && _presentTexture.ready;
}

- (void)setup:(EAGLContext*)context {
  if (!context) {
    return;
  }
  
  CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache);
  if (ret != kCVReturnSuccess) {
    return;
  }
  
  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:context.sharegroup];
  _program1 = [MyProgram new];
  _program2 = [MyProgram new];
  _presentTexture = [[EJTextureHolder alloc] initWithCache:textureCache];
  _outputTexture = [[EJTextureHolder alloc] initWithCache:textureCache];
  
  [_holder join:_context];
  
  do {
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    if (![_program1 create:VertexShader fragmentsShader:PresentFragmentsShader]) {
      break;
    }
    
    if (![_program2 create:VertexShader fragmentsShader:FlipFragmentsShader]) {
      break;
    }
    
    available = YES;
  } while (false);
  
  [_holder leave];
}

- (BOOL)renderStorage:(CAEAGLLayer*)layer viewWidth:(GLint)w viewHeight:(GLint)h {
  if (!available) {
    return NO;
  }
  
  GLenum glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  GLenum glError = glGetError();
  BOOL ret = NO;
  
  [_holder join:_context];
  
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
  
  glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  glError = glGetError();
  
  ret = [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
  
  glStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  glError = glGetError();
  
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &buff_width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &buff_height);
  
  view_width = w;
  view_height = h;
  
  [_presentTexture resize:w height:h];
  [_presentTexture active];
  
  [_outputTexture resize:w height:h];
  [_outputTexture active];
  
  [_holder leave];
  
  return YES;
}

- (BOOL)renderPresent {
  if (!self.ready) {
    return NO;
  }
  
  glFlush();
  
  StatusHolder* status = [[StatusHolder alloc] init];
  [status join:_context];
  
  glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
  
  glViewport(0, 0, view_width, view_height);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [_program1 use];
  
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _presentTexture.textureId);
  
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
  
  [self.context presentRenderbuffer:GL_RENDERBUFFER];

  [_program2 use];
  
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputTexture.textureId, 0);
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
  glFlush();
  
  [_holder leave];
  
  ++ present_count;
  return YES;
}


@end
