package com.example.cfms;
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
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
import android.os.Bundle;
import net.nyx.printerservice.print.*;
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.cfms/nb55_printer";
    private static Nb55PrinterMethod Nb55PrinterMethod;
    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        Nb55PrinterMethod = new Nb55PrinterMethod(this);
    }
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            Log.e("Nb55PrinterPlugin", call.method);
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
                                case "PAPER_OUT":
                                    Nb55PrinterMethod.paperOut();
                                    result.success(true);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }
}