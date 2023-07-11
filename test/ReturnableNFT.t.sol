// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../example/Test721.sol";
import "../example/Test1155.sol";

contract CounterTest is Test {
    Test721 public nft721;
    Test1155 public nft1155;

    function setUp() public {
        nft721 = new Test721();
        nft1155 = new Test1155();
    }

    function testMintAndReturn721() public {
        address sender = address(123);
        vm.deal(sender, 1 ether);
        vm.startPrank(sender);

        assertEq(sender.balance, 1 ether, "sender balance before mint");

        // get total price (mint price + premium for 3 day window)
        uint256 selectedWindow = 3 days;
        uint256 unitPrice = nft721.price() + nft721.returnPrice(selectedWindow, nft721.price());

        // assert proper amount was charged
        nft721.mintWithReturn{value: unitPrice}(selectedWindow);
        assertEq(nft721.ownerOf(0), sender, "sender owns token");
        assertEq(sender.balance, 1 ether - unitPrice, "sender balance after mint");

        // return token and ensure refund was received
        vm.warp(2 days);
        nft721.returnToken(0);
        assertEq(sender.balance, 1 ether, "sender balance after return");

        vm.expectRevert("NOT_MINTED");
        nft721.ownerOf(0);

        vm.stopPrank();
    }

    function testFailMintAndReturn721TooLate() public {
        address sender = address(123);
        vm.deal(sender, 1 ether);
        vm.startPrank(sender);

        assertEq(sender.balance, 1 ether, "initial sender balance");

        // get total price (mint price + premium for 3 day window)
        uint256 selectedWindow = 3 days;
        uint256 unitPrice = nft721.price() + nft721.returnPrice(selectedWindow, nft721.price());

        // assert proper amount was charged
        nft721.mintWithReturn{value: unitPrice}(selectedWindow);
        assertEq(nft721.ownerOf(0), sender, "sender owns token");
        assertEq(sender.balance, 1 ether - unitPrice, "sender balance after mint");

        // try to return token after window (fails)
        vm.warp(3 days + 4 seconds);
        vm.expectRevert("ReturnableNFT: past deadline");
        nft721.returnToken(0);
        assertEq(nft721.ownerOf(0), sender, "sender still owns token");
        assertEq(sender.balance, 1 ether, "sender balance after failed return");

        vm.stopPrank();
    }

    function testMintAndReturn1155() public {
        address sender = address(123);
        vm.deal(sender, 1 ether);
        vm.startPrank(sender);

        assertEq(sender.balance, 1 ether, "sender balance before mint");

        // get total price (mint price + premium for 3 day window)
        uint256 selectedWindow = 3 days;
        uint256 unitPrice = nft1155.price() + nft1155.returnPrice(selectedWindow, nft1155.price());

        // assert proper amount was charged
        nft1155.mintWithReturn{value: 2 * unitPrice}(0, selectedWindow, 2);
        assertEq(nft1155.balanceOf(sender, 0), 2, "sender owns tokens");
        assertEq(sender.balance, 1 ether - 2 * (unitPrice), "sender balance after mint");

        // return token and ensure refund was received
        vm.warp(2 days);
        nft1155.returnToken(0, 2);
        assertEq(sender.balance, 1 ether, "sender balance after return");
        assertEq(nft1155.balanceOf(sender, 0), 0, "sender burnt tokens");

        vm.stopPrank();
    }

    function testFailMintAndReturn1155TooLate() public {
        address sender = address(123);
        vm.deal(sender, 1 ether);
        vm.startPrank(sender);

        assertEq(sender.balance, 1 ether, "initial sender balance");

        // get total price (mint price + premium for 3 day window)
        uint256 selectedWindow = 3 days;
        uint256 unitPrice = nft1155.price() + nft1155.returnPrice(selectedWindow, nft1155.price());

        // assert proper amount was charged
        nft1155.mintWithReturn{value: 2 * unitPrice}(0, selectedWindow, 2);
        assertEq(nft1155.balanceOf(sender, 0), 2, "sender owns tokens");
        assertEq(sender.balance, 1 ether - 2 * (unitPrice), "sender balance after mint");

        // try to return token after window (fails)
        vm.warp(4 days);
        vm.expectRevert("ReturnableNFT: past deadline");
        nft1155.returnToken(0, 2);
        assertEq(nft1155.balanceOf(sender, 0), 2, "sender failed to burn tokens");
        assertEq(sender.balance, 1 ether, "sender balance after failed return");

        vm.stopPrank();
    }
}
