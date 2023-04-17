# Architecture

Billboard messaging is based entirely on the [dm3 Message Transport Protocol](../message-transport/mtp-transport.md) with some particular extensions:

* **Billboard client:** This client is a special implementation of a [**dm3** client](bmp-client.md). Received messages are stored in a merged conversation (all received messages), ordered by a time of reception.
* **Billboard service:** The billboard service provides an API to access the messages from the billboard and additional functions. Since the messages are visible to all in the form of a bulletin board (depending on the operation mode), the entire communication can be retrieved from this service.
* **Billboard embedded component:** Optionally, an embedded component is provided to visualize the billboard and enable message sending. This UI components can be integrated in existing dApps with minimum effort.
* **Delivery Service API extenstion:** The delivery service attached to the billboard client uses an extension to **DM3MAP**, the **dm3** message access protocol, to fetch the messages.

## Message Flow

1. Statements are added to the conversation by any participant via direct message. To do this, the participant sends a message directly to one of the billboard's delivery services (**dm3** standard).
2. The billboard client fetches incoming statements from the delivery service(s). The client stores the collected statements.
3. Viewers of the billboard conversation retrieve the billboard messages (list of statements) using the [billboard service API](bmp-service-api.md). Viewers can be active (send and view statements) or passive (view only).

![image](billboard-principle.svg)

## Components

The billboard message extension consists of the following components:

* **Delivery Service(s):** These service(s) receive the messages/statements. The delivery serivce implements the dm3 message access protocol with the billboard extension to access all messages (not separated into conversations).
* **Billboard client**
* **Billboard service**
* **Billboard Embedded Widget**
* **Billboard Management Backend:** This service provides all functions needed to administrate the billboard, like configuration management, creation of billboards, management of ENS subdomains for virtual profiles (including CCIP integration into ENS Subdomain). 