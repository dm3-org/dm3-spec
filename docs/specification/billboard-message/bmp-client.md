# Billboard Client

The **Billboard Client** is a hosted service that fetches messages directed to it as statements from the corresponding delivery service(s) using **dm3 Message Access Protocol (DM3MAP)** and collects them as a merged list. The messages are not managed as separate conversations with individual participants, but as a list of statements sorted by the time they were received.

The client is designed to receive the statements only, as it does not send direct responses to the participants.

## Billboard Service

The Billboard service is the interface to the viewers. It provides the API for accessing the statements, which the viewers can use to retrieve the communication.
A Billboard Service can manage a number of billboards. For example, a billboard server can host all the billboards of an orgsanization or an event.

## Scaling

A billboard can use one or more delivery services. Depending on the expected number of statements to be received simultaneously, one or more fallback delivery services might be defined. If one is overloaded automatically the next will take over (already defined on protocol level for direct messaging).

The scaling of the billboard service can be sufficiently realized by common web2 load balancing techniques, so that enough bandwidth is available for all viewers. Caching of the current information is also useful on the server side.
