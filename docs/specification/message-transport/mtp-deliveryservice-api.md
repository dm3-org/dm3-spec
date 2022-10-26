# API Delivery-Service (Incoming Messages)

For more detailed information about delivery services, see [appendix](mtp-appendix.md#appendix). Relevant to DM3MTP (protocol) is the API to deliver messages (encrypted envelopes) only.

To accept incoming messages, the delivery service MUST support the JSON-RPC method `dm3_submitMessage` with the following structure:

## Request

The request delivers the encrypted envelope containing the message itself and the delivery information as [EncryptionEnvelop](mtp-transport.md#encryption-envelop-data-structure).

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
