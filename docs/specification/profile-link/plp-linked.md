# Linked Profiles

If LSP ([Limited Scope Profiles](lsp-overview.md)) is linked to a main profile, the communications of the LSP are also mirrored to the main profile. This is done by the LSP dApp forwarding all incoming and outgoing messages to the main profile.
If a dm3 compatible app does not support linking to LSP, these communications will not be displayed. In the app of the main profile, LSP communications are usually displayed as read-only communications.

## LSP Conversations

As defined in [Message Transport Protocol](../message-transport/mtp-transport.md#encryption-envelope-data-structure), the Envelope contains the same **To** and **From** information (see [Envelope Metadata Structure](../message-transport/mtp-transport.md#envelope-metadata-structure)) as the Message (see [Message Metadata Structure](../message-transport/mtp-transport.md#message-metadata-structure)).

When messages are forwarded from an LSP to the main profile, the message (in Message Metadata Structure) contains the original information (so it is a communication between the LSP and the actual receiver/sender), but the envelope is directed from the LSP to the main profile (in Envelope Metadata Structure).

So the dm3 compatible messenger app must (be able to) create its own communication that is not its own.

### Signatures

The signatures in the message correspond to the actual communication, in the envelope is the signature from the LSP.

### Encryption der Message


## LSP App

### First action after