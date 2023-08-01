# Overview

For certain use cases, it is required to create standalone profiles that can optionally be linked and synchronized with the main profile. For example, a dApp could use integrated in-app messaging, or a website could allow direct contact with designated persons or a [billboard chat](billboard-message/bmp.rst) allows anonymous users to post statements. These functions can be realized using the embedded **dm3** components.

Eventually, it might be desirable for a user to be able to send a message anonymously, but also, users should be able to write a message from the embedded messaging widget independently of their actual messenger app, which is then optionally also synchronized with their inbox.

In addition, security considerations may require the use of limited scope profiles (LSP) with their own keys.

The following description refers exclusively to ENS as a registry, but can equally be applied to any other nameservice of any chain or layer 2 or even a cloud service.

## Interoperability

Limited Scope Profiles are also used to enable interoperability and user choice of messenger while implementing embedded messaging features in dApps. These components work independently of the user's messenger and can optionally be linked to the user's inbox, so that they can also have the communication that takes place in the external application synchronously in their inbox.

```[IMAGE: Principle External communication linked to inbox]```
