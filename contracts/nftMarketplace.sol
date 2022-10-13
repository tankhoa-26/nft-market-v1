// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error PriceNotMet(address nftAddress, uint256 tokenID, uint256 proce);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

contract NftMartketplace is ReentrancyGuard {
    struct Listing{
        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    //Map from nft address => nft Id => listItem(seller, price)
    mapping(address => mapping(uint256 => Listing)) private  nftListings;
    //Map from seller to his proceed
    mapping(address => uint256) private sellProceeds;

    modifier notListed(
        address nftAddress,
        uint256 tokenID,
        address owner
    ) {
        Listing memory listing = nftListings[nftAddress][tokenID];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenID);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ){
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);

        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    modifier isListed (address nftAddress, uint256 tokenId){
        Listing memory listing = nftListings[nftAddress][tokenId];
        if (listing.price <= 0){
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    function listItem(
            address nftAddress, 
            uint256 tokenId,
            uint256 price
        )
            external
            notListed(nftAddress, tokenId, msg.sender)
            isOwner(nftAddress, tokenId, msg.sender)
        {
            if (price <= 0) {
                revert PriceMustBeAboveZero();
            }

            IERC721 nft = IERC721(nftAddress);
            if (nft.getApproved(tokenId) != address(this)){
                revert NotApprovedForMarketplace();
            }
            nftListings[nftAddress][tokenId] = Listing(price, msg.sender);
            emit ItemListed(msg.sender, nftAddress, tokenId, price);
        }

    function cancelListing(address nftAddress, uint256 tokenId)
            external
            isOwner(nftAddress, tokenId, msg.sender)
            isListed(nftAddress, tokenId)
        {
            delete (nftListings[nftAddress][tokenId]);
            emit ItemCanceled(msg.sender, nftAddress, tokenId);
        }

    function buyItem(address nftAddress, uint256 tokenId)
            external
            payable
            isListed(nftAddress, tokenId)
            nonReentrant
        {
            Listing memory listedItem = nftListings[nftAddress][tokenId];

            if (msg.value < listedItem.price){
                revert PriceNotMet(nftAddress, tokenId, listedItem.price);
            }

            sellProceeds[listedItem.seller] += msg.value;
            delete (nftListings[nftAddress][tokenId]);
            IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
            emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
        }

    function updateListing(
            address nftAddress, 
            uint256 tokenId,
            uint256 newPrice
        )
            external
            isListed(nftAddress, tokenId)
            isOwner(nftAddress, tokenId, msg.sender)
        {
            if (newPrice == 0){
                revert PriceMustBeAboveZero();
            }

            nftListings[nftAddress][tokenId].price = newPrice;
            emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
        }

    function withdrawProceeds() external {
        uint256 proceeds = sellProceeds[msg.sender];

        if (proceeds <= 0){
            revert NoProceeds();
        }
        sellProceeds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    function getListing(address nftAddress, uint256 tokenId) 
            external
            view
            returns (Listing memory)
        {
            return nftListings[nftAddress][tokenId];
        }
    function getProceeds(address seller) external view returns (uint256){
        return sellProceeds[seller];
    }

}