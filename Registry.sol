// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Registry {
    struct Property {
        address owner;
        uint value;
    }

    struct SaleRequest {
        uint amount;
        address sender;
        bool approved;
    }

    Property public property;
    SaleRequest saleRequest;

    constructor(uint value) {
        property = Property({
            owner: msg.sender,
            value: value
        });
    }

    modifier restricted() {
        require(msg.sender == property.owner);
        _;
    }

    function changePropertyValue(uint value) public restricted {
        property.value = value;
    }

    function createRequest(uint amount) public {
        require(msg.sender != property.owner);
        saleRequest = SaleRequest({
            sender: msg.sender,
            amount: amount,
            approved: false
        });
    }

    function getSaleRequest() public view restricted returns (SaleRequest memory) {
        return saleRequest;
    }

    function approveRequest() public restricted {
        saleRequest.approved = true;
    }

    function buy() public payable {
        require(msg.sender == saleRequest.sender);
        require(saleRequest.approved);
        require(msg.value >= property.value);
        payable(property.owner).transfer(msg.value);
        property.owner = msg.sender;
        property.value = msg.value;
        saleRequest.approved = false;
    }
}