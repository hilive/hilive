//
// Created by cort xu on 1/28/21.
//
#include <jni.h>
#include <string>

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  JNIEnv* env = NULL;
  if (vm->GetEnv((void**) &env, JNI_VERSION_1_6) != JNI_OK) {
    return -1;
  }

  return JNI_VERSION_1_6;
}

JNIEXPORT void JNI_OnUnload(JavaVM* vm, void* reserved) {
}


extern "C" JNIEXPORT jstring JNICALL
Java_com_hilive_proxysdk_ProxySdk_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}
