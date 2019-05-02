## OPCUAServerEvent
Creating OPC UA Server with Event
### Description
This sample is creating an OPC UA Server that listens on (default) port 4840.
It has a single object which is able to notify events in its address space.
The server generates this event periodically.
### How to Run
To demo this sample any OPC UA client can be used. The description of this sample is based 
on the free UaExpert which is offered from Automation GmbH.
After running this sample, connecting to the server (localhost or deviceIP) and
browsing the created address space is possible with the client. To view the events,
a document of type "Event View" has to be added to the UaExpert project. Then the
servers object can be added to the event view by drag and drop.
To show this sample a device with OPC UA support is necessary. Alternatively
the emulator of AppStudio 2.2 and higher will support it

### Topics
System, Communication, Sample, SICK-AppSpace