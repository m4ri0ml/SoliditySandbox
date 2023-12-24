pragma solidity ^0.8.0;

import "../utils/IERC721.sol";
import "../utils/IERC20.sol";

contract NFTDepositContract {

    // Collection + tokenId are used as unique identifiers for each NFT struct.
    struct NFTDeposit {
        address depositor;
        address collection;
        uint256 tokenId;
        uint256 minimumPrice;
        bool forSale;
        mapping (address => Bid) bids;
    }

    struct Bid {
        uint256 amount;
        uint256 deadline;
    }

    // Mapping from NFT contract address and token ID to NFT deposit information
    mapping(address => mapping(uint256 => NFTDeposit)) public tokenDeposits;

    // Optional smolMarketplace fees
    uint256 buyerFee;
    uint256 sellerFee;

    /*
    ##############################
          Deposit / Withdraw       
    ##############################
    */

    function depositNFT(address _collection, uint256 _tokenId) public {
        IERC721 nft = IERC721(_collection);
        require(nft.ownerOf(_tokenId) == msg.sender, "You are not the owner");

        nft.transferFrom(msg.sender, address(this), _tokenId);

        NFTDeposit memory nftInfo = NFTDeposit({
            depositor: msg.sender,
            collection: _collection,
            tokenId: _tokenId,
            minimumPrice: 0,
            forSale: false
        });

        tokenDeposits[_collection][_tokenId] = nftInfo;
    }

    function withdrawNFT(address _collection, uint256 _tokenId) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.depositor == msg.sender, "You are not the owner");

        IERC721 nft = IERC721(_collection);

        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete nftInfo;
    }

    /*
    ##############################
                Listings      
    ##############################
    */

    function listNFT(address _collection, uint256 _tokenId, uint256 _price) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.depositor == msg.sender);

        nftInfo.forSale = true;
        nftInfo.minimumPrice = _price;
    }

    function unlistNFT(address collection, uint256 tokenId) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.depositor == msg.sender);
        
        nftInfo.forSale = false;
        nftInfo.minimumPrice = 0;
    }

    /*
    ##############################
               Buy / Bid      
    ##############################
    */

    function buyNFT(address _collection, uint256 _tokenId) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.forSale, "Not for sale");
        
        ERC20(WETH).transferFrom(msg.sender, nftInfo.depositor, nftInfo.minimumPrice);

        IERC721 nft = IERC721(_collection);
        nft.transfer(address(this), msg.sender, _tokenId);

        delete nftInfo;
    }

    function addBid(address _collection, uint256 _tokenId, uint256 _amount, uint256 _deadline) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.forSale, "Not for sale");

        nftInfo.bids[msg.sender] == Bid(_amount, _deadline);
        ERC20(WETH).transferFrom(msg.sender, address(this), _amount);
    }

    function removeBid(address _collection, uint256 _tokenId) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.bids[msg.sender].amount > 0, "No bids available");

        ERC20(WETH).transfer(msg.sender, nftInfo.bids[msg.sender].amount);
        delete nftInfo.bids[msg.sender];
    }

    function acceptBid(address _collection, uint256 _tokenId, address _bidder) public {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.bids[_bidder].deadline < block.timestamp, "Bid expired");

        ERC20(WETH).transfer(nftInfo.depositor, nftInfo.bids[_bidder].amount);

        IERC721 nft = IERC721(_collection);
        nft.transfer(address(this), msg.sender, _tokenId);

    }

    /*
    ##############################
            Info Retrieval      
    ##############################
    */

    function getNFTPrice(address _collection, uint256 _tokenId) public view returns(uint256) {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];
        require(nftInfo.forSale, "NFT is not for sale");

        return nftInfo.minimumPrice;
    }

    function isForSale(address _collection, uint256 _tokenId) public view returns(uint256) {
        NFTDeposit nftInfo = tokenDeposits[_collection][_tokenId];

        return nftInfo.forSale;
    }
}