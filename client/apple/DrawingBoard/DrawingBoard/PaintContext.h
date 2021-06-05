//
//  PaintContext.h
//  DrawingBoard
//
//  Created by cort xu on 2021/5/30.
//

#ifndef PaintContext_h
#define PaintContext_h
#import <Foundation/Foundation.h>
#import "common/GLDefine.h"

@interface PaintContext : NSObject
- (BOOL)render:(CAEAGLLayer*)layer;
@end

#endif /* PaintContext_h */
