package com.example.showfox

import android.media.MediaPlayer
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var mediaPlayer: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 스플래시 효과음 재생
        mediaPlayer = MediaPlayer.create(this, R.raw.splash_sound) // 'splash_sound.mp3'를 res/raw에 저장해야 함
        mediaPlayer?.start()

        // 효과음이 끝난 후 리소스 해제
        mediaPlayer?.setOnCompletionListener {
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        mediaPlayer = null
    }
}
