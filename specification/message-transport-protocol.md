# Specification: _dm3_ Message Transport Protocol

## Abstract

_The **dm3** (for **D**ecentralices **M**essageing for web**3**) protocol is a peer-2-peer messaging protocol with with focus on seamless **end-2-end encryption** for messgages and connection meta data, **decentralization** and no single-points-of-failure, a **lean architecture** with minimum resource requirements, **interoperability** with other services and applications, and preserving the **self-sovereignity** of the users.
The dm3 protocol uses **ENS** (Etherem Name Service) as general registry for neccessary contact information (like public keys, addresses of delivery services, ...), stored in ENS text records, in combination with a standardized API to build an open system of message delivery services allowing to send messages from ENS name to ENS name._

## Motivation

Messaging (such as instant massages, chats, email, etc.) has become an integral part of most people's lives. Mobile devices (such as smartphones, tablets, laptops, etc.) with instant access to the Internet make it possible to be in touch with family, friends, as well as work colleagues and customers at any time.

While email is still largely decentralized and interoperable, the lack of appropriate spam protection methods other than blocking and censoring has resulted in only a few large providers interacting with each other, not to mention the fact that even today a large part of email communication is mostly unencrypted.
Messaging services on the web2 have become closed silos, making cross-service or cross-app communication almost impossible.

Although they mostly offer end-to-end encryption, some services may still have backdoors via the central service providers.

In the past months, a number of different approaches and tools have been presented in the web3. Methods from the web3 such as key-based identification, encryption, and the availability of blockchain-based registries are being used. Many applications are built to follow user preferences, several protocols, mostly application specific, have been presented. Trade-offs are often necessary - such as centralized services, complex protocols. Interoperability beyond applications, services, and protocols has been limited, if possible at all. 

With dm3 a protocol is presented, which is characterized by a very lean basic protocol, which can serve as a bridge between different services and can enable integration and interoperability with other services and different applications.

## Base Architecture


## Specification

The specification of the **_dm3_ Message Transport Protocol** focuses on how to deliver messages to the delivery service defined in the receiver's dm3 profile. dm3 delivery service and app implementations MAY also use the following dm3 protocol extensions:

* [Message Access Specification](): Specifies how received messages on a delivery service can be accessed.
* [Message Storage Specification](storage-specification.md): Specifies how messages are persisted after they are delivered.
* [Public Message Feed Specification](): Specifies how a public message feed is created and accessed.
* [Intra Delivery Service Messaging Specification](): Specifies additional features for messaging if sender and receiver are using the same delivery service.
* [Group Messaging Specification](): Specifies a protocol extension to enable group messaging.


### Profile Registry
The protocol requires a registry where the dm3 app can look up dm3 profiles of other users and delivery services. dm3 uses the following ENS text records for this purpose:
* `eth.dm3.profile`: User profile entry
* `eth.dm3.deliveryService`: Delivery service profile entry 

The text records MUST either contain the profile JSON string defined in Appendix 1 or a URL pointing to a profile JSON string. In the case of an URL, the integrity of the resolved profile JSON string MUST be ensured. Therefore, the URL MUST be a native IPFS URL or an URL containing exactly one `dm3Hash` parameter. 

Example `eth.dm3.profile` text record entries:
* `https://delivery.dm3.network/profile/0xbcd6de065fd7e889e3...7553ab3cc?dm3Hash=0x84f89a7...278ca03e421ab50c8`
* `ipfs://bafybeiemxf5abjwjz3e...vfyavhwq/`


The profiles can only be changed by creating a new profile JSON file and changing the corresponding text record via an Ethereum transaction. It is possible to add a mutable profile extension for a user profile.

The user profile MUST contain:

* Public Signing Key: Key used to verify a message signature. 
* Public Encryption Key: Key used to encrypt a message.
* Delivery Service List: List with at least one delivery service ENS name.

The user profile MAY contain:

* Mutable Profile Extension URL: URL pointing to a JSON file containing additional profile information (e.g., spam filter settings). It is possible to change this information without sending an Ethereum transaction.

The delivery service profile MUST contain:
* Public Signing Key: Key used to verify a postmark signature. 
* Public Encryption Key: Key used to encrypt the delivery instructions.
* Delivery Service URL: URL pointing to the delivery service instance.

The following data structures defined in Appendix 2 MUST be used for the profile files.


### Message Transport Protocol

Sending a message takes place in two steps:
1. The sender app prepares and sends the message to the receiver's delivery service.
2. The delivery service buffers and processes the message.

Step 1 MUST consist of the following sub-steps:
1. Query the `eth.dm3.profile` text record of the receiver's ENS name.
2. Check if the `eth.dm3.profile` text record starts with a letter. If this is the case, interpret the content as a URL. If it does not start with a letter, interpret the content as a profile JSON string and skip sub-steps 2 and 3.
3. Use the URL  in `eth.dm3.profile` to retrieve the user profile document. This sub-step MUST be skipped if `eth.dm3.profile` directly contains the profile JSON string.
4. Use the `dm3Hash` URL parameter to check the integrity of the profile document. This sub-step MUST be skipped if the URL is a native IPFS URL.
5. Select the receiver delivery service ENS name by reading the `deliverySerives` user profile entry at index `0`.
6. Repeat sub-steps 1 to 3 with `eth.dm3.deliveryService` instead of `eth.dm3.profile` to get the delivery service profile. If the selected delivery service is unavailable, the sender app MUST use the service with the next higher index in the `deliveryServices` list.
7. Sign the message using the private sender signing key.
8. Encrypt the message using the public encryption key of the receiver (part of the user profile).
9. Sender app encrypts the delivery information using the public encryption key of the delivery service (part of the delivery service profile).
10. Submit the message to the delivery service using the URL defined in the delivery service profile.

