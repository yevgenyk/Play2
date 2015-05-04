package com.Play2;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.*;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.cloay.crefreshlayout.widget.CRefreshLayout;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class RandomRumbers extends Activity {
    static {
        System.loadLibrary("Play2_android");
    }

    private Api                     mApi;
    private StableArrayAdapter      mArrayAdapter;
    private final String dbFile     = "numbers.sqlite";
    private String                  mFilePath;
    private ListView                mListView;
    private long                    mLatestStamp;
    private CRefreshLayout          mRefreshLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_github_users);
        mListView = (ListView)findViewById(R.id.github_user_list);

        try {
            File file = new File(getFilesDir() + File.separator + dbFile);

            if (file.exists() == false) {
                FileOutputStream out = this.openFileOutput(dbFile, Context.MODE_PRIVATE);
                InputStream in = getAssets().open(dbFile);
                byte[] buff = new byte[1024];
                int read = 0;
                while ((read = in.read(buff)) > 0) {
                    out.write(buff, 0, read);
                }
                in.close();
                out.close();
            }
            this.mFilePath = file.getAbsolutePath();
        }
        catch (Exception e) {
            //===>some failure locating or copying DB file
        }

        mApi = Api.create(mFilePath);

        final Runnable r = new Runnable() {
            public void run() {
                loadAndRefresh("", true, "", 25);
            }
        };

        mRefreshLayout = (CRefreshLayout) findViewById(R.id.crefreshLayout);
        mRefreshLayout.setOnRefreshListener(new CRefreshLayout.OnRefreshListener() {
            public void onRefresh() {
                downloadUpdates(r);
            }
        });

        final StableArrayAdapter adapter = new StableArrayAdapter(this,android.R.layout.simple_list_item_1, new ArrayList<Item>());
        mListView.setAdapter(adapter);
        this.mArrayAdapter = adapter;

        refreshListFromDb(r, null);

        downloadUpdates(r);
    }

    private void downloadUpdates(final Runnable runAfterSuccessfulDownload) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mLatestStamp = System.currentTimeMillis();

                    Network net = new NetworkImpl();

                    HashMap<NetworkParams, String> params = new HashMap<NetworkParams, String>();
                    params.put(NetworkParams.URL, "https://api.random.org/json-rpc/1/invoke");
                    params.put(NetworkParams.N, "5");
                    params.put(NetworkParams.MAX, "7");
                    params.put(NetworkParams.APIKEY, "00000000-0000-0000-0000-000000000000");

                    /*
                        //This is the flavor that flies string back and forth jni boundaries. May not be the most efficient
                        //plus there should be no need to deal with raw json response in UI layer
                        HttpResponse response = net.download(params);
                        if (response.getHttpCode() == 200) {
                            String jsonString = response.getData();
                            if (jsonString.length() > 0) {
                                mApi.updateItems(jsonString, mLatestStamp);
                            }
                        }
                    */
                    ParsedItems parsed = mApi.download(params, net);
                    if (parsed.getHttpCode() == 200) {
                        ArrayList<Item> newItems = parsed.getItems();
                        if (newItems.size() > 0) {
                            mApi.updateItemsFromList(newItems, mLatestStamp);
                        }
                    }

                    //--->refresh in UI thread
                    refreshListFromDb(runAfterSuccessfulDownload, getMainLooper());
                }
                catch (Exception e) {
                    System.out.println("\r\r\r\n======> " + e.getMessage());
                }
            }
        }).start();
    }

    private void refreshListFromDb(Runnable r, Looper looper) {
        assert (r != null);
        Handler h = null;

        if (looper != null)
            h = new Handler(looper);
        else
            h = new Handler(); //current thread

        h.postDelayed(r, 0);
    }

    private void loadAndRefresh(String query, boolean clear, String after, int max) {
        if (mFilePath != null) {
            try {
                if (clear) {
                    mArrayAdapter.clear();
                }
                ArrayList<Item> a00 = mApi.itemsGroupedByCount("");
                System.out.print("savedItems returned " + a00.size() + " items for: " + query);
                mArrayAdapter.addAll(a00);
            }
            catch (Exception e) {
                //===>data exception
                System.out.println("\r\r\r\n====000==> " + e.getMessage());
            }
        }
        mArrayAdapter.notifyDataSetChanged();
        mRefreshLayout.setRefreshing(false);
    }

    private class StableArrayAdapter extends ArrayAdapter<Item> {

        public StableArrayAdapter(Context context, int textViewResourceId, List<Item> objects) {
            super(context, textViewResourceId, objects);
        }
        protected class ViewHolder {
            TextView word;
        }
        @Override
        public View getView(int position, View cv, ViewGroup parent) {
            ViewHolder holder = null;
            if (cv == null) {
                LayoutInflater vi = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                cv = vi.inflate(R.layout.github_user_cell, null);
                holder = new ViewHolder();
                holder.word = (TextView) cv.findViewById(R.id.name_label);
                cv.setTag(holder);
            } else {
                holder = (ViewHolder) cv.getTag();
            }

            Item w = this.getItem(position);
            holder.word.setText("Value of " + w.getValue() + " (count " + w.getCount() + ")");
            if (w.getTime() == mLatestStamp) {
                holder.word.setTextColor(Color.BLUE);
            }
            else {
                holder.word.setTextColor(Color.BLACK);
            }
            return cv;
        }
    }
}
