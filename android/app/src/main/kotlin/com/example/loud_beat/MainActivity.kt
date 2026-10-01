package com.example.loud_beat

import android.app.ActivityManager
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setTaskDescription(
            ActivityManager.TaskDescription("LoudBeat")
        )
    }
}