// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "./CommonModifier.sol";
import "./Track.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TrackElection is Ownable, CommonModifier {
    using SafeMath for uint256;
	using EnumerableSet for EnumerableSet.AddressSet;
	using EnumerableSet for EnumerableSet.UintSet;

	event Voted(address voter, uint256 track_id, uint256 half_stars);
	event FeePayed(address payer, uint256 fee);
	event Redeemed(uint256 token_amount, uint256 eth_amount);
	event PrizeForMusician(address musician, uint256 prize, uint8 position);
	event PrizeForInvestor(address investor, uint256 prize, uint8 position);
	event AllPrizesDistributed();

	struct Song {
		address owner;
		uint256 votes;
		EnumerableSet.AddressSet voters;
	}

	struct Ranking {
		uint256 track_id;
		uint256 votes;
	}

	// track => { owner, votes, voters }
	mapping(uint256 => Song) participants;
	EnumerableSet.UintSet voted_songs;

	Melody token;
	Track track;
	uint256 half_star_value;
	uint256 prize_fee;

	modifier canVote(uint256 track_id, uint256 half_stars) {
		require(track.exists(track_id), "Track does not exist");
		require(!participants[track_id].voters.contains(msg.sender), "Track already voted");
		require(msg.sender != track.ownerOf(track_id), "Cannot vote your own track");
		_;
	}

	constructor(
		uint256 _start, 
		uint256 _end, 
		Melody _token, 
		Track _track, 
		uint256 _half_star_value,
		uint256 _prize_fee
	) {
		token = _token;
		half_star_value = _half_star_value * 1 ether;
		start = _start;
		end = _end;
		track = _track;
		prize_fee = _prize_fee;
	}

	function payVoteFee(uint256 vote_value) internal {
		token.transferFrom(msg.sender, address(this), vote_value);

		emit FeePayed(msg.sender, vote_value);
	}

	function vote(uint256 track_id, uint256 half_stars) public whenRunning canVote(track_id, half_stars) payable {
		uint256 vote_value = half_star_value * half_stars;

		require(token.balanceOf(msg.sender) >= vote_value, "Not enough funds to give this vote");
		payVoteFee(vote_value);
		
		voted_songs.add(track_id);
		participants[track_id].votes += half_stars;

		// Check if the track owner is changed or if it null and update it
		address track_owner = track.ownerOf(track_id);
		// Avoid checking for difference to reduce gas fee
		participants[track_id].owner = track_owner;

		// Add the address of the voter to the set of voters if not yet present
		participants[track_id].voters.add(msg.sender);

		emit Voted(msg.sender, track_id, half_stars);
	} 

	function getBalance() public view returns(uint256) { return address(this).balance; }
	function getTokenBalance() public view returns(uint256) { return token.balanceOf(address(this)); }

	function finalize() public onlyOwner /*whenClosed*/ {
		_finalize();
		_distribute();

		emit AllPrizesDistributed();

		redeem();
	}

	function _swapTrack(Ranking memory new_ranking, Ranking memory old_ranking) internal pure returns(Ranking memory, Ranking memory) {
		if(new_ranking.votes > old_ranking.votes) {
			return (old_ranking, new_ranking);
		}
		return (new_ranking, old_ranking);
	}

	function _distribute() internal {       
		Ranking memory first_place;
		Ranking memory second_place;
		Ranking memory third_place;
		Ranking memory old;

		uint256 track_id;

		for(uint256 i; i < voted_songs.length(); i++) {
			// caches the current track_id
			track_id = voted_songs.at(i);

			// Check if current track has more votes than the first one, in case swap them
			(old, first_place) = _swapTrack(
				Ranking({
					votes: participants[track_id].votes, 
					track_id: track_id
				}), 
				first_place
			);

			// Check if the track with less votes in the previous step has more votes than 
			// the one marked as second, in case swap them
			(old, second_place) = _swapTrack(old, second_place);

			// Check if the track with less votes in the previous step has more votes than 
			// the one marked as third, in case swap them, the one with less votes is simply
			// trashed
			(, third_place) = _swapTrack(old, third_place);
		}

		(uint256 first_place_prize, address first_place_address) = _computeMusicianPrize(1, first_place);
		(uint256 second_place_prize, address second_place_address) = _computeMusicianPrize(2, second_place);
		(uint256 third_place_prize, address third_place_address) = _computeMusicianPrize(3, third_place);

		uint256 balance = token.balanceOf(address(this)) - first_place_prize - second_place_prize - third_place_prize;

		// Send the prizes to the winners and investors
		_sendPrize(first_place, first_place_address, first_place_prize, 1, balance);
		_sendPrize(second_place, second_place_address, second_place_prize, 2, balance);
		_sendPrize(third_place, third_place_address, third_place_prize, 3, balance);
	}

	function _computeMusicianPrize(uint8 position, Ranking memory ranking) internal view returns(uint256, address) {
		uint256 prize = ranking.votes * half_star_value * 100; // normalize fee percentage given as integer
		uint256 fee = ranking.votes * half_star_value * prize_fee * position;

		return ((prize - fee) / 100, participants[ranking.track_id].owner);
	}

	function _computeInverstorPrize(uint256 balance, uint8 position, Ranking memory ranking) internal view returns(uint256) {
		// the balance is divided in 8 chunks (125 is 0.125 of the total) each position receive the specified chunk
		// shifted right by 2; returns 4, 2.75 or 1.25 which are the shares of the total balance given to the investor of the classified
		uint256 prize = balance * 125 * (position == 1 ? 400 : (position == 2 ? 275 : 125));
		uint256 fee = prize * 5 * position;

		return (prize * 100 - fee) / participants[ranking.track_id].voters.length() / 1e7;
	}

	function _sendPrizeToInvestor(Song storage song, uint256 prize, uint8 position) internal {
		for(uint256 i; i < song.voters.length(); i++) {
			address investor = song.voters.at(i);

			token.transfer(investor, prize);

			emit PrizeForInvestor(investor, prize, position);
		}
	}

	function _sendPrize(
		Ranking memory rank, 
		address first_place_address, 
		uint256 first_place_prize, 
		uint8 position, 
		uint256 balance
	) internal {
		// Track id = 0 will never exist so if it is null the position is not filled
		if(rank.track_id != 0) {
			// send prize to the winner
			token.transfer(first_place_address, first_place_prize);

			emit PrizeForMusician(first_place_address, first_place_prize, position);
			
			// send prize to the investors
			uint256 investor_prize = _computeInverstorPrize(balance, 1, rank);
			_sendPrizeToInvestor(participants[rank.track_id], investor_prize, position);
		}
	}

	function redeem() public onlyOwner /*whenClosed*/ {
		address addr = address(this);
		uint256 token_amount = token.balanceOf(addr);
		uint256 eth_amount = addr.balance;

		// Transfer all the tokens (and ether if someone sent it) to the owner
		token.transferFrom(addr, owner(), token_amount);
		payable(owner()).transfer(eth_amount);

		emit Redeemed(token_amount, eth_amount);
	}
}