package com.colorcloud.server;

import com.google.android.gcm.server.Message;
import com.google.android.gcm.server.Result;
import com.google.android.gcm.server.Sender;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;


public class GcmSender {
    private static final String TAG = "GCM_Sender";

    protected final Logger logger = Logger.getLogger(getClass().getSimpleName());

    private String mApiKey;
    private Sender mSender;
    
    public GcmSender(String apiKey) {
        mApiKey = apiKey;
        mSender = new Sender(apiKey);
    }
    
    /**
     * send a gcm message to device regId with key/value pair
     */
    public void send(String regId, String key, String msg) {
        Message message = new Message.Builder()
            .addData(key, msg)
            .build();
        try{
            Result reslt = mSender.send(message, regId, 0);
            logger.info(reslt.toString());
        }catch(IOException e){
            logger.warning("send IOException : " + e.toString());
        }
    }
    
    public static void main( String[] args) {
        String apiKey = "AIzaSyB5E-bSD9SnlNHfmxwICU8tcmq0Q1eTrwk";
        String regId = "APA91bH6gu6Nyk6Y0zFYqoS35nnY1MgdZhOE_ojjGfA2XSS2eNeDLjWHFU8G3vfAzrdtTEMXJEVdOCmyrtp6i9JApA2T3AIJIy22Dge345jxt_HsHuDDoa2odVIIilNswD1VW0p39dbZrtQy5XZCQdlWIdamWfzWzw";
        GcmSender sender = new GcmSender(apiKey);
        sender.send(regId, "title", " hello from java gcm-server");
    }
}
