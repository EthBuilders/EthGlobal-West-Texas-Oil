// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract Token is ERC20PresetMinterPauser("", "") {

    /// @dev faucet function
    function getTokens(uint256 _value) public {
        _mint(msg.sender, _value);
    }
}