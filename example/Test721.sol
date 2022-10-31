// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/ReturnableERC721.sol";

contract Test721 is ReturnableERC721 {
    uint256 public price = 0.05 ether;
    uint256 public totalSupply;

    constructor() ERC721("Test", "TEST") {}

    function mintWithReturn(uint256 returnWindow) external payable {
        _mint(msg.sender, totalSupply);
        createRecord(totalSupply, price, returnWindow);
        totalSupply++;
    }

    function tokenURI(uint256 id) public pure override returns (string memory) {
        return string(abi.encodePacked("uri/", id));
    }
}
