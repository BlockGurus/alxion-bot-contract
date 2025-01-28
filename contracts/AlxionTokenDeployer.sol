// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./AlxionToken.sol";

contract AlxionDeployer {
    AlxionToken public immutable alxionToken;
    mapping(address => PointData) public userPoints;
    mapping(bytes32 => bool) public usedHashes;
    mapping(address => uint256) public userNonce;
    uint256 public constant POINT_BASIS = 35;

    address public botAddress; // Address of the bot for verification
    error AlxionDeployer__Unauthorized();
    error AlxionDeployer__InvalidSignature();
    error AlxionDeployer__InsufficientPoints();
    error AlxionDeployer__HashAlreadyUsed();
    error AlxionDeployer__AddressCannotBeZero();

    event PointsAdded(address indexed user, uint256 points);
    event PointsRedeemed(address indexed user, uint256 points);
    event BotAddressUpdated(address indexed oldBotAddress, address indexed newBotAddress);

    struct PointData {
        uint256 points;
        uint256 updatedTimeStamp;
        uint256 createdTimeStamp;
        address user;
    }

    constructor(address _botAddress) {
        if (_botAddress == address(0)) {
            revert AlxionDeployer__Unauthorized();
        }
        alxionToken = new AlxionToken();
        botAddress = _botAddress;
    }

    /**
     * @dev Add points to the user based on the weight of the waste.
     * Users must call this function and provide a signed message from the bot.
     * @param pointToAdd The number of points to add
     * @param signature The bot's signature of the user's address and points
     */
    function addPoints(uint256 pointToAdd, bytes memory signature) public {
        // Verify the signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(msg.sender, pointToAdd, userNonce[msg.sender])
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        if (usedHashes[messageHash]) {
            revert AlxionDeployer__HashAlreadyUsed();
        }

        if (recoverSigner(ethSignedMessageHash, signature) != botAddress) {
            revert AlxionDeployer__InvalidSignature();
        }
        userNonce[msg.sender]++;

        usedHashes[messageHash] = true;

        // Calculate points based on the weight
        uint256 points = pointToAdd * POINT_BASIS;

        PointData storage userPointData = userPoints[msg.sender];

        // Update the user's point data
        if (userPointData.points > 0) {
            userPointData.points += points;
            userPointData.updatedTimeStamp = block.timestamp;
        } else {
            userPoints[msg.sender] = PointData(
                points,
                block.timestamp,
                block.timestamp,
                msg.sender
            );
        }

        emit PointsAdded(msg.sender, points);
    }

    /**
     * @dev Redeem points to get ERC20 token
     * @param point Points to redeem
     */
    function redeemCode(uint256 point) public returns (bool) {
        if (userPoints[msg.sender].points < point) {
            revert AlxionDeployer__InsufficientPoints();
        }

        // Deduct points and mint tokens
        userPoints[msg.sender].points -= point;
        alxionToken.mint(msg.sender, point * 10 ** alxionToken.decimals());
        emit PointsRedeemed(msg.sender, point);
        return true;
    }

    /**
     * @dev Update the bot address (only callable by the bot)
     * @param _newBotAddress The new bot address
     */
    function updateBotAddress(address _newBotAddress) public {
        if (msg.sender != botAddress) {
            revert AlxionDeployer__Unauthorized();
        }
        if (_newBotAddress == address(0)) {
            revert AlxionDeployer__AddressCannotBeZero();
        }
        address oldBotAddress = botAddress;
        botAddress = _newBotAddress;
        emit BotAddressUpdated(oldBotAddress, _newBotAddress);
    }

    /**
     * @dev Hash the message to create an Ethereum-signed message hash
     * @param messageHash The original message hash
     * @return The Ethereum-signed message hash
     */
    function getEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    /**
     * @dev Recover the signer of the message
     * @param ethSignedMessageHash The Ethereum-signed message hash
     * @param signature The signature to verify
     * @return The recovered address
     */
    function recoverSigner(
        bytes32 ethSignedMessageHash,
        bytes memory signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    /**
     * @dev Split the signature into r, s, and v
     * @param signature The full signature
     * @return r The r component of the signature
     * @return s The s component of the signature
     * @return v The v component of the signature
     */
    function splitSignature(
        bytes memory signature
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(signature.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
