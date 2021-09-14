pragma solidity ^0.5.0;

import "./3_FintooneyCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// Inherit contracts above
contract FintooneyCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    constructor(
        uint rate, address payable wallet, FintooneyCoin token, uint openingTime, uint closingTime, uint goal)

        Crowdsale(rate, wallet, token) 
        // MintedCrowdsale ()   // does not need constructor as empty brackets
        CappedCrowdsale (goal)
        TimedCrowdsale (openingTime, closingTime)
        RefundableCrowdsale (goal)
        
        public
    {
        // constructor can stay empty
    }
}

contract FintooneyCoinSaleDeployer {

    address public token_sale_address; 
    address public token_address;

    constructor(
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal,
        uint rate
        
    )
        public
    {
        // Create FintoonyCoin, note contract address - 0xxxxxxxxxxxxxxxxxxxxxxx
        FintooneyCoin token = new FintooneyCoin(name, symbol, 0);
        token_address = address(token);

        // Create FintooneyCoinSale - inform token, set the goal, set the open and close times
        FintooneyCoinSale fintooney_sale = new FintooneyCoinSale(rate, wallet, token, now, now + 24 weeks, goal);
        token_sale_address = address(fintooney_sale);

        // Make the FintooneyCoinSale contract a minter, then have the FintooneyCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}
