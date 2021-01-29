package com.hilive.realproxy;

import android.content.Intent;
import android.net.VpnService;

public class ProxyService extends VpnService {
    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onRevoke() {
        super.onRevoke();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
