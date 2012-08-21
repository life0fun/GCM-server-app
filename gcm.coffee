#!/usr/bin/env coffee

#
# a simple test app to push a hello world msg to device using gcd
#
# config:
#   * Post json object msg to https endpoint at android.googleapis.com/gcm/send
#   * Http header Authorization using the API key from your GCM app project page. 
#     https://code.google.com/apis/console/#project:686172024995:access
#   * Cache a list of devices GCM registration ids for msg to be sent to each of them.
#   * device GCM registration id is obtained when device registered to GCM on Android phone.
#
# Dependency: requestwrapper.coffee 
#   * https headers for authorization and request options
#
# Usage: coffee gcm.coffee 'gym time'
#

ReqWrapper = require('./requestwrapper')

class GCM
    constructor: (@config, @regid) ->
        @gcm_url = 'https://android.googleapis.com/gcm/send'
        # http request options 
        @gcmOptions = {
            host: 'android.googleapis.com',
            port: 443,
            path: '/gcm/send',
            method: 'POST',
            headers: {}
        }

        ## this http header contain api key for gcm server to identify the app
        @apiHeader = {
            'Authorization': 'key=AIzaSyB5E-bSD9SnlNHfmxwICU8tcmq0Q1eTrwk',
            #'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Type': 'application/json'
        }

        @request = ReqWrapper.factory @gcm_url, @gcmOptions
        @request.attachHeaders @apiHeader

    @factory: (config, regid) ->
        g = new GCM(config, regid)
        if typeof options is 'object'
            for own key, value of options
                g[key] = value
        return g

    send: (msg, cb) ->
        msgobj = {
            registration_ids: [@regid],
            collapse_key: 'groupby-time',
            data: {
                title: msg,
                score: '4:0'
            }
        }

        @request.post msgobj, (err, reslt) ->
            if err
                cb err
            else
                cb reslt

exports.factory = GCM.factory

# not usable config block
config = {
    user: 'thezenofworld@gmail.com',
    password: 'xxxx'
    source: 'com.colorcloud.colorcloudmessaging'
}

# the regId of my vanquish, does the regId changes across app restart ?
#deviceGcmRegId = 'APA91bGXuFVeoz-x_ReIZQu4mhNT5Q7eJQuNnJcH9LIX551DWBAJquHeNUu5_6HLuQp9zSyFOAUWCFC_Zs0GDNHkeiWkg0Tn7OvmFH9cr62I_Xc4Nk4-6ui_12wZea8URZAasmdZa1CyKKMxMz3S0JmH_nP7l-O2oA'
deviceGcmRegId = 'APA91bH6gu6Nyk6Y0zFYqoS35nnY1MgdZhOE_ojjGfA2XSS2eNeDLjWHFU8G3vfAzrdtTEMXJEVdOCmyrtp6i9JApA2T3AIJIy22Dge345jxt_HsHuDDoa2odVIIilNswD1VW0p39dbZrtQy5XZCQdlWIdamWfzWzw'
request = GCM.factory(config, deviceGcmRegId)
message = process.argv[2] ? 'hello world'
request.send message, (reslt) ->
