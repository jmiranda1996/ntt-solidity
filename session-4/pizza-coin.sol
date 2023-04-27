// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./safe-math.sol";
import "./base-contract.sol";

contract ERC20Basic is BaseContract {

    string public constant name = "PizzaCoin";
    string public constant symbol = "PZC";
    uint8 public constant decimals = 18;
    
    using SafeMath for uint256;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint256 totalSupply_;
    
    constructor(uint256 initialSupply) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
        owner = msg.sender;
    }
    
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }
    
    function increaseTotalSupply(uint amount) public {
        totalSupply_ += amount;
        balances[msg.sender] += amount;
    }
    
    function balanceOf(address account) public view returns(uint256) {
        return balances[account];
    }
    
    function allowance(address owner, address spender) external view returns(uint256) {
        return allowed[owner][spender];
    }
    
    function transfer(address recipient, uint256 amount) public returns(bool) {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        
        return true;
    }
    
    function approve(address spender, uint256 amount) public returns(bool) {
        allowed[msg.sender][spender] = amount;
        
        return true;
    }
    
    function transferFrom(address sender, address recepient, uint256 amount) public returns(bool) {
        require(amount <= balances[sender]);
        require(amount <= allowed[sender][msg.sender]);
        
        balances[sender] = balances[sender].sub(amount);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(amount);
        balances[recepient] = balances[recepient].add(amount);
        
        return true;
    }

    function transferToOwner(address sender, uint256 amount) public onlyOwner {
        require(amount <= balances[sender]);

        balances[sender] = balances[sender].sub(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
    }
}