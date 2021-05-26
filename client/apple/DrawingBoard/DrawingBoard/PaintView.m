//
//  PaintView.m
//  DrawingBoard
//
//  Created by cort xu on 2021/5/21.
//


#import "PaintView.h"
#import "common/GLContext.h"
#import "common/GLProgram.h"
#import "common/GLTexture.h"


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


GLfloat vertices[] = {
  // Positions    // Texture Coords
  -1.0f,  -1.0f, 0.0f, 0.0f, 0.0f, // Bottom Left
  1.0f, -1.0f, 0.0f, 1.0f, 0.0f, // Bottom Right
  1.0f, 1.0f, 0.0f, 1.0f, 1.0f, // Top Right
  -1.0f,  1.0f, 0.0f, 0.0f, 1.0f  // Top Left
};

const GLushort indices[] = { 0, 1, 2, 2, 3, 0 };

@interface PaintView()
@property (nonatomic, strong) GLContext* context;
@property (nonatomic, strong) GLTexture* presentTexture;
@property (nonatomic, strong) GLTexture* flipTexture;
@property (nonatomic, strong) GLProgram* presentProgram;
@property (nonatomic, strong) GLProgram* flipProgram;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
@end

@implementation PaintView {
  BOOL    ready;
  GLint   pixelWidth;
  GLint   pixelHeigh;
  
  GLuint  _presentVao;
  GLuint  _presentVbo;
  GLuint  _presentEbo;
  GLuint  _presentPosition;
  GLuint  _presentCoords;
  GLuint  _presentTexture;
  
  GLuint  _flipVao;
  GLuint  _flipVbo;
  GLuint  _flipEbo;
  GLuint  _flipPosition;
  GLuint  _flipCoords;
  GLuint  _flipTexture;
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
  [_context join];
  
  if (_presentVao) {
    glDeleteVertexArraysOES(1, &_presentVao);
    _presentVao = 0;
  }
  
  if (_flipVao) {
    glDeleteVertexArraysOES(1, &_flipVao);
    _flipVao = 0;
  }
  
  if (_presentVbo) {
    glDeleteBuffers(1, &_presentVbo);
    _presentVbo = 0;
  }
  
  if (_flipVbo) {
    glDeleteBuffers(1, &_flipVbo);
    _flipVbo = 0;
  }
  
  if (_presentEbo) {
    glDeleteBuffers(1, &_presentEbo);
    _presentEbo = 0;
  }
  
  if (_flipEbo) {
    glDeleteBuffers(1, &_flipEbo);
    _flipEbo = 0;
  }
  
  if (_frameBuffer) {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
  }
  
  if (_renderBuffer) {
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
  }
  
  _presentTexture = nil;
  _flipTexture = nil;
  
  _presentProgram = nil;
  _flipProgram = nil;
  
  [_context leave];
  _context = nil;
}

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

- (void)setup {
  _context = [[GLContext alloc] initWithShare:nil];
  _presentTexture = [GLTexture new];
  _flipTexture = [GLTexture new];
  _presentProgram = [GLProgram new];
  _flipProgram = [GLProgram new];
  [_context join];
  do {
    if (![_presentProgram attach:VertexShader fragShader:PresentFragmentsShader]) {
      break;
    }
    
    [_presentProgram use];
    _presentPosition = [_presentProgram getAttribLocation:"position"];
    _presentCoords = [_presentProgram getAttribLocation:"texcoord"];
    _presentTexture = [_presentProgram getUniformLocation:"my_texture"];
    
    glGenVertexArraysOES(1, &_presentVao);
    glGenBuffers(1, &_presentVbo);
    glGenBuffers(1, &_presentEbo);
    
    glBindVertexArrayOES(_presentVao);
    
    glBindBuffer(GL_ARRAY_BUFFER, _presentVbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _presentEbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // Position attribute
    glEnableVertexAttribArray(_presentPosition);
    glVertexAttribPointer(_presentPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
    
    // TexCoord attribute
    glEnableVertexAttribArray(_presentCoords);
    glVertexAttribPointer(_presentCoords, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
    
    if (![_flipProgram attach:VertexShader fragShader:FlipFragmentsShader]) {
      break;
    }

    [_flipProgram use];
    _flipPosition = [_flipProgram getAttribLocation:"position"];
    _flipCoords = [_flipProgram getAttribLocation:"texcoord"];
    _flipTexture = [_flipProgram getUniformLocation:"my_texture"];
    
    glGenVertexArraysOES(1, &_flipVao);
    glGenBuffers(1, &_flipVbo);
    glGenBuffers(1, &_flipEbo);
    
    glBindVertexArrayOES(_flipVao);
    
    glBindBuffer(GL_ARRAY_BUFFER, _flipVbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _flipEbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // Position attribute
    glEnableVertexAttribArray(_flipPosition);
    glVertexAttribPointer(_flipPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
    
    // TexCoord attribute
    glEnableVertexAttribArray(_flipCoords);
    glVertexAttribPointer(_flipCoords, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
  } while (false);
  [_context leave];
}

- (void)layoutSubviews {
  [super layoutSubviews];
}

- (void)clear {
  
}

@end
