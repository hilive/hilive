package com.hilive.mediaplayer;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.hilive.mediasdk.MediaSdk;

public class MainActivity extends AppCompatActivity {
    MediaSdk mMediaSd = new MediaSdk();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
        TextView tv = findViewById(R.id.sample_text);
        tv.setText(mMediaSd.test());
    }
}
