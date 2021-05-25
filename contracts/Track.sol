// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Track is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

	event TrackRegistered(address owner, uint256 track_id);
	event FeePayed(address payer, uint256 fee);
	event Redeemed(uint256 amount);
	
	uint256 song_registration_fee;
	Melody token;

	string private _baseTokenURI;

	modifier canRegisterSong() {
		require(token.balanceOf(msg.sender) >= song_registration_fee, "Not enough funds to register a song");
		_;
	}

    constructor(Melody _token, uint256 _song_registration_fee, string memory baseTokenURI) ERC721("MelodyTrack", "MELDT") {
		token = _token;
		song_registration_fee = _song_registration_fee * 1 ether;
		_baseTokenURI = baseTokenURI;
	}

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function registerTrack(address musician) public canRegisterSong {
		payRegistrationFee();

		uint256 track_id = _tokenIds.current();
        _safeMint(musician, track_id);
        _tokenIds.increment();

		emit TrackRegistered(msg.sender, track_id);
    }

	function payRegistrationFee() internal {
		token.burnFrom(msg.sender, song_registration_fee);
		emit FeePayed(msg.sender, song_registration_fee);
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