pragma solidity ^0.4.19;

contract Auction {
    // Parameters
    address public beneficiary;
    uint public auctionEnd;
    uint minPrice;

    // State
    address public highestBidder;
    uint public highestBid;
    bool ended;

    // Pending widrawals
    mapping(address => uint) pendingReturns;

    // Events
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Create new auction
    function Auction(
        address _beneficiary,
        uint _biddingTime,
        uint _minPrice
    ) public {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
        minPrice = _minPrice;
    }

    function bid() public payable {
        require(now <= auctionEnd);
        require(msg.value > highestBid);

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(now >= auctionEnd);
        require(!ended);

        ended = true;
        AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }

    function getMinPrice() view public returns(uint) {
        return minPrice;
    }
}