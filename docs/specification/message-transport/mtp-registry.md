# Registry

A general registry is needed where a **dm3** compatible app, service, or protocol can look up **dm3 profiles** of other users, containing

* Public keys,
* Links to delivery services, and
* (optional) Additional information (like spam reduction settings, other user preferences).

The **dm3** protocol uses **ENS** as general registry. The following text records are used for this purpose:

* `eth.dm3.profile`: User profile entry
* `eth.dm3.deliveryService`: Delivery service profile entry

The text records MUST either contain

* The profile JSON string defined below, or
* A URL pointing to a profile JSON object. To validate the integrity of the resolved profile JSON string, the URL MUST be a native IPFS URL or a URL containing a `dm3Hash` parameter containing the **SHA-256** hash of the JSON.

> **Example** `eth.dm3.profile` text record entries:
>
> * `https://delivery.dm3.network/profile/0xbcd6de065fd7...b3cc?dm3Hash=ab84f8...b50c8`
> * `ipfs://bafybeiemxf5abjwjz3e...vfyavhwq/`

The profiles can only be changed by creating a new profile JSON and changing the corresponding text record via an Ethereum transaction (if published on layer-1). Storing this information on layer-2 or linked via CCIP ([Cross-Chain Interoperability Protocol](https://chain.link/cross-chain)) using subdomains, is possible, too.
The specification thereof will be published in protocol extension **Layer-2 Registry Specification**. This is currently under development and will be published soon.

## User Profile

The user profile MUST contain:

* **Public Signing Key:** Key used to verify a message signature (ECDSA). The public signing key is the public key of an secp256k1 private/public key pair. How to generate or derive this key pair depends on the implementation of the client. The **Encryption and Signing Key Derivation Specification** proposes a method to derive those keys based of a signature of the wallet keys.
* **Public Encryption Key:** Key used to encrypt a message. As default, the algorithm **x25519-chacha20-poly1305** is used. If needed (e.g., for compatibility reasons with an integrated protocol), a different encryption can be specified in the Mutable Profile Extension (see below). Nevertheless, to use the default encryption is highly recommended.
* **Delivery Service List:** List with at least one delivery service' ENS name.

The user profile MAY contain (optional) a

* **Mutable Profile Extension URL:** a URL pointing to a JSON file containing additional profile information (e.g., spam filter settings, special encryption requirements). It is possible to change this information without sending an Ethereum transaction. This optional information must be considered every time a message is sent. If it is not set, defaults are used.

**DEFINITION:** UserProfile

```JavaScript
{
  // Key used to encrypt messages
  publicEncryptionKey: string,
  // Key used to sign messages
  publicSigningKey: string,
  // ENS name list of the delivery services e.g., delivery.dm3.eth
  deliveryServices: string[], 
  // URL pointing to the profile extension JSON file
  mutableProfileExtensionUrl: string
}
```

> **Example** UserProfile with optional field _mutableProfileExtensionUrl_:
>
> ```JavaScript
> {
>    "publicEncryptionKey":"nyDsUmYV4EDNCsG+pK...D=",
>    "publicSigningKey":"MBpqhsSkxevwbYEGnXX9r...c=",
>    "deliveryService": ["example_deliveryservice.eth"],
>    "mutableProfileExtensionUrl":"https://example_profile/abcd"
> }
> ```

> **Example** UserProfile with fallback delivery service:
>
> ```JavaScript
> {
>    "publicEncryptionKey":"nyDsUmYV4EDNCsG+pK...D=",
>    "publicSigningKey":"MBpqhsSkxevwbYEGnXX9r...c=",
>    "deliveryService": ["example_deliveryservice.eth","example_fallback-deliveryservice.eth"]
> }
> ```

The mutableProfileExtension (optional) contains, if available, additional configuration information of the receiver:

* **Minimum Nonce:** the sender's address (address linked to the ENS domain) must have a nonce higher than this value, showing that this is a used account.
* **Minimum Balance:** the sender's address holds more than a defined minimum in Ether or another token, as specified in Minimum Token Address.
* **Minimum Balance Token Address:** If the balance is not defined in Ether, the address of the token contract needs to be declared. If Ether is used, this fields stays empty.
* **Encryption Algorithm:** the default encryption algorithm is **x25519-chacha20-poly1305**. If another encryption algorithm needs to be used (e.g., because this is needed for an ecosystem which is integrated into **dm3**), this can be requested. The default algorithm must be accepted, too. Otherwise, it might be impossible for a sender to deliver a message when it doesn't support the requested algorithm.
This is a list of supported algorithms, sorted by importance. All listed algorithms must be supported by the receiver. The sender is free to choose but should use reveivers preferrences if supported.
* **Not supported Messsage Types:** the receiver can inform that the client he/she uses is not supporting any of the optional message types (see [message data structure](mtp-transport.md#message_data_structure)). The sender must not send such messages, as the receiver will not accept those messages.

**DEFINITION:** mutableProfileExtension

```JavaScript
{
  // the minimum nonce of the sender's address
  // (optional)
  minNonce: string,
  // the minimum balcance of the senders address 
  // (optional)
  minBalance: string,
  // token address, which shoould be evaluated. 
  // Empty address means Ether balance.
  // (optional)
  minBalanceTokenAddress: string,
  // Request of a specific ancryption algorithm.
  // (optional)
  encryptionAlgorithm: string[],
  // List not sopported message types
  // (optional)
  notSupportedMessageTypes: string[],
}
```

> **Example** Mutable Profile Exception:
>
> ```JavaScript
> {
>    "minNonce":"1",
>    "minBalance":"1000000000000000000",
>    "encryptionAlgorithm": ["x25519-chacha20-poly1305"],
>    "notSupportedMesssageTypes": ["EDIT", "READ_RECEIPT","RESEND_REQUEST"],
> }
> ```

## Delivery Service Profile

The delivery service profile MUST contain:

* **Public Signing Key:** Key used to verify a postmark signature (see **UserProfile**).
* **Public Encryption Key:** Key used to encrypt the delivery instructions (x25519-chacha20-poly1305).
* **Delivery Service URL:** URL pointing to the delivery service instance.

As encryption algorithm for the delivery service, the default algorithm **x25519-chacha20-poly1305** is mandatory.

**DEFINITION:** DeliveryServiceProfile

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

> **Example:** DeliveryServiceProfile
>
> ```JavaScript
> {
>    "publicEncryptionKey":"nyDsUmYV4EDNCsG+pK...D=",
>    "publicSigningKey":"MBpqhsSkxevwbYEGnXX9r...c=",
>    "url": "https://example_deliveryservice"
> }
> ```
