package com.example.loud_beat

import android.app.ActivityManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setTaskDescription(
            ActivityManager.TaskDescription("LoudBeat")
        )
    }
}