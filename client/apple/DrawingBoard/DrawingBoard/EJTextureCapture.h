//
//  EJTextureCapture.h
//  WAOpenGL
//
//  Created by cort xu on 2021/4/24.
//  Copyright © 2021 eldwinwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>
#import <GLKit/GLKit.h>

@interface WAEJTextureCapture : NSObject
@property (nonatomic, readonly) GLint textureId;
@property (nonatomic, readonly) GLint viewWidth;
@property (nonatomic, readonly) GLint viewHeight;
@property (nonatomic, readonly) GLint buffWidth;
@property (nonatomic, readonly) GLint buffHeight;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

- (id)initWithContext:(EAGLContext*)context;
- (BOOL)renderStorage:(CAEAGLLayer*)layer viewWidth:(GLint)viewWidth viewHeight:(GLint)viewHeight;
- (BOOL)renderPresent;

@end

