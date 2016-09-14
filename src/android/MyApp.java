package mobi.parktag.sdk.plugin;

import android.app.Application;
import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import mobi.parktag.sdk.Parktag;
import mobi.parktag.sdk.ParktagInterface;

public class MyApp extends Application implements ParktagInterface {

    @Override
    public void onCreate() {
        super.onCreate();
        Parktag.getInstance(getApplicationContext()).setListener((ParktagInterface) this);
    }

    @Override
    public void vacatedParking(Location startLocation, long timeOfDetection) {
        notify(getApplicationContext(), 1, "Vacated Parking", "User just vicated a parking ");
    }

    @Override
    public void vehicleParked(Location parkedLocation, long startTime, long endTime) {
        notify(getApplicationContext(), 2, "Vehicle Parked", "User just parked his vehicle");
    }

    @Override
    public void lookingForParking(Location location) {
        notify(getApplicationContext(), 3, "Looking for Parking", "ParkTAG has detected that you are looking for parking");
    }

    @Override
    public void newLocationReceived(Location location) {
    }

    @Override
    public void activationFailed(int errorCode) {
        notify(getApplicationContext(), 4, "activationFailed", "Something went wrong, Error Code : " + errorCode);
    }

    private void notify(Context context, int id, String title, String Detail) {
        try {
            Notification noti = new NotificationCompat.Builder(context)
                    .setContentTitle(title)
                    .setTicker(Detail)
                    .setContentText(Detail)
                    .setDefaults(Notification.DEFAULT_ALL)
                    .setSmallIcon(android.R.drawable.ic_dialog_alert)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), android.R.drawable.ic_dialog_alert))
                    .build();
            noti.flags |= Notification.FLAG_AUTO_CANCEL;
            NotificationManager notificationManager = (NotificationManager) context
                    .getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.notify(id, noti);
        } catch (Exception e) {
            Log.e("Error", "Error = " + e.getMessage());
        }
    }
}