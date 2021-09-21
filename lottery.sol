//SPDX-License-Identifier: GPL-3.0
 
pragma solidity ^0.8.0;


contract PoolContract{
	address owner;
	
	mapping(address => uint) balances;
    
  address payable[] public users;

	uint public noOfWinners;
	
	string public tokenName;
	uint public tokenPrice;

	uint public totalRaisedAmount;
	
	uint public coolDownPeriod; //TimeStamp After which user can easily withdraw money without any charges
	
	uint public earlyExitFee;
	
	uint public remaningTime;

  uint yieldedProfit;

  uint fairness; // lock-down period
// 	enum timePeriod{weekly, daily}
	
// 	timePeriod public PoolPeriod;

    // enum PoolState { Open, Closed, Finished }

	constructor(uint _noOfWinners, uint _coolDownPeriod, uint _earlyExitFeePercentage, string memory _tokenName, uint _tokenPrice){
		noOfWinners = _noOfWinners;
		coolDownPeriod = block.timestamp + _coolDownPeriod;
		earlyExitFee = _earlyExitFeePercentage;
		owner = msg.sender;
		tokenName = _tokenName;
		tokenPrice = _tokenPrice;
		remaningTime = block.timestamp + 3600;
		fairness = 8; // pool period + 1 day
	}

	modifier onlyOwner() { 
		require (msg.sender == owner); 
		_; 
	}

	function investInPool() public payable {
	    require(msg.sender != owner, "Owner can not Invest");
	    require(msg.value > 0, "Must be greater than zero");
	    if(balances[msg.sender] == 0){
	        users.push(payable (msg.sender));
	        balances[msg.sender] = msg.value;
	    }
	    else{
	        balances[msg.sender]+=msg.value;
	    }
	    totalRaisedAmount+=msg.value;
	}
	
	function Investment() public onlyOwner{
	    require(block.timestamp > remaningTime);
      yieldedProfit = totalRaisedAmount + 1000;
	}
	
	
	//Do not use it for online transactions
	function random() internal view returns(uint){
		return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, users.length))) ;
	}


	function pickWinner() public onlyOwner{
		require(msg.sender == owner, "You are not owner");
		uint randomNumber = random();
		address payable winner;
		uint idx = randomNumber % users.length;
		winner = users[idx];
		uint winnerPrice = (yieldedProfit - totalRaisedAmount);
		winner.transfer(winnerPrice);
		revertPoolMoney();
		users = new address payable[](0); // reset lottery
	}
	
	
	
	function RenounceOwnership(address _newOwner) public onlyOwner{
	    owner = _newOwner;
	}       
	
// Rollover all tickets to next draw
// 	function rollover() public onlyOwner isState(LotteryState.Finished) {
// 		//rollover new lottery
// 	}


    // function getTimeLeft() public view returns(uint){
    //     return (remaningTime - block.timestamp);
    // }
    
   function revertPoolMoney() internal onlyOwner{
      for(uint i;i<users.length;i++){
          uint x = balances[users[i]];
          balances[users[i]] = 0;
          users[i].transfer(x);
      }
  }
	
	function getTokenBalance(address _userAddr) public view returns(uint){
	    if(balances[_userAddr] == 0){
	        return 0;
	    }
	    return balances[_userAddr];
	}
	
	function withdraw() public {

		
	}
	    
}



//Assume we get the interest and do other functionality



//will deploy Pool contract (as each pool has a different owner who deployed it)
contract DeployLotteryContract{
	//need to has a mapping which store who deploy a new Pool Contract
	// mapping(address => instanceof(PoolContract))

}


