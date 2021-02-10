---
title:  'Formal Semantics of P in Maude'
author:
- Manasvi Saxena (msaxena2@illinois.edu)
- Nishant Rodrigues (nishant2@illinois.edu)
keywords: [Semantics, Distributed Systems]
bibliography: bibliography.bib
figPrefix:
  - "Fig."
  - "Figs."
secPrefix:
  - "Section"
  - "Sections"
...

Problem Statement
=================

P is a language for developing asynchronous systems.
Components of a distributed system in P are modeled
as state machines that interact via message passing.
Systems written in P can use the P model checker to
establish correctness. Furthermore, P generates
performant C# code that can be used in production
environments. P has been used successfully used components
of complex large scale systems at AWS and Microsoft.

Even though P finds increasing adoption, the executable
semantics of P are loosely defined in [@DesaiPLDI17].
In this paper, we formally define the executable semantics of
a fragment of the P programming language in Maude.
Our fragment is complete enough to run the examples from the
P tutorial. We demonstrate the use of maude
maude's search capabilities on programs written in our
fragment and demonstrate an alternative methodology of
developing correct asynchronous systems.

Premliminaries
==============

The P Programming Language
--------------------------

In this section, we briefly describe the P language.
P is a Domain Specific Language for building
asynchronous event driven programs [@DesaiPLDI17]. A P program is
a collection of machines that communicate via passing messages.
Each machine has a collection of states, variables and actions.
On receving an event, a machine may transition to another state
by performing the action associated with said transition.
P programs can be analyzed using a model checker, and
compiled into executable code that can be used in a
production environment. Favourable performance has allowed
P to be used in large scale production environments at Microsoft
and Amazon Web Services (AWS) [@DesaiPLDI17].

We futher explain the features of P using an example program.
Consider the following `server` machine written in P.

```
    machine ServerMachine
    sends eResponse ;
    {
      var successful : bool ;
      start state Init {
        on eRequest do (payload : requestType) {
          successful = true ;
          send payload . source, eResponse, (id = payload . id , success = successful) ;
        }
      }
    }  .

```

The machine has a single state `Init`. On receiving an `eRequest`
event, the machine sets updates its internal variable and
sends the souce of the event an `eResponse` message.

Similarly, the `client` machine is defined as:
```
     machine ClientMachine sends eRequest ;
   { var a : int ;
     var server : ServerMachine ;
     var nextReqId : int ;
     var lastRecvSuccessfulReqId : int ;
     var index : int ;

     start state Init {
       entry
      {
         nextReqId = 1 ;
         server = new ServerMachine( .Exps ) ;
         goto StartPumpingRequests ;
       }
    }

    state StartPumpingRequests {
      entry {
        index = 0 ;
        while(index < 2)
        {
            send server, eRequest, (source = this , id = nextReqId) ;
            nextReqId = nextReqId + 1 ;
            index = index + 1 ;
        }
      }

      on eResponse do (payload : responseType) {
           lastRecvSuccessfulReqId = payload . id ;
      }
    }
  }
```
It sends event `eRequest` to the server machine, and after receiving a response,
it updates its internal state to store the id of the last successful
request.

P Semantics in Maude
====================

Syntax {#sec:syntax}
------

In this section, we briefly describe the syntax of various P constructs.
For brevity, we only show some of the operators that make up the
entire syntax.

### Expressions {#sec:syntax-expr}

#### Arithmetic and Boolean Expression
```
  sort Exp .
  subsort Int < Exp .
  subsort Id < Exp .

  op _+_ : Exp Exp -> Exp [prec 33 gather (E e) format (d b o d)] .
  op _/_ : Exp Exp -> Exp [prec 31 gather (E e) format (d b o d)] .

  subsort Bool < Exp .
  op _<=_ : Exp Exp -> Exp  [prec 37 format (d b o d)] .

  --- Assignment Exp
  op _=_ : Id Exp -> Exp [prec 39 format (d b o o)] .

  --- Attributes Expression
  op _._ : Exp Exp -> Exp [prec 38] .
```

Expressions in are semantics are parsed using the `Exp`
sort. For instance, `_+_` is the `binary plus` operator
in the language. `Assignment` takes an identifier on the LHS
and an expression on the RHS.

Statements
----------

### Declarations

```
  --- Expressions To Statements
  op _; : Exp -> Stmt [prec 40] .

  --- Stmt Composition
  op __ : Stmt Stmt -> Stmt [prec 60 gather (e E) assoc id: .Stmt format (d ni d)] .

  --- Variable Statements
  op var_;   : Exp -> Stmt [prec 40 format (y o o o)] .

```

### Blocks

```
  op {} : -> Block [format (b b o)] .
  op {_} : Stmt -> Block [prec 39 format (d n++i n--i d)] .

```

### If, While

```
  op if(_)_else_ : Exp Stmt Stmt -> Stmt [prec 59 format (b so d d s nib o d)] .
  op while(_)_ : Exp Block -> Stmt [prec 59 format (b so d d o d)] .
```

### Machine Declaration

The following constructs are used to define machine in P.
This allows us to parse the entire P program, which
consists of a collection of machines as a `Stmt`.

```
  sort MachineStmt .
  subsort MachineStmt < Stmt .

  op machine_;_ : Id Block -> MachineStmt [prec 41] .
  op machine_sends_;_ : Id Exps Block -> MachineStmt [prec 41] .

```

Semantics
---------

In this section, we describe the semantics of
constructs introduced in section [@sec:syntax].

### Configuration

We organize our configuration as an Associate Commutative
(AC) soup of attributes. Attributes hold information about
program execution. We briefly describe some imporant attributes:

 - *pgm*: Holds the executing program.
 - *machines*: Holds a set of *machine schemas* used to
    create instances of *machines during execution.

```
  subsort Attribute < Configuration .
  op __ : Configuration Configuration -> Configuration [prec 65 assoc comm id: .Attribute] .
  op (( pgm: _ )) : Stmt -> Attribute [prec 64 format(n d ++i -- d)] .
```

### Machine Schemas

P programs allow executing code to dynamically create instances of
machines defined in the program via the `new` construct.
This mechanism is analogous to classes and objects in Object
Oriented Programming. A machine schema or definition in P can be thought of
as a class, and instances of the schema its objects.



