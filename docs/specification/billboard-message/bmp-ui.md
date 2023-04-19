# Embedded Widget

With the **dm3 billboard embedded widget** a REACT component is available, based on [DM3MTP](../message-transport/mtp.rst) and [DM3BMP](bmp.rst) a billboard chat function can be integrated into any web application with minimal effort. The appearance and look-and-feel of the component can be extensively customized to seamlessly integrate the component into applications.

## UI/UX Overview

The embedded widget displays the messages of the billboard and allows users to participate in the discussion with statements. Special users (authorized by the billboard service) act as mediators to delete inappropriate or inadmissible amounts. Special functions are available for these users.

## Parameters

The component needs some parameters from the parent application:

- **Billboard ID:** The billboard id is the ENS name of the billboard. This name contains a **dm3 profile** containing all relevant information.
- **Seed:** The seed is needed to derive Encryption and signature keys. These keys are then required for dm3 communication. In order to integrate the component into an existing dApp, this dApp can then pass a suitable seed (this is generated from a signature of the connected wallet, for example).
_**IMPORTANT:** the seed must be a secret and must not be generated from reproducible data!_
- **User Address:** The address of the user's wallet. The address is needed to establish the connection to his/her ENS name (reverse record must be set!) and his/her avatar. In addition, the address is needed to eventually identify the user as a [moderator](bmp-client.md#moderation-of-the-conversation).
- **Start Time:** The components can diplay the time of the message relative to the start time. This parameter is OPTIONAL. If it is not set, the ablolute time is displayed.
