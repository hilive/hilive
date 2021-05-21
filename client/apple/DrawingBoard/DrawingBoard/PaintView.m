//
//  PaintView.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/21.
//


#import "PaintView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


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
  
  GLint linkSuccess;
  glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
  if (linkSuccess == GL_FALSE) {
    GLchar message[256] = {0};
    glGetProgramInfoLog(_program, sizeof(message), 0, &message[0]);
    NSString* messageStr = [NSString stringWithUTF8String:message];
    NSLog(@"%@", messageStr);
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

@interface PaintView()
@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, strong) MyProgram* program1;
@property (nonatomic, strong) MyProgram* program2;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, assign) GLint textureId;
@end

@implementation PaintView {
  BOOL    ready;
  GLint   pixelWidth;
  GLint   pixelHeigh;
}

@synthesize available;
@synthesize pixelBuffer;

- (instancetype)init {
  if (self = [super init]) {
    [self setup];
  }
  
  return self;
}

- (void)dealloc {
  EAGLContext* currContext = EAGLContext.currentContext;
  [EAGLContext setCurrentContext:_context];
  
  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
  }
  
  if (pixelBuffer) {
    CFRelease(pixelBuffer);
    pixelBuffer = nil;
  }
  
  if (_textureCache) {
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
    CFRelease(_textureCache);
    _textureCache = nil;
  }
  
  [EAGLContext setCurrentContext:currContext];
}

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

@end
