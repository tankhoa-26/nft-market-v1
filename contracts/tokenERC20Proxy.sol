// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";  

contract ERC20Proxy{

    function erc20TransferFrom(IERC20 token, address from, address to, uint256 value)  external {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }
}