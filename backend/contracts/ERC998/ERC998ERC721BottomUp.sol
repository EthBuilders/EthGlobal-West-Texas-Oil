// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ERC998/IERC998ERC721BottomUp.sol";

contract ERC998ERC721BottomUp is IERC998ERC721BottomUp, ERC721 {
    using SafeMath for uint256;

    struct TokenOwner {
        address tokenOwner;
        uint256 parentTokenId;
    }

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 constant ERC998_MAGIC_VALUE = bytes32(bytes4(0xcd740db5));

    // tokenId => token owner
    mapping(uint256 => TokenOwner) tokenIdToTokenOwner;

    function _tokenOwnerOf(uint256 _tokenId)
        internal
        view
        returns (
            address tokenOwner,
            uint256 parentTokenId,
            bool isParent
        )
    {
        tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        if (parentTokenId > 0) {
            // The value in the struct is (parentTokenId + 1)
            isParent = true;
            parentTokenId = parentTokenId.sub(1);
        } else {
            isParent = false;
        }
        return (tokenOwner, parentTokenId, isParent);
    }

    /// @notice Get the owner address and parent token (if there is one) of a token
    /// @param _tokenId The tokenId to query.
    /// @return tokenOwner The owner address of the token
    /// @return parentTokenId The parent owner of the token and ERC998 magic value
    /// @return isParent True if parentTokenId is a valid parent tokenId and false if there is no parent tokenId
    function tokenOwnerOf(uint256 _tokenId)
        external
        view
        override
        returns (
            bytes32 tokenOwner,
            uint256 parentTokenId,
            bool isParent
        )
    {
        address _tokenOwner;
        (_tokenOwner, parentTokenId, isParent) = _tokenOwnerOf(_tokenId);
        return (
            (ERC998_MAGIC_VALUE << 224) | bytes32(uint256(_tokenOwner)),
            parentTokenId,
            isParent
        );
    }
}
