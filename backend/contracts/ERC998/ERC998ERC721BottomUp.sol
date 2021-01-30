// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ERC998/IERC998ERC721BottomUp.sol";
import "../interfaces/ERC998/IERC998ERC721TopDown.sol";

contract ERC998ERC721BottomUp is IERC998ERC721BottomUp, ERC721 {
    using SafeMath for uint256;

    struct TokenOwner {
        address tokenOwner;
        uint256 parentTokenId;
    }

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 constant ERC998_MAGIC_VALUE = bytes32(bytes4(0xcd740db5));

    bytes4 private constant _INTERFACE_ID_ERC998ERC721TOPDOWN = 0x1efdf36a;
    bytes4 private constant _INTERFACE_ID_ERC998ERC721BOTTOMUP = 0xa1b23002;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    // tokenId => token owner
    mapping(uint256 => TokenOwner) tokenIdToTokenOwner;

    // Use Cases handled:
    // Case 1: Token owner is this contract and no parent tokenId.
    // Case 2: Token owner is this contract and token
    // Case 3: Token owner is top-down composable
    // Case 4: Token owner is an unknown contract
    // Case 5: Token owner is a user
    // Case 6: Token owner is a bottom-up composable
    // Case 7: Token owner is ERC721 token owned by top-down token
    // Case 8: Token owner is ERC721 token owned by unknown contract
    // Case 9: Token owner is ERC721 token owned by user
    /// @notice Get the root owner of tokenId.
    /// @param _tokenId The token to query for a root owner address
    /// @return rootOwner The root owner at the top of tree of tokens and ERC998 magic value.
    function rootOwnerOf(uint256 _tokenId)
        external
        view
        override
        returns (bytes32 rootOwner)
    {
        (address tokenOwner, uint256 parentTokenId, bool isParent) =
            _tokenOwnerOf(_tokenId);

        if ((tokenOwner == address(this))) {
            do {
                if (isParent == false) {
                    // Case 1: Token owner is this contract and no token.
                    // This case should not happen.
                    return
                        (ERC998_MAGIC_VALUE << 224) |
                        bytes32(uint256(tokenOwner));
                } else {
                    // Case 2: Token owner is this contract and token
                    (tokenOwner, parentTokenId, isParent) = _tokenOwnerOf(
                        parentTokenId
                    );
                }
            } while (tokenOwner == address(this));
            _tokenId = parentTokenId;
        }

        if (isParent == false) {
            // success if this token is owned by a top-down token
            // 0xed81cdda == rootOwnerOfChild(address, uint256)
            if (Address.isContract(tokenOwner)) {
                // Top Down Contract
                bool _isERC998ERC721TopDown =
                    ERC165Checker.supportsInterface(
                        tokenOwner,
                        _INTERFACE_ID_ERC998ERC721TOPDOWN
                    );
                // Case 3: Token owner is top-down composable
                if (_isERC998ERC721TopDown) {
                    IERC998ERC721TopDown _contract =
                        IERC998ERC721TopDown(tokenOwner);
                    return _contract.rootOwnerOfChild(address(this), _tokenId);
                } else {
                    // Case 4: Token owner is an unknown contract
                    return
                        (ERC998_MAGIC_VALUE << 224) |
                        bytes32(uint256(tokenOwner));
                }
            } else {
                // Case 5: Token owner is a user
                return
                    (ERC998_MAGIC_VALUE << 224) | bytes32(uint256(tokenOwner));
            }
        } else {
            // 0x43a61a8e == rootOwnerOf(uint256)
            if (Address.isContract(tokenOwner)) {
                bool _isERC998ERC721TopDown =
                    ERC165Checker.supportsInterface(
                        tokenOwner,
                        _INTERFACE_ID_ERC998ERC721TOPDOWN
                    );
                bool _isERC998ERC721BottomDown =
                    ERC165Checker.supportsInterface(
                        tokenOwner,
                        _INTERFACE_ID_ERC998ERC721BOTTOMUP
                    );
                bool _isERC721 =
                    ERC165Checker.supportsInterface(
                        tokenOwner,
                        _INTERFACE_ID_ERC721
                    );

                if (_isERC998ERC721TopDown) {
                    // Case 6: Token owner is a bottom-up composable
                    IERC998ERC721BottomUp _contract =
                        IERC998ERC721BottomUp(tokenOwner);
                    return _contract.rootOwnerOf(parentTokenId);
                } else if (_isERC998ERC721BottomDown) {
                    // Case 2: Token owner is top-down composable
                    IERC998ERC721TopDown _contract =
                        IERC998ERC721TopDown(tokenOwner);
                    return _contract.rootOwnerOf(parentTokenId);
                } else if (_isERC721) {
                    IERC721 _contract = IERC721(tokenOwner);
                    tokenOwner = _contract.ownerOf(parentTokenId);
                    if (Address.isContract(tokenOwner)) {
                        bool _isERC998ERC721TopDown_ =
                            ERC165Checker.supportsInterface(
                                tokenOwner,
                                _INTERFACE_ID_ERC998ERC721TOPDOWN
                            );

                        // Case 7: Token owner is ERC721 token owned by top-down token
                        if (_isERC998ERC721TopDown_) {
                            IERC998ERC721TopDown _contract_ =
                                IERC998ERC721TopDown(tokenOwner);
                            return
                                _contract_.rootOwnerOfChild(
                                    tokenOwner,
                                    parentTokenId
                                );
                        } else {
                            // Case 8: Token owner is ERC721 token owned by unknown contract
                            return
                                (ERC998_MAGIC_VALUE << 224) |
                                bytes32(uint256(tokenOwner));
                        }
                    } else {
                        // Case 9: Token owner is ERC721 token owned by user
                        return
                            (ERC998_MAGIC_VALUE << 224) |
                            bytes32(uint256(tokenOwner));
                    }
                }
            }
        }
    }

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
