// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BillOfLading is Ownable, ERC721 {
    constructor(string memory name, string memory symbol)
        public
        ERC721(name, symbol)
    {}
}
