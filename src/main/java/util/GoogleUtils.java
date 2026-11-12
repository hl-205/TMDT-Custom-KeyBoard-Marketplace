package util;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import model.GoogleAccount;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

public class GoogleUtils {

    // THAY CLIENT_ID VÀ CLIENT_SECRET TỪ GOOGLE CLOUD CONSOLE CỦA BẠN VÀO ĐÂY
    public static final String GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com";
    public static final String GOOGLE_CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET";

    public static final String GOOGLE_GRANT_TYPE = "authorization_code";
    public static final String GOOGLE_LINK_GET_TOKEN = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";

    // Tự động lấy đúng đường dẫn Redirect URI (kể cả khi chạy có hoặc không có /KeebHub)
    public static String getRedirectUri(String baseUrl) {
        return baseUrl + "/login-google";
    }

    public static String getAuthorizationUrl(String baseUrl, String state) {
        String redirectUri = getRedirectUri(baseUrl);
        String url = "https://accounts.google.com/o/oauth2/v2/auth"
                + "?scope=" + URLEncoder.encode("email profile openid", StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&client_id=" + URLEncoder.encode(GOOGLE_CLIENT_ID, StandardCharsets.UTF_8)
                + "&prompt=select_account";
        if (state != null && !state.isBlank()) {
            url += "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8);
        }
        return url;
    }

    public static String getToken(String code, String redirectUri) throws IOException, InterruptedException {
        String formBody = "client_id=" + URLEncoder.encode(GOOGLE_CLIENT_ID, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(GOOGLE_CLIENT_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&grant_type=" + URLEncoder.encode(GOOGLE_GRANT_TYPE, StandardCharsets.UTF_8);

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GOOGLE_LINK_GET_TOKEN))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        JsonObject jobj = new Gson().fromJson(response.body(), JsonObject.class);

        if (jobj == null || !jobj.has("access_token")) {
            throw new IOException("Lỗi lấy access_token từ Google: " + response.body());
        }
        return jobj.get("access_token").getAsString();
    }

    public static GoogleAccount getUserInfo(final String accessToken) throws IOException, InterruptedException {
        String link = GOOGLE_LINK_GET_USER_INFO + URLEncoder.encode(accessToken, StandardCharsets.UTF_8);

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(link))
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return new Gson().fromJson(response.body(), GoogleAccount.class);
    }
}