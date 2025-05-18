# CONTRACT NAME: RealmFacet.sol

## Contract Overview

The RealmFacet contract’s purpose in the Aavegotchi Gotchiverse is to manage land parcels (known as "realms") within the virtual metaverse. This contract enables core functionalities such as minting of parcels, equipping and unequipping installations and tiles, and updating and upgrading land.

## Core Functionalities of the Realm Facet

- Minting and assigning of parcels

This enables the controlled minting of new land parcels as NFTs, setting unique attributes that define each parcel's value and characteristics.

- Equipping and Customizing of Parcels:

This enables players to equip various installations (like resource generators and defensive structures), upgrade them and add decorative tiles on their parcels, enhancing both functionality and aesthetics.

## Dependencies

The RealmFacet contract relies on several external and internal libraries and interfaces to implement its core functionalities securely and modularly.

Below is a breakdown of each dependency and its purpose:

### External Libraries

**@openzeppelin/contracts/token/ERC20/IERC20.sol:** This interface from OpenZeppelin allows interactions with ERC20 tokens, specifically for transferring and handling Alchemica resources, which are used in-game as rewards, refunds, or upgrade costs.

**Internal Libraries** **AppStorage.sol:** This library handles state management for the Aavegotchi Diamond contract. It consolidates state variables across facets, allowing the RealmFacet to access and modify shared data such as parcel metadata and resource configurations.

**LibDiamond.sol:** Implements EIP-2535 (Diamond Standard) to enable modular and upgradeable facets. LibDiamond manages function selectors and ensures that the RealmFacet can operate as part of the larger Diamond architecture.

**LibStrings.sol:** Provides utility functions for string manipulation, useful for handling parcel and installation identifiers or other metadata strings.

**LibMeta.sol:** Supplies metadata-related utilities, specifically for tracking and verifying the message sender (msg.sender) across facets.

**LibERC721.sol:** Contains functionality for minting ERC721 tokens, allowing RealmFacet to create new parcels as NFTs, ensuring secure and standardized ownership transfer.

**LibRealm.sol:** The core library for handling realm-specific logic, such as minting, equipping, or unequipping parcels and installations. It encapsulates operations and state variables that are unique to the Gotchiverse.

**LibAlchemica.sol:** Manages operations related to Alchemica (in-game resources). This includes modifying player traits and handling resource generation, storage, and refunds.

**LibSignature.sol:** Provides signature verification functions, enabling secure authorization and preventing unauthorized actions on parcels or installations.

### Interfaces

**InstallationDiamondInterface.sol:** Facilitates interaction with the installation management facet in the Diamond contract. This interface allows RealmFacet to equip, unequip, and upgrade installations by interacting with installation-related data and functions.

**IERC1155Marketplace.sol:** Supports marketplace interactions, allowing installations and tiles to be listed, updated, or removed from the Aavegotchi marketplace.

## Functional Review

### mintParcels function

This function allows the contract owner to mint new parcels as NFTs, assigning each parcel to specified addresses with unique metadata attributes (e.g., coordinates, size, district).

**Key Operations**

- Minting: Mints each parcel with a unique token ID and assigns it to the specified address.
- Metadata Assignment: Sets parcel attributes (e.g., coordinates, size, boosts) based on the provided metadata input.

**Checks**

- Supply Limit: Ensures that the total number of parcels does not exceed the maximum supply (LibRealm.MAX_SUPPLY).
- Input Consistency: Checks that \_to, \_tokenIds, and \_metadata arrays are the same length to prevent mismatches in parcel data.

### batchEquip function

The batchEquip function allows batch operations on a parcel by equipping or unequipping multiple installations or tiles at once. This supports efficient customization of parcels in the Gotchiverse, enabling players to modify setups with a single transaction.

**Key Operations**

- Uses the gameActive modifier to ensures that the game is currently active, preventing operations when the game is paused.

- Uses the canBuild modifier to confirms that building actions are allowed on the parcel, preventing unauthorized or restricted modifications.

- Batch processess items by iterating through \_params.ids and determines, based on types and equip values, whether to equip or unequip each item.

- Routes actions to corresponding functions (equipInstallation, equipTile, unequipInstallation, unequipTile) according to item type.

**Checks**

- Array Length Matching: Ensures \_params.ids has the same length as \_params.x and \_params.y to avoid data misalignment.
- Signature Verification: Uses \_signatures to validate permission for each batch operation, protecting against unauthorized changes.

