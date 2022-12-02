# API Delivery-Service (Incoming Messages)

For more detailed information about delivery services, see [appendix](mtp-appendix.md#appendix). Relevant to DM3MTP (protocol) is the API to deliver messages (encrypted envelopes) only.

To accept incoming messages, the delivery service MUST support the following JSON-RPC methods:

## Submit Message

The submit messge method is called to deliver the complete message envelope containing the delivery information and the encrypted message.

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

```TypeScript
success: boolean
```

The response is true, if the delivery service received the envelope with the message. It is still ``true``, if the message does not fit the spam parameters (like minNonce or minBalance) and is recarded.
The response is ``false``, if the envelope can't be opended and interpreted by the delivery service.

## Get Properties of the Delivery Service

A **delivery service** provides a set of properties which a sending client MUST evaluate and observe. These properties can be informative or define that the sender of a message must follow in order for the delivery service to accept the message at all.

(_**compatibility information:** it replaces the formerly defined mutableProfileExtension provided in the `eth.dm3.profile`_)

### Methode

```TypeScript
// call to get list of properties. 
dm3_getDeliveryServiceProperties
```

### Response

* **Message TTL:** Defines, how long the delivery service guarantees to cache a message. After the guaranteed time, the message MAY be removed, even if it was not picked up by the receiver. The minimum MUST be 30 days. If the value is not set, or set to 0 or null, messages will cached unlimited (default).
* **Size Limit:** Each delivery service can define a maximum size of incoming messages. As the content of the message incl. attachments is encrypted for the receiver, the delivery service can't restrict attachments or other embedded data by its content. The only way is to restrict the total size of the message.
A sender MUST check this property before sending the message, otherwise the message may be rejected.

```TypeScript
{
    // Number of days a delivery service must buffer a message
    // The message may be deleted if: incoming_timestamp_in_ms + days_to_ms(messageTTL) < now_in_ms
    messageTTL: number;
  
    // The delivery service accepts only envelopes which fulfill the following condition: sizeInBytes(envelope) <= sizeLimit
    sizeLimit: number; 
}
```

## Get the User's Profile Extension

Profile extensions are mutable properties of a receiver (identified by his/her ENS Name, ...) which are not stored in the `eth.dm3.profile` and can be changed without the need of a transaction. As these properties may vary between different delivery services, each delivery service to which the user is connected must provide this information.

### Methode

```TypeScript
// call to submit a message
dm3_getProfileExtension
```

### Request

The request passes the **name** of receiver.

```TypeScript
// the name of the receiver
the_name
```

### Response

The profileExtension contains configuration information of the receiver:

* **Minimum Nonce:** _(OPTIONAL)_ The sender's address (address linked to the ENS domain) must have a nonce higher than this value, showing that this is a used account.
* **Minimum Balance:** _(OPTIONAL)_ The sender's address holds more than a defined minimum in Ether or another token, as specified in Minimum Token Address.
* **Minimum Balance Token Address:** If the balance is not defined in Ether, the address of the token contract needs to be declared. If Ether is used, this fields stays empty.
* **Encryption Scheme:** _(OPTIONAL)_ The default encryption scheme is **x25519-chacha20-poly1305**. If another encryption scheme needs to be used (e.g., because this is needed for an ecosystem which is integrated into **dm3**), this can be requested. The default algorithm MUST be accepted, too. Otherwise, it might be impossible for a sender to deliver a message when it doesn't support the requested algorithm.
This is a list of supported schemes, sorted by importance. All listed algorithms MUST be supported by the receiver. The sender is free to choose but should use reveivers preferrences if supported.
* **Supported Message Types:** The receiver MUST provide a list of all **message types** that the client he/she uses is supporting (see [message data structure](mtp-transport.md#message_data_structure)).
The message type **NEW** MUST be supported always and is set as default in case no information is delivered.
The sender MUST NOT send unsupported messages, as the receiver will not accept those messages.

```JavaScript
{
  // the minimum nonce of the sender's address
  // (optional)
  minNonce: string,
  // the minimum balcance of the senders address 
  // (optional)
  minBalance: string,
  // token address, which shoould be evaluated. 
  // Empty address means Ether balance.
  // (optional)
  minBalanceTokenAddress: string,
  // Request of a specific ancryption algorithm.
  // (optional)
  encryptionAlgorithm: string[],
  // List of supported message types
  supportedMessageTypes: string[],
}
```

> **Example** Profile Exception:
>
> ```JavaScript
> {
>    "minNonce":"1",
>    "minBalance":"1000000000000000000",
>    "encryptionAlgorithm": ["x25519-chacha20-poly1305"],
>    "supportedMesssageTypes": ["NEW","EDIT", "READ_RECEIPT","RESEND_REQUEST"],
> }
> ```
