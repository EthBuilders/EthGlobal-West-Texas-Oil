/// @title ERC998ERC721 Bottom-Up Composable Non-Fungible Token
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
///  Note: the ERC-165 identifier for this interface is 0xa1b23002
interface ERC998ERC721BottomUp {

  /// @dev This emits when a token is transferred to an ERC721 token
  /// @param _toContract The contract the token is transferred to
  /// @param _toTokenId The token the token is transferred to
  /// @param _tokenId The token that is transferred  
  event TransferToParent(
    address indexed _toContract, 
    uint256 indexed _toTokenId, 
    uint256 _tokenId
  );
  
  /// @dev This emits when a token is transferred from an ERC721 token
  /// @param _fromContract The contract the token is transferred from
  /// @param _fromTokenId The token the token is transferred from
  /// @param _tokenId The token that is transferred  
  event TransferFromParent(
    address indexed _fromContract, 
    uint256 indexed _fromTokenId, 
    uint256 _tokenId
  );
  
  /// @notice Get the root owner of tokenId.
  /// @param _tokenId The token to query for a root owner address
  /// @return rootOwner The root owner at the top of tree of tokens and ERC998 magic value.
  function rootOwnerOf(uint256 _tokenId) external view returns (bytes32 rootOwner);

  /// @notice Get the owner address and parent token (if there is one) of a token
  /// @param _tokenId The tokenId to query.
  /// @return tokenOwner The owner address of the token
  /// @return parentTokenId The parent owner of the token and ERC998 magic value
  /// @return isParent True if parentTokenId is a valid parent tokenId and false if there is no parent tokenId
  function tokenOwnerOf(
    uint256 _tokenId
  )
    external 
    view
    returns (
      bytes32 tokenOwner, 
      uint256 parentTokenId, 
      bool isParent
    );
 
  /// @notice Transfer token from owner address to a token
  /// @param _from The owner address
  /// @param _toContract The ERC721 contract of the receiving token
  /// @param _toToken The receiving token
  /// @param _data Additional data with no specified format
  function transferToParent(
    address _from, 
    address _toContract, 
    uint256 _toTokenId, 
    uint256 _tokenId, 
    bytes _data
  )
    external;
   
  /// @notice Transfer token from a token to an address
  /// @param _fromContract The address of the owning contract
  /// @param _fromTokenId The owning token
  /// @param _to The address the token is transferred to.
  /// @param _tokenId The token that is transferred
  /// @param _data Additional data with no specified format
  function transferFromParent(
    address _fromContract, 
    uint256 _fromTokenId, 
    address _to, 
    uint256 _tokenId, 
    bytes _data
  )
    external;
  
  /// @notice Transfer a token from a token to another token
  /// @param _fromContract The address of the owning contract
  /// @param _fromTokenId The owning token
  /// @param _toContract The ERC721 contract of the receiving token
  /// @param _toToken The receiving token
  /// @param _tokenId The token that is transferred
  /// @param _data Additional data with no specified format
  function transferAsChild(
    address _fromContract, 
    uint256 _fromTokenId, 
    address _toContract, 
    uint256 _toTokenId, 
    uint256 _tokenId, 
    bytes _data
  )
    external;
}
