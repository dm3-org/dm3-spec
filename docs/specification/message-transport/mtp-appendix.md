# Appendix

## Delivery Service

A Delivery Service is an RPC endpoint where a client can deliver its message (see [API](mtp-deliveryservice-api.md)).

The delivery service

1. checks whether the message satisfies the recipient's spam policy (see [ProfileExtension](mtp-deliveryservice-api.md#get-the-users-profile-extension))
2. decrypts the envelope, adds a postmark, and stores the message encrypted for the recipient until the recipient picks it up.
3. if supported, notifies the receiver that there is a new message.

Delivery service nodes can be operated as a service or self-sovereign by the user. The protocol explicitly allows (see [user profile](mtp-registry.md#user-profile)) for a user to point to multiple delivery services, so that if one is not available, another can be used. However, delivery service nodes can also act as gateways to other protocols, services or applications.

![image](deliveryservice_fallback.svg)

### Gateway to other service

If a delivery service works as a gateway to another protocol or service, it must implement the [API](mtp-deliveryservice-api.md) to receive dm3 messages. However, how it then processes the messages and delivers them to the ecosystem to which it is acting as a gateway is completely up to it and depends only on the service or protocol to which it is connecting.

![image](deliveryservice_gateway.svg)

A gateway can also provide multiple delivery service nodes as primary and fallback services.

## Cross Chain Applications

Although the dm3 protocol is fundamentally designed to use ENS as a central registry, the protocol can also be implemented on other chains. Name services similar to ENS can be used as a local registry in the ecosystem of this chain. For the entire dm3 ecosystem, this local registry can be directly integrated via CCIP (Cross Chain Interoperability Protocol) (and vice versa) so that interoperability can be established.
A complementary extension will further simplify the handling of names of such local registries by automatic mapping of toplevel domains (see toplevel alias at [protocol extensions](../overview.md#protocol-extensions)).
