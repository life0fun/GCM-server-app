#!/usr/bin/env coffee

https = require 'https'
url = require 'url'
retry = require 'retry'
emitter = require('events').EventEmitter

#
# A module encaps details of http authorization headers and http request options.
#
# twitter-node is a good example of create http client with http authorization headers 
# and setup request options for http requests.
#

# class defs module pattern with closure contains privacy
class RequestWrapper extends emitter
	constructor: (remoteurl) ->
		@url = url.parse(remoteurl)
        
        # http request options contains http headers.
		@options = {
			host: @url.hostname,
			port: @url.port || 80,
			path: @url.pathname + @url.search || '',
			headers: {}  # http headers inside http request options object.
		}
	
    # static factory for creating instance objects
	@factory: (url, config) ->
		reqw = new RequestWrapper(url)
        # if config option is missing, use whatever get from url
		if typeof config is 'object'
			for own key, value of config
				reqw.setOption(key, value)
		return reqw

	setOption: (key, value) ->
		@options[key] = value
	
    # attach additional http headers to options headers
	attachHeaders: (headers) ->
		if typeof headers is 'object'
			for hd, val of headers
				@options.headers[hd] = val
	
    # instantiate a http.request object and bind respond event handlers
    # if datajson present, this is a post method
	httpRequest : (method, datajson, cb) ->
        @options.method = method

        operation = retry.operation({
            retries: 5          # retry 5 times 
        })

        operation.attempt (currentAttemp) =>
            #console.log 'request options -->', @options

            request = https.request @options, (resp)->
                console.log 'httpRequest handling request response...', resp.statusCode

                reslt = []
                ## retry if the server temporaly unavailable
                if resp.statusCode == 503
                    if (res.headers['retry-after'])
                        retrySeconds = res.headers['retry-after'] * 1; # force number
                        if (isNaN(retrySeconds))
                            # The Retry-After header is a HTTP-date, try to parse it
                            retrySeconds = new Date(res.headers['retry-after']).getTime() - new Date().getTime()
                        if (!isNaN(retrySeconds) && retrySeconds > 0)
                            operation._timeouts['minTimeout'] = retrySeconds
                
                    if (!operation.retry('TemporaryUnavailable'))
                        self.emit('sent', operation.mainError(), null)
                
                    return  # if no error or max retries not reached, keep retrying

                if resp.statusCode >= 400
                    return cb(new Error(resp.statusCode), null)

                # http response normally in utf8. data += chunk.toString('utf8')
                resp.setEncoding 'utf8'
                # data event emits a Buffer (by default) or a string if setEncoding() was used.
                resp.on 'data', (chunk) ->
                    reslt.push chunk
			
                resp.on 'end', () ->
                    body = reslt.join('')   # concat all chunks in the array
                    data = null
                    try
                        data = JSON.parse(body) if body?  # convert to json if existential
                    catch e
                        err = e

                    cb err, data  # send reslt back thru callback
			
            if datajson?
                request.setHeader 'Content-Type', 'application/json'
                request.write JSON.stringify(datajson)

            request.end()
			
    # map get/post to module request function with method name
	get : (cb) ->
		@httpRequest 'GET', null, cb
		
	post: (datajson, cb) ->
		@httpRequest 'POST', datajson, cb
	
# exports class factory to create requirable module.
exports.factory = RequestWrapper.factory

#
# test
#
config = {
    user: 'thezenofworld@gmail.com',
    password: 'same',
    source: 'com.colorcloud.colorcloudmessaging'
}
#req = require('requestwrapper').factory('https://android.googleapis.com/gcm/send', config)
#req.get (err, reslt) -> console.log reslt
#msgobj = { registration_ids : [1,2], data: { title: 'hello' } }
#req.post msgobj, (err, reslt) -> console.log reslt
