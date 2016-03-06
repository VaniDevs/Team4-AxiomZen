package axiomzen.co.eva;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ReportActivity extends AppCompatActivity {

    private static final int REQUEST_LOCATION_PERMISSION_CODE = 42;
    LocationManager mLocationManager = null;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_report);

        mLocationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

        Button reportButton = (Button) findViewById(R.id.report_button);
        reportButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                report();
            }
        });
    }

    void report() {
        Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_FINE);

        String bestProvider = mLocationManager.getBestProvider(criteria, true);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    REQUEST_LOCATION_PERMISSION_CODE);

            return;
        }

        Location location = mLocationManager.getLastKnownLocation(bestProvider);
        if (location == null) {
            // TODO:
            return;
        }

        API.ReportRequest request = new API.ReportRequest();
        request.lat = location.getLatitude();
        request.lng = location.getLongitude();

        API.service.report(request).enqueue(new Callback<Object>() {
            @Override
            public void onResponse(Call<Object> call, Response<Object> response) {

                AlertDialog.Builder builder = new AlertDialog.Builder(ReportActivity.this);
                builder.setTitle("OK");
                builder.setMessage("Requested help");
                builder.setPositiveButton("OK", null);
                builder.show();
            }

            @Override
            public void onFailure(Call<Object> call, Throwable t) {

                AlertDialog.Builder builder = new AlertDialog.Builder(ReportActivity.this);
                builder.setTitle("Error");
                builder.setMessage("Failed to request: " + t);
                builder.setPositiveButton("OK", null);
                builder.show();
            }
        });



    }

    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults)
    {
        report();
    }
}