### equipInstallation

This function allows a player to equip an installation (like a harvester, lodge, or other structures) on a specified parcel in the Gotchiverse.

**Key Operations**

- Confirms player’s permission and verifies the \_signature to authorize the action.
- Enforces survey status for certain types and ensures only one lodge per parcel.
- Validates requirements for “Maker” installations.
- Places the installation on the parcel, updates traits, and records the change in the marketplace.

**Checks**

- Limits initial equipping to level 1 installations only.
- Survey and Lodge Requirements: Verifies parcel readiness for specific installation types.
- Signature and Access Checks: Ensures only authorized players can make changes to the parcel.

### unequipInstallation

This function allows a parcel owner to unequip an installation from their parcel, provided certain conditions are met. It handles validations, removes the installation, updates traits, and processes partial resource refunds.

**Key Operations**

- Confirms the caller’s ownership of the parcel and verifies the \_signature to validate the unequip action.
- Prevents unequipping if the installation is currently in an upgrade queue.
- Ensures only one altar or maker installation can exist on the parcel at a time.
- Removes the installation from the parcel grid, updates traits, and logs the change in unequipInstallation.
- Calculates a partial refund based on the installation’s upgrade costs, returning half of the Alchemica used for each level in reverse order.

**Checks**

- Ensures the parcel owner initiates the action.
- Checks that no upgrade is active for the installation.
- Confirms that the parcel setup supports unequipping specific installation types (e.g., altar).

### moveInstallation

This function enables a parcel owner to relocate an existing installation from one set of coordinates to another within the same parcel, provided certain conditions are met.

**Key Operations**

- Ensures the caller owns the parcel.
- Uses gameActive and canBuild modifiers to confirm the game state allows building and modification actions.
- Ensures the installation is not in the process of upgrading before allowing it to be moved.
- Calls LibRealm.removeInstallation to take the installation off the grid at its original position (\_x0, \_y0).
- Calls LibRealm.placeInstallation to place the installation at the new coordinates (\_x1, \_y1).
- Emits UnequipInstallation and EquipInstallation events to log the installation’s movement.

**Checks**

- Checks that the installation is not undergoing an upgrade, preventing unintended state changes during an upgrade.

### equipTile function

The function allows a player to equip a tile at specified coordinates on a parcel, provided they have the necessary access rights and authorization.

**Key Operations**

- gameActive and canBuild modifiers confirm the game is active and the parcel is allowed to be modified.

- Uses LibRealm.verifyAccessRight to confirm the player’s right to equip the tile on the specified parcel.
- Validates the \_signature to ensure the request is authorized by the backend (s.backendPubKey).
- Calls LibRealm.placeTile to assign the tile at specified coordinates (\_x, \_y).
- Calls equipTile on TileDiamondInterface, registering the tile placement.
- Updates the tile’s status in the Aavegotchi marketplace via IERC1155Marketplace.
- Emits an EquipTile event to record the tile placement action.

**Checks**

Ensures only authorized players can equip tiles, protecting the parcel from unauthorized changes.

### unequipTile function

This function allows a parcel owner to unequip a tile from specified coordinates on their parcel, ensuring proper access rights and authorization.

**Key Operations**

- the onlyParcelOwner modifier ensures that only the parcel owner can initiate the unequip action.
- the gameActive and canBuild modifier confirms the game is active and building is allowed.
- validates \_signature to authorize the unequip action, ensuring it’s requested by a verified user (s.backendPubKey).
- Calls LibRealm.removeTile to take the tile off the specified coordinates (\_x, \_y).
- Calls unequipTile on TileDiamondInterface to confirm the unequip action.
- Emits an UnequipTile event, logging the tile’s removal from the parcel.

**Checks**

Ensures only authorized actions by verifying ownership and validating the \_signature.

### moveTile function

This function enables a parcel owner to move a tile from one set of coordinates to another on their parcel.

**Key Operations**

- Ensures only the parcel owner can initiate the move action.
- the gameActive and canBuild modifier confirms that the game is active and modifications are allowed.
- Calls LibRealm.removeTile to take the tile off the grid at the original coordinates (\_x0, \_y0) and emits an UnequipTile event.
- Calls LibRealm.placeTile to place the tile at the new coordinates (\_x1, \_y1) and emits an EquipTile event to log the change.

**Checks**

Ensures only authorized users can make modifications and that the game state allows building.

### upgradeInstallation function

**Key Operations**

