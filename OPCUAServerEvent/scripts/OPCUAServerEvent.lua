
--Start of Global Scope---------------------------------------------------------

--Create OPC UA server instance
Server = OPCUA.Server.create()
--The server can be bound to a specific interface, using the following line.
--OPCUA.Server.setInterface(Server, "ETH1")
OPCUA.Server.setApplicationName(Server, 'SampleOPCUAServer')

--Creation of namespace and adding it the server.
--Namespaces are organizing the address space.
--Each server can have one or more user defined namespaces.
local namespace = OPCUA.Server.Namespace.create()
OPCUA.Server.setNamespaces(Server, namespace)
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
OPCUA.Server.start(Server)

-- Creation of periodic timer and registration of "gGenerateEvent" function
local i = 1
local timer = Timer.create()
Timer.setExpirationTime(timer, 1000)
Timer.setPeriodic(timer, true)
Timer.start(timer)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---Function is called periodically by timer and increments sample variable
local function generateEvent()
  local numberOfDummyMessageBytes = 10 --Dummy data which is inserted to the event message
  local message = 'Begin Message Event ' .. i .. ' ' ..
            string.rep('x', numberOfDummyMessageBytes) .. ' End Message Event ' .. i
  --Actual notification of the event, which can be viewed in the client
  OPCUA.Server.Node.notifyEvent( objectNode, baseEventTypeNode, 'MEDIUM', message )
  print('Event number: ' .. i)
  i = i + 1
end
Timer.register(timer, 'OnExpired', generateEvent)

--End of Function and Event Scope------------------------------------------------
