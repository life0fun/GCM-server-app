#
# a simple test app to push a hello world msg to device using gcd
#

C2DM = require('c2dm').C2DM

class Hello
    constructor: (@config, @regid) ->
        @sender = new C2DM(@config)
        console.log 'constructor...', @config

    @factory: (config, regid) ->
        h = new Hello(config, regid)
        if typeof options is 'object'
            for own key, value of options
                h[key] = value
        return h

    send: (msg, cb) ->
        msgobj = {
            registration_ids: [@regid],
            collapse_key: 'title-hello',
            data: {
                title: 'hello world',
                score: '4:0'
            }
        }

        console.log 'sending msg : ', msgobj
        @sender.sendWithApiKey msgobj, (err, msgid) ->
            if err
                console.log 'send: error : ', err
                cb err
            else
                console.log 'send: success :', msgid
                cb msgid


exports.factory = Hello.factory

regId = 'APA91bGSsiuxgMi3mDssSsgvPBgLe5JLEEqguY_L-94H-dQcPoJMqI0IySWQRe9CON_RQh9qetkv7VL1qZAwnNTp52TY9eT_Dl5VcqmqURF_b6pYjciqLj_QrOIpnfncMwTcvTW4565l1zeZG1p6wdutkrsfYg-Cig'
config = {
    user: 'thezenofworld@gmail.com',
    password: 'thezenofworld'
    #source: 'com.colorcloud.colorcloudmessaging'
}

sender = Hello.factory(null, regId)
console.log 'done create sender...', regId
sender.send 'hello', (reslt) ->
    console.log 'sending hello: ', reslt

