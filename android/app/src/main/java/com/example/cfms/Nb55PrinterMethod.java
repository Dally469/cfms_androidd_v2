package com.example.cfms;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import java.util.ArrayList;

//import woyou.aidlservice.jiuiv5.*;
import net.nyx.printerservice.print.*;

import java.util.Arrays;


public class Nb55PrinterMethod {

    private final String TAG = Nb55PrinterMethod.class.getSimpleName();
    private ArrayList<Boolean> _printingText = new ArrayList<Boolean>();
    private Handler handler = new Handler(Looper.getMainLooper());
    private Context _context;

    public Nb55PrinterMethod(Context context) {
        this._context = context;
    }

    private IPrinterService printerService;
    public ServiceConnection connService = new ServiceConnection() {
        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.e(TAG, "printer service disconnected, try reconnect");
            printerService = null;
            // 尝试重新bind
            handler.postDelayed(() -> bindPrinterService(), 5000);
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            Log.e(TAG, "onServiceConnected: " + name);
            printerService = IPrinterService.Stub.asInterface(service);
        }
    };

    public void bindPrinterService() {
        Intent intent = new Intent();
        intent.setPackage("net.nyx.printerservice");
        intent.setAction("net.nyx.printerservice.IPrinterService");
        _context.bindService(intent, connService, Context.BIND_AUTO_CREATE);
    }

    public void unbindPrinterService() {
        _context.unbindService(connService);
    }


    public void printText(String text) {

        try {
            PrintTextFormat textFormat = new PrintTextFormat();
            // textFormat.setTextSize(32);
            // textFormat.setUnderline(true);
            int ret = printerService.printText(text, textFormat);
//            if (ret == 0) {
//                printerService.paperOut(80);
//            }
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    public void paperOut() {
        try {
            printerService.paperOut(2);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    /*
    public Boolean setAlignment(Integer alignment) {
        try {
            _woyouService.setAlignment(alignment, this._callback());
            return true;
        } catch (RemoteException e) {
            return false;
        } catch (NullPointerException e) {
            return false;
        }
    }

    public Boolean setFontSize(int fontSize) {
        try {
            _woyouService.setFontSize(fontSize, this._callback());
            return true;
        } catch (RemoteException e) {
            return false;
        } catch (NullPointerException e) {
            return false;
        }
    }
     */
}
