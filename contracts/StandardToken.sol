// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    modifier validAddress(address to) {
        require(to != address(0), "Invalid address: zero address");
        _;
    }

    modifier hasEnoughBalance(address from, uint256 value) {
        require(balances[from] >= value, "Insufficient balance");
        _;
    }

    function transfer(address _to, uint256 _value) public validAddress(_to) hasEnoughBalance(msg.sender, _value) returns (bool) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

