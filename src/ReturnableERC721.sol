// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz/token/ERC721/ERC721.sol";

abstract contract ReturnableERC721 is ERC721 {
    struct Receipt {
        uint256 deadline;
        uint256 price;
    }
    mapping(uint256 => Receipt) private tokenReceipts;

    event TokenReturned(uint256 tokenID, uint256 refund);
    event ReceiptCreated(uint256 tokenID, uint256 price, uint256 returnWindow);

    /**
     * @notice call this to return your nft
     */
    function returnToken(uint256 tokenID) external {
        require(
            tokenReceipts[tokenID].deadline != 0,
            "ReturnableNFT: receipt not found"
        );
        require(
            block.timestamp <= tokenReceipts[tokenID].deadline,
            "ReturnableNFT: past deadline"
        );

        // burn token
        _burn(tokenID);
        // issue refund
        uint256 value = tokenReceipts[tokenID].price;
        (bool sent, ) = msg.sender.call{value: value}("");
        require(sent, "Failed to send Ether");

        delete tokenReceipts[tokenID];

        emit TokenReturned(tokenID, value);
    }

    /**
     * @notice override this function to set a custom pricing model,
     *         default is 30 days max, increasing linearly up to 100% premium
     * @param returnWindow number of seconds token can be returned during
     * @return premium total premium to be paid for given window
     */
    function returnPrice(uint256 returnWindow, uint256 mintPrice)
        public
        virtual
        returns (uint256 premium)
    {
        uint256 maxWindow = 30 days;
        require(returnWindow <= maxWindow, "ReturnableNFT: window too long");
        premium = (returnWindow * mintPrice) / maxWindow;
    }

    /**
     * @notice call this to set a returnable receipt
     * @param tokenID id of token
     * @param mintPrice base price paid for mint
     * @param returnWindow requested window of return by minter
     */
    function createRecord(
        uint256 tokenID,
        uint256 mintPrice,
        uint256 returnWindow
    ) internal {
        uint256 premium = returnPrice(returnWindow, mintPrice);
        uint256 totalCost = mintPrice + premium;
        require(msg.value == totalCost, "ReturnableNFT: insufficient premium");
        tokenReceipts[tokenID] = Receipt(
            block.timestamp + returnWindow,
            totalCost
        );
        emit ReceiptCreated(tokenID, mintPrice, returnWindow);
    }
}
