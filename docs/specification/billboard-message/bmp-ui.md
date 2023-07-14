# Embedded Widget

With the **dm3 billboard embedded widget** a REACT component is available, based on [DM3MTP](../message-transport/mtp.rst) and [DM3BMP](bmp.rst). A billboard chat function can be integrated into any web application with minimal effort. The appearance and look-and-feel of the component can be extensively customized to seamlessly integrate the component into applications.

- [UI/UX Overview](#uiux-overview)
- [Parameters](#parameters)
- [Processes](#processes)

## UI/UX Overview

The embedded widget displays the messages of the billboard and allows users to participate in the discussion with statements. Special users (authorized by the billboard service) act as mediators to delete inappropriate or inadmissible messages. Special functions are available for these users.

## Parameters

The component needs some parameters from the parent application:

- **Billboard ID:** The billboard id is the ENS name of the billboard. This name has a **dm3 profile** as text record containing all relevant information.
- **Login-Message:** This is a message provided as login information (like the _Login-With-Ethereum Message_). This message will be shared with the backend for verification purposes. This parameter may be **empty** or undefined if user is not logged in.
- **Login-Signature:** This is the signature to the above message by the user's private key. This parameter may be **empty** or undefined if user is not logged in.
- **User Address:** The address of the user's wallet. The address is needed to establish the connection to his/her ENS name (reverse record must be set!) and his/her avatar. In addition, the address is needed to eventually identify the user as a [mediator](bmp-client.md#moderation-of-the-conversation).
- **Start Time:** The components can diplay the time of the message relative to the start time. This parameter is OPTIONAL. If it is not set, the ablolute time is displayed.
- **ENS Lookup:** The components supports ENS name lookup (showin the ENS name pointing to the address instead of the address). This parameter (**boolean**) defines, if this feature is enabled or not. If enabled, an additional signature is requested to proof that the user controls the key belonging to the address.

## Processes

### Viewer

All communications of a billboard chat are public. This means that anyone can view the communication history (the statements). In the view mode of the UI component, it is associated with a particular billboard and displays the messages retrieved via the Billboard Service API. Interaction with the billboard and statements is not possible in this view.

![image](ui_only_viewing.svg)

#### Parameters

Only the `billboard id` and optionally the `start time` is defined. The `Login-Message`, `Login-Signature`, and the user's `address` are not set.

### Discussion Participant

To join the conversation, the user must identify himself. This is done, for example, by "Login with Ethereum" in the parent application. The billboard widget is then passed a `Login-Message`, the `Login-Signature`, and the `User Address`.
Based on a **random seed**, the **dm3** keys are derived and a virtual ENS name is created on the billboard delivery service (managed in the service and linked into the ENS via CCIP). This enables the user to send messages to the billboard service and thus participate in the discussion.
IMPORTANT: the login process is done outside the component. After sucessful login, the parameters `Login-Message`, `Login-Signature`, and `User Address` are set.

If the parameter `ENS Lookup`is set `true`, the users can proof their wallet address by providing a signature.

![image](ui_logged_in_not_validated.svg)

If the parameter `ENS Lookup` is set `false`, this option is not activated.

![image](ui_logged_in_no_enslookup.svg)

#### Parameters

All parameters are set.

#### Validation of the wallet address

The participation takes place under the identity of the Wallet address. If this option is activated and the user has an ENS name that is linked to this address, this name can be used instead of the address in the conversation (the reverse record in the ENS must be set correctly for this).

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

Once the user has logged in (e.g. with Sign In With Ethereum), the user's login information and address are passed to the component and participation mode is enabled. Here the user can send his/her statements as messages to the billboard. This is done according to **dm3** standard by sending an envelope with an encrypted message to the billboard.

If a minimum waiting time is defined by the billboard service (see properties), the user must wait this time before he can send a message again.

![image](ui_logged_in_validated_waiting_after_sending.svg)

### Moderator

Moderation of a discussion is necessary when inappropriate or improper statements are made. The list of authorized moderators (their ENS names or addresses) is provided by the Billboard Service.
The billboard ui componente recognizes a moderator if he is logged in via SIWE and his address is on the moderator list.

In this case user joins the conversation as a moderator. The `Login Signature` must fit to `Login message`. The signature must be checked.

The moderator view provides the moderator with the option to delete inappropriate statements (via the delete link next to the message).

![image](ui_logged_in_moderator_loggedin.svg)

If a statement is marked for deletion, the delete link is changed to a recovery link where the moderator has for 15s to cancel the deletion.

![image](ui_logged_in_moderator_deleted.svg)

Only after this time, the [API function](bmp-service-api.md#deleteblock-an-inappropriate-message) is called to delete the message.

If a user sends multiple messages that need to be deleted by the moderators, the UI can also provide an option to permanently ban that user. This is done via the [API function](bmp-service-api.md#suspend-sender).
