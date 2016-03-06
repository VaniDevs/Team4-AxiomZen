package axiomzen.co.eva;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.ProgressBar;

import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber.PhoneNumber;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class SignupActivity extends AppCompatActivity {

    private AutoCompleteTextView mPhoneNumberTextView;
    private ProgressBar mProgressView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        final Button signUpButton = (Button) findViewById(R.id.sign_up_button);
        signUpButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptSignup();
            }
        });


        mPhoneNumberTextView = (AutoCompleteTextView) findViewById(R.id.phone_number);
        mPhoneNumberTextView.addTextChangedListener(new TextWatcher() {

            @Override
            public void afterTextChanged(Editable s) {}

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start,
                                      int before, int count) {
                signUpButton.setEnabled(parsePhoneNumber() != null);
            }
        });

        mProgressView = (ProgressBar)findViewById(R.id.signup_progress);
    }


    private void attemptSignup() {

        PhoneNumber number = parsePhoneNumber();
        if (number == null) {
            return;
        }

        final String formattedNumber = PhoneNumberUtil.getInstance()
                .format(number, PhoneNumberUtil.PhoneNumberFormat.E164);

        showProgress(true);

        API.SignupRequest request = new API.SignupRequest();
        request.phone = formattedNumber;

        API.service.signup(request).enqueue(new Callback<API.SignupResponse>() {
            @Override
            public void onResponse(Call<API.SignupResponse> call, Response<API.SignupResponse> response) {
                showProgress(false);

                API.SignupResponse signupResponse = response.body();
                Intent intent = new Intent(SignupActivity.this, VerificationActivity.class);
                intent.putExtra(VerificationActivity.TOKEN, signupResponse.token);
                intent.putExtra(VerificationActivity.NUMBER, formattedNumber);
                startActivity(intent);
            }

            @Override
            public void onFailure(Call<API.SignupResponse> call, Throwable t) {
                showProgress(false);

                AlertDialog.Builder builder = new AlertDialog.Builder(SignupActivity.this);
                builder.setTitle("Error");
                builder.setMessage("Failed to sign up " + formattedNumber + ": " + t);
                builder.setPositiveButton("OK", null);
                builder.show();
            }
        });
    }

    PhoneNumber parsePhoneNumber() {
        String locale = getResources().getConfiguration().locale.getCountry();
        String phoneNumber = mPhoneNumberTextView.getText().toString();
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

