// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnSendETH {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya owner");
        _;
    }

    // Terima ETH
    function deposit() public payable{}

    // transfer ETH
    function sendReward(address _to) public onlyOwner {
        (bool success, ) = _to.call{value: 0.001 ether}("");
        require(success, "Transfer gagal");
    }

    // Cek saldo
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}