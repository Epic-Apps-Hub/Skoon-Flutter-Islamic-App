package com.skoon.muslim.app;


import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.content.Context;
import android.view.Gravity;
import android.widget.Toast;
import com.ryanheise.audioservice.AudioServiceActivity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
public class MainActivity extends AudioServiceActivity  {
 @Override
 public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
 GeneratedPluginRegistrant.registerWith(flutterEngine);


 }
}