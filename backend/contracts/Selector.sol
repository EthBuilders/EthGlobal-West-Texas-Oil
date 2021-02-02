// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "./interfaces/IERC1948.sol";

interface Solidity101 {
    function hello() external pure;

    function world(int256) external pure;
}

/// @title Contract for calculating Interface IDs
contract Selector {
    /// @dev Calculate the interface
    /// @dev Requires the import of the interface
    function calculateSelectorReadData() public pure returns (bytes4) {
        IERC1948 i;
        return i.readData.selector;
    }

    function calculateSelectorWriteData() public pure returns (bytes4) {
        IERC1948 i;
        return i.writeData.selector;
    }

    function calculateSelector() public pure returns (bytes4) {
        return calculateSelectorReadData() ^ calculateSelectorWriteData();
    }
}
