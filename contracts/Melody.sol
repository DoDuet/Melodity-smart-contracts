// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract Melody is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    address public crowdsaleAddress;
	uint256 public ICOEndTime;

	modifier onlyCrowdsale {
		require(msg.sender == crowdsaleAddress);
		_;
	}

	modifier afterCrowdsale {
		require(block.timestamp > ICOEndTime || msg.sender == crowdsaleAddress);
		_;
	}

    modifier onlyOwnerOrCrowdsale {
        require(msg.sender == crowdsaleAddress || msg.sender == owner(), "Function allowed only to owner and crowdsale");
        _;
    }

    constructor() ERC20("Melody", "MELD") ERC20Permit("Melody") {
        _mint(msg.sender, 2e9 * 10 ** super.decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwnerOrCrowdsale {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function setCrowdsale(address _crowdsaleAddress) public onlyOwner {
		require(_crowdsaleAddress != address(0));
		crowdsaleAddress = _crowdsaleAddress;
	}

	function buyTokens(address _receiver, uint256 _amount) public onlyCrowdsale {
		require(_receiver != address(0));
		require(_amount > 0);
		transfer(_receiver, _amount);
	}

    function setIcoEndTime(uint256 _time) public onlyOwner {
        require(block.timestamp < _time, "Ico cannot end in the past");
        ICOEndTime = _time;
    }

    function getBlockTime() public view returns(uint256 timestamp) {
        return block.timestamp;
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function transfer(address _to, uint256 _value) override public afterCrowdsale returns(bool) {
        return super.transfer(_to, _value);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function transferFrom(address _from, address _to, uint256 _value) override public afterCrowdsale returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function approve(address _spender, uint256 _value) override public afterCrowdsale returns(bool) {
        return super.approve(_spender, _value);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function increaseApproval(address _spender, uint _addedValue) public afterCrowdsale returns(bool success) {
        return super.increaseAllowance(_spender, _addedValue);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function decreaseApproval(address _spender, uint _subtractedValue) public afterCrowdsale returns(bool success) {
        return super.decreaseAllowance(_spender, _subtractedValue);
    }

    function emergencyExtract() external onlyOwner {
        address payable _owner = payable(super.owner());
        _owner.transfer(address(this).balance);
    }
}
