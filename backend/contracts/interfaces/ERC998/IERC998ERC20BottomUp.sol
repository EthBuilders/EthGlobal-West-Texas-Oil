// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

/// @title ERC998ERC20 Bottom-Up Composable Fungible Token
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
/// Note: The ERC-165 identifier for this interface is 0xffafa991
interface ERC998ERC20BottomUp {
    /// @dev This emits when a token is transferred to an ERC721 token
    /// @param _toContract The contract the token is transferred to
    /// @param _toTokenId The token the token is transferred to
    /// @param _amount The amount of tokens transferred
    event TransferToParent(
        address indexed _toContract,
        uint256 indexed _toTokenId,
        uint256 _amount
    );

    /// @dev This emits when a token is transferred from an ERC721 token
    /// @param _fromContract The contract the token is transferred from
    /// @param _fromTokenId The token the token is transferred from
    /// @param _amount The amount of tokens transferred
    event TransferFromParent(
        address indexed _fromContract,
        uint256 indexed _fromTokenId,
        uint256 _amount
    );

    /// @notice Get the balance of a non-fungible parent token
    /// @param _tokenContract The contract tracking the parent token
    /// @param _tokenId The ID of the parent token
    /// @return amount The balance of the token
    function balanceOfToken(address _tokenContract, uint256 _tokenId)
        external
        view
        returns (uint256 amount);

    /// @notice Transfer tokens from owner address to a token
    /// @param _from The owner address
    /// @param _toContract The ERC721 contract of the receiving token
    /// @param _toTokenId The receiving token
    /// @param _amount The amount of tokens to transfer
    function transferToParent(
        address _from,
        address _toContract,
        uint256 _toTokenId,
        uint256 _amount
    ) external;

    /// @notice Transfer token from a token to an address
    /// @param _fromContract The address of the owning contract
    /// @param _fromTokenId The owning token
    /// @param _to The address the token is transferred to
    /// @param _amount The amount of tokens to transfer
    function transferFromParent(
        address _fromContract,
        uint256 _fromTokenId,
        address _to,
        uint256 _amount
    ) external;

    /// @notice Transfer token from a token to an address, using ERC223 semantics
    /// @param _fromContract The address of the owning contract
    /// @param _fromTokenId The owning token
    /// @param _to The address the token is transferred to
    /// @param _amount The amount of tokens to transfer
    /// @param _data Additional data with no specified format, can be used to specify the sender tokenId
    function transferFromParentERC223(
        address _fromContract,
        uint256 _fromTokenId,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external;

    /// @notice Transfer a token from a token to another token
    /// @param _fromContract The address of the owning contract
    /// @param _fromTokenId The owning token
    /// @param _toContract The ERC721 contract of the receiving token
    /// @param _toTokenId The receiving token
    /// @param _amount The amount tokens to transfer
    function transferAsChild(
        address _fromContract,
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        uint256 _amount
    ) external;
}
