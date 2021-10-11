// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Melodity is ERC20, ERC20Permit, ERC20Capped, AccessControlEnumerable {
    bytes32 public constant CROWDSALE_ROLE = keccak256("CROWDSALE_ROLE");

    event Bought(address account, uint256 amount);
    event Locked(address account, uint256 amount);
    event Released(address account, uint256 amount);

    struct Locks {
        uint256 locked;
        uint256 release_time;
        bool released;
    }

    uint256 public total_locked_amount = 0;

    mapping(address => Locks[]) private _locks;

    constructor() ERC20("Melodity", "MELD") ERC20Permit("Melodity") ERC20Capped(1000000000 * 10 ** decimals()) {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        ERC20Capped._mint(account, amount);
    }

    /**
     * Lock the bought amount:
     *  - 10% released immediately
     *  - 15% released after 3 months
     *  - 25% released after 9 month (every 6 months starting from the third)
     *  - 25% released after 15 month (every 6 months starting from the third)
     *  - 25% released after 21 month (every 6 months starting from the third)
     */
    function saleLock(address account, uint256 _amount) public onlyRole(CROWDSALE_ROLE) {
        emit Bought(account, _amount);
        
        // immediately release the 10% of the bought amount
        uint256 immediately_released = _amount * 10 / 100; 

        // 15% released after 3 months
        uint256 m3_release = _amount * 15 / 100; 

        // 25% released after 9 months
        uint256 m9_release = _amount * 25 / 100; 
        
        // 25% released after 15 months
        uint256 m15_release = _amount * 25 / 100; 
        
        // 25% released after 21 months
        uint256 m21_release = _amount - (immediately_released + m3_release + m9_release + m15_release); 

        uint256 locked_amount = m3_release + m9_release + m15_release + m21_release;

        // update the counter
        total_locked_amount += locked_amount;

        Locks memory lock_m3 = Locks({
            locked: m3_release,
            release_time: block.timestamp + 7776000,    // 60s * 60m * 24h * 90d
            released: false
        }); 
        Locks memory lock_m9 = Locks({
            locked: m9_release,
            release_time: block.timestamp + 23328000,   // 60s * 60m * 24h * 270d
            released: false
        }); 
        Locks memory lock_m15 = Locks({
            locked: m15_release,
            release_time: block.timestamp + 38880000,   // 60s * 60m * 24h * 450d
            released: false
        }); 
        Locks memory lock_m21 = Locks({
            locked: m21_release,
            release_time: block.timestamp + 54432000,   // 60s * 60m * 24h * 630d
            released: false
        }); 

        _locks[account].push(lock_m3);
        _locks[account].push(lock_m9);
        _locks[account].push(lock_m15);
        _locks[account].push(lock_m21);

        emit Locked(account, locked_amount);

        _mint(account, immediately_released);
        emit Released(account, immediately_released);
    }

	function burnUnSold(uint256 _amount) public onlyRole(CROWDSALE_ROLE) {
		_mint(address(0), _amount);
	}

	/**
	 * Lock the provided amount of MELD for "_release_time" seconds starting from now
	 * NOTE: This method is capped 
	 */
    function insertLock(address account, uint256 _amount, uint256 _release_time) public onlyRole(DEFAULT_ADMIN_ROLE) {
		require(totalSupply() + total_locked_amount + _amount <= cap(), "Unable to lock the defined amount, cap exceeded");
		Locks memory lock_ = Locks({
            locked: _amount,
            release_time: block.timestamp + _release_time,   // 60s * 60m * 24h * 630d
            released: false
        }); 
		_locks[account].push(lock_);

		total_locked_amount += _amount;

		emit Locked(account, _amount);
    }

	/**
	 * Insert an array of locks for the provided account
	 */
    function batchInsertLock(address account, Locks[] memory locks) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint256 i = 0; i < locks.length; i++) {
            insertLock(account, locks[i].locked, locks[i].release_time);
        }
    }

	/**
	 * Retrieve the locks state for the account
	 */
    function locksOf(address account) public view returns(Locks[] memory) {
        return _locks[account];
    }

	/**
	 * Get the number of locks for an account
	 */
    function getLockNumber(address account) public view returns(uint256) {
        return _locks[account].length;
    }

	/**
	 * Release (mint) the amount of token locked
	 */
    function release(uint256 lock_id) public {
        require(_locks[msg.sender].length > 0, "No locks found for your account");
        require(_locks[msg.sender].length -1 >= lock_id, "Lock index too high");
		require(!_locks[msg.sender][lock_id].released, "Lock already released");
		require(block.timestamp > _locks[msg.sender][lock_id].release_time, "Lock not yet ready to be released");

		_locks[msg.sender][lock_id].released = true;
		_mint(msg.sender, _locks[msg.sender][lock_id].locked);
		emit Released(msg.sender, _locks[msg.sender][lock_id].locked);
    }
}