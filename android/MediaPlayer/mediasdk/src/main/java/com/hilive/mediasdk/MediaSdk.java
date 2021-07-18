package com.hilive.mediasdk;

public class MediaSdk {
    private static final String TAG = "[hilive][MediaSdk]";
    private boolean mInited = false;

    static {
        LoadDelegate.loadLibraries();
    }

    public MediaSdk() {
    }

    synchronized public boolean init() {
        return false;
    }

    synchronized public String test() {
        return stringFromJNI();
    }

    synchronized public void uint() {

    }

    public native String stringFromJNI();
}
