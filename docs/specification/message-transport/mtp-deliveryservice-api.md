# API Delivery-Service (Incoming Messages)

To accept incoming messages, the delivery service MUST support the JSON-RPC method `dm3_submitMessage` with the following structure:

## Request

```TypeScript
// see description of EncryptionEnvelop data structure
EncryptionEnvelop
```

## Response

```TypeScript
success: boolean
```

The response is true, if the delivery service received the envelop with the message. It is still ``true``, if the message does not fit the spam parameters (like minNonce or minBalance) and is recarded.
The response is ``false``, if the envelope can't be opended and interpreted by the delivery service.
