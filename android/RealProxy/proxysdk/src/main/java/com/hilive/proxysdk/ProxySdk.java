package com.hilive.proxysdk;

public class ProxySdk {
    static {
        LoadDelegate.loadLibrary("proxyjni");
    }

    public ProxySdk() {
    }

    synchronized public boolean login() {
        return true;
    }

    synchronized public boolean bind() {
        return true;
    }

    synchronized public boolean logout() {
        return true;
    }

    public native String stringFromJNI();
}
