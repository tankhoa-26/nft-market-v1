// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LuciferNFTCore is ERC721 {
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    uint256 private tokenID;

    event Minted(uint256 indexed tokenId, address indexed owner);

    constructor() ERC721("Lucifer", "LUC") {
        tokenID = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, tokenID);
        tokenID = tokenID + 1;

        emit Minted(tokenID, msg.sender);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    function getTokenID() public view returns (uint256) {
        return tokenID;
    }
}