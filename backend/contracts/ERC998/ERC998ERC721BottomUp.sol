// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
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
        public
        view
        returns (bytes32 rootOwner)
    {
        (address rootOwnerAddress, uint256 parentTokenId, bool isParent) =
            _tokenOwnerOf(_tokenId);

        bytes memory calldata_;
        bool callSuccess;

        if ((rootOwnerAddress == address(this))) {
            do {
                if (isParent == false) {
                    // Case 1: Token owner is this contract and no token.
                    // This case should not happen.
                    return
                        (ERC998_MAGIC_VALUE << 224) | bytes32(rootOwnerAddress);
                } else {
                    // Case 2: Token owner is this contract and token
                    (rootOwnerAddress, parentTokenId, isParent) = _tokenOwnerOf(
                        parentTokenId
                    );
                }
            } while (rootOwnerAddress == address(this));
            _tokenId = parentTokenId;
        }

        if (isParent == false) {
            // success if this token is owned by a top-down token
            // 0xed81cdda == rootOwnerOfChild(address, uint256)
            calldata_ = abi.encodeWithSelector(
                0xed81cdda,
                address(this),
                _tokenId
            );
            assembly {
                callSuccess := staticcall(
                    gas,
                    rootOwnerAddress,
                    add(calldata_, 0x20),
                    mload(calldata_),
                    calldata_,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(calldata_)
                }
            }
            if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {
                // Case 3: Token owner is top-down composable
                return rootOwner;
            } else {
                // Case 4: Token owner is an unknown contract
                // Or
                // Case 5: Token owner is a user
                return (ERC998_MAGIC_VALUE << 224) | bytes32(rootOwnerAddress);
            }
        } else {
            // 0x43a61a8e == rootOwnerOf(uint256)
            calldata_ = abi.encodeWithSelector(0x43a61a8e, parentTokenId);
            assembly {
                callSuccess := staticcall(
                    gas,
                    rootOwnerAddress,
                    add(calldata_, 0x20),
                    mload(calldata_),
                    calldata_,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(calldata_)
                }
            }
            if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {
                // Case 6: Token owner is a bottom-up composable
                // Or
                // Case 2: Token owner is top-down composable
                return rootOwner;
            } else {
                // token owner is ERC721
                address childContract = rootOwnerAddress;
                //0x6352211e == "ownerOf(uint256)"
                calldata_ = abi.encodeWithSelector(0x6352211e, parentTokenId);
                assembly {
                    callSuccess := staticcall(
                        gas,
                        rootOwnerAddress,
                        add(calldata_, 0x20),
                        mload(calldata_),
                        calldata_,
                        0x20
                    )
                    if callSuccess {
                        rootOwnerAddress := mload(calldata_)
                    }
                }
                require(callSuccess, "Call to ownerOf failed");

                // 0xed81cdda == rootOwnerOfChild(address,uint256)
                calldata_ = abi.encodeWithSelector(
                    0xed81cdda,
                    childContract,
                    parentTokenId
                );
                assembly {
                    callSuccess := staticcall(
                        gas,
                        rootOwnerAddress,
                        add(calldata_, 0x20),
                        mload(calldata_),
                        calldata_,
                        0x20
                    )
                    if callSuccess {
                        rootOwner := mload(calldata_)
                    }
                }
                if (
                    callSuccess == true &&
                    rootOwner >> 224 == ERC998_MAGIC_VALUE
                ) {
                    // Case 7: Token owner is ERC721 token owned by top-down token
                    return rootOwner;
                } else {
                    // Case 8: Token owner is ERC721 token owned by unknown contract
                    // Or
                    // Case 9: Token owner is ERC721 token owned by user
                    return
                        (ERC998_MAGIC_VALUE << 224) | bytes32(rootOwnerAddress);
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
