// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BolToken is ERC20, ERC20PresetMinterPauser {
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	constructor(uint256 supply) ERC2PresetMinterPauser("Bol", "BOL") public {
		//Creating intial supply to accomodate approx. 100 BOLs
		_mint(msg.sender, 10000);
	}

	//Checks that no more than 1000
	modifier auditorRestrictions(address auditor, uint amount) {
		require(amount <= 1000);
		require(balanceOf(auditor) < 100);
		_;
	}

	//Grant permission to specific address, most likely a 
	function grantPermission(address oilManager) onlyOwner() {
		setupRole(MINTER_ROLE, oilManager);
	}

	function revokePermission(address oilManager) onlyOwner() {
		revokeRole(MINTER_ROLE, oilManager);
	}

	//In order to mint you must be a minter or contract deployer
	function mint(address to, uint256 amount) public auditorRestrictions(msg.sender, amount) {
		require(hasRole(MINTER_ROLE, msg.sender), "Must be a minter");
		_mint(to, amount);
	}

	//Can only be called by current owner
	function transferOwnership(address newOwner) public {
		transferOwnership(newOwner);
	}

}