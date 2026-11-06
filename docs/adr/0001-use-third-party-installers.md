# Use third-party installers instead of storing third-party skills

The hub stores its owner's skills and a catalog of third-party sources.
Third-party skill files stay out of the hub repository.
When the user selects an entry, the hub uses that source's documented installation process.
This includes the Skills CLI, agent plugin installers, and source-specific installers.

This decision preserves each source's packaging and supporting components without maintaining copies in the hub.
The trade-off is that installation scope, revision pinning, updates, and required setup differ between installers.
The hub must show those limits, record installation details, and provide manual instructions when automation is unavailable.
