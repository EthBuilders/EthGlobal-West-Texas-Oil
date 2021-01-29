// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

/// @title ERC998ERC20 Top-Down Composable Non-Fungible Token
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
///  Note: the ERC-165 identifier for this interface is 0x7294ffed
interface ERC998ERC20TopDown {
    /// @dev This emits when a token receives ERC20 tokens.
    /// @param _from The prior owner of the token.
    /// @param _toTokenId The token that receives the ERC20 tokens.
    /// @param _erc20Contract The ERC20 contract.
    /// @param _value The number of ERC20 tokens received.
    event ReceivedERC20(
        address indexed _from,
        uint256 indexed _toTokenId,
        address indexed _erc20Contract,
        uint256 _value
    );

    /// @dev This emits when a token transfers ERC20 tokens.
    /// @param _fromTokenId The token that owned the ERC20 tokens.
    /// @param _to The address that receives the ERC20 tokens.
    /// @param _erc20Contract The ERC20 contract.
    /// @param _value The number of ERC20 tokens transferred.
    event TransferERC20(
        uint256 indexed _fromTokenId,
        address indexed _to,
        address indexed _erc20Contract,
        uint256 _value
    );

    /// @notice A token receives ERC20 tokens
    /// @param _from The prior owner of the ERC20 tokens
    /// @param _value The number of ERC20 tokens received
    /// @param _data Up to the first 32 bytes contains an integer which is the receiving tokenId.
    function tokenFallback(
        address _from,
        uint256 _value,
        bytes calldata _data
    ) external;

    /// @notice Look up the balance of ERC20 tokens for a specific token and ERC20 contract
    /// @param _tokenId The token that owns the ERC20 tokens
    /// @param _erc20Contract The ERC20 contract
    /// @return The number of ERC20 tokens owned by a token from an ERC20 contract
    function balanceOfERC20(uint256 _tokenId, address _erc20Contract)
        external
        view
        returns (uint256);

    /// @notice Transfer ERC20 tokens to address
    /// @param _tokenId The token to transfer from
    /// @param _to The address to send the ERC20 tokens to
    /// @param _erc20Contract The ERC20 contract
    /// @param _value The number of ERC20 tokens to transfer
    function transferERC20(
        uint256 _tokenId,
        address _to,
        address _erc20Contract,
        uint256 _value
    ) external;

    /// @notice Transfer ERC20 tokens to address or ERC20 top-down composable
    /// @param _tokenId The token to transfer from
    /// @param _to The address to send the ERC20 tokens to
    /// @param _erc223Contract The ERC223 token contract
    /// @param _value The number of ERC20 tokens to transfer
    /// @param _data Additional data with no specified format, can be used to specify tokenId to transfer to
    function transferERC223(
        uint256 _tokenId,
        address _to,
        address _erc223Contract,
        uint256 _value,
        bytes calldata _data
    ) external;

    /// @notice Get ERC20 tokens from ERC20 contract.
    /// @param _from The current owner address of the ERC20 tokens that are being transferred.
    /// @param _tokenId The token to transfer the ERC20 tokens to.
    /// @param _erc20Contract The ERC20 token contract
    /// @param _value The number of ERC20 tokens to transfer
    function getERC20(
        address _from,
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) external;
}

/// @dev The ERC-165 identifier for this interface is 0xc5fd96cd
interface ERC998ERC20TopDownEnumerable {
    /// @notice Get the number of ERC20 contracts that token owns ERC20 tokens from
    /// @param _tokenId The token that owns ERC20 tokens.
    /// @return uint256 The number of ERC20 contracts
    function totalERC20Contracts(uint256 _tokenId)
        external
        view
        returns (uint256);

    /// @notice Get an ERC20 contract that token owns ERC20 tokens from by index
    /// @param _tokenId The token that owns ERC20 tokens.
    /// @param _index The index position of the ERC20 contract.
    /// @return address The ERC20 contract
    function erc20ContractByIndex(uint256 _tokenId, uint256 _index)
        external
        view
        returns (address);
}
