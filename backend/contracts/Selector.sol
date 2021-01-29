// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

interface Solidity101 {
    function hello() external pure;

    function world(int256) external pure;
}

/// @title Contract for calculating Interface IDs
contract Selector {
    /// @dev Calculate the interface
    /// @dev Requires the import of the interface
    function calculateSelector() public pure returns (bytes4) {
        Solidity101 i;
        return i.hello.selector ^ i.world.selector;
    }
}
