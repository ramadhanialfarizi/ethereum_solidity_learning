// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MintableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;


    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    modifier validApproveAddress(address spender) {
        require(spender != address(0), "Invalid approve address: zero address");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
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

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public validApproveAddress(_spender) returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

     function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _value, "Insufficient allowance");
        require(_to != address(0), "Cannot transfer to zero address");

        balances[_from] -= _value;
        balances[_to] += _value;

        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function mint(address _to, uint256 _value) public onlyOwner {
        require(_to != address(0), "Cannot mint to zero address");
        balances[_to] += _value;
        totalSupply += _value;

        emit Transfer(address(0), _to, _value);
    }

    function burn(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance to burn");
        balances[msg.sender] -= _amount;

        totalSupply -= _amount;

        emit Transfer(msg.sender, address(0), _amount);
    }

}

