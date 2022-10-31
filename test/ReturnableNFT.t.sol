// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./TestNFT.sol";

contract CounterTest is Test {
    TestNFT public nft;

    function setUp() public {
        nft = new TestNFT();
    }
}
