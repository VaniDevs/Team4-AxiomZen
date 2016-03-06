package axiomzen.co.eva;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Intent;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class VerificationActivity extends AppCompatActivity {

    public final static String TOKEN = "co.axiomzen.VerificationActivity.TOKEN";
    public final static String NUMBER = "co.axiomzen.VerificationActivity.NUMBER";

    String mToken = null;
    TextView mPhoneNumberView;
    private TextView mVerificationCodeView;
    private ProgressBar mProgressView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_verification);

        Intent intent = getIntent();
        mToken = intent.getStringExtra(TOKEN);
        String number = intent.getStringExtra(NUMBER);

        Phonenumber.PhoneNumber phoneNumber = parsePhoneNumber(number);
        String formattedNumber = PhoneNumberUtil.getInstance().format(phoneNumber,
                PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL);

        mPhoneNumberView = (TextView)findViewById(R.id.phone_number);
        mPhoneNumberView.setText(formattedNumber);
        mVerificationCodeView = (TextView)findViewById(R.id.verification_code);
        Button verifyButton = (Button) findViewById(R.id.verify_button);
        verifyButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptVerification();
            }
        });

        mProgressView = (ProgressBar)findViewById(R.id.signup_progress);

    }

    private void attemptVerification() {

        showProgress(true);

        API.VerificationRequest request = new API.VerificationRequest();
        request.code = mVerificationCodeView.getText().toString();
        request.token = mToken;

        API.service.verify(request).enqueue(new Callback<API.VerificationResponse>() {
            @Override
            public void onResponse(Call<API.VerificationResponse> call, Response<API.VerificationResponse> response) {
                showProgress(false);

                VerificationActivity context = VerificationActivity.this;

                API.VerificationResponse verificationResponse = response.body();
                API.setToken(context, verificationResponse.token);

                Intent intent = new Intent(context, ReportActivity.class);
                startActivity(intent);
            }

            @Override
            public void onFailure(Call<API.VerificationResponse> call, Throwable t) {
                showProgress(false);

                AlertDialog.Builder builder = new AlertDialog.Builder(VerificationActivity.this);
                builder.setTitle("Error");
                builder.setMessage("Failed to sign up: " + t);
                builder.setPositiveButton("OK", null);
                builder.show();
            }
        });
    }

    Phonenumber.PhoneNumber parsePhoneNumber(String phoneNumber) {
        String locale = getResources().getConfiguration().locale.getCountry();
        try {
            return PhoneNumberUtil.getInstance().parse(phoneNumber, locale);
        } catch (Throwable t) {
            return null;
        }
    }

    private void showProgress(final boolean show) {
        int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);
        mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
        mProgressView.animate().setDuration(shortAnimTime)
                .alpha(show ? 1 : 0)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
                    }
                });
    }
}
