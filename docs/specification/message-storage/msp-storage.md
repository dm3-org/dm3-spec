# Storage

The dm3 protocol does not specify where the user has to store his messages. Depending on the use case and the requirements of the user, the messages can be stored in different places and ways. The user should always be in full control of his/her decision, where and how to manage conversation data.

The following approaches are possible, although not the only ones.

* **Local File Storage:** All conversations including attached media are stored in the local file system. All stored information is encrypted. While local storage is the most privacy preseving (conversation data is only stored an the user's device and in full control of the user), synchronization between devices is resistricted or not possible.
* **Web3 Decentralized Storage:** The conversations are organized and pinned in IPFS. The information is stored fully encrypted. Multiple devices of the user can access the decentrally managed data.
* **Cloud Storage:** The conversations are stored at a cloud service of the user (like Google drive). The information is stored fully encrypted. The user decides whether and/or which cloud service provider to use. The availability of the conversation data thus depends on the availability of the cloud service provider. Synchronization between different devices is easy as long as the cloud drive is accessable.
* **dm3 Service Storage:** A special variant of cloud storage is the data service of a dm3 node (delivery service). As an optional service, this can offer the storage of encrypted conversations. To access the conversation history, the client must be connected to this delivery service. Synchronization between multiple delivery service nodes is optional.

_[IMAGE to visualize storage, tbd.]_

For performance reasons, a client can/should cache current conversations so that it does not have to fetch the data from a possibly remote storage each time it is accessed. If additional data is needed (e.g. earlier parts of the communication history), it can be retrieved sequentially.
