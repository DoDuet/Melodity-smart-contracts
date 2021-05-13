// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "./PriceConsumer.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdsale is Ownable {
    using SafeMath for uint256;

    bool completed;
    uint256 start;
    uint256 end;
    uint256 rate;
    uint256 goal;
    Melody token;
    bool fixed_rate;
    PriceConsumer pc;

    modifier whenCompleted() {
        require(completed, "Crowdsale not yet completed");
        _;
    }

    modifier notCompleted() {
        require(!completed, "Crowdsale already completed");
        _;
    }

    modifier isClosed() {
        require(
            block.timestamp >= end || address(this).balance >= goal, 
            "Unable to close the crowdsale, closing requirements not met"
        );
        _;
    }

    modifier running() {
        require(
            block.timestamp >= start && block.timestamp <= end && address(this).balance <= goal, 
            "Crowdsale not running"
        );
        _;
    }

    receive() payable external {
        buy();
    }

    constructor(uint256 _start, uint256 _end, Melody _token, uint256 _goal, bool _fixed_rate, uint256 _tokenRate, address _consumer) {
        require(_start != 0 && block.timestamp < _start, "Starting time cannot be null or in the past");
        require(_end != 0 && block.timestamp < _end, "Ending time cannot be null or in the past");
        require(_goal != 0, "Goal cannot be null");
        require(_tokenRate != 0, "Token rate cannot be null");

        if(!_fixed_rate) {
            require(_consumer != address(0), "Consumer contract cannot be null");
            pc = PriceConsumer(_consumer);
        }

        start = _start;
        end = _end;
        rate = _tokenRate;
        goal = _goal;
        token = _token;
        fixed_rate = _fixed_rate;   
    }

    function buy() public running notCompleted payable {
        uint256 tokensToBuy;

        if(fixed_rate) {
            // If a fixed rate is provided compute the amount of token to buy based on the rate
            tokensToBuy = msg.value * 1e18 / rate;
        }
        else {
            // If the rate is not fixed, dynamically compute the number of tokens to return based on the defined rate
            tokensToBuy = msg.value * 1e18 / pc.computeNumberOfToken(rate);
        }

        token.mint(address(this), tokensToBuy);
        token.buyTokens(msg.sender, tokensToBuy);
    }

    function finalize() public onlyOwner isClosed notCompleted returns(bool) {
        completed = true;
        return true;
    }

    function isCompleted() public onlyOwner view returns(bool) {
        return completed;
    }

    function isStarted() public view returns(bool) {
        return block.timestamp >= start;
    }

    function redeem() public onlyOwner whenCompleted isClosed payable {
        payable(owner()).transfer(address(this).balance);
    }

    function currentBalance() public view returns(uint256) {
        return address(this).balance;
    }
}
