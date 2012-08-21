import urllib, urllib2
 
"""
c2dm to push msg to device.
this class run at your server side and talk to google c2dm server.
it obtain an access token from c2dm server and uses this token to identify itself
when talking to c2dm server later. 

http://blog.serverdensity.com/2010/10/07/android-push-notifications-tutorial/

You can also do quick curl
Auth
  curl https://www.google.com/accounts/ClientLogin -d Email=$1 -d "Passwd=$2" -d accountType=GOOGLE -d source=My-Server-Event-Alerter -d service=ac2dm
Send:
  curl --header "Authorization: GoogleLogin auth=$1" "https://android.apis.google.com/c2dm/send" -d registration_id=$2 -d "data.payload=$3" -d collapse_key=myappalert09

"""

class ClientLoginTokenFactory(): 
    _token = None
     
    def __init__(self):
        self.url = 'https://www.google.com/accounts/ClientLogin'
        self.accountType = 'GOOGLE'
        self.email = 'example@gmail.com'
        self.password = 'password'
        self.source = 'Domokun'
        self.service = 'ac2dm'
     
    def getToken(self): 
        if self._token is None:
             
            # Build payload
            values = {'accountType' : self.accountType,
                      'Email' : self.email,
                      'Passwd' : self.password, 
                      'source' : self.source, 
                      'service' : self.service}
             
            # Build request
            data = urllib.urlencode(values)
            request = urllib2.Request(self.url, data)
            # request.add_header({'User-Agent', 'Mozilla 4.0'})
             
            # Post
            response = urllib2.urlopen(request)
            responseAsString = response.read()
             
            # Format response
            responseAsList = responseAsString.split('n')
             
            self._token = responseAsList[2].split('=')[1]
             
        return self._token


"""
this class build the request, get your ClientAuth token, and send to c2dm server
To send a msg to a device, device must have reg to the c2dm server, and obtained
an id that identify the device. Sender server uses this id to specify msg to the device.
"""
class C2DM():
     
    def __init__(self):
        self.url = 'https://android.apis.google.com/c2dm/send'
        self.clientAuth = None
        self.registrationId = None    # reg id is the id device obtained from c2dm
        self.collapseKey = None
        self.data = {}
         
    def sendMessage(self):
        if self.registrationId == None or self.collapseKey == None:
            return False
         
        clientAuthFactory = ClientLoginTokenFactory()
        self.clientAuth = clientAuthFactory.getToken()
         
        # Loop over any data we want to send
        for k, v in self.data.iteritems():          
            self.data['data.' + k] = v
             
        # Build payload
        values = {'registration_id' : self.registrationId,
                  'collapse_key' : self.collapseKey}        
         
        # Build request
        headers = {'Authorization': 'GoogleLogin auth=' + self.clientAuth}      
        data = urllib.urlencode(values)
        request = urllib2.Request(self.url, data, headers)
         
        # Post
        try:
            response = urllib2.urlopen(request)
            responseAsString = response.read()
             
            return responseAsString
        except urllib2.HTTPError, e:
            print 'HTTPError ' + str(e)


if __name__ == '__main__':
    mypushserver = C2DM()
    mypushserver.registrationId = 'XXX'
    mypushserver.collapseKey = 1
    mypushserver.data = { 'message': 'hello world', 'XXX' : 12 }
    response = mypushserver.sendMessage()
