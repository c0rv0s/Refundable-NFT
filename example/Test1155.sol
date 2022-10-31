// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/ReturnableERC1155.sol";

contract Test1155 is ReturnableERC1155 {
    uint256 public price = 0.05 ether;
    mapping(uint256 => uint256) public totalSupply;

    constructor() ERC1155("uri") {}

    function mintWithReturn(
        uint256 tokenID,
        uint256 returnWindow,
        uint256 amount
    ) external payable {
        _mint(msg.sender, totalSupply[tokenID], amount, "");
        createRecord(totalSupply[tokenID], price, returnWindow, amount);
        totalSupply[tokenID] += amount;
    }
}
