// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "./CommonModifier.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdsale is Ownable, CommonModifier {
    using SafeMath for uint256;

    uint256 goal;
    uint256 minted;
    Melody token;
    PaymentTier[] payment_tier;

    event Buy(address indexed from, uint256 amount);
    event Finalize();
    event Redeemed(uint256 amount);

    struct PaymentTier {
        uint256 rate;
        uint256 lower_limit;
        uint256 upper_limit;
    }

    receive() payable external {
        buy();
    }

    modifier whenClosed() override {
        require(
            block.timestamp >= end || minted >= goal, 
            "Crowdsale not yet closed"
        );
        _;
    }

    modifier whenRunning() override {
        require(
            block.timestamp >= start && block.timestamp < end && minted < goal, 
            "Crowdsale not running"
        );
        _;
    }

    /**
    @param _start Ico starting time
    @param _end Ico ending time, if goal is not reached first
    @param _token Melody token instance
    @param _goal Amount of funds to raise
    @param _payment_tier Array of crowdsale price tier
     */
    constructor(uint256 _start, uint256 _end, Melody _token, uint256 _goal, PaymentTier[] memory _payment_tier) {
        require(_start != 0 && block.timestamp < _start, "Starting time cannot be null or in the past");
        require(_end != 0 && block.timestamp < _end, "Ending time cannot be null or in the past");
        require(_goal != 0, "Goal cannot be null");
        require(_payment_tier.length > 0, "At least one payment tier must be defined");
        require(_token != Melody(payable(address(0))), "Token address cannot be null");

        start = _start;
        end = _end;
        goal = _goal;
        token = _token;

        for(uint256 i = 0; i < _payment_tier.length; i++) {
            payment_tier.push(_payment_tier[i]);
        }
    }

    function buy() public whenRunning whenNotCompleted payable {
        // If a fixed rate is provided compute the amount of token to buy based on the rate
        uint256 tokens_to_buy = computeTokensAmount();

        // Mint new tokens for each submission
        token.mint(msg.sender, tokens_to_buy);
        minted += tokens_to_buy;

        emit Buy(msg.sender, tokens_to_buy);
    }

    function computeTokensAmount() internal whenRunning returns(uint256) {
        uint256 future_minted = minted;
        uint256 tokens_to_buy;
        uint256 current_round_tokens;      
        uint256 ether_used = msg.value; 
        uint256 future_round; 
        uint256 rate;
        uint256 upper_limit;

        for(uint256 i = 0; i < payment_tier.length; i++) {
            // minor performance improvement, caches the value
            upper_limit = payment_tier[i].upper_limit;

            if(
                ether_used > 0 &&                                   // Check if there are still some funds in the request
                future_minted >= payment_tier[i].lower_limit &&     // Check if the current rate can be applied with the lower_limit
                future_minted < upper_limit                         // Check if the current rate can be applied with the upper_limit
                ) {
                // minor performance improvement, caches the value
                rate = payment_tier[i].rate;
                
                // Keep a static counter and reset it in each round
                // NOTE: Order is important in value calculation
                current_round_tokens = ether_used * 1e18 / 1 ether * rate;

                // minor performance optimization, caches the value
                future_round = future_minted + current_round_tokens;
                // If the tokens to mint exceed the upper limit of the tier reduce the number of token bounght in this round
                if(future_round > upper_limit) {
                    current_round_tokens -= future_round - upper_limit;
                }

                // Update the future_minted counter with the current_round_tokens
                future_minted += current_round_tokens;

                // Recomputhe the available funds
                ether_used -= current_round_tokens * 1 ether / rate / 1e18;

                // And add the funds to the total calculation
                tokens_to_buy += current_round_tokens;
            }
        }

        // minor performance optimization, caches the value
        uint256 new_minted = minted + tokens_to_buy;
        // Check if we have reached and exceeded the funding goal to refund the exceeding tokens and ether
        if(new_minted > goal) {
            uint256 exceedingTokens = new_minted - goal;
            
            // Convert the exceedingTokens to ether and refund that ether
            uint256 exceedingEther = exceedingTokens * 1 ether / payment_tier[payment_tier.length -1].rate / 1e18;
            payable(msg.sender).transfer(exceedingEther);

            // Change the tokens to buy to the new number
            tokens_to_buy -= exceedingTokens;
        }

        return tokens_to_buy;
    }

    function finalize() public onlyOwner whenClosed whenNotCompleted {
        completed = true;
        emit Finalize();
    }

    function redeem() public onlyOwner whenCompleted whenClosed payable {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(address(this).balance);
        emit Redeemed(balance);
    }

    function getBalance() public view returns(uint256) { return address(this).balance; }
    function getMinted() public view returns(uint256) { return minted; }
    function getStartingTime() public view returns(uint256) { return start; }
    function getEndingTime() public view returns(uint256) { return end; }
    function getGoal() public view returns(uint256) { return goal; }
    function getTiers() public view returns(PaymentTier[] memory) { return payment_tier; }
    function isCompleted() public onlyOwner view returns(bool) { return completed; }
    function isStarted() public view returns(bool) { return block.timestamp >= start; }
}