Step 2 MUST consist of the following sub-steps:
1. Decrypt delivery information.
2. Apply filter rules from the receiver's mutable profile extension file.
3. Create a postmark.
4. Buffer message.
5. Push message to receiver app.

The data structures defined in Appendix 2 MUST be used for message transport.

#### API
To accept incoming messages, the delivery service MUST support the JSON-RPC method `dm3_submitMessage` with the following structure:

**Request**
```TypeScript
// see appendix 3 for EncryptioEnvelop data structure
EncryptionEnvelop
```

**Response**
```TypeScript
success: boolean
```

## Appendix 1: Profile Data Structures
UserProfile
```JavaScript
{
  // Key used to encrypt messages
  publicEncryptionKey: string,

  // Key used to sign messages
  publicSigningKey: string,
  
  // ENS name list of the delivery services e.g., delivery.dm3.eth
  deliveryServices: string[], 

  // URL pointing to the profile extension JSON file
  mutableProfileExtensionUrl: string,

}
```

DeliveryServiceProfile
```JavaScript
{
  // Key used to sign postmarks
  publicSigningKey: string,

  // Key used to encrypt delivery information
  publicEncryptionKey: string,

  // URL pointing to the delivery service instance
  url: string
}
```

## Appendix 2: Messaging Data Structures

Message
 ```JavaScript
{
  
  // receiver ens-name
  // optional (not needed for public messages)
  to: string,

  // sender ens-name
  from: string,

  // message creation timestamp
  timestamp: number,

  // message text
  // optional (not needed for messages of type READ_RECEIPT and DELETE_REQUEST)
  message: string,

  // specifies the message type
  type: "NEW" | "DELETE_REQUEST" | "EDIT" | "THREAD_POST" | "REACTION" | "READ_RECEIPT"

  // message hash of the reference message
  // optional (not needed for messages of type NEW)
  referenceMessageHash: string,

  // message attachments e.g. images
  // optional
  attachments: Attachment[],

  // instructions used by the receiver of the message on how to send a reply
  // optional (used for bridging messages to other protocols)
  replyDeliveryInstruction: string,

  // sign( keccak256( safe-stable-stringify( message_without_sig ) ) )
  signature: string

}
```

DeliveryInformation
```JavaScript
{
  // receiver ens-name
  // optional (not needed for public messages)
  to: string,

  // sender ens-name
  from: string,

  // instructions used by the delivery service on how to deliver the message
  // optional (used for bridging messages to other protocols)
  deliveryInstruction: string
  
}
```

Postmark
```JavaScript
{
  // if unecrypted keccak256( safe-stable-stringify( EncryptionEnvelop.message ) ) 
  // if encrypted keccak256( EncryptionEnvelop.message ) 
  messageHash: string,

  // timestamp of when the delivery service received the message
  incommingTimestamp: number,

  // sign( keccak256( safe-stable-stringify( postmark_without_sig ) ) )
  signature: string
}
```

EncryptionEnvelop
```JavaScript
{
  // dm3 protocol version
  version: 'v1'
  
  // encryption default: x25519-chacha20-poly1305
  // x25519-chacha20-poly1305 MUST be supported
  // optional (not needed if public message)
  encryptionVersion: 'x25519-chacha20-poly1305';

  // message
  // if private message: encrypted with receiver public encryption key
  // if public message: unencrypted
  message: string | message; 

  deliveryInformation: DeliveryInformation
  
  // encrypted with receiver public encryption key
  postmark: Postmark
}
 ```

Attachment
```JavaScript
{
  // MIME types
  type: string,

  data: string
}
 ```

 ## Appendix 3: Example Sequences


 ### Message Delivery
  ```mermaid
  sequenceDiagram
    actor A as Alice
    participant AA as Alice's App

    
    participant BD as Bobs's Delivery Service


    A->>AA: writes message
  
    AA->>AA: prepare message

    AA->>BD: dm3_submitMessage
    BD->>BD: decrypt deliveryInformation
    BD->>BD: apply filter rules
    BD->>BD: add postmark
    BD->>BD: buffer message
   

```

**Prepare Message**
   ```mermaid
  sequenceDiagram
   
    participant AA as Alice's App
    participant E as ENS
    participant P as Profile Storage (e.g. IPFS)
  
    AA->>E: get eth.dm3.profile for Bob's ENS name
    E-->>AA: eth.dm3.profile text record
    opt eth.dm3.profile text record is an URL
      AA->>P: query Bob's profile
      P-->>AA: profileRegistryEntry
      AA->>AA: check profileRegistryEntry integrity
    end
    
    AA->>E: get eth.dm3.deliveryService of Bob's delivery service
    E-->>AA: eth.dm3.deliveryService text record
    opt eth.dm3.profile text record is an URL
      AA->>P: query delivery service profile 
      P-->>AA: deliveryServiceRegistryEntry
      AA->>AA: check deliveryServiceRegistryEntry integrity
    end

    AA->>AA: sign message
    AA->>AA: encrypt message
    AA->>AA: encrypt deliveryInformation
    
```