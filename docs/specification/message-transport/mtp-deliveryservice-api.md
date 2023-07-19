# API Delivery-Service (Incoming Messages)

For more detailed information about delivery services, see the [appendix](mtp-appendix.md#appendix). Relevant to DM3MTP (protocol) is the API to deliver messages (encrypted envelopes) only.

The delivery service is a JSON-RPC service, following the JSON-RPC 2.0 specification (see also [**[RPC1]**](../references.md)).

To accept incoming messages, the delivery service MUST support the following JSON-RPC methods:

## Submit Message

The submit message method is called to deliver the complete message envelope containing the delivery information and the encrypted message.

### Methode

```TypeScript
// call to submit a message
dm3_submitMessage 
```

### Request

The request delivers the encrypted envelope containing the message itself and the delivery information as [EncryptionEnvelope](mtp-transport.md#encryption-envelope-data-structure).

```TypeScript
// see description of EncryptionEnvelope data structure
EncryptionEnvelope
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

#### Error codes

For default JSON-RPC error codes see [appendix](mtp-appendix.md#rpc-error-codes).

Additional, application specific error codes can be reported:

| Error code | Error text  | Description |
|:---|:---|:---|
| -32000 | Invalid input | Missing or invalid parameters.|
| -32001 | Resource not found | Requested resource not found.|
| -32002 | Resource unavailable | Requested resource not available.|
| -32003 | Unauthorized | The caller was not authorized to call this method.|
| -32004 | Method not supported | Method is not implemented.|
| -32005 | Limit exceeded | Request exceeds defined limit.|
| -32006 | JSON-RPC version not supported | Version of JSON-RPC protocol is not supported.|

If the message is rejected from the delivery service, the following error codes will be returned:

| Error code | Error text  | Description |
|:---|:---|:---|
| -32010 | Spam | The sender's address didn't fit the required spam protection settings.|
| -32011 | Too big | The size of the message exceeds the approved maximum size.|

## Get Properties of the Delivery Service

A **delivery service** provides a set of properties that a sending client MUST evaluate and observe. These properties can be informative or define what the sender of a message must follow in order for the delivery service to accept the message at all.

(_**compatibility information:** it replaces the formerly defined mutableProfileExtension provided in the `network.dm3.profile`_)

### Methode

```TypeScript
// call to get a list of properties. 
dm3_getDeliveryServiceProperties
```

### Response

* **Message TTL:** Defines, how long the delivery service guarantees to cache a message. After the guaranteed time, the message MAY be removed, even if it was not picked up by the receiver. The minimum MUST be 30 days. If the value is not set, or set to 0 or null, messages will be cached unlimited (default).
* **Size Limit:** Each delivery service can define a maximum size of incoming messages. As the content of the message incl. attachments is encrypted for the receiver, the delivery service can't restrict attachments or other embedded data by its content. The only way is to restrict the total size of the message.
A sender MUST check this property before sending the message, otherwise, the message may be rejected.

```TypeScript
{
    // Number of days a delivery service must buffer a message
    // The message may be deleted if: incoming_timestamp_in_ms + days_to_ms(messageTTL) < now_in_ms
    messageTTL: number;
  
    // The delivery service accepts only envelopes which fulfill the following condition: sizeInBytes(envelope) <= sizeLimit
    sizeLimit: number; 
}
```

In case of an error, an error object is returned as described in [error codes](#error-codes).

## Get the User's Profile Extension

Profile extensions are mutable properties of a receiver (identified by his/her ENS Name, ...) that are not stored in the `network.dm3.profile` and can be changed without the need for a transaction. As these properties may vary between different delivery services, each delivery service to which the user is connected must provide this information.

### Methode

```TypeScript
// call to submit a message
dm3_getProfileExtension
```

### Request

The request passes the **name** of the receiver.

```TypeScript
// the name of the receiver
the_name
```

### Response

The profileExtension contains configuration information of the receiver:

* **Encryption Scheme:** _(OPTIONAL)_ The default encryption scheme is **x25519-chacha20-poly1305**. If another encryption scheme needs to be used (e.g., because this is needed for an ecosystem that is integrated into **dm3**), this can be requested. The default algorithm MUST be accepted, too. Otherwise, it might be impossible for a sender to deliver a message when it doesn't support the requested algorithm.
This is a list of supported schemes, sorted by importance. All listed algorithms MUST be supported by the receiver. The sender is free to choose but should use receiver's preferences if supported.
* **Supported Message Types:** The receiver MUST provide a list of all **message types** that the client he/she uses is supporting (see [message data structure](mtp-transport.md#message_data_structure)).
The message type **NEW** MUST be supported always and is set as default in case no information is delivered.
The sender MUST NOT send unsupported messages, as the receiver will not accept those messages.

Other information (like spam protection settings) can be added to this struct (defined in protocol extensions).

```JavaScript
{
  // Request of a specific encryption scheme.
  // (optional)
  encryptionScheme?: string[],
  // List of supported message types
  supportedMessageTypes: string[],
}
```

> **Example** Profile Exception:
>
> ```JavaScript
> {
>    "encryptionScheme": ["x25519-chacha20-poly1305"],
>    "supportedMesssageTypes": ["NEW","EDIT", "READ_RECEIPT","RESEND_REQUEST"],
> }
> ```

In case of an error, an error object is returned as described in [error codes](#error-codes).
