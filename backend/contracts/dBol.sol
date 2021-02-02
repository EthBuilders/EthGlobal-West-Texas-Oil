// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./interfaces/ERC998/IERC998ERC20TopDown.sol";
import "./ERC998/ERC998ERC721BottomUp.sol";

contract DBol is
    ERC721PresetMinterPauserAutoId,
    ERC998ERC721BottomUp,
    IERC998ERC20TopDown
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev Keeps track of all the tokens which a tokenId owns
    mapping(uint256 => EnumerableSet.AddressSet) erc20Contrracts;

    /// @dev index of a contract inside of erc20Contracts set
    mapping(uint256 => mapping(address => uint256)) erc20ContractIndex;

    /// @dev tokenId balance for contract
    mapping(uint256 => mapping(address => uint256)) erc20Balances;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) public ERC721PresetMinterPauserAutoId(name_, symbol_, baseURI_) {}

    /// @dev Wrapper around the ERC721 mint function to create a new token
    /// @dev this function will only work if the msg.sender has the minter role
    /// @dev must call grantRole first to assign permission
    function createDBol() public {
        mint(msg.sender);
    }

    ////////////////////// Iplementation of ERC998ERC20TopDown.sol below ///////////////////

    /// @notice Look up the balance of ERC20 tokens for a specific token and ERC20 contract
    /// @param _tokenId The token that owns the ERC20 tokens
    /// @param _erc20Contract The ERC20 contract
    /// @return The number of ERC20 tokens owned by a token from an ERC20 contract
    function _balanceOfERC20(uint256 _tokenId, address _erc20Contract)
        internal
        view
        returns (uint256)
    {
        return erc20Balances[_tokenId][_erc20Contract];
    }

    /// @notice Look up the balance of ERC20 tokens for a specific token and ERC20 contract
    /// @param _tokenId The token that owns the ERC20 tokens
    /// @param _erc20Contract The ERC20 contract
    /// @return The number of ERC20 tokens owned by a token from an ERC20 contract
    function balanceOfERC20(uint256 _tokenId, address _erc20Contract)
        external
        view
        returns (uint256)
    {
        return _balanceOfERC20(_tokenId, _erc20Contract);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////

    //params@tokenId refers to NFT who will be owner of FT
    //params@to refers to owner of tokenId and will also by nature be the new owner of the FT
    //params@erc20Contract refers to contract addrress of FT factory
    //params@value refers to amount of FT tokens being transferred
    function transferERC20(
        uint256 fromTokenId,
        address to,
        address erc20Contract,
        uint256 value
    ) external {
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
    function getERC20(
        address from,
        uint256 tokenId,
        address erc20Contract,
        uint256 value
    ) external {
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
