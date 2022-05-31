const {expect} = require("chai");
const { ethers } = require("hardhat");

describe("Test Marketplace Contract", function(){
    let Coin99, coin99, BasicNft, basicNft, Marketplace, marketplace, owner, addr1, addr2, addr3;
    let erc20Owner, erc721Owner, marketplaceADMIN;

    beforeEach(async function(){
        [erc20Owner, erc721Owner, marketplaceADMIN, addr1, ...addr2] = await ethers.getSigners(); 

        Coin99 = await ethers.getContractFactory("Coin99");
        coin99 = await Coin99.deploy();

        BasicNft = await ethers.getContractFactory("BasicNft");
        basicNft = await BasicNft.deploy();

        Marketplace = await ethers.getContractFactory("NftMartketplace");
        marketplace = await Marketplace.deploy();

        await basicNft.connect(erc721Owner).mintNft();
        //NFT owner approve to marketplace list his NFT 
        await basicNft.connect(erc721Owner).approve(marketplace.address, 0);
        //NFT Owner list his first NFT
        await marketplace.connect(erc721Owner).listItem(basicNft.address, 0, 5);
        //ERC20 Owner claim his token
        await coin99.connect(erc20Owner).issueToken();
    });

    describe("Issue Token For Owner", function(){
        it("Should issuing token function", async function(){
            // await coin99.connect(erc20Owner).issueToken();
            //const ownerBalance = new BigNumber(0);
            const ownerBalance = await coin99.balanceOf(erc20Owner.address);
            const decimals = ethers.BigNumber.from(10).pow(18);

            //console.log("token owner: ", await coin99.owner());

            expect(ownerBalance).to.equal(ethers.BigNumber.from(1000).mul(decimals));
        });
    });

    describe("Create NFT ERC721", function(){
        it("Should create NFT ERC721", async function(){
            const ownerBalance = await basicNft.balanceOf(erc721Owner.address);
            expect(ownerBalance).to.equal(1);
        });
    });

    describe("Demo list nft to marketplace", function(){
        it("NFT Owner list first NFT", async function(){
            // await basicNft.connect(erc721Owner).mintNft();
            // //NFT owner approve to marketplace list his NFT 
            // await basicNft.connect(erc721Owner).approve(marketplace.address, 0);
            //check approve success?
            expect(await basicNft.getApproved(0)).to.equal(marketplace.address);

            //NFT Owner list his first NFT
            // await marketplace.connect(erc721Owner).listItem(basicNft.address, 0, 5);

            //Check listing nft (price + seller)
            let listing = await marketplace.connect(erc721Owner).getListing(basicNft.address, 0);
            expect(listing.price).to.equal(5);
            expect(listing.seller).to.equal(erc721Owner.address);
        });
    });

    describe("Demo cancel listing nft", function () {
        it("NFT Owner  cancel listing nft", async function(){
            // await basicNft.connect(erc721Owner).mintNft();
            // //NFT owner approve to marketplace list his NFT 
            // await basicNft.connect(erc721Owner).approve(marketplace.address, 0);
            // //NFT Owner list his first NFT
            // await marketplace.connect(erc721Owner).listItem(basicNft.address, 0, 5);
            //Cancel listing NFT
            await marketplace.connect(erc721Owner).cancelListing(basicNft.address, 0);
            //Check cancel listing success
            let listing = await marketplace.connect(erc721Owner).getListing(basicNft.address, 0);

            expect(listing.price).to.equal(0);
            expect(listing.seller).to.equal(ethers.constants.AddressZero);
            //console.log(listing);
        });
    });

    describe("Demo update listing nft functon", function(){
        it("NFT Owner update listing nft", async function(){
            // await basicNft.connect(erc721Owner).mintNft();
            // //NFT owner approve to marketplace list his NFT 
            // await basicNft.connect(erc721Owner).approve(marketplace.address, 0);
            // //NFT Owner list his first NFT
            // await marketplace.connect(erc721Owner).listItem(basicNft.address, 0, 5);
            //Update listing NFT
            await marketplace.connect(erc721Owner).updateLsiting(basicNft.address, 0, 10);
            //Check update NFT success
            listing = await marketplace.connect(erc721Owner).getListing(basicNft.address, 0);

            expect(listing.price).to.equal(10);
        });
    });

    describe("Demo buy nft", function(){
        it("NFT Owner list nft, then the other buy it", async function(){
            //Get ERC20 Owner initial balance
            const initialBalance_erc20_Owner = await coin99.balanceOf(erc20Owner.address);   
            // 
            const transactionValue = 5;
            const options = {value: transactionValue};
            //Get initial proceeds of seller
            const initialBalance_seller = await marketplace.getProceeds(erc721Owner.address);
            //Do buy nft
            await marketplace.connect(erc20Owner).buyItem(basicNft.address, 0, options);
            //Get final proceeds of seller
            const finalBalance_seller = await marketplace.getProceeds(erc721Owner.address);
            //Get ERC20 Owner final balance
            const finalBalance_erc20_Owner = await coin99.balanceOf(erc20Owner.address);
            console.log('here...fi...',initialBalance_seller);
            console.log('here...fi...',finalBalance_seller);
            expect(finalBalance_erc20_Owner).to.equal(initialBalance_erc20_Owner.sub(5));
            expect(finalBalance_seller).to.equal(initialBalance_seller.add(5));
            
        });
    });

});