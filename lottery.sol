//SPDX-License-Identifier: GPL-3.0
 
pragma solidity ^0.8.0;


contract PoolContract{
	address owner;
	
	mapping(address => uint) balances;

    mapping (address => uint) lastLockPeriod;

    address payable[] public users;

	uint public noOfWinners;
    
    uint public totalRaisedAmount;
	
	uint public remaningTime;
    
    uint earlyExitTotalSupply;

    uint public poolStart;
    
    uint public poolEnd;
    
    event Transaction(address userAddr, uint256 amount);
    
	constructor(){
		earlyExitTotalSupply = 0;
		noOfWinners = 1;
		owner = msg.sender;
		poolStart = block.number;
		poolEnd = block.number + 46080;
		coolDownPeriod= block.number + 46080; // (8 days ( Pool Period + 1 Day))
		// Why 46080
		// because for 8 days (Total second / time to mine new block) =>>>(60 * 60 * 24 * 7 )/15
	}
    
    function getCurrentBlockNumber() public view returns(uint){
        return block.number;
    }

    function addInitialFund() external payable onlyOwner{}



	modifier onlyOwner() { 
		require (msg.sender == owner); 
		_; 
	}

		function investInPool() external payable {
	    require(msg.sender != owner, "Owner can not Invest");
	    require(msg.value > 0, "Must be greater than zero");
	    if(balances[msg.sender] == 0){
	        users.push(payable(msg.sender));
	        balances[msg.sender] = msg.value;
	    }
	    else{
	        balances[msg.sender]+=msg.value;
	    }
	    lastLockPeriod[msg.sender] = block.number + coolDownPeriod;
	    totalRaisedAmount+=msg.value;
	}

	//Do not use it for online transactions
	function random() internal view returns(uint){
		return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, users.length))) ;
	}
	
	function getBalance() public view returns(uint){
	    return address(this).balance;
	}
	
	
	 // need to work only after pool ends
    // currently withdraw whole money from pool
    function withdraw() public{
        require(block.number >= poolEnd, "Pool has not ended, try withdrawEarly option");
        require(balances[msg.sender] > 0,"No Balance");
        // require(balances[msg.sender] >= _amount, "amount greater than balance");
        uint totalBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(totalBalance);
    }

	function calculateEarlyExitFee() public view returns(uint){
	   uint remaningTimeToUnlock = lastLockPeriod[msg.sender] - poolEnd;
	   uint balance = balances[msg.sender];
	   uint earlyFee = (balance * remaningTimeToUnlock) / 100;
	   return earlyFee;
	}

	function withdrawEarly() public{
	    require(block.number < poolEnd);
	    uint exitFee = calculateEarlyExitFee();
	    uint remaningAmount = balances[msg.sender] - exitFee;
	    balances[msg.sender] = 0;
	    earlyExitTotalSupply+=exitFee;
	    payable(msg.sender).transfer(remaningAmount);
	}



	function pickWinner() public onlyOwner{
		require(msg.sender == owner, "You are not owner");
		uint randomNumber = random();
		address payable winner;
		uint idx = randomNumber % users.length;
		winner = users[idx];
		uint winnerPrice = 1 ether;
		winner.transfer(winnerPrice);
		revertPoolMoney();
	}
	
	function resetLottery() internal {
	    users = new address payable[](0);
	    totalRaisedAmount = 0;
	}
	
	
	
	function RenounceOwnership(address _newOwner) public onlyOwner{
	    owner = _newOwner;
	}       


    function getTimeLeft() public view returns(uint){
        return (remaningTime - block.timestamp);
    }
    

    
    function revertPoolMoney() internal  onlyOwner{
        for(uint i=0;i<users.length;i++){
                users[i].transfer(balances[users[i]]);
                balances[users[i]] = 0;
                emit Transaction(users[i], balances[users[i]]);
        }
        resetLottery();
        
    }
    
	
	function getTokenBalance(address _userAddr) public view returns(uint){
	    if(balances[_userAddr] == 0){
	        return 0;
	    }
	    return balances[_userAddr];
	}
	
	    
}



//will deploy Pool contract (as each pool has a different owner who deployed it)
contract DeployLotteryContract{
	//need to has a mapping which store who deploy a new Pool Contract
	// mapping(address => instanceof(PoolContract))

}


