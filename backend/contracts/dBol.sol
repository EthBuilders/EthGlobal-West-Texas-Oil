// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "/Users/edsonramirez/ChainSkills/private/West-texas-prep/node_modules/@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

//Inherits from IERC20.sol, Need this to check balance on transferERC20.sol
//Actually might not need this, I know great comments
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//IERC99820TopDown.sol inherits from IERC721.sol
// import "./IERC998ERC20TopDown.sol";

contract DBol is ERC721PresetMinterPauserAutoId {

	constructor() public ERC721PresetMinterPauserAutoId("DBol", "DBL", "") {
	}



	//This function will be called from the original ticket contract.
	//Uses openzeppelin 
	function createDBol(address driver) public {
		mint(driver);
	}

	event TransferERC20(
    	uint256 indexed _fromTokenId, 
    	address indexed _to, 
    	address indexed _erc20Contract, 
    	uint256 _value
  	);

	////////////////////// Iplementation of ERC998ERC20TopDown.sol below ///////////////////

	mapping(uint256 => mapping(address => uint256)) balanceOfFungibleToken;


	function _balanceOfERC20(uint256 tokenId, address erc20Contract) internal view returns (uint256) {
		//params@tokenId refer to the ERC-998 token that owns ERC-20 tokens
		//params@erc20Contract refers to the token contract of the erc20Contract
		//Function will return the number of ERC20 tokens owned by a specific token
		return balanceOfFungibleToken[tokenId][erc20Contract];
	}

	function balanceOfERC20(uint256 tokenId, address erc20Contract) external view returns (uint256) {
		return _balanceOfERC20(tokenId, erc20Contract);
	}

	/////////////////////////////////////////////////////////////////////////////////////////////

	//params@tokenId refers to NFT who will be owner of FT
	//params@to refers to owner of tokenId and will also by nature be the new owner of the FT
	//params@erc20Contract refers to contract addrress of FT factory
	//params@value refers to amount of FT tokens being transferred
	function transferERC20(uint256 fromTokenId, address to, address erc20Contract, uint256 value) external {
		//Checks that the sender of these ERC20 tokens has enough to send
		//This also makes sure balanceOf(msg.sender) doens't come back undefined
		require(_balanceOfERC20(fromTokenId, erc20Contract) >= value);

		//NFTOwner is the address of the one who owns tokenId, which is a reference to their uniquq DBol token id
		//ownerOf() is a ERC721.sol function that returns address of ERC-721 token
		address NFTOwner = ownerOf(fromTokenId);
		//This require checks that the owner of the token transferrring the ERC20 is the caller of the function
		require(NFTOwner == msg.sender);

		//Need to find owner of params@to
		// address NFTReciever = ownerOf(to);

		//Msg.sender calls transfer() to send ERC20 tokens to owner of params@to
		IERC20(erc20Contract).transfer(to, value);

		//update amount of FT, for each individual NFT
		balanceOfFungibleToken[fromTokenId][erc20Contract] -= value;
		// balanceOfFungibleToken[to][erc20Contract] += value;
	
		emit TransferERC20(fromTokenId, to, erc20Contract, value);
	}

	//Needs to get approved before this function will work
	//params@from the current owner of the 
	function getERC20(address from, uint256 tokenId, address erc20Contract, uint256 value) external {
		//require that msg.sender has permission to transfer ERC20 tokens
		address NFTOwner = ownerOf(tokenId);
		//erc20Contract.allowance(from, NFTOwner) returns how much NFTOwner is allowed to use
		//This require also verifies that NFTOwner has been approved to spend the ERC20 tokens that belong to params@from
		require(IERC20(erc20Contract).allowance(from, NFTOwner) >= value);

		//Use transferFrom() from IERC20.sol
		IERC20(erc20Contract).transferFrom(from, NFTOwner, value);

		//update amount of FT, only for the tokenId(ERC998) token
		balanceOfFungibleToken[tokenId][erc20Contract] += value;

		emit Transfer(from, NFTOwner, value);
	}
	/////////////////////////////////////////////////////////////////////////////////////////////
}