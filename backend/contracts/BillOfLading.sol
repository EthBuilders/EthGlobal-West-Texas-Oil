// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";

// @title Bill of Lading NFT Contract
// @author Edward Amor
// @notice Users should not directly interact with this contract
// @dev All ERC721 functions are inherited from Openzeppelin ERC721 contract
contract BillOfLading is ERC721PresetMinterPauserAutoId {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) public ERC721PresetMinterPauserAutoId(name, symbol, baseURI) {}
}
