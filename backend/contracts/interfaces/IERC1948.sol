// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Interface of the ERC1948 contract.
 */
interface IERC1948 is IERC721 {
    /**
     * @dev Emitted when `oldData` is replaced with `newData` in storage of `tokenId`.
     *
     * Note that `oldData` or `newData` may be empty bytes.
     */
    event DataUpdated(
        uint256 indexed tokenId,
        bytes32 oldData,
        bytes32 newData
    );

    /**
     * @dev Reads the data of a specified token. Returns the current data in
     * storage of `tokenId`.
     *
     * @param tokenId The token to read the data off.
     *
     * @return A bytes32 representing the current data stored in the token.
     */
    function readData(uint256 tokenId) external view returns (bytes32);

    /**
     * @dev Updates the data of a specified token. Writes `newData` into storage
     * of `tokenId`.
     *
     * @param tokenId The token to write data to.
     * @param newData The data to be written to the token.
     *
     * Emits a `DataUpdated` event.
     */
    function writeData(uint256 tokenId, bytes32 newData) external;
}
