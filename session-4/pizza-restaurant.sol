// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./pizza-coin.sol";
import "./base-contract.sol";

contract PizzaRestaurant is BaseContract {

    ERC20Basic private token;

    constructor() {
        token = new ERC20Basic(10000);
        owner = payable(msg.sender);
    }

    // --------------------------------- GESTION DE TOKENS ---------------------------------

    function tokensPrice(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);
    }

    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function buyTokens(uint _numTokens) external payable {
        uint cost = tokensPrice(_numTokens);
        require(msg.value >= cost, "Compra menos tokens o paga mas ethers");
        uint returnValue = msg.value - cost;
        payable(msg.sender).transfer(returnValue);
        uint balance = balanceOf();
        require(balance >= _numTokens, "Compra menos tokens");
        token.transfer(msg.sender, _numTokens);
    }

    function getMyTokens() external view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    function increaseTokens(uint _numTokens) external onlyOwner {
        token.increaseTotalSupply(_numTokens);
    }

    // ------------------------------------------------------------------

    struct Pizza {
        string name;
        string code;
        uint8 price;
    }

    struct Order {
        bytes32 id;
        string[] pizzaCodes;
        uint16 total;
        uint date;
    }

    mapping(string => Pizza) public pizzasMap;
    mapping(address => Order) public ordersMap;

    function addPizzas(string memory _name, string memory _code, uint8 _price) public onlyOwner {
        Pizza memory newPizza = Pizza(_name, _code, _price);
        pizzasMap[_code] = newPizza;
    }

    function getPizzaByCode(string memory _code) public view returns(Pizza memory) {
        return pizzasMap[_code];
    }

    function addOrder(string[] memory _codes) external {
        uint16 total = 0;
        for (uint i = 0; i < _codes.length; i++) {
            string memory code = _codes[i];
            Pizza memory pizza = pizzasMap[code];
            total += pizza.price;
        }
        uint balance = token.balanceOf(msg.sender);
        require(balance >= total, "Incorrect amount");
        bytes32 orderId = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        Order memory newOrder = Order(orderId, _codes, total, block.timestamp);
        ordersMap[msg.sender] = newOrder;
        token.transferToOwner(msg.sender, total);
    }
}