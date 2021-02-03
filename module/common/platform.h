//
//  platform.h
//  common
//
//  Created by cort xu on 2021/2/4.
//

#pragma once


#if defined(HILIVE_IOS)
#ifndef PLATFORM_IOS
#define PLATFORM_IOS  1
#endif
#elif defined(HILIVE_MAC)
#ifndef PLATFORM_MAC
#define PLATFORM_MAC  1
#endif
#elif defined(HILIVE_ANDROID)
#ifndef PLATFORM_ANDROID
#define PLATFORM_ANDROID  1
#endif
#elif defined(HILIVE_WIN)
#ifndef PLATFORM_WIN
#define PLATFORM_WIN  1
#endif
#endif
