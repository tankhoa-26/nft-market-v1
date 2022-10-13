// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ItemsGameCore is ERC1155 {

    uint256 private tokenID;
    string uri = "https://game.example/api/item/temp.json";

    event Mint(address indexed owner, uint256 indexed tokenID, uint256 indexed amount);
    
    constructor() ERC1155(uri) {
        tokenID = 0;
    }

    function getTOkenID() public view {
        return tokenID;
    }

    function mint(uint256 amount, bytes memory data) external {
        _mint(msg.sender, tokenID, amount, data);
        tokenID++;

        emit Mint(msg.sender, tokenID, amount);
    }
}