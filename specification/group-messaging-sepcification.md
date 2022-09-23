## Abstract


## Motivation
// TODO

## Specification




## Appendix 1: Data Structures


### Group Signaling

DeliveryState 
```TypeScript
{
  timestamp: number,
  delivered: boolean,
  error: string // optional
}
```

MessageSentSignal 
```JavaScript
{
  from: string,
  group: string,
  messageHash: string,
  deliverState: {
    account: string,
    deliveryState: DeliveryState
  }[],

  // Sender Signature
  signature: string
}
```

MessageReceivedSignal 
```JavaScript
{
  receiver: string,
  group: string,
  deliveryState: DeliveryState,

  // Receiver signature
  signature: string
}
```

MessageState 
```JavaScript
{
  senderDeliverStateClaim: DeliverState[],
  receiverDeliverStateCalim: DeliverState[],
  timestamp: number,
  
  // Group delivery service signature
  signature: string

}
```

MembershipChange
```JavaScript
{
  type: "ADD" | "REMOVE"
  account: string,

  signature: string

}
```

GroupManifest
```JavaScript
{
  adminEnsName: string,
  title: string,
  creationTimestamp: number,
  membersEnsName: string[],
  signature: string
}
```

## Appendix 2: Example Flows

### Group creation with initial message
 ```mermaid
  sequenceDiagram
    actor A as Alice
    participant AA as Alice's App
    participant AD as Alice's Delivery Service
    
    participant BD as Bobs's Delivery Service
    participant BA as Bob's App
    actor B as Bob 
 
    A->>AA: Initial Group Message

    AA->>AD: POST createGroup
    
    AD-->>AA: SUCCESS
    AA->>BD: POST message
    BD-->>AA: SUCCESS
    AA->>AD: POST messageSent
    AD-->>AA: messageState
    BD->>BA: message 
    BA->>AD: GET groupManifest
    AD-->>BA: groupManifest
    BA->>AD: GET messageState
    AD-->>BA: messageState
    BA->>BA: checkMessage
    BA->>AD: POST messageReceived
    AD-->>BA: messageState
    BA->>B: show message
```
 
