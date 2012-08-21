# GCM Server side App

The GCM server side App(gcm.coffee) allows you to send messages to device from your console.
The App connects to google API server using your Google API project credentials.
After connecting, it can post message to google API server through https POST.
Google API server will broadcast the message to all the devices that registered to GCM.

There is also a java project included to demo how to use gcm-server.jar to send message to client.
The gcm-server.jar handles retries gracefully when sending to a list of devices.

A curl python script is included to send message to broadcast channel through Parser.
Device Android App has seamlessly integrated both GCM and Parser into one service. The Android App
listens to both GCM and Parser channels for incoming messages and store/display the message with
the same fragment UI.

## How to obtain the device GCM registeration Id ?

After device registrated to GCM, it got a registration ID. Server app needs that registration ID
in order to be able to send message to the device. That said, our server app needs to provide 
a http post API for device to inform back the GCM registration Id. The post API just get the value
of registration key and store it into a list.

Please refer to sdk gcm-demo-server Registration servlet code.

## Usage

For node server app, edit the gcm.coffee file to specify the API key and device Reg ID.
For java server app, build the app with ant and execute the gcm-sender.jar. 
