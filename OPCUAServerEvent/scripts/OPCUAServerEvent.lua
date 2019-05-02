--[[----------------------------------------------------------------------------

  Application Name: OPCUAServerEvent

  Description:
  Creating OPC UA Server which generates events

  This sample is creating an OPC UA Server that listens on (default) port 4840.
  It has a single object which is able to notify events in its address space.
  The server generates this event periodically.

  To demo this sample any OPC UA client can be used. The description of this sample
  is based on the free UaExpert which is offered from Automation GmbH.
  After running this sample, connecting to the server (localhost or deviceIP) and
  browsing the created address space is possible with the client. To view the events,
  a document of type "Event View" has to be added to the UaExpert project. Then the
  servers object can be added to the event view by drag and drop.
  To show this sample a device with OPC UA support is necessary. Alternatively
  the emulator of AppStudio 2.2 and higher will support it.

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

--Create OPC UA server instance
-- luacheck: globals gServer
gServer = OPCUA.Server.create()
--The server can be bound to a specific interface, using the following line.
--OPCUA.Server.setInterface(server, "ETH1")
OPCUA.Server.setApplicationName(gServer, 'SampleOPCUAServer')

--Creation of namespace and adding it the server.
--Namespaces are organizing the address space.
--Each server can have one or more user defined namespaces.
local namespace = OPCUA.Server.Namespace.create()
OPCUA.Server.setNamespaces(gServer, namespace)
--Every namespace has an index. 0 and 1 are reserved for OPC UA standard namespaces
OPCUA.Server.Namespace.setIndex(namespace, 2)

--Creation of folder that will be used as root node for the namespace.
--Every namespace needs a root node.
local allNodes = {}
local rootNode = OPCUA.Server.Node.create('OBJECT')
OPCUA.Server.Node.setID(rootNode, 'STRING', 'SampleRoot')
OPCUA.Server.Node.setTypeDefinition(rootNode, 'FOLDER_TYPE')
OPCUA.Server.Namespace.setRootNode(namespace, rootNode)
table.insert(allNodes, rootNode)

--Events need to have a type. This sample uses the BaseEventType from the
--OPC UA standard namespace. It is also possible to create own event types.
local baseEventTypeNode =
  OPCUA.Server.Namespace.getNodeFromStandardNamespace( namespace, 'NUMERIC', 2041 ) -- 2041: BaseEventType

-- Creation of an object node
local objectNode = OPCUA.Server.Node.create('OBJECT')
OPCUA.Server.Node.setID(objectNode, 'STRING', 'SampleObject')
table.insert(allNodes, objectNode)

-- Adding the object node to the folder rootNode
OPCUA.Server.Node.addReference(rootNode, 'ORGANIZES', objectNode)
-- Adding the object node as an event source of the root node
OPCUA.Server.Node.addReference(rootNode, 'HAS_EVENT_SOURCE', objectNode)

-- Adding all created nodes to the namespace
OPCUA.Server.Namespace.setNodes(namespace, allNodes)

-- Starting the server
OPCUA.Server.start(gServer)

-- Creation of periodic timer and registration of "gGenerateEvent" function
local i = 1
-- luacheck: globals gTimer
gTimer = Timer.create()
Timer.setExpirationTime(gTimer, 1000)
Timer.setPeriodic(gTimer, true)
Timer.register(gTimer, 'OnExpired', 'gGenerateEvent')
Timer.start(gTimer)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Function is called periodically by timer and increments sample variable
-- luacheck: globals gGenerateEvent
function gGenerateEvent()
  local numberOfDummyMessageBytes = 10 --Dummy data which is inserted to the event message
  local message = 'Begin Message Event ' .. i .. ' ' ..
            string.rep('x', numberOfDummyMessageBytes) .. ' End Message Event ' .. i
  --Actual notification of the event, which can be viewed in the client
  OPCUA.Server.Node.notifyEvent( objectNode, baseEventTypeNode, 'MEDIUM', message )
  print('Event number: ' .. i)
  i = i + 1
end

--End of Function and Event Scope------------------------------------------------
