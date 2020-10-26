package com.example.ZeloApp;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import com.yandex.mapkit.MapKitFactory;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        MapKitFactory.setApiKey("d56f42c2-3507-441f-8100-5d3183b183ba");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}