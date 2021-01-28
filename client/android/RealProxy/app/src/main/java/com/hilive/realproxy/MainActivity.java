package com.hilive.realproxy;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.hilive.proxysdk.ProxySdk;

public class MainActivity extends AppCompatActivity {
    private ProxySdk mSdk = new ProxySdk();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tv = (TextView) findViewById(R.id.tvTest);
        tv.setText(mSdk.stringFromJNI());
    }
}