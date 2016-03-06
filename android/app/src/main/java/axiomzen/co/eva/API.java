package axiomzen.co.eva;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.annotations.SerializedName;

import java.io.IOException;
import java.util.Date;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;

public class API {

    private static String token = null;

    final static String API_TOKEN = "d0bacab2-e412-4f77-8e5d-3b3c7475a750";

    static class SignupRequest {
        String phone;
    }

    static class SignupResponse {
        String token;
    }

    static class VerificationRequest {
        String code;
        String token;
    }

    static class VerificationResponse {
        String token;
    }

    static class ReportRequest {
        Double lat;
        Double lng;
    }

    public interface Service {
        @POST("authenticate")
        Call<SignupResponse> signup(@Body SignupRequest request);

        @POST("authenticate")
        Call<VerificationResponse> verify(@Body VerificationRequest request);

        @POST("report")
        Call<Object> report(@Body ReportRequest request);

    }

    static void setToken(Context context, String token) {
        API.token = token;

        SharedPreferences sharedPref =
                context.getSharedPreferences(context.getString(R.string.api_preferences),
                        Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(context.getString(R.string.preference_token), token);
        editor.commit();
    }

    static boolean loadToken(Context context) {
        SharedPreferences sharedPref =
                context.getSharedPreferences(context.getString(R.string.api_preferences),
                        Context.MODE_PRIVATE);
        String token = sharedPref.getString(context.getString(R.string.preference_token), null);
        if (token == null) {
            return false;
        }

        API.token = token;
        return true;
    }


    final static Service service;
    static {
        HttpLoggingInterceptor loggingInterceptor = new HttpLoggingInterceptor();
        loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

        Interceptor apiTokenInterceptor = new Interceptor() {
            @Override
            public okhttp3.Response intercept(Chain chain) throws IOException {
                Request.Builder builder = chain.request().newBuilder()
                        .addHeader("x-api-token", API_TOKEN);
                if (token != null) {
                    builder.addHeader("x-authentication-token", token);
                }
                return chain.proceed(builder.build());
            }
        };

        OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(loggingInterceptor)
                .addInterceptor(apiTokenInterceptor)
                .build();

        service = new Retrofit.Builder()
                .baseUrl("http://90888a61.ngrok.io/api/v1/")
                .addConverterFactory(GsonConverterFactory.create())
                .client(client)
                .build()
                .create(Service.class);
    }
}
