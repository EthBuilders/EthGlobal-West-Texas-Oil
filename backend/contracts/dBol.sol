// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutold.sol";
import "../interfaces/ERC20TopDown.sol";
import "../interfaces/ERC721BottomUp.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DBol is ERC721PresetMinterPauserAutoId, Ownable {
	//This will allow us to keep a unique tokenId for each dBol.
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	constructor(string memory baseURI) public ERC721("DBol", "DBL", baseURI) public {
	}

	//Will allow others to make mint dBol tokens;
	function grantPermission(address oilManager) onlyOwner() {
		setupRole(MINTER_ROLE, oilManager);
	}

	//Will revoke permission to mint dBol tokens;
	function revokePermission(address oilManager) onlyOwner() {
		revokeRole(MINTER_ROLE, oilManager);
	}

	//This function will be called from the original ticket contract.
	function createDBol(address driver, string memory tokenURI) public returns (uint256) {
		require(hasRole(MINTER_ROLE, msg.sender), "Don't have permission to mint DBol token");

		_tokenIds.increment();
		uint256 newDBolId = _tokenIds.current();
		_mint(driver, newDBolId);
		_setTokenUri(newDBolId, tokenURI);

		return newDBolId;
	}

	////////////////////////////////////////////////////////////

	function getStableBol(uint tokenId, address to, address StableBolAddress, uint amount) public {

		//Kind of lost here as to where to go
	}

}