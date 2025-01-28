// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AlxionToken is ERC20 {
    address public immutable OWNER;
    error AlxionToken__NotOwner();

    constructor() ERC20("AlxionToken", "AXT") {
        OWNER = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        if (msg.sender != OWNER) {
            revert AlxionToken__NotOwner();
        }
        _mint(to, amount);
    }
}
