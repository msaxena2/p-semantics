--- Client machine from P client-server example

in "../builtins.maude"
in "../p-syntax.maude"

mod DECLS-TEST is
  including P-SYNTAX .

  --- Define some extra Ids
  op clientMachine : -> Stmt .
  ops ClientMachine server nextReqId lastRecvSuccessfulReqId eRequest
  ServerClientInterface lastRecvSuccessfulReqId Init payload StartPumpingRequest
  eResponse responseType -> Id .

endm .

  parse machine ClientMachine sends eRequest;
  { var a : int } .
   var server : ServerClientInterface;
---   var nextReqId : int;
---   var lastRecvSuccessfulReqId: int;
---
---    state Init {
---      entry (payload : ServerClientInterface)
---      {
---        nextReqId = 1;
---        server = payload;
---        goto StartPumpingRequests;
---      }
---    }
---
---    state StartPumpingRequests {
---      entry {
---        var index : int;
---        index = 0;
---        while(index < 2)
---        {
--- ---            send server, eRequest, (source = this to ClientInterface, id = nextReqId);
---            nextReqId = nextReqId + 1;
---            index = index + 1;
---        }
---      }
---
---      on eResponse do (payload: responseType){
------        assert(payload.id > lastRecvSuccessfulReqId);
------        lastRecvSuccessfulReqId = payload.id;
---      }
---    } .


