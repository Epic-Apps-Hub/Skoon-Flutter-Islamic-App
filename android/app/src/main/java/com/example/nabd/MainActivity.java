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


//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "toast")
//        .setMethodCallHandler(
//                (call, result) -> {

//                    if (call.method.equals("show")) {

//                        String text = call.argument("text");
                       
//                     Toast toast=   Toast.makeText(getApplicationContext(), text, Toast.LENGTH_SHORT);
// toast.setGravity(Gravity.TOP|Gravity.RIGHT,0,0);
// toast.show();	
// // View view=toast.getView();
// // view.setBackgroundResource(android.R.drawable.)
//                                     result.success("initialized");
//                    } else {
//                        result.notImplemented();
//                    }
            //    });

 }
}