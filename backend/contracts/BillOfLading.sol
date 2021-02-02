// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";
import "./interfaces/IERC1948.sol";
import "dBol.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// @title Bill of Lading NFT Contract
// @author Edward Amor
// @notice Users should not directly interact with this contract
// @dev All ERC721 functions are inherited from Openzeppelin ERC721 contract
contract BillOfLading is ERC721PresetMinterPauserAutoId, IERC1948 {
    enum CardinalDirections {NORTH, EAST, SOUTH, WEST} // clock-wise ordering

    /**
        @param degree ranges from 0 to 90 for latitude and 0 to 180 for longitude
        @param minute ranges from 0 to 60
        @param second ranges from 0.0 to 60.0, since this can be a decimal number
        and solidity only works with integers, we have to do some padding.
        A standardized way to do this is simply provide a number within the range
        of [0, 2 ^ 16 - 1], and to pad it with 3 zeros.
        
        Ex.
        25.23 => 25230
        59.98 => 59980
        00.39 => 00390
     */
    struct GeoPosition {
        uint8 degree;
        uint8 minute;
        uint16 second;
        CardinalDirections cardinalDirection;
    }

    /**
        @param quantity is the amount in MT (metric tons) since this is a decimal
        we pad and make sure to leave the last 2 digits as the decimal numbers.

        Ex. 
        28.1 MT => 2810
        1289.32 MT => 128932
     */
    struct MintArgs {
        address driver;
        string serialNumber;
        GeoPosition[2] origin;
        GeoPosition[2] destination;
        uint256 quantity;
    }

    struct Bill {
        address driver;
        string serialNumber;
        GeoPosition originLatitude;
        GeoPosition originLongitude;
        GeoPosition destinationLatitude;
        GeoPosition destinationLongitude;
        uint256 quantity;
        uint256 timestamp;
    }

    Bill[] public bills;
    mapping(uint256 => bytes32) data;

    DBol dBOLContract;

    /*
     *     bytes4(keccak256('readData()')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *
     *     => 0x37ebbc03 ^ 0xa983d43f == 0x9e68683c
     */
    bytes4 private constant _INTERFACE_ID_ERC1948 = 0x9e68683c;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address dbolContract
    ) public ERC721PresetMinterPauserAutoId(name, symbol, baseURI) {
        _registerInterface(_INTERFACE_ID_ERC1948);
        dBOLContract = DBol(dbolContract);
    }

    /// @notice Create a Bill of Lading for a shipment
    /// @dev User facing function which creates a bill
    function createBillOfLading(
        MintArgs memory _args,
        address _funding,
        uint256 _value
    ) public {
        require(
            IERC20(_funding).allowance(msg.sender, address(this)) >= _value
        );
        bills.push(
            Bill({
                driver: _args.driver,
                serialNumber: _args.serialNumber,
                originLatitude: _args.origin[0],
                originLongitude: _args.origin[1],
                destinationLatitude: _args.destination[0],
                destinationLongitude: _args.destination[1],
                quantity: _args.quantity,
                timestamp: block.timestamp
            })
        );
        mint(msg.sender);
        IERC20(_funding).transferFrom(msg.sender, address(this), _value);
        IERC20(_funding).approve(address(dBOLContract), _value);
        uint256 childToken =
            dBOLContract.createDBol(_funding, totalSupply() - 1);
        dBOLContract.getERC20(address(this), childToken, _funding, _value);
    }

    /**
     * @dev See `IERC1948.readData`.
     *
     * Requirements:
     *
     * - `tokenId` needs to exist.
     */
    function readData(uint256 tokenId)
        external
        view
        override
        returns (bytes32)
    {
        require(_exists(tokenId));
        return data[tokenId];
    }

    /**
     * @dev See `IERC1948.writeData`.
     *
     * Requirements:
     *
     * - `msg.sender` needs to be owner of `tokenId`.
     */
    function writeData(uint256 tokenId, bytes32 newData) external override {
        require(msg.sender == ownerOf(tokenId));
        emit DataUpdated(tokenId, data[tokenId], newData);
        data[tokenId] = newData;
    }
}
