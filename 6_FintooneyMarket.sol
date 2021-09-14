pragma solidity ^0.5.0;
//FinTooney Token

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./5_FintooneyAuction.sol";
//import token creator file
// buy FinTooney token using ether
// bid taking place in ether still - ERC721Full
// how to use FinTooney for auction?
// in auction, call for msg balance of FinTooney token

contract ToonFinMarket is ERC721Full, Ownable {

    constructor() ERC721Full("FintooneyMarket", "TOON") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => FintooneyAuction) public auctions;

    modifier toonRegistered(uint token_id) {
        require(_exists(token_id), "NFT not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new FintooneyAuction(foundation_address);
    }

    function registerToon(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(foundation_address, token_id);
        _setTokenURI(token_id, uri); //each token has 1 uri
        createAuction(token_id);
    }

    function endAuction(uint token_id) public onlyOwner toonRegistered(token_id) {
        FintooneyAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        FintooneyAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view toonRegistered(token_id) returns(uint) {
        FintooneyAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view toonRegistered(token_id) returns(uint) {
        FintooneyAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable toonRegistered(token_id) {
        FintooneyAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}
