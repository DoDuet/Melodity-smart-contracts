// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Track is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

	event TrackRegistered(address owner, uint256 track_id);
	event FeePayed(address payer, uint256 fee);
	event Redeemed(uint256 amount);
	
	uint256 song_registration_fee;
	Melody token;

	modifier canRegisterSong() {
		require(token.balanceOf(msg.sender) >= song_registration_fee, "Not enough funds to register a song");
		_;
	}

    constructor(Melody _token, uint256 _song_registration_fee) ERC721("MelodyTrack", "MELDT") {
		token = _token;
		song_registration_fee = _song_registration_fee * 1 ether;
	}

    function registerTrack(address musician, string memory tokenURI) public canRegisterSong {
		payRegistrationFee();

        uint256 track_id = genTrackId();
        _mint(musician, track_id);
        _setTokenURI(track_id, tokenURI);

		emit TrackRegistered(msg.sender, track_id);
    }

	function payRegistrationFee() internal {
		token.transferFrom(msg.sender, owner(), song_registration_fee);
		emit FeePayed(msg.sender, song_registration_fee);
	}

	function genTrackId() internal returns(uint256) {
		_tokenIds.increment();
		return _tokenIds.current();
	}

	function exists(uint256 track_id) public view returns(bool) {
		return _exists(track_id);
	}

	function redeem() public onlyOwner {
		address addr = address(this);
		uint256 balance = token.balanceOf(addr);
		token.transferFrom(addr, owner(), balance);

		emit Redeemed(balance);
	}
}