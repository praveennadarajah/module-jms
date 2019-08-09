// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/java;
import ballerina/log;

# Represents JMS Connection
#
# + config - Used to store configurations related to a JMS Connection
public type Connection client object {

    public ConnectionConfiguration config = {};
    private handle jmsConnection = java:createNull();

    # JMS Connection constructor
    public function __init(ConnectionConfiguration c) {
        self.config = c;
        self.createConnection();
    }

    function createConnection() {
        
        handle icf = java:fromString(self.config.initialContextFactory);

        handle providerUrl = java:fromString(self.config.providerUrl);
        handle factoryName = java:fromString(self.config.connectionFactoryName);

        handle|error value = createJmsConnection(icf, providerUrl, factoryName, self.config.properties);
        if (value is handle) {
            self.jmsConnection = value;
            log:printInfo("Successfully connected to broker.");
        } else {
            log:printError("Error connecting broker", value);
        }
    }

    # Starts (or restarts) a connection's delivery of incoming messages.
    # A call to start on a connection that has already been started is ignored.
    public remote function start() {
        error? err = startJmsConnection(self.jmsConnection);
        if (err is error) {
            log:printError("Error starting connection", err);
        }
        
    }
    
    # Temporarily stops a connection's delivery of incoming messages.
    # Delivery can be restarted using the connection's start method.
    public remote function stop() {
        error? err = stopJmsConnection(self.jmsConnection);
        if (err is error) {
            log:printError("Error stopping connection", err);
        }
    }

    function getJmsConnection() returns handle {
        return self.jmsConnection;
    }
};

# Configurations related to a JMS connection
#
# + initialContextFactory - JMS provider specific inital context factory
# + providerUrl - JMS provider specific provider URL used to configure a connection
# + connectionFactoryName - JMS connection factory to be used in creating JMS connections
# + username - Username for the JMS connection
# + password - Password for the JMS connection
# + properties - Additional properties use in initializing the initial context
public type ConnectionConfiguration record {|
    string initialContextFactory = "wso2mbInitialContextFactory";
    string providerUrl = "amqp://admin:admin@ballerina/default?brokerlist='tcp://localhost:5672'";
    string connectionFactoryName = "ConnectionFactory";
    string? username = ();
    string? password = ();
    map<string> properties = {};
|};

public function startJmsConnection(handle jmsConnection) returns error? = @java:Method {
    name: "start",
    class: "javax.jms.Connection"
} external;


public function stopJmsConnection(handle jmsConnection) returns error? = @java:Method {
    name: "stop",
    class: "javax.jms.Connection"
} external;