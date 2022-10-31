# Returnable NFT

NFT contracts that extend the ERC1155 and ERC721 standards (solmate implementations) allowing NFT minters to pay a premium on mint to get a refund window

## Usage

See the contracts in the example folder for an example of how to create the returnable receipt on a mint or refer to the test file to see how to mint with receipt and issue refund.

To set your own premium for returns override the `returnPrice` function with your own formula.
