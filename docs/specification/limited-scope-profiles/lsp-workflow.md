# Workflow

## Create Limited Scope Profile

To create an LSP, a signed message is required. This is created by the initiating component and signed with the private key of the user's wallet or provided by a higher-level component of the application (for example, if Sign-in-with-Ethereum (SIWE) is used).

To create the keys for communication (encryption and signatures), the seed is either derived from the signature of the message or generated randomly, depending on the application.

The use of the signature as a seed is only permitted if the signed message is generated exclusively within the application (embedded component) and is used exclusively for this purpose (e.g. a special message is generated including a non-guessable nonce for which a signature is requested with the wallet key). If this message including signature is provided by the application in which the messaging component is integrated (e.g. when using SIWE), it must not be used as seed, otherwise the keys derived from it are not secure. In this case, the seed for the keys must be randomly generated with sufficient entropy.

Based on these keys and the address of the wallet a **dm3** profile is created. For this purpose, the dApp that uses the Messaging component, may also operates one or more delivery service nodes. The profiles are given a virtual ENS name which is the wallet address as subdomain of the ENS name of the dApp, which is used to publish this profile. This is usually provided via CCIP (Cross Chain Interoperability Protocol), so that the information is managed cost-effectively by a service or in Layer-2.

> **Example** of a virtual name for the dm3 profile :
>
> ```JavaScript
> 0x1234...789.addr.myapp.eth
> ```

```[IMAGE dApp infrastructure and dm3 DS]```

## Usage of the Limited Scope Profile

Once the LSP is published, it can already be used like any other dm3. Users can send and receive messages.

These profiles are already connected to the wallet address, but have no connection to a **dm3** profile. So it is now possible to run an anonymous profile.

The effort for users is minimal, so that the creation of LSP can be effectively integrated into dApps by the UX. At most a signature of the wallet is needed if a custom message is used. When using SIWE or similar, the creation can be done completely in the background without any user interaction.

From the user's point of view, it may be desirable to have such a communication without a connection to his main profile (or at least to start the communication that way). Especially when the user does not know how much he can trust the application, there is a need to first disclose as little information as possible and still have a secure communication.

Possible applications for anonymous profiles:

* In-app messaging (e.g., in a game), where active users exchange information and the communication is only temporarily interesting,
* a public feedback form where users leave general info.
* Contact form to write directly to contact persons,
* support form, to ask for help.

For other use cases (including some of the above), it is useful or desirable that the communication is also managed in the inbox and linked to the main profile.

## Linking to Main Profile

To pair a Limited Scope Profile with a Main Profile, a service message is sent to the Main Profile containing the pairing request.

For this purpose a new message type is introduced (see [Message Metadata Structure](../message-transport/mtp-transport.md#message-metadata-structure) ):

* **LINK_LSP:** _(OPTIONAL)_ This is a service message. The sender wants to link a [Limited Scope Profile (LSP)](../limited-scope-profiles/lsp.rst) with this profile. The receiving app must allow the user to accept or reject a link request. If the app does not support this message, a user cannot connect his LSP and manage the communication in his inbox.

```JavaScript
DEFINITION: Message Metadata Structure

{
   ...
   // specifies the message type
   type: ... | "LINK_LSP"
   ...
} 
```


