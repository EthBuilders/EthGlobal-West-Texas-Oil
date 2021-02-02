/**********************************
/* Author: Nick Mudge, <nick@perfectabstractions.com>, https://medium.com/@mudgen.
/**********************************/

pragma solidity ^0.7.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ERC998/IERC998ERC721BottomUp.sol";

contract ComposableBottomUp is
    ERC721,
    IERC998ERC721BottomUp,
    IERC998ERC721BottomUpEnumerable
{
    using SafeMath for uint256;

    struct TokenOwner {
        address tokenOwner;
        uint256 parentTokenId;
    }

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 constant ERC998_MAGIC_VALUE = bytes32(bytes4(0xcd740db5));

    // tokenId => token owner
    mapping(uint256 => TokenOwner) internal tokenIdToTokenOwner;

    // root token owner address => (tokenId => approved address)
    mapping(address => mapping(uint256 => address))
        internal rootOwnerAndTokenIdToApprovedAddress;

    // token owner address => token count
    mapping(address => uint256) internal tokenOwnerToTokenCount;

    // token owner => (operator address => bool)
    mapping(address => mapping(address => bool)) internal tokenOwnerToOperators;

    // parent address => (parent tokenId => array of child tokenIds)
    mapping(address => mapping(uint256 => uint256[]))
        private parentToChildTokenIds;

    // tokenId => position in childTokens array
    mapping(uint256 => uint256) private tokenIdToChildTokenIdsIndex;

    // wrapper on minting new 721
    /*
    function mint721(address _to) public returns(uint256) {
      _mint(_to, allTokens.length + 1);
      return allTokens.length;
    }
    */
    //from zepellin ERC721Receiver.sol
    //old version
    bytes4 constant ERC721_RECEIVED = 0x150b7a02;

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
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
            isParent = true;
            parentTokenId--;
        } else {
            isParent = false;
        }
        return (tokenOwner, parentTokenId, isParent);
    }

    function tokenOwnerOf(uint256 _tokenId)
        external
        view
        returns (
            bytes32 tokenOwner,
            uint256 parentTokenId,
            bool isParent
        )
    {
        address tokenOwnerAddress = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwnerAddress != address(0));
        parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        if (parentTokenId > 0) {
            isParent = true;
            parentTokenId--;
        } else {
            isParent = false;
        }
        return (
            (ERC998_MAGIC_VALUE << 224) | bytes32(tokenOwnerAddress),
            parentTokenId,
            isParent
        );
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
    function rootOwnerOf(uint256 _tokenId)
        public
        view
        returns (bytes32 rootOwner)
    {
        address rootOwnerAddress = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(rootOwnerAddress != address(0));
        uint256 parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        bool isParent = parentTokenId > 0;
        parentTokenId--;
        bytes memory _calldata;
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
            _calldata = abi.encodeWithSelector(
                0xed81cdda,
                address(this),
                _tokenId
            );
            assembly {
                callSuccess := staticcall(
                    gas(),
                    rootOwnerAddress,
                    add(_calldata, 0x20),
                    mload(_calldata),
                    _calldata,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(_calldata)
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
            _calldata = abi.encodeWithSelector(0x43a61a8e, parentTokenId);
            assembly {
                callSuccess := staticcall(
                    gas(),
                    rootOwnerAddress,
                    add(_calldata, 0x20),
                    mload(_calldata),
                    _calldata,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(_calldata)
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
                _calldata = abi.encodeWithSelector(0x6352211e, parentTokenId);
                assembly {
                    callSuccess := staticcall(
                        gas(),
                        rootOwnerAddress,
                        add(_calldata, 0x20),
                        mload(_calldata),
                        _calldata,
                        0x20
                    )
                    if callSuccess {
                        rootOwnerAddress := mload(_calldata)
                    }
                }
                require(callSuccess, "Call to ownerOf failed");

                // 0xed81cdda == rootOwnerOfChild(address,uint256)
                _calldata = abi.encodeWithSelector(
                    0xed81cdda,
                    childContract,
                    parentTokenId
                );
                assembly {
                    callSuccess := staticcall(
                        gas(),
                        rootOwnerAddress,
                        add(_calldata, 0x20),
                        mload(_calldata),
                        _calldata,
                        0x20
                    )
                    if callSuccess {
                        rootOwner := mload(_calldata)
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

    /**
     * In a bottom-up composable authentication to transfer etc. is done by getting the rootOwner by finding the parent token
     * and then the parent token of that one until a final owner address is found.  If the msg.sender is the rootOwner or is
     * approved by the rootOwner then msg.sender is authenticated and the action can occur.
     * This enables the owner of the top-most parent of a tree of composables to call any method on child composables.
     */
    // returns the root owner at the top of the tree of composables
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        return tokenOwner;
    }

    function balanceOf(address _tokenOwner) external view returns (uint256) {
        require(_tokenOwner != address(0));
        return tokenOwnerToTokenCount[_tokenOwner];
    }

    function approve(address _approved, uint256 _tokenId) external {
        address tokenOwner = tokenIdToTokenOwner[_tokenId].tokenOwner;
        require(tokenOwner != address(0));
        address rootOwner = address(rootOwnerOf(_tokenId));
        require(
            rootOwner == msg.sender ||
                tokenOwnerToOperators[rootOwner][msg.sender]
        );

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] = _approved;
        emit Approval(rootOwner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        address rootOwner = address(rootOwnerOf(_tokenId));
        return rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0));
        tokenOwnerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        require(_owner != address(0));
        require(_operator != address(0));
        return tokenOwnerToOperators[_owner][_operator];
    }

    function removeChild(
        address _fromContract,
        uint256 _fromTokenId,
        uint256 _tokenId
    ) internal {
        uint256 childTokenIndex = tokenIdToChildTokenIdsIndex[_tokenId];
        uint256 lastChildTokenIndex =
            parentToChildTokenIds[_fromContract][_fromTokenId].length - 1;
        uint256 lastChildTokenId =
            parentToChildTokenIds[_fromContract][_fromTokenId][
                lastChildTokenIndex
            ];

        if (_tokenId != lastChildTokenId) {
            parentToChildTokenIds[_fromContract][_fromTokenId][
                childTokenIndex
            ] = lastChildTokenId;
            tokenIdToChildTokenIdsIndex[lastChildTokenId] = childTokenIndex;
        }
        parentToChildTokenIds[_fromContract][_fromTokenId].length--;
    }

    function authenticateAndClearApproval(uint256 _tokenId) private {
        address rootOwner = address(rootOwnerOf(_tokenId));
        address approvedAddress =
            rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
        require(
            rootOwner == msg.sender ||
                tokenOwnerToOperators[rootOwner][msg.sender] ||
                approvedAddress == msg.sender
        );

        // clear approval
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
            emit Approval(rootOwner, address(0), _tokenId);
        }
    }

    function transferFromParent(
        address _fromContract,
        uint256 _fromTokenId,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external {
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _fromContract);
        require(_to != address(0));
        uint256 parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        require(parentTokenId != 0, "Token does not have a parent token.");
        require(parentTokenId - 1 == _fromTokenId);
        authenticateAndClearApproval(_tokenId);

        // remove and transfer token
        if (_fromContract != _to) {
            assert(tokenOwnerToTokenCount[_fromContract] > 0);
            tokenOwnerToTokenCount[_fromContract]--;
            tokenOwnerToTokenCount[_to]++;
        }

        tokenIdToTokenOwner[_tokenId].tokenOwner = _to;
        tokenIdToTokenOwner[_tokenId].parentTokenId = 0;

        removeChild(_fromContract, _fromTokenId, _tokenId);
        delete tokenIdToChildTokenIdsIndex[_tokenId];

        if (isContract(_to)) {
            bytes4 retval =
                IERC721Receiver(_to).onERC721Received(
                    msg.sender,
                    _fromContract,
                    _tokenId,
                    _data
                );
            require(retval == ERC721_RECEIVED);
        }

        emit Transfer(_fromContract, _to, _tokenId);
        emit TransferFromParent(_fromContract, _fromTokenId, _tokenId);
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
    ) external {
        require(_from != address(0)); // token owner address can't be zero address (token must exist)
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _from); // the token owner must equal the given token owner address
        require(_toContract != address(0)); // the contract of the receiving token can't be zero address
        require( // the token can't be transferred if it's already owned by another token
            tokenIdToTokenOwner[_tokenId].parentTokenId == 0,
            "Cannot transfer from address when owned by a token."
        );
        address approvedAddress =
            rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId]; // get the address approved to move _tokenId
        if (msg.sender != _from) {
            // if the msg.sender is not the owning address
            bytes32 rootOwner;
            bool callSuccess;
            // 0xed81cdda == rootOwnerOfChild(address,uint256)
            // call the root Owner of Child function
            // which is a Top Down Contract function
            // which returns The root owner at the top of tree of tokens and ERC998 magic value
            // this is necessary because the _tokenId could be owned by a parent token
            // so we are checking to see who is the root owner
            bytes memory _calldata =
                abi.encodeWithSelector(0xed81cdda, address(this), _tokenId); // call data to send to Top Down Contract
            // use assembly code to issue a static call to the _from address
            // which may or may not be a contract
            assembly {
                callSuccess := staticcall(
                    // issue the call
                    gas(),
                    _from,
                    add(_calldata, 0x20),
                    mload(_calldata),
                    _calldata,
                    0x20
                )
                if callSuccess {
                    // if the call was successful load the rootOwner
                    rootOwner := mload(_calldata)
                }
            }
            if (callSuccess == true) {
                // if the call was successful
                // require the rootOwner at the top of the tree
                // is not a top Down composable contract
                // i assume because then that address would need to be called
                // to transfer this child token via transferChild function
                require(
                    rootOwner >> 224 != ERC998_MAGIC_VALUE,
                    "Token is child of other top down composable"
                );
            }
            require( // regardless of whether the call is successful or not
                //
                tokenOwnerToOperators[_from][msg.sender] || // is the msg.sender an operator account for _from (they are allowed to call functions on behalf of owner)
                    approvedAddress == msg.sender // is the msg.sender an approvedAddress (they are allowed to move that token)
            );
        }

        // clear the approval
        if (approvedAddress != address(0)) {
            // only run if there is an approved address
            // this exists because there may be no approved address for the token
            // but the _from address may have an approved operator account
            // so before transferring ownership of the token we have to remove the
            // approval
            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
            emit Approval(_from, address(0), _tokenId);
        }

        // remove and transfer token
        if (_from != _toContract) {
            // if the ownerAddress doesn't equal the recipient
            // sometimes you want to transfer a token to a new parenttoken at the same contract
            // if that is the case don't run this
            assert(tokenOwnerToTokenCount[_from] > 0); // verify the _from address has a token balance
            tokenOwnerToTokenCount[_from]--; // reduce the balance of the _from address
            tokenOwnerToTokenCount[_toContract]++; // increase the balance of _toContract
        }
        TokenOwner memory parentToken =
            TokenOwner(_toContract, _toTokenId.add(1)); // create a new TokenOwner structure
        tokenIdToTokenOwner[_tokenId] = parentToken; // rewrite the value in the tokenIdToTokenOwner mapping
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length; // get the length of _toContract parentToken's owned tokens (only tokens from this contract)
        parentToChildTokenIds[_toContract][_toTokenId].push(_tokenId); // append the _tokenId to the parentToken's set of owned tokens
        tokenIdToChildTokenIdsIndex[_tokenId] = index; // set the index of _token in ParenToken's set of tokens

        require(
            ERC721(_toContract).ownerOf(_toTokenId) != address(0), // require the toTokenId has an owner (exists)
            "_toTokenId does not exist"
        );

        // emit events
        emit Transfer(_from, _toContract, _tokenId);
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }

    function transferAsChild(
        address _fromContract,
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        uint256 _tokenId,
        bytes calldata _data
    ) external {
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _fromContract);
        require(_toContract != address(0));
        uint256 parentTokenId = tokenIdToTokenOwner[_tokenId].parentTokenId;
        require(parentTokenId > 0, "No parent token to transfer from.");
        require(parentTokenId - 1 == _fromTokenId);
        address rootOwner = address(rootOwnerOf(_tokenId));
        address approvedAddress =
            rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
        require(
            rootOwner == msg.sender ||
                tokenOwnerToOperators[rootOwner][msg.sender] ||
                approvedAddress == msg.sender
        );
        // clear approval
        if (approvedAddress != address(0)) {
            delete rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
            emit Approval(rootOwner, address(0), _tokenId);
        }

        // remove and transfer token
        if (_fromContract != _toContract) {
            assert(tokenOwnerToTokenCount[_fromContract] > 0);
            tokenOwnerToTokenCount[_fromContract]--;
            tokenOwnerToTokenCount[_toContract]++;
        }

        TokenOwner memory parentToken = TokenOwner(_toContract, _toTokenId);
        tokenIdToTokenOwner[_tokenId] = parentToken;

        removeChild(_fromContract, _fromTokenId, _tokenId);

        //add to parentToChildTokenIds
        uint256 index = parentToChildTokenIds[_toContract][_toTokenId].length;
        parentToChildTokenIds[_toContract][_toTokenId].push(_tokenId);
        tokenIdToChildTokenIdsIndex[_tokenId] = index;

        require(
            ERC721(_toContract).ownerOf(_toTokenId) != address(0),
            "_toTokenId does not exist"
        );

        emit Transfer(_fromContract, _toContract, _tokenId);
        emit TransferFromParent(_fromContract, _fromTokenId, _tokenId);
        emit TransferToParent(_toContract, _toTokenId, _tokenId);
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) private {
        require(_from != address(0));
        require(tokenIdToTokenOwner[_tokenId].tokenOwner == _from);
        require(
            tokenIdToTokenOwner[_tokenId].parentTokenId == 0,
            "Cannot transfer from address when owned by a token."
        );
        require(_to != address(0));
        address approvedAddress =
            rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
        if (msg.sender != _from) {
            bytes32 rootOwner;
            bool callSuccess;
            // 0xed81cdda == rootOwnerOfChild(address,uint256)
            bytes memory _calldata =
                abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);
            assembly {
                callSuccess := staticcall(
                    gas(),
                    _from,
                    add(_calldata, 0x20),
                    mload(_calldata),
                    _calldata,
                    0x20
                )
                if callSuccess {
                    rootOwner := mload(_calldata)
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
        if (_from != _to) {
            assert(tokenOwnerToTokenCount[_from] > 0);
            tokenOwnerToTokenCount[_from]--;
            tokenIdToTokenOwner[_tokenId].tokenOwner = _to;
            tokenOwnerToTokenCount[_to]++;
        }
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferFrom(_from, _to, _tokenId);
        if (isContract(_to)) {
            bytes4 retval =
                IERC721Receiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    ""
                );
            require(retval == ERC721_RECEIVED);
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external {
        _transferFrom(_from, _to, _tokenId);
        if (isContract(_to)) {
            bytes4 retval =
                IERC721Receiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                );
            require(retval == ERC721_RECEIVED);
        }
    }

    function totalChildTokens(address _parentContract, uint256 _parentTokenId)
        public
        view
        returns (uint256)
    {
        return parentToChildTokenIds[_parentContract][_parentTokenId].length;
    }

    function childTokenByIndex(
        address _parentContract,
        uint256 _parentTokenId,
        uint256 _index
    ) public view returns (uint256) {
        require(
            parentToChildTokenIds[_parentContract][_parentTokenId].length >
                _index
        );
        return parentToChildTokenIds[_parentContract][_parentTokenId][_index];
    }
}
