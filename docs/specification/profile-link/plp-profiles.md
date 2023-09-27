# Profile Links

## Limited Scope Profiles

In many applications, embedded messaging components are used so that users can exchange messages with each other, or users can get in touch with the app team or similar. With **dm3 embedded widgets** such a component is available, which is fully integrated into the **dm3** ecosystem.
Communication in these applications should often be anonymous, i.e. users come to this page and want to start immediately without going through an elaborate authentication process. In addition, it should be possible to link this communication to the user's inbox (any **dm3-compatible** messenger) if necessary, and also to ensure that the communication keys for encryption and signatures do not have to be shared with potentially risky dApps at any time.

**Limited Scope Profiles (LSP)** are local communication profiles that are created for a specific application and meet the above requirements. LSP provide:

* **Security:** Having different keys for different apps.
* **Interoperability:** LSP enable any embedded component to link with the user's main messenger (dm3-compatible messenger).
* **Self-sovereignty:** The users decide, if they want to connect these profiles to their inbox or not.

## General Profile Links

Besides LSP, any other **dm3** profiles can be linked together. This makes it possible to have communications in different identities, but to bring them together and manage them in one place.

## Create a Linked Profile

To create a **Linked Profile**, two approaches to create the communication keys are possible:

1. A unique message is provided and signed by the wallet's key. The keys (for encryption and signatures) are derived from this signature of the message.
2. The message and signature are provided by the embedding app (for example, if **Sign-in-with-Ethereum** (SIWE) is used). Then the signature cannot be used as seed for deriving the key (this information is potential public information and must not be used to derive keys). The keys are then derived from a random entropy.[^1]

[^1]: The use of the signature as a seed is only permitted if the signed message is generated exclusively within the application (embedded component) and is used exclusively for this purpose (e.g., a special message is generated including a non-guessable nonce for which a signature is requested with the wallet key). If this message including signature is provided by the application in which the messaging component is integrated (e.g., when using SIWE), it must not be used as seed, otherwise the keys derived from it are not secure. In this case, the seed for the keys must be randomly generated with sufficient entropy.

Based on these keys and the address of the wallet a **dm3** profile is created. For this purpose, the dApp that uses the messaging component, SHOULD also operate one or more delivery service nodes and a CCIP resolver backend if dm3 profiles are managed in a cloud service.

The profiles are given virtual ENS names which is the wallet's address as subdomain of the ENS name of the dApp, which is used to publish this profile. This is usually provided via CCIP ([Cross Chain Interoperability Protocol](https://chain.link/cross-chain)), so that the information is managed cost-effectively by a cloud service or in Layer-2.

> **Example** of a virtual name for the dm3 profile :
>
> ```JavaScript
> 0x1234...789.addr.myapp.eth
> ```

### Workflow to create a Linked Profile by signing a message

```mermaid
  sequenceDiagram

    participant DM3 as DM3-Widget
    participant W as Wallet
    participant LIB as DM3-Lib-Lsp
    participant DS as DM3-Delivery Service
    participant OR as DM3-Offchain Resolver

    DM3 ->> W: signCreateProfileMessage()
    LIB-->LIB:createLspWallet(createProfileSig)
    LIB-->LIB:createProfile(addr,createProfileSig)
    LIB-->>DS: getDeliveryServiceToken(lspWallet)
    LIB-->>OR: claimAddress(lspWallet)
    LIB-->>OR: claimSubdomain(lspWallet,lspName,ownerAddr,authSig)
    LIB-->>DS: submitUserProfile(lspName,lspProfile)

```

### Workflow to create a Linked Profile embedded in another dApp

```mermaid
  sequenceDiagram
    participant DAPP as dApp
    participant W as DM3-Widget
    participant LIB as DM3-Lib-Lsp
    participant DS as DM3-Delivery Service
    participant OR as DM3-Offchain Resolver

    DAPP ->> W: props(authMessage,ownerAddr,authSig,appId,entropy)
    W->>OR: lspExists(appID,ownerAddr)
    opt lsp.owner.appId.dm3.eth has not a limited Scope profile yet
        W->>LIB: createNewLsp(ownerAddr,appId,entropy)
            LIB-->LIB:createLspWallet(entropy)
            LIB-->LIB:createProfile(ownerAddr,lspWallet)
            LIB-->>OR: claimAddress(lspWallet)
            LIB-->>OR: claimSubdomain(lspWallet,lspName,ownerAddr,authSig)
            LIB-->>DS: submitUserProfile(lspName,lspProfile)
    end
    opt lsp.owner.appId.dm3.eth has already a profile
    W ->> DS: request privateKey for LspWallet(appId,ownerAddr)
    LIB-->LIB:recreateProfile(ownerAddr,lspWallet)
    LIB-->>DS: getDeliveryServiceToken(lspWallet)
    end

```

