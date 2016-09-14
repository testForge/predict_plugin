package mobi.parktag.sdk.plugin;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import mobi.parktag.sdk.Parktag;
import mobi.parktag.sdk.ParktagInterface;

public class ParkTAG extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        Parktag parktag = Parktag.getInstance(getApplicationContext());
        if ("start".equals(action)) {
            startTracker(data, callbackContext);
            return true;
        } else if ("stop".equals(action)) {
            stopTracker(callbackContext);
            return true;
        } else if ("isTrackerRunning".equals(action)) {
            boolean trackerRunning = parktag.isTrackerRunning();
            callbackContext.success(String.valueOf(trackerRunning));
            return true;
        } else if ("setInterface".equals(action)) {
            Log.d("ParkTAG","Parktag interface set");
            parktag.setListener((ParktagInterface) this);
            return true;
        } else if ("isSearchForParkingEnabled".equals(action)) {
            boolean isSearchParkingEnable = parktag.isSearchForParkingEnabled();
            callbackContext.success(String.valueOf(isSearchParkingEnable));
            return true;
        } else if ("isFullPrecisionEnabled".equals(action)) {
            boolean fullPrecisionEnabled = parktag.isFullPrecisionEnabled();
            callbackContext.success(String.valueOf(fullPrecisionEnabled));
            return true;
        } else if ("isEnabled".equals(action)) {
            boolean enabled = parktag.isEnabled();
            callbackContext.success(String.valueOf(enabled));
            return true;
        } else if ("restart".equals(action)) {
            parktag.restart();
            return true;
        } else {
            return false;
        }
    }

    private void stopTracker(CallbackContext callbackContext) {
        try {
            Parktag.getInstance(getApplicationContext()).stop();
            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
            e.printStackTrace();
        }
    }

    private void startTracker(JSONArray params, CallbackContext callbackContext) {
        boolean fullPrecision = false;
        boolean searchForParking = false;
        if (params != null) {
            try {
                fullPrecision = params.optBoolean(0, false);
                searchForParking = params.optBoolean(1, false);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        try {
            Log.d("ParkTAG", "fullPrecision (" + fullPrecision + ") - SearchForParking (" + searchForParking);
            Parktag parktag = Parktag.getInstance(getApplicationContext());
            parktag.enableFullPrecision(fullPrecision);
            parktag.enableSearchForParking(searchForParking);
            parktag.start();
            callbackContext.success();
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
            e.printStackTrace();
        }
    }

    public Context getApplicationContext() {
        return this.cordova.getActivity().getApplicationContext();
    }


}
