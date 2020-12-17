//Events between client and server
event eRequest : requestType;
event eResponse: responseType;

//Events between server and helper
event eProcessReq: int;
event eReqSuccessful;
event eReqFailed;

//Payload types
type requestType = (source: ClientMachine, id:int);
type responseType = (id: int, success: bool);

// Client Machine
machine ClientMachine
sends eRequest;
{
  var server : ClientMachine;
  var nextReqId : int;
  var lastRecvSuccessfulReqId: int;

  start state Init {
    entry (payload : ServerMachine)
    {
      nextReqId = 1;
      server = payload;
      goto StartPumpingRequests;
    }
  }

  state StartPumpingRequests {
    entry {
      var index : int;
      //send 2 requests
      index = 0;
      while(index < 2)
      {
          send server, eRequest, (source = this, id = nextReqId);
          nextReqId = nextReqId + 1;
          index = index + 1;
      }
    }

    on eResponse do (payload: responseType){
        assert(payload.id > lastRecvSuccessfulReqId);
        lastRecvSuccessfulReqId = payload.id;
    }
  }
}

// Server Machine
machine ServerMachine
sends eResponse;
{
  start state Init {
    on eRequest do (payload: requestType){
      var successful : bool;
      successful = $;
      send payload.source, eResponse, (id = payload.id, success = successful);
    }
  }
}

spec ReqIdsAreMonotonicallyIncreasing observes eRequest {
  var previousId : int;
  start state Init {
    on eRequest do (payload: requestType){
        assert(payload.id == previousId + 1);
        previousId = payload.id;
    }
  }
}

spec RespIdsAreMonotonicallyIncreasing observes eResponse {
  var previousId : int;
  start state Init {
    on eResponse do (payload: responseType){
        assert(payload.id == previousId + 1);
        previousId = payload.id;
    }
  }
}

//Test driver that creates 1 client and 1 server for testing the client-server system
machine TestDriver0
receives;
sends;
 {
  start state Init {
    entry {
      var server : ServerMachine;
      //create server
      server = new ServerMachine();
      //create client
      new ClientMachine(server);
    }
  }
}

module ClientModule = {ClientMachine -> ClientMachine};
module ServerModule = {ServerMachine -> ServerMachine};

test testcase0 [main=TestDriver0]: (union { TestDriver0 },
    (assert ReqIdsAreMonotonicallyIncreasing, RespIdsAreMonotonicallyIncreasing in (union ClientModule, ServerModule)));
