# CONTRACT REVIEW

## Introduction

## Imports

## Data Structure & State Variable

### Structs

#### struct MintParcelInput

```solidity
struct MintParcelInput {
  uint256 coordinateX;
  uint256 coordinateY;
  uint256 district;
  string parcelId;
  string parcelAddress;
  uint256 size; //0=humble, 1=reasonable, 2=spacious vertical, 3=spacious horizontal, 4=partner
  uint256[4] boost; //fud, fomo, alpha, kek
}
```

```solidity
struct BatchEquipIO {
    uint256[] types; //0 for installation, 1 for tile
    bool[] equip; //true for equip, false for unequip
    uint256[] ids;
    uint256[] x;
    uint256[] y;
  }
```

## Events

```solidity
event EquipInstallation(uint256 _realmId, uint256 _installationId, uint256 _x, uint256 _y);
event UnequipInstallation(uint256 _realmId, uint256 _installationId, uint256 _x, uint256 _y);
event EquipTile(uint256 _realmId, uint256 _tileId, uint256 _x, uint256 _y);
event UnequipTile(uint256 _realmId, uint256 _tileId, uint256 _x, uint256 _y);
event AavegotchiDiamondUpdated(address _aavegotchiDiamond);
event InstallationUpgraded(uint256 _realmId, uint256 _prevInstallationId, uint256 _nextInstallationId, uint256 _coordinateX, uint256 _coordinateY);
```

## Modifiers

### Functions

mintParcels batchEquip equipInstallation unequipInstallation moveInstallation equipTile unequipTile moveTile upgradeInstallation addUpgradeQueueLength subUpgradeQueueLength fixGrid buildingFrozen function setFreezeBuilding(bool \_freezeBuilding) external onlyOwner {
