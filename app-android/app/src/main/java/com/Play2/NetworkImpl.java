package com.Play2;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.concurrent.Executor;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;


public class NetworkImpl extends Network {

    public HttpResponse download(HashMap<NetworkParams, String> params) {
        try {
            String line;
            StringBuffer jsonString = new StringBuffer();

            URL urlObj = new URL(params.get(NetworkParams.URL));

            String apiKey    = "00000000-0000-0000-0000-000000000000";
            if (params.get(NetworkParams.APIKEY) != null) {
                apiKey = params.get(NetworkParams.APIKEY);
            }

            String n         = "3";
            if (params.get(NetworkParams.N) != null) {
                n = params.get(NetworkParams.N);
            }

            String max         = "5";
            if (params.get(NetworkParams.MAX) != null) {
                max = params.get(NetworkParams.MAX);
            }

            String payload = String.format("{\"jsonrpc\":\"2.0\",\"method\":\"generateIntegers\",\"params\":{\"apiKey\":\"%s\",\"n\":%s,\"min\":1,\"max\":%s,\"replacement\":false,\"base\":10},\"id\":24448}", apiKey, n, max);

            HttpURLConnection connection = (HttpURLConnection) urlObj.openConnection();

            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            OutputStreamWriter writer = new OutputStreamWriter(connection.getOutputStream(), "UTF-8");
            writer.write(payload);
            writer.close();
            BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
            while ((line = br.readLine()) != null) {
                jsonString.append(line);
            }
            br.close();
            connection.disconnect();
            if (connection.getResponseCode() == 200) {
                String response = jsonString.toString();
                HttpResponse a = new HttpResponse((short)200, "", response);
                return a;
            }
        }
        catch (MalformedURLException ex) {
            return new HttpResponse((short)5550, "MalformedURLException", null);
        }
        catch (IOException ex) {
            return new HttpResponse((short)5551, "IOException", null);
        }
        return new HttpResponse((short)0, "Exception", null);
    }

    private static String getString(InputStream stream, String charsetName) throws IOException
    {
        int n = 0;
        char[] buffer = new char[1024 * 4];
        InputStreamReader reader = new InputStreamReader(stream, charsetName);
        StringWriter writer = new StringWriter();
        while (-1 != (n = reader.read(buffer))) {
            writer.write(buffer, 0, n);
        }
        return writer.toString();
    }
}
