// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";

// @title Bill of Lading NFT Contract
// @author Edward Amor
// @notice Users should not directly interact with this contract
// @dev All ERC721 functions are inherited from Openzeppelin ERC721 contract
contract BillOfLading is ERC721PresetMinterPauserAutoId {
    enum CardinalDirections {NORTH, EAST, SOUTH, WEST} // clock-wise ordering

    /**
        @param degree ranges from 0 to 90 for latitude and 0 to 180 for longitude
        @param minute ranges from 0 to 60
        @param second ranges from 0.0 to 60.0, since this can be a decimal number
        and solidity only works with integers, we have to do some padding.
        A standardized way to do this is simply provide a number within the range
        of [0, 2 ^ 16 - 1], and to pad it with 3 zeros.
        
        Ex.
        25.23 => 25230
        59.98 => 59980
        00.39 => 00390
     */
    struct geoPosition {
        uint8 degree;
        uint8 minute;
        uint16 second;
        CardinalDirections cardinalDirection;
    }

    /**
        @param quantity is the amount in MT (metric tons) since this is a decimal
        we pad and make sure to leave the last 2 digits as the decimal numbers.

        Ex. 
        28.1 MT => 2810
        1289.32 MT => 128932
     */
    struct MintArgs {
        address driver;
        string serialNumber;
        geoPosition[2] origin;
        geoPosition[2] destination;
        uint256 quantity;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) public ERC721PresetMinterPauserAutoId(name, symbol, baseURI) {}

    function createBillOfLading(MintArgs memory _args) public {
        mint(msg.sender);
    }
}
