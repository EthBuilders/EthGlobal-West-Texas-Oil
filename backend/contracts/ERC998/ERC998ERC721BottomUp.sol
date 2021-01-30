// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ERC998/IERC998ERC721BottomUp.sol";
import "../interfaces/ERC998/IERC998ERC721TopDown.sol";

contract ERC998ERC721BottomUp is IERC998ERC721BottomUp {
    using SafeMath for uint256;

    struct TokenOwner {
        address tokenOwner;
        uint256 parentTokenId;
    }

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 constant ERC998_MAGIC_VALUE = bytes32(bytes4(0xcd740db5)) << 224;

    bytes4 private constant _INTERFACE_ID_ERC998ERC721TOPDOWN = 0x1efdf36a;
    bytes4 private constant _INTERFACE_ID_ERC998ERC721BOTTOMUP = 0xa1b23002;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    // tokenId => token owner
    mapping(uint256 => TokenOwner) tokenIdToTokenOwner;

    function addressToBytes32(address _addr)
        internal
        pure
        returns (bytes32 addr)
    {
        addr = bytes32(uint256(_addr)); // this is left padded
        return addr;
    }

    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (ERC165Checker.supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = ERC165Checker.supportsInterface(
                    account,
                    interfaceIds[i]
                );
            }
        }

        return interfaceIdsSupported;
    }

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
        bool _isERC998ERC721TopDown;
        bool _isERC998ERC721BottomUp;
        bool _isERC721;
        IERC998ERC721TopDown _topDownContract;
        IERC998ERC721BottomUp _bottomUpContract;
        IERC721 _ERC721Contract;
        // Get token ownership information
        // isParent: True if parentTokenId is a valid parent tokenId and false if there is no parent tokenId
        // if isParent is false, no parent token, just owned by the tokenOwner
        (address tokenOwner, uint256 parentTokenId, bool isParent) =
            _tokenOwnerOf(_tokenId);

        // check whether owned by a contract
        if (Address.isContract(tokenOwner)) {
            // true owned by a contract
            // which contract is it owned by
            // this contract or an external contract
            if (tokenOwner == address(this)) {
                // _tokenId is owned by this contract
                // is it owned by another token
                if (isParent) {
                    // yes owned by another token in this contract
                    // we have to check if that token is owned by anyone
                    do {
                        // traverse up by overwritting the tokenOwner, parentTokenId, isParent
                        // this way we can see who owns the _tokenID's parent token ...
                        (tokenOwner, parentTokenId, isParent) = _tokenOwnerOf(
                            parentTokenId
                        );
                        // if the tokenOwner is still this contract repeat until
                        // we've found that the tokenOwner is an external contract or User
                    } while (tokenOwner == address(this));
                    // we need to change the _tokenId we are looking at to be the parentTokenId
                    // because we should now inspect if the parent has a parent or if it's the root
                    _tokenId = parentTokenId;
                } else {
                    // no it isn't owned by another token in this contract
                    // just the contract itself
                    // essentially a dead token?
                    return (ERC998_MAGIC_VALUE | addressToBytes32(tokenOwner));
                }
            }

            // we should do check this next since we know the tokenOwner isn't this contract
            // and just in case we did loop through our own contract
            // check whether the parentTokenId is valid, or the token is owned by a Contract/EOA
            if (isParent == false) {
                // there is no parent token only a parent contract/ EOA
                // we have to check both branches
                // check if it is a contract
                if (Address.isContract(tokenOwner)) {
                    // yes it is a contract but there is no parent token
                    // owned by just the contract
                    // since no parentToken, is this contract a TopDown composable
                    // which receives, transfers, and manages ERC721 tokens/bottom up composables
                    _isERC998ERC721TopDown = ERC165Checker.supportsInterface(
                        tokenOwner,
                        _INTERFACE_ID_ERC998ERC721TOPDOWN
                    );
                    // if it is a TopDown contract we can query it for information
                    if (_isERC998ERC721TopDown) {
                        // true it is a top down contract
                        // we can further query who the root owner is
                        // by calling the rootOwnerOfChild function on the contract
                        _topDownContract = IERC998ERC721TopDown(tokenOwner);
                        return
                            _topDownContract.rootOwnerOfChild(
                                address(this),
                                _tokenId
                            );
                    } else {
                        // this is not a Top Down composable contract
                        return (ERC998_MAGIC_VALUE |
                            addressToBytes32(tokenOwner));
                    }
                } else {
                    // It is owned by a EOA account
                    return (ERC998_MAGIC_VALUE | addressToBytes32(tokenOwner));
                }
            } else {
                // _tokenId does have a parent token and it's in tokenOwner
                // meaning either it is a topdown/bottomup/ or regular ERC721
                // we have to check who the parent token is owned by
                // get the supported interfaces at once in a batch
                bool[] memory _supportedInterfaces =
                    getSupportedInterfaces(
                        tokenOwner,
                        [
                            _INTERFACE_ID_ERC998ERC721TOPDOWN,
                            _INTERFACE_ID_ERC998ERC721BOTTOMUP,
                            _INTERFACE_ID_ERC721
                        ]
                    );
                // assign whether they support the interface
                (_isERC998ERC721TopDown, _isERC998ERC721BottomUp, _isERC721) = (
                    _supportedInterfaces[0],
                    _supportedInterfaces[1],
                    _supportedInterfaces[2]
                );
                if (_isERC998ERC721TopDown) {
                    // yes it is a Top Down contract
                    // this is the easiest we just call the rootOwnerOf
                    // to see who the parent is of our token's parent
                    _topDownContract = IERC998ERC721TopDown(tokenOwner);
                    return _topDownContract.rootOwnerOf(parentTokenId);
                } else if (_isERC998ERC721BottomUp) {
                    // the contract is a bottom up contract
                    // similar to above we call the root owner of
                    // to see who the parent is of our token's parent
                    _bottomUpContract = IERC998ERC721BottomUp(tokenOwner);
                    return _bottomUpContract.rootOwnerOf(parentTokenId);
                } else if (_isERC721) {
                    // this is interesting, our token's parent token is
                    // in an ERC721 contract, and has no awareness of having
                    // our token attached to it
                    // we have to see who the owner of the parent token is
                    // the parent token can be owned by an EOA or a topdown composable contract
                    // first we have to query who owns the parent token in the ERC721 contract
                    _ERC721Contract = IERC721(tokenOwner);
                    // set the new tokenOwner to be the address that owns the parent token
                    tokenOwner = _ERC721Contract.ownerOf(parentTokenId);
                    // now we check who owns the parent token
                    if (Address.isContract(tokenOwner)) {
                        // its owned by a contract
                        // is it a top down contract?
                        _isERC998ERC721TopDown = ERC165Checker
                            .supportsInterface(
                            tokenOwner,
                            _INTERFACE_ID_ERC998ERC721TOPDOWN
                        );
                        if (_isERC998ERC721TopDown) {
                            // yes our parent token is owned by a
                            // top down contract we can query who the
                            // root owner is from there
                            _topDownContract = IERC998ERC721TopDown(tokenOwner);
                            // can't use tokenOwner because that is now the ERC998Top down
                            // contract which we are calling
                            return
                                _topDownContract.rootOwnerOfChild(
                                    address(_ERC721Contract),
                                    parentTokenId
                                );
                        } else {
                            // parent token is owned by an unknown contract
                            return (ERC998_MAGIC_VALUE |
                                addressToBytes32(tokenOwner));
                        }
                    } else {
                        // its owned by an EOA
                        return (ERC998_MAGIC_VALUE |
                            addressToBytes32(tokenOwner));
                    }
                }
            }
        } else {
            // false owned by a contract
            // check openzeppelin notice
            // not 100% this is an EOA
            // Case 5: Token owner is a user
            return (ERC998_MAGIC_VALUE | addressToBytes32(tokenOwner));
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
            (ERC998_MAGIC_VALUE | addressToBytes32(_tokenOwner)),
            parentTokenId,
            isParent
        );
    }

    /// @notice Transfer token from owner address to a token
    /// @param _from The owner address
    /// @param _toContract The ERC721 contract of the receiving token
    /// @param _toTokenId The receiving token
    /// @param _tokenId The token to transfer
    /// @param _data Additional data with no specified format
    function transferToParent(
        address _from,
        address _toContract,
        uint256 _toTokenId,
        uint256 _tokenId,
        bytes calldata _data
    ) external override {
        require(_from != address(0));
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _from);
        require(_toContract != address(0));
        require(
            tokenIdToTokenOwner[_tokenId].parentTokenId == 0,
            "Cannot transfer from address when owned by a token."
        );
        address approvedAddress =
            rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
        if (msg.sender != _from) {
            bytes32 rootOwner;
            bool callSuccess;
            // 0xed81cdda == rootOwnerOfChild(address,uint256)
            bytes memory calldata =
                abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);
            assembly {
                callSuccess := staticcall(
                    gas,
                    _from,
                    add(calldata, 0x20),
                    mload(calldata),
                    calldata,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(calldata)
                }
            }
            if (callSuccess == true) {
                require(
                    rootOwner >> 224 != ERC998_MAGIC_VALUE,
                    "Token is child of other top down composable"
                );
            }
            require(
                tokenOwnerToOperators[_from][msg.sender] ||
                    approvedAddress == msg.sender
            );
        }

        // clear approval
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
            emit Approval(_from, address(0), _tokenId);
        }

        // remove and transfer token
        if (_from != _toContract) {
            assert(tokenOwnerToTokenCount[_from] > 0);
            tokenOwnerToTokenCount[_from]--;
            tokenOwnerToTokenCount[_toContract]++;
        }
        TokenOwner memory parentToken =
            TokenOwner(_toContract, _toTokenId.add(1));
        tokenIdToTokenOwner[_tokenId] = parentToken;
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length;
        parentToChildTokenIds[_toContract][_toTokenId].push(_tokenId);
        tokenIdToChildTokenIdsIndex[_tokenId] = index;

        require(
            ERC721(_toContract).ownerOf(_toTokenId) != address(0),
            "_toTokenId does not exist"
        );

        emit Transfer(_from, _toContract, _tokenId);
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }
}
