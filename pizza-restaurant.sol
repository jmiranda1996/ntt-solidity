// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract PizzaRestaurant {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

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

    // memory - storage
    function addPizzas(string memory _name, string memory _code, uint8 _price) public onlyOwner {
        Pizza memory newPizza = Pizza(_name, _code, _price);
        pizzasMap[_code] = newPizza;
    }

    function getPizzaByCode(string memory _code) public view returns(Pizza memory) {
        return pizzasMap[_code];
    }

    function addOrder(string[] memory _codes) external payable {
        uint16 total = 0;
        for (uint i = 0; i < _codes.length; i++) {
            string memory code = _codes[i];
            Pizza memory pizza = pizzasMap[code];
            total += pizza.price;
        }
        require(msg.value == total, "Incorrect amount");
        bytes32 orderId = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        Order memory newOrder = Order(orderId, _codes, total, block.timestamp);
        ordersMap[msg.sender] = newOrder;
    }
}
