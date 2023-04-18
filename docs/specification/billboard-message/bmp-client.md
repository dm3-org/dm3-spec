# Billboard Client

The **Billboard Client** is a hosted service that fetches messages directed to it as statements from the corresponding delivery service(s) using the extended **dm3 Message Access Protocol (DM3MAP)** and collects them as a list of statements. The messages are not managed as separate conversations with individual participants, but as a list of statements sorted by the time they were received.

Each billboard has it's own ENS name with **dm3** profile. This can be a subdomain where data is organized off-chain and linked using [CCIP](https://chain.link/cross-chain) (Cross Chain Interoperability Protocol) or it can be a separated ENS domain with a published **dm3** profile.

The client is designed to receive the statements only, as it does not send direct responses to the participants. It serves as database for the billboard service which provides the [API](bmp-service-api.md) to access the messages.

## Database

The database of the billboard client contains all messages received from any sender. As mediators can delete/block messages, entries in this database must be markable as deleted.

## Billboard Service

The Billboard service acts as the interface to the viewers. It provides the [API](bmp-service-api.md) to access the statements, which the viewers can use to retrieve the communication.
A Billboard Service can manage a number of billboards. For example, a billboard server can host all the billboards of an orgsanization or an event.

The messages/statements can be retrieved using the REST API. The messages are delivered paged, in reverse order (from newest to oldest). Also, it is possible to use websocket connection to fetch new incoming messaged.

## DM3MAP Extension

The **dm3** Message Access Protocol allows the retrieval of messages in conversations (with sender and receiver). For reasons of effectiveness, an additional API function is added for the billboard client, which provides the messages of all conversations for one receiver.

## Moderation of the Conversation

For regulatory reasons and the need for the billboard operator to block inappropriate comments to ensure proper conversation, each billboard service may be defined a list of moderators/mediators who exercise the right and duty to delete inappropriate comments and, if necessary, block users who repeatedly defy the rules.

For this purpose, the billboard serivce provides appropriate functions (see [API](bmp-service-api.md) that can be called up by the mediators.

If a sender repeatedly sends messages that need to be deleted, the mediator can also ban this sender. This means that the sender is blacklisted from the delivery service, so that no more messages can be received from him. For this purpose the spam protection rules of DM3MTP are applied.

## Scaling

A billboard can use one or more delivery services. Depending on the expected number of statements to be received simultaneously, one or more fallback delivery services might be defined. If one is overloaded automatically the next will take over (already defined on protocol level for direct messaging).

The scaling of the billboard service can be sufficiently realized by common web2 load balancing techniques, so that enough bandwidth is available for all viewers. Caching of the current information is also useful on the server side.
