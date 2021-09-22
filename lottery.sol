//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract PoolContract{
	address owner;

	mapping(address => uint) balances;

    address payable[] public users;

	uint public noOfWinners;

    uint public totalRaisedAmount;

	uint public remaningTime;


    event Transaction(address userAddr, uint256 amount);

	constructor(){
		noOfWinners = 1;
		owner = msg.sender;
		remaningTime = block.timestamp + 3600;

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
	    totalRaisedAmount+=msg.value;
	}

	//Do not use it for online transactions
	function random() internal view returns(uint){
		return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, users.length))) ;
	}

	function getBalance() public view returns(uint){
	    return address(this).balance;
	}


// hey Ishaan here is writting fucntion defination for function to calculate interest for a particular account on daily basis
// we have to inplement a schedular for it ,but was not possible so we have add the schedular on javaScript side to call this function on fixed time interval
function interestCalculator(address _depositer,uint _rate)public  onlyOwner{

}
// if user tries to withdraw money before the pool gets matured he has to pay some panalty money
// we charge the panalty on the amount he withdraw
// panalty calculator implementation
function panalty_Cal(address _depositer,uint _amount ,uint rate_panalty) public return(uint){
  
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