## Usage of the Linked Profiles

Once the LP is created, it can already be used like any other **dm3** profile. Users can send and receive messages.

These profiles are already connected to the wallet address, but have no connection to any existing **dm3** profile. So it is now possible to run an anonymous profile.

The effort for users to onboard is minimal so that the creation of LP can be effectively integrated into dApps. At most a signature of the wallet is needed if a custom message is used. When using SIWE or similar, the creation can be done completely in the background without any user interaction.

From the user's point of view, it may be desirable to have such a communication without a connection to his main **dm3** profile (or at least to start the communication that way). Especially when the user does not know how much he can trust the application, there is a need to first disclose as little information as possible and still have a secure communication.

Possible applications for anonymous profiles:

* In-app messaging (e.g., in a game), where active users exchange information and the communication is only temporarily interesting,
* a public feedback form where users leave general info.
* Contact form to write directly to contact persons,
* support form, to ask for help inside a dApp.

For other use cases (including some of the above), it is useful or desirable that the communication is also managed in the user's main inbox and thus linked to the main profile.

## Linking to Main Profile

To pair a Linked Profile with a Main Profile, a service message is sent to the Main Profile containing the pairing request.

For this purpose new message types are introduced (see [Message Metadata Structure](../message-transport/mtp-transport.md#message-metadata-structure)):

* **LINK:** _(OPTIONAL)_ This is a service message. The sender (LP) wants to link a local profile with this main profile. The receiving app (main profile) must allow the user to accept or reject a link request. If the app does not support this message, a user cannot connect his local profile and manage the communication in his inbox.
* **LINK_RECOVER:** _(OPTIONAL)_ This is a service message. The sender (LP) is already linked but needs to recover the keys (e.g., because he is accessing the dApp from another device). If the main profile knows the link, the necessary keys and information are returned in the LINK_ACCEPT message.
* **LINK_ACCEPT:** _(OPTIONAL)_ This is a service message. The sender (Main Profile) signals that the link request is approved. If appropriate, the known private keys and other information is included.

For linking, additional metadata fields are defined to transfer the required information:

* `Profile Private Key` The local private key of the linked profile needs to be revealed to the **Main Profile**. It is needed by the Main Profile to recover linked profiles.
* `Wallet Private Key` _(OPTIONAL)_ If the wallet is generated randomly, this key is needed to recover the linked profile. If the keys a generated from a signature, this field is not set.
* `Profile Name` The ENS name of the profile.
* `Profile Hash` The sha256 Hash of the profile content.  
* `Nonce` The nonce used to derive the keys. It is needed to recover the profile.
* `Link Message` The **Link Message** which needs to be signed by the user's wallet. Together with the signature it is needed to verify the ownership of the wallet and prevent unautorized tries to connect.
* `Wallet Signature` This signature by the wallet's key is needed to proof the ownership of the address. Signed is the **Link Message**.

### Definition Link Message

> Link your local profile with your dm3 account:
> [your_ens_name]
>
> (There is no paid transaction initiated.
> The signature is used offcain only.)
> 
> URI: [dapp initiating the connection]
> Version: 1
> Chain ID: 1
> Nonce: [...]
> Issued At: [date_time]
> Expiration Time: [date_time]

The definition of the Link Messages follows largely [EIP-4361](https://docs.login.xyz/general-information/siwe-overview/eip-4361).

### Extension of Message Metadata Structure

```JavaScript
DEFINITION: Message Metadata Structure

{
   ...
   // specifies the message type
   type: ... | "LINK" | "LINK_RECOVER" | "LINK_ACCEPT"
   ...
   link: {
      // the local profile's private key
      profilePrivateKey: string,
      // the wallet key if local wallet exists
      walletPrivateKey?: string,
      // the ENS name of the profile
      profileName: string,
      // the hash of the profile
      profileHash: string,
      // the link message
      linkMessage: string
      // signature of the wallet (LSP) or signature key (main profile)
      // sign( sha256( linkMessage) )
      signature: string
   }
}
```

### Workflow: Link

To connect a **Local Profile** to another **dm3 Profile**, a service message from the type `LINK` with the filled data structure `link` in **Message Metadata** is sent to the profile to connect to. The `message` filed of the **Envelope** is empty or may contain a fallback message informing that this is a service message only.

As result of the received LINK service message, the receiving messenger app initiates a user interaction to inform about the linking attempt. If the user agrees, a `LINK_ACCEPT` service message is returned, confirming the linkage, containing the ENS-name of the profile and the signature of the main profile's signature key.

```mermaid
  sequenceDiagram
    actor USER as User
    participant WALLET as Wallet

    box App with embedded dm3 widget 
    participant LSP as Local Linked Profile App
    participant DS1 as Delivery Service
    end
    
    box Main dm3 App
    participant DS2 as Delivery Service (Main Profile)
    participant DM3 as DM3-compatible Messenger (Main Profile)
    end
   
    USER-->>LSP: Requests Linkage to Main Profile
    LSP -->> WALLET: Request Signature to Link-Message
    WALLET -->> USER: Request Signature to Link-Message
    USER -->> LSP: Signature (to Link-Message)
    LSP->>DS2: Send Message (LINK)
    note over LSP,DS2: includes: Link-Message, Signature, Private Keys, <br> Nonce, profileName, ProfileHash  
    DS2->>DS2: Cache Message
   
    DM3-->>DS2: Request new Messages
    DS2->>+DM3: Deliver Message (LINK)
    DM3-->>DM3: Check <br> if Linked profile does not exist 
    DM3-->>USER: Requests Approval for Linkage
    USER-->>DM3: Approves Linkage
    DM3-->>DM3: Stores Linked Profile Keys and Info
    DM3->>-DS1: Send Message (LINK_ACCEPT)
    note over DM3,DS1: includes: Name of Linked Profile, Signature
    DS1->>DS1: Cache Message
   
    LSP-->>DS1: Request new Messages
    DS1->>+LSP: Deliver Message (LINK_ACCEPT)
    LSP-->>-LSP: Publishes Link Info in Profile <br> [network.dm3.link]

```

## Profile Recovery

As **Linked Profiles** often are used for embedded messaging components in dApps, it is common for users to access the same dApp on different devices or in a different browser or browser context. Then it is not possible to automatically generate the same local profile`s private keys. The user can easily use another anonymous profile, but this one would be independent and not linked to the initial profile.
However, once users have connected the local profile to their main profile, they can use it to recover the local profile's private keys and information (nonce).

This is executed by sending a **LINK_RECOVERY** to the Main Profile, @@@@@@ but without setting the metadata LSP.privateKey. But the signed **Link Message** must be sent as verification.
If the Main Profile receives such a message (without private key), which is already registered as a link, it transmits the private key in the response message (**LSP_LINK_ACCEPT**).

```mermaid
  sequenceDiagram
    actor USER as User
    participant WALLET as Wallet

    box LSP App
    participant LSP as Limited Scope Profile App
    participant DS1 as Delivery Service (LSP)
    end
    
    box Main dm3 App
    participant DS2 as Delivery Service (Main Profile)
    participant DM3 as DM3-compatible Messenger (Main Profile)
    end
   
    LSP -->> WALLET: Request Signature to Link-Message
    WALLET -->> USER: Request Signature to Link-Message
    USER -->> LSP: Signature (to Link-Message)
    
    LSP->>DS2: Send Message (LSP_LINK)
    note over LSP,DS2: includes: Link-Message, Signature 
    DS2->>DS2: Cache Message
   
    DM3-->>DS2: Request new Messages
    DS2->>+DM3: Deliver Message (LSP_LINK)
    DM3-->>DM3: Check <br> if LSP already exists  
   
    DM3->>-DS1: Send Message (LSP_LINK_ACCEPT)
    note over DM3,DS1: includes: Name of linked LSP, Signature, LSP Private key
    DS1->>DS1: Cache Message
   
    LSP-->>DS1: Request new Messages
    DS1->>+LSP: Deliver Message (LSP_LINK_ACCEPT)
    LSP-->>LSP: Stores LSP Private Key
    LSP-->>-LSP: Publishes Link Info in Profile (LSP)

```
