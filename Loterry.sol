// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address public manager;
    address[] public players;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function reset() private {
        players = new address[](0);
    }

    function enter() public payable {
        require(msg.value > 1 ether);
        players.push(msg.sender);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view restricted returns (address[] memory) {
        return players;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players))) % players.length;
    }

    function pickWinner() public restricted {
        uint index = random();
        payable(players[index]).transfer(getBalance());
        reset();
    }
}