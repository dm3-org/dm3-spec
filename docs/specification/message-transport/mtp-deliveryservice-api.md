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

The request delivers the encrypted envelope containing the message itself and the delivery information as [EncryptionEnvelop](mtp-transport.md#encryption-envelop-data-structure).

```TypeScript
// see description of EncryptionEnvelop data structure
EncryptionEnvelop
```

### Response

```TypeScript
success: boolean
```

The response is true, if the delivery service received the envelop with the message. It is still ``true``, if the message does not fit the spam parameters (like minNonce or minBalance) and is recarded.
The response is ``false``, if the envelope can't be opended and interpreted by the delivery service.

## Get Properties of the Delivery Service

A **delivery service** provides a set of properties which a sending client must evaluate and observe. These properties can be informative or define that the sender of a message must follow in order for the delivery service to accept the message at all.

### Methode

```TypeScript
// call to get list of properties. 
dm3_getDeliveryServiceProperties
```

### Response

* **Message TTL:** Defines, how long the delivery service guarantees to cache a message. After the guaranteed time, the message MAY be removed, even if it was not picked up by the receiver. The minimum MUST be 1 month. If the value is not set, messages will cached unlimited (default).
* **Size Limit:** Each delivery service can define a maximum size of incoming messages. As the content of the message incl. attachments is encrypted for the receiver, the delivery service can't restrict attachments or other embedded data by its content. The only way is to restrict the total size of the message.
A sender MUST check this property before sending the message, otherwise the message may be rejected.

```TypeScript
{
    // Number of days a delivery service must buffer a message
    // The message should be deleted if: incoming_timestamp_in_ms + days_to_ms(messageTTL) < now_in_ms
    messageTTL: number;
  
    // The delivery service accepts only envelops which fulfill the following condition: sizeInBytes(envelop) <= sizeLimit
    sizeLimit: number; 
}
```
