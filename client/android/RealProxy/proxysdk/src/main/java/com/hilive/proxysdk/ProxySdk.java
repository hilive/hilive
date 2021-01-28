package com.hilive.proxysdk;

public class ProxySdk {
    static {
        LoadDelegate.loadLibrary("proxyjni");
    }

    public ProxySdk() {
    }

    public native String stringFromJNI();
}