- Restricts the function to be called exclusively by the InstallationDiamond contract, ensuring only authorized upgrades.
- Calls LibRealm.removeInstallation to remove the current (lower-level) installation from the specified coordinates.
- Calls LibRealm.placeInstallation to position the upgraded installation at the same coordinates.
- Adjusts parcel traits by reducing traits of the previous installation and increasing them for the new installation using LibAlchemica.reduceTraits and LibAlchemica.increaseTraits.
- Emits InstallationUpgraded event, logging details of the upgrade for tracking purposes.

**Checks** Only InstallationDiamond can initiate the upgrade, safeguarding against unauthorized upgrades.

### addUpgradeQueueLength function

The function increments the upgradeQueueLength for a specific parcel, allowing tracking of active upgrades on that parcel.

**Key Operations**

- Restricts access to the InstallationDiamond contract, ensuring only authorized sources can modify the upgrade queue length.
- Increases the upgradeQueueLength counter for the parcel identified by \_realmId in s.parcels. This keeps track of ongoing upgrades for management and prevents exceeding upgrade limits.

**Checks** Ensures only InstallationDiamond can call this function, protecting against unauthorized queue changes.

### subUpgradeQueueLength function

The function increments the upgradeQueueLength for a specified parcel, managing the count of active upgrades for that parcel.

**Key Operations**

- Restricts the function to be called by the InstallationDiamond contract, ensuring that only authorized sources can modify the upgrade queue length.

- Decreases the upgradeQueueLength counter for the parcel identified by \_realmId in s.parcels, reflecting the completion or removal of an upgrade from the queue.

### fixGrid function

This function allows the contract owner to manually correct the grid layout on a parcel, setting installations or tiles at specific coordinates. This can be used for maintenance or fixing grid inconsistencies.

**Key Operations**

- the onlyOwner modifier restricts the function to the contract owner, ensuring only authorized personnel can make manual changes to the parcel grid. Grid Fixing:
- Confirms that \_x and \_y arrays have matching lengths to prevent misalignment in coordinate entries.
- Ensures each coordinate pair (\_x[i], \_y[i]) is within the 64x64 grid size.

- Updates either the buildGrid or tileGrid for the specified parcel based on the tile flag. If tile is false, it updates buildGrid; if true, it updates tileGrid.

**Checks**

Coordinate Length and Bounds: Ensures matching lengths for \_x and \_y arrays and restricts coordinate values to within the 64x64 grid.

### buildingFrozen function

This function provides a read-only view of the freezeBuilding state, indicating whether building actions are currently restricted in the Gotchiverse.

**Key Operations**

This is an external view function that returns the value of s.freezeBuilding, allowing external contracts or users to check if building is frozen.

**Checks**

As a view function, it performs no state changes, ensuring it doesn’t alter any contract data.

### setFreezeBuilding function

This function allows the contract owner to enable or disable building actions across the Gotchiverse by setting the freezeBuilding state.

**Key Operations**

- Restricts access to the contract owner, ensuring only they can modify the freezeBuilding state.
- Sets s.freezeBuilding to the provided \_freezeBuilding value, controlling whether building actions are allowed or restricted.

**Checks** Ensures only the owner can toggle the building freeze state, protecting against unauthorized changes.

## Conclusion

### Conclusion

The **RealmFacet** contract serves as a vital component within the Aavegotchi Gotchiverse, enabling players to interact with and customize their land parcels through a range of functions. It effectively combines asset management, access control, and modular functionality to provide a secure and user-friendly experience for players. By leveraging the **Diamond Standard (EIP-2535)** architecture, the contract allows for seamless upgrades and modularity, supporting the dynamic and evolving needs of the Gotchiverse.

Key strengths of the RealmFacet contract include its structured approach to equipping, unequipping, and upgrading installations and tiles, which are integral to parcel functionality and customization. Additionally, built-in access controls, such as `onlyOwner` and `onlyInstallationDiamond` modifiers, ensure that sensitive operations remain restricted to authorized users or contracts, adding a strong layer of security.

Several opportunities for improvement were identified, including implementing additional validation for coordinate bounds, enhancing error messaging for better debugging, and introducing event emissions where appropriate. These refinements would enhance the contract’s robustness and usability, supporting future growth and more complex interactions within the Gotchiverse.

Overall, the RealmFacet contract is well-designed to manage parcel interactions in a modular, secure, and efficient manner, laying a solid foundation for an immersive virtual experience in the Aavegotchi Gotchiverse.
