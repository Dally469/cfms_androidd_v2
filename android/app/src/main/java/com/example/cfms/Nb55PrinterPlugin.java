package com.example.cfms;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


/**
 * SunmiPrinterPlugin
 */
public class Nb55PrinterPlugin implements FlutterPlugin, MethodCallHandler {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static Nb55PrinterMethod Nb55PrinterMethod;

    @Override
    public void onAttachedToEngine(
            @NonNull FlutterPluginBinding flutterPluginBinding
    ) {
        final MethodChannel channel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                "nb55_printer"
        );
        Log.e("Nb55PrinterPlugin","Initialization");
        Nb55PrinterMethod =
                new Nb55PrinterMethod(flutterPluginBinding.getApplicationContext());
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It
    // supports the old pre-Flutter-1.12 Android projects. You are encouraged to
    // continue supporting plugin registration via this function while apps migrate
    // to use the new Android APIs post-flutter-1.12 via
    // https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith
    // to keep them functionally equivalent. Only one of onAttachedToEngine or
    // registerWith will be called depending on the user's project.
    // onAttachedToEngine or registerWith must both be defined in the same class.

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.e("Nb55PrinterPlugin",call.method);
        switch (call.method) {
            case "BIND_PRINTER_SERVICE":
                Nb55PrinterMethod.bindPrinterService();
                result.success(true);
                break;
            case "UNBIND_PRINTER_SERVICE":
                Nb55PrinterMethod.unbindPrinterService();
                result.success(true);

                break;
            case "PRINT_TEXT":
                String text = call.argument("text");

                Nb55PrinterMethod.printText(text);
                result.success(true);

                break;
            case "FONT_SIZE":
//                int fontSize = call.argument("size");
//                Nb55PrinterMethod.setFontSize(fontSize);
//                result.success(true);
                break;
            case "SET_ALIGNMENT":
//                int alignment = call.argument("alignment");
//                Nb55PrinterMethod.setAlignment(alignment);
//                result.success(true);
                break;
            case "CUT_PAPER":
                result.notImplemented();
//                Nb55PrinterMethod.cutPaper();
//                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}