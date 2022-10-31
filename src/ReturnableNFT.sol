// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReturnableNFT {
    struct Receipt {
        uint256 deadline;
        uint256 price;
    }
    mapping(uint256 => Receipt) private tokenReceipts;

    event TokenReturned(uint256 tokenID);
    event ReceiptCreated(uint256 tokenID, uint256 price, uint256 returnWindow);

    /**
     * @notice call this to return your nft
     */
    function returnToken(uint256 tokenID) external {
        require(
            tokenReceipts[tokenID].deadline != 0,
            "ReturnableNFT: receipt not found"
        );
        if (block.timestamp <= tokenReceipts[tokenID].deadline) {
            // TODO: burn token
            // issue refund
            uint256 value = tokenReceipts[tokenID].price;
            (bool sent, ) = msg.sender.call{value: value}("");
            require(sent, "Failed to send Ether");
            emit TokenReturned(tokenID);
        }
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
        require(returnWindow <= 30 days, "ReturnableNFT: window too long");
        premium = (returnWindow / 30 days) * mintPrice;
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
    ) private {
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
