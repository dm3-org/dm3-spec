# Embedded Widget

With the **dm3 billboard embedded widget** a REACT component is available, based on [DM3MTP](../message-transport/mtp.rst) and [DM3BMP](bmp.rst). A billboard chat function can be integrated into any web application with minimal effort. The appearance and look-and-feel of the component can be extensively customized to seamlessly integrate the component into applications.

## UI/UX Overview

The embedded widget displays the messages of the billboard and allows users to participate in the discussion with statements. Special users (authorized by the billboard service) act as mediators to delete inappropriate or inadmissible messages. Special functions are available for these users.

## Parameters

The component needs some parameters from the parent application:

- **Billboard ID:** The billboard id is the ENS name of the billboard. This name contains a **dm3 profile** containing all relevant information.
- **Seed:** The seed is needed to derive Encryption and signature keys. These keys are then required for dm3 communication. In order to integrate the component into an existing dApp, this dApp can then pass a suitable seed (this is generated from a signature of the connected wallet, for example).
_**IMPORTANT:** the seed must be a secret and must not be generated from reproducible data!_
- **User Address:** The address of the user's wallet. The address is needed to establish the connection to his/her ENS name (reverse record must be set!) and his/her avatar. In addition, the address is needed to eventually identify the user as a [mediator](bmp-client.md#moderation-of-the-conversation).
- **Start Time:** The components can diplay the time of the message relative to the start time. This parameter is OPTIONAL. If it is not set, the ablolute time is displayed.

## Processes

### Viewer

The communication of a billboard chat is public. This means that anyone can view the communication history (the statements). In the view mode of the UI component, it is associated with a particular billboard and displays the messages retrieved via the Billboard Service API. Interaction with the billboard and statements is not possible in this view.

![image](ui_only_viewing.svg)

#### Parameters

Only the **billboard id** and optionally the **start time** is defined. The **seed** and the **user's address** are not set.

### Discussion Participant

To join the conversation, the user must identify himself. This is done, for example, by "Login with Ethereum" in the parent application. The billboard widget is then passed a **seed** and the **address** of the user. Based on the seed, the **dm3** keys are derived and a virtual ENS name is created on the billboard delivery service (managed in the service and linked into the ENS via CCIP). This enables the user to send messages to the billboard service and thus participate in the discussion.
IMPORTANT: the login process is done outside the component. After sucessful login, the parameters **seed** and **address** are set.

![image](ui_logged_in_not_validated.svg)

#### Parameters

All parameters are set.

#### Validation of the wallet address

The participation takes place under the identity of the Wallet address. If the user has an ENS name that is linked to this address, this name can be used instead of the address in the conversation (the reverse record in the ENS must be set correctly for this).

However, in order to establish this connection, it must be proven that the user is actually in possession and control of the keys to this address (to exclude tampering). This proof is provided by an additional signature.

**TEXT to be SIGNED:**

> dm3 billboard chat:
> Please sign this message to activate the
> linkage of your address to your ENS name
> in the chat (if reverse lookup is set!).
> Important: No transaction is sent to the
> blockchain. No fees have to be paid.

This process is triggered by pressing the button "Proof your wallet address". As soon as the signature and thus the proof has been provided, the corresponding ENS name is now displayed for this address in all viewers.

![image](ui_logged_in_validated.svg)

#### Sending Statements

Once the user has logged in (e.g. with Sign In With Ethereum), the user's **seed** and **address** are passed to the component and participation mode is enabled. Here the user can send his statements as messages to the billboard. This is done according to **dm3** standard by sending an envelope with an encrypted message to the billboard.

If a minimum waiting time is defined by the billboard service (see properties), the user must wait this time before he can send a message again. 

![image](ui_logged_in_validated_waiting_after_sending.svg)

### Moderator
