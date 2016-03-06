package axiomzen.co.eva;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;


public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        boolean loaded = API.loadToken(this);
        Class clazz = loaded ? ReportActivity.class : SignupActivity.class;
        Intent intent = new Intent(this, clazz);
        startActivity(intent);
        finish();
    }
}
