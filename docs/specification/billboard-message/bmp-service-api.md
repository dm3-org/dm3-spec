# Billboard Service API

The Billboard Service API provides the functions needed to retrieve the billboard information (like messages, ...).

The billboard service is a JSON-RPC service, following the JSON-RPC 2.0 specification (see also [RPC1]).


- [Billboard Service API](#billboard-service-api)
  - [Retrieve the Billboard Messages](#retrieve-the-billboard-messages)
    - [Methode](#methode)
    - [Request](#request)
    - [Response](#response)
    - [Websocket connection](#websocket-connection)
  - [Retrieve List of Billboards](#retrieve-list-of-billboards)
    - [Methode](#methode-1)
    - [Response](#response-1)
  - [Retrieve Billboard's Properties](#retrieve-billboards-properties)
    - [Methode](#methode-2)
    - [Response](#response-2)
  - [Delete/block an (inappropriate) Message](#deleteblock-an-inappropriate-message)
    - [Methode](#methode-3)
    - [Request](#request-1)
    - [Response](#response-3)
  - [Delete/block an (inappropriate) Message, SIWE](#deleteblock-an-inappropriate-message-siwe)
    - [Methode](#methode-4)
    - [Request](#request-2)
    - [Response](#response-4)
  - [Suspend Sender](#suspend-sender)
    - [Methode](#methode-5)
    - [Request](#request-3)
    - [Response](#response-5)
  - [Get active viewers](#get-active-viewers)
    - [Methode](#methode-6)
    - [Request](#request-4)
    - [Response](#response-6)

## Retrieve the Billboard Messages

The billboard is a list of statements (messages) from all participants which is ordered by the creation time. Since the number of entries can be very large, the return is paged and only a defined number of results are returned per retrieval.

Each entry in the list is a **dm3** [MessageDataStructure](../message-transport/mtp-transport.md#message-data-structure) where the message entry is not encrypted.

### Methode

This method is called to retrieve a block (page) of statements.

```TypeScript
// call to request a number of statements
dm3_billboard_getMessages
```

### Request

The request passes the **identifier** of the billboard and a description which messages must be returned. As messages may be paged, the information must be provided, which messages are already read. So it must be possible to fetch newest messeges first and get the older ones page by page, too.

These parameters must be provided to define which messages should be returned:

- **idBillboard** The **id** of the billboard which messages should be returned. This is the ENS name of the billboard.
- **time** This is the time of the newest requested message. If older messages are fetched, `time` is the timestamp of the last already fetched message. If `time` is empty or undefined, the most current message is addressed. If several messages have the same timestamp, all of these messages will be returned, even if the number of maximum messages per page is reached.
- **cursor** The time of the newest message of the complete block. If `cursor` is empty or undefined, no messages are already fetched and `cursor` is set to zero.

```TypeScript
// the id of the billboard
idBillboard = <ENS name of the requested billboard>
// the time of the message to be started of the current page
// maybe empty or undefined
time? = <the time>
// the time of the latest message of the (complete) block of messages 
cursor? = <time of the latest message of the block>
```

If `time` is empty or undefined, the first page (`k` entries) of the newest messages of the billboard is returned. The viewer can request other pages (backwards) until the `cursor` is reached (then all messages are fetched). For performance reasons it may be appropriate to only fetch the first page starting with the newest message and additional pages only if needed.

The fetching and paging process is visualized in the graph:
![image](fetch_messages.svg)

### Response

The list of messages is returned.

```JavaScript
{
  messages: MessageDataStructure[],
}
```

> **Example** Billboard Messages:
>
> ```JavaScript
> {
>    "messages": 
>    [
>      {
>         "message":"message 1",
>         "metadata":{...},
>         ...
>      },{
>         "message":"message 2",
>         "metadata":{...},
>         ...
>      },
>    ]
> }
> ```

In case of an error, an error object is returned as described in [error codes](#error-codes).

### Websocket connection

Optionally, a websocket connection can established to retrieve updates via the direct connection to the billboard service.
The data from the past are then retrieved and supplemented page by page as needed (such as initialization, scrolling into the past,...). New messages are fetched directly using the websocket.

## Retrieve List of Billboards

One billboard service can host multiple billboards. The list can be queried.

### Methode

This method is called to retrieve the list of available billboards.

```TypeScript
// call to request the list of available billboards
dm3_billboard_list
```

### Response

The list with the ENS-names containing the dm3 profile for each billboard is return.

```JavaScript
{
  billboards: string[],
}
```

> **Example** List of Billboards:
>
> ```JavaScript
> {
>    "billboards": 
>    [
>      "billboard01.billboards.example.eth",
>      "billboard02.billboards.example.eth",
>    ],
> }
> ```

## Retrieve Billboard's Properties

Each billboard is defined by a ENS name providing a **dm3** profile (see [dm3 profile](../message-transport/mtp-registry.md#user-profile)). While this profile contains all information needed for sending messages to the billboard, additinal information and properties can be requested from the billboard service.

- **Name:** The name od the billboard. This name may be shown in the billboard message viewer.
- **Mediators:** Mediators have the task of moderating the chat conversation. They have the ability to delete/block inappropriate comments (these will then no longer be delivered). They can also exclude users from the discussion. Then all their comments will not be delivered and they will not be able to post new comments. Mediators are defined by their ENS name or address.
- **Minimum Waiting Time:** For each billboard, it is defined how long a participant has to wait after posting a comment before being allowed to post another comment. This ensures that the discussion is balanced and not dominated by individual participants. This is enforced by the UI only.

```JavaScript
DEFINITION: Billboard Properties

{
  name: string,
  mediators: string[],
  time: number,
}
```

### Methode

This method is called to retrieve the list of available billboards.

```TypeScript
// call to request the list of available billboards
dm3_billboard_list
```

### Response

The list with the ENS-names containing the dm3 profile for each billboard is return.

```JavaScript
{
  billboards: string[],
}
```

> **Example** List of Billboards:
>
> ```JavaScript
> {
>    "billboards": 
>    [
>      "billboard01.billboards.example.eth",
>      "billboard02.billboards.example.eth",
>    ],
> }
> ```

In case of an error, a RPC error message is returned.

## Delete/block an (inappropriate) Message

Mediators have the task and the right to block or delete inappropriate content. The Billboard service provides a function to mark a particular message as to be deleted. This can only be done by the mediators defined in the Billboard service, confirming this authorization with a signature.

Deleted messages will NOT any longer published by the [billboard service](bmp-client.md#billboard-service) but may kept in the database of the [billboard client](bmp-client.md#billboard-client), marked as blocked/deleted.

### Methode

This method is called to delete/block a message.

```TypeScript
// call to delete a message
dm3_billboard_deleteMessage
```

### Request

The request passes the **identifier** of the billboard and the  **identifier** of the message. Also, a signature of the mediator is passed to proof the autority to execute this function and to ensure traceability.

- **idBillboard** The **id** of the billboard where a messages should be deleted.
- **idMessage** The **id** of the message which should be deleted. This is the hash of the message.
- **mediator** The ENS name of the mediator who deleted the messages. This ENS name must contain a valid **dm3** profile.
- **signature** The signature of the above information, signed by the mediators signing key (defined in [**dm3** profile](../message-transport/mtp-registry.md#user-profile))

```TypeScript
// the id of the billboard
idBillboard = <ens name of the billboard>
// the id of the message to be deleted
idMessage = <hash of the message>
// the ENS name of the mediator
mediator = <ens name of the mediator>
// signature:  
signature = sign(sha256(safe-stable-stringify(idBillboard+idMessage)))
```

### Response

The response is as defined in the JSON-RPC specification. In case of an error, an error message is returned.

> **Example**
>
> ```TypeScript
> {
>  "jsonrpc": "2.0", 
>  "error": {
>    "code": -32600, 
>    "message": "Invalid Request"
>  }, 
>  "id": null
>}
>```

## Delete/block an (inappropriate) Message, SIWE

This is the same functions as above with the extension that temporary profiles can be used by providing additionally the SIWE message and signature.

To verify that the delete request is valid, the SIWE message must be checked for containing the correct

- address,
- domain.

### Methode

This method is called to delete/block a message.

```TypeScript
// call to delete a message
dm3_billboard_deleteMessage
```

### Request

The request passes the **identifier** of the billboard and the  **identifier** of the message. Also, a signature of the mediator is passed to proof the autority to execute this function and to ensure traceability.

- **idBillboard** The **id** of the billboard where a messages should be deleted.
- **idMessage** The **id** of the message which should be deleted. This is the hash of the message.
- **mediator** The ENS name of the mediator who deleted the messages. This ENS name must contain a valid **dm3** profile.
- **signature** The signature of the above information, signed by the mediators signing key (defined in [**dm3** profile](../message-transport/mtp-registry.md#user-profile))
- **SIWEMessage** the SIWE message containing the mediators address and the domain.
- **SIWESignature** the signature to the `SIWEMessage`

```TypeScript
// the id of the billboard
idBillboard = <ens name of the billboard>
// the id of the message to be deleted
idMessage = <hash of the message>
// the ENS name of the mediator
mediator = <ens name of the mediator>
// signature:  
signature = sign(sha256(safe-stable-stringify(idBillboard+idMessage)))
// SIWE message
SIWEMessage = <SIWE text message>
// SIWE signature
SIWESignature = <SIWE signature>
```

### Response

The response is as defined in the JSON-RPC specification. In case of an error, an error message is returned.

## Suspend Sender

Mediators have the task and the right to block or delete inappropriate content. If a sender repeatedly sends messages that need to be deleted, the mediator can also ban this sender. This means that the sender is blacklisted from the delivery service, so that no more messages can be received from him. For this purpose the spam protection rules of DM3MTP are applied.

All messages of blocked user are handled as deleted.

### Methode

This method is called to suspend a sender

```TypeScript
// call to suspend a sender
dm3_billboard_suspendSender
```

### Request

The request passes the ENS name of the to be suspended sender. Also, a signature of the mediator is passed to proof the autority to execute this function and to ensure traceability.

- **blockedSender** The address or ENS name of the sender to be suspended.
- **mediator** The ENS name of the mediator who deleted the messages.
- **signature** The signature of the above information, signed by the mediators signing key (defined in [**dm3** profile](../message-transport/mtp-registry.md#user-profile))

```TypeScript
// the address or ENS name of the blocked sender
blockedSender = <ENS name of the sender>
// the ENS name of the mediator
mediator = <ens name of the mediator>
// signature:  
signature = sign(sha256(blockedSender))
```

### Response

The response is as defined in the JSON-RPC specification. In case of an error, an error message is returned.

> **Example**
>
> ```TypeScript
> {
>  "jsonrpc": "2.0", 
>  "error": {
>    "code": -32600, 
>    "message": "Invalid Request"
>  }, 
>  "id": null
>}
>```

## Get active viewers

Active viewers are instances retrieving the billboard messages. This number is displayed in the billboard embedded widget. 

### Methode

This method is called retrieve the number ob active viewers.

```TypeScript
// call to retrieve number of active viewers
dm3_billboard_countActiveViewers
```

### Request

The request passes the **identifier** of the billboard.

- **idBillboard** The **id** of the billboard.

```TypeScript
// the ENS name of the billboard
idBillboard = <ENS name of the billboard>
```

### Response

The number of active viewers is returned.

```JavaScript
{
  viewers: Number,
}
```

In case of an error, an error message is returned.
