// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommonModifier {
	bool public completed;
    uint256 public start;
    uint256 public end;

    event Finalized();

	modifier whenCompleted() virtual {
        require(completed, "Contract not yet completed");
        _;
    }

    modifier whenNotCompleted() virtual {
        require(!completed, "Contract already completed");
        _;
    }

    modifier whenClosed() virtual {
        require(
            block.timestamp >= end, 
            "Contract not yet closed"
        );
        _;
    }

    modifier whenRunning() virtual {
        require(
            block.timestamp >= start && block.timestamp < end, 
            "Contract not running"
        );
        _;
    }

    function _finalize() internal virtual {
        completed = true;
        emit Finalized();
    }
}
