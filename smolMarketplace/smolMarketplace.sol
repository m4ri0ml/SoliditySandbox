// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/IERC721.sol";
import "../utils/IERC20.sol";
import "../utils/Owned.sol";

contract smolMarketplace is Owned {

    // Collection + tokenId are used as unique identifiers for each NFT struct.
    struct NFTDeposit {
        address depositor;
        address collection;
        uint256 tokenId;
        uint256 minimumPrice;
        bool forSale;
        address[] bidders;
    }

    struct Bid {
        address bidder;
        uint256 bidId;
        uint256 amount;
        uint256 date;
        uint256 deadline;
        bool isDecaying;
    }

    mapping(address => mapping(uint256 => NFTDeposit)) public tokenDeposits;
    mapping(bytes32 => uint256) private bidIdMapping;
    mapping(uint256 => Bid) public bids;

    // Marketplace variables
    uint256 public mktFee;
    bool public paused;

    address immutable WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /*
    ##############################
          Deposit / Withdraw       
    ##############################
    */

    constructor () Owned(msg.sender) {}

    function depositNFT(address _collection, uint256 _tokenId) public {
        IERC721 nft = IERC721(_collection);
        require(nft.ownerOf(_tokenId) == msg.sender, "You are not the owner");
        require(!paused, "Marketplace paused");

        nft.transferFrom(msg.sender, address(this), _tokenId);

        NFTDeposit storage nftData = tokenDeposits[_collection][_tokenId];

        nftData.depositor = msg.sender;
        nftData.collection = _collection;
        nftData.tokenId = _tokenId;
        nftData.minimumPrice = 0; // Set the default value or update as needed
        nftData.forSale = false; // Set the default value or update as needed

    }   

    function withdrawNFT(address _collection, uint256 _tokenId) public {
        NFTDeposit memory nftData = tokenDeposits[_collection][_tokenId];
        require(nftData.depositor == msg.sender, "You are not the owner");

        IERC721 nft = IERC721(_collection);

        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete nftData;
    }

    /*
    ##############################
                Listings      
    ##############################
    */

    function listNFT(address _collection, uint256 _tokenId, uint256 _price) public view {
        NFTDeposit memory nftData = tokenDeposits[_collection][_tokenId];
        require(nftData.depositor == msg.sender);
        require(!paused, "Marketplace paused");

        nftData.forSale = true;
        nftData.minimumPrice = _price;
    }

    function unlistNFT(address _collection, uint256 _tokenId) public view {
        NFTDeposit memory nftData = tokenDeposits[_collection][_tokenId];
        require(nftData.depositor == msg.sender);
        
        nftData.forSale = false;
        nftData.minimumPrice = 0;

        delete nftData;
    }

    /*
    ##############################
               Buy / Bid      
    ##############################
    */

    function buyNFT(address _collection, uint256 _tokenId) public {
        NFTDeposit memory nftData = tokenDeposits[_collection][_tokenId];
        require(nftData.forSale, "Not for sale");
        require(!paused, "Marketplace paused");
        
        uint256 fee = (nftData.minimumPrice * mktFee) / 100;
        IERC20(WETH).transferFrom(msg.sender, nftData.depositor, nftData.minimumPrice - fee);

        IERC721 nft = IERC721(_collection);
        nft.transferFrom(address(this), msg.sender, _tokenId);

        delete nftData;
    }

    function placeBid(address _collection, uint256 _tokenId, uint256 _amount, uint256 _deadline, bool _decaying) public {
        NFTDeposit storage nftData = tokenDeposits[_collection][_tokenId];
        require(!paused, "Marketplace paused");
        require(nftData.forSale, "Not for sale");
        require(block.timestamp < _deadline, "Deadline must be greater that current time");

        IERC20(WETH).transferFrom(msg.sender, address(this), _amount);

        bytes32 bidKey = _getBidKey(msg.sender, _collection, _tokenId);
        uint256 bidId = bidIdMapping[bidKey];

        bids[bidId] = Bid({
            bidder: msg.sender,
            date: block.timestamp,
            bidId: bidId,
            amount: _amount,
            deadline: _deadline,
            isDecaying: _decaying
        });

        nftData.bidders.push(msg.sender);
    }

    function removeBid(address _collection, uint256 _tokenId) public {
        bytes32 bidKey = _getBidKey(msg.sender, _collection, _tokenId);
        uint256 bidId = bidIdMapping[bidKey];

        require(bidId != 0, "No active bid found");
        Bid storage bid = bids[bidId];
        require(bid.bidder == msg.sender, "Not the bidder");

        IERC20(WETH).transfer(msg.sender, bid.amount);
        delete bids[bidId];
        delete bidIdMapping[bidKey];
    }

    function acceptBid(address _collection, uint256 _tokenId, address _bidder) public {
        NFTDeposit storage nftData = tokenDeposits[_collection][_tokenId];
        require(!paused, "Marketplace paused");

        bytes32 bidKey = _getBidKey(_bidder, _collection, _tokenId);
        uint256 bidId = bidIdMapping[bidKey];
        Bid storage bid = bids[bidId];

        require(block.timestamp < bid.deadline, "Bid expired");
        require(nftData.depositor == msg.sender, "You are not the owner");

        IERC721 nft = IERC721(_collection);

        if (bid.isDecaying) {
            uint256 bidValue = getDecayingBidValue(_collection, _tokenId, _bidder);

            IERC20(WETH).transfer(nftData.depositor, bidValue);
            nft.transferFrom(address(this), _bidder, _tokenId);
        } else{
            IERC20(WETH).transfer(nftData.depositor, bid.amount);
            nft.transferFrom(address(this), _bidder, _tokenId);
        }

        delete bids[bidId];
        delete bidIdMapping[bidKey];
    }

    /*
    ##############################
            Info Retrieval      
    ##############################
    */

    function getNFTPrice(address _collection, uint256 _tokenId) public view returns(uint256) {
        NFTDeposit storage nftData = tokenDeposits[_collection][_tokenId];
        require(nftData.forSale, "NFT is not for sale");

        return nftData.minimumPrice;
    }

    function isForSale(address _collection, uint256 _tokenId) public view returns(bool) {
        NFTDeposit storage nftData = tokenDeposits[_collection][_tokenId];

        return nftData.forSale;
    }

    function getBidsForNFT(address _collection, uint256 _tokenId) public view returns (Bid[] memory) {
        NFTDeposit storage nftDeposit = tokenDeposits[_collection][_tokenId];
        Bid[] memory nftBids = new Bid[](nftDeposit.bidders.length);

        for (uint i = 0; i < nftDeposit.bidders.length; i++) {
            bytes32 bidKey = keccak256(abi.encodePacked(nftDeposit.bidders[i], _collection, _tokenId));
            uint256 bidId = bidIdMapping[bidKey];
            nftBids[i] = bids[bidId];
        }

        return nftBids;
    }

    function getDecayingBidValue(address _collection, uint256 _tokenId, address _bidder) public view returns (uint256) {
        bytes32 bidKey = _getBidKey(_bidder, _collection, _tokenId);
        uint256 bidId = bidIdMapping[bidKey];
        Bid storage bid = bids[bidId];

        uint256 amount = bid.amount;
        uint256 date = bid.date;
        uint256 deadline = bid.deadline;

        if (bid.isDecaying) {
            if (block.timestamp > deadline) {
                return 0;     
            } else {
                uint256 totalDuration = deadline - date;
                uint256 elapsedTime = block.timestamp - date;
                uint256 decreaseRate = amount / totalDuration;
                uint256 decreasedAmount = elapsedTime * decreaseRate;

                if (amount > decreasedAmount) {
                    return amount - decreasedAmount;
                } else {
                    return 0;
                }
            }
        }

        return 0;
    }

    // Generate a key that associates a bidder with a bidId
    function _getBidKey(address _bidder, address _collection, uint256 _tokenId) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_bidder, _collection, _tokenId));
    }

    function setMarketFee(uint256 _fee) public onlyOwner {
        mktFee = _fee;
    }

    function pauseMarket(bool _switch) public onlyOwner {
        paused = _switch;
    }
}