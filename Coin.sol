// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Coin {
    address public minter;
    uint balance;
    mapping(address => uint) public balances;

    modifier restricted() {
        require(msg.sender == minter);
        _;
    }

    constructor(uint amount) {
        balance = amount;
        minter = msg.sender;
    }

    function sendMoney(address person, uint amount) public restricted {
        require(balance > amount);
        balances[person] += amount;
        balance -= amount;  
    }

    function getBalance() public view restricted returns (uint) {
        return balance;
    }

    function getMyBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function addPerson(address value) public restricted {
        balances[value] = 0;
    }

    function transfer(address to, uint amount) public {
        require(balances[msg.sender] > amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
