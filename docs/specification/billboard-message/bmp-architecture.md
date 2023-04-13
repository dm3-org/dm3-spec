# Architecture

Billboard messaging is based entirely on the [dm3 Message Transport Protocol](../message-transport/mtp-transport.md) with some particular extensions:

* **Billboard client:** This client is a special implementation of a **dm3** client. Each billboard has it's own ENS name with **dm3** profile. This can be a subdomain where data is organized off-chain and linked using CCIP. Received messages are stored in a merged conversation (all received messages), ordered by a time of reception.
* **Billboard service:** The billboard service provides an API to access the messages from the billboard. Since the messages are visible to all in the form of a bulletin board (depending on the operation mode), the entire communication can be retrieved from this service.
* **Billboard embedded component:** Optionally, an embedded component is provided to visualize the billboard and enable message sending. This UI components can be integrated in existing dApps with minimum effort.

## Message Flow

1. Statements are added to the conversation by any participant via direct message. To do this, the participant sends a message directly to one of the billboard's delivery services (**dm3** standard).
2. The billboard client fetches incoming statements from the delivery service(s). The client stores the collected statements.
3. Viewers of the billboard conversation retrieve the billboard messages (list of statements) using the billboard service API. Viewers can be active (send and view statements) or passive (view only).

![image](billboard-principle.svg)
