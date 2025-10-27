// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnPayable {
    uint256 public plantCounter;

    modifier onlyOwner() {
        require(msg.value >= 0.001 ether, "Perlu 0.001 ETH");
        _;
    }

    function buyPlant() public payable onlyOwner returns  (uint256)  {
        plantCounter++;
        return plantCounter;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}