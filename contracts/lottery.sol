//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Lottery{

    address public immutable manager;
    address payable[] public players;

    constructor(){
        manager = msg.sender;
        resetLottery();
    }

    receive() external payable{
        require(msg.value == 0.1 ether);
        require(msg.sender != manager);
        players.push(payable(msg.sender));
    }

    fallback() external payable{
        revert();
    }

    modifier managerOnly(){
        require(msg.sender == manager);
        _;
    }

    function getBalance() public view managerOnly returns(uint){
        return address(this).balance;
    }

    /**
    picks a random winner,
    sends the balance to the winner,
    resets the lottery players board
    */ 
    function pickWinner() public managerOnly{
        require(players.length >= 3);
        
        uint rand = random() % players.length;
        address payable winner = players[rand];
        
        //calculate 10% fee for the manager and 90% winning prize
        uint managerFee = (getBalance() * 10) / 100;
        uint winnerPrize = (getBalance() * 90) / 100;

        winner.transfer(winnerPrize);
        payable(manager).transfer(managerFee);

        resetLottery();
    }

    // TODO: Improve random
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    // clears the players array
    function resetLottery() private {
        players = new address payable[](0);
    }
}