pragma solidity ^0.5.0;

import './RWD.sol';
import './Tether.sol';

contract DecentralBank {
    string public name = "Decentral Bank";
    address public owner;

    Tether public tether;
    RWD public rwd;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(RWD _rwd, Tether _tether) public {
        rwd = _rwd;
        tether = _tether;
        owner = msg.sender;
    }

    function depositTokens(uint _amount) public {
        //requiring staking amount to be more than 0
        require(_amount>0, 'amount cannot be 0');

        //transfer tether tokens to this address for staking
        tether.transferFrom(msg.sender, address(this), _amount);

        //update staking balance
        stakingBalance[msg.sender] += _amount;

        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //Update staking balance
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    //issue rewards
    function issueTokens() public {
        require(msg.sender == owner, 'caller must be the owner');

        for(uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient] / 9;
            
            if(balance > 0) rwd.transfer(recipient, balance);
        }
    }

    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];

        //require the amount to be greater than zero
        require(balance > 0, 'staking balance could not be less than zero when unstaking');

        //transfer the tokens to the specified contract address from our bank
        tether.transfer(msg.sender, balance);

        //reset staking balance
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;


    }

}