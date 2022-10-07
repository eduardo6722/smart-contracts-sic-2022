// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Factory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimumContributionValue) public {
        address campaignAddress = address(new Campaign(minimumContributionValue, msg.sender));
        deployedCampaigns.push(campaignAddress);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        uint value;
        address recipient;
        bool complete;
        uint approversCount;
        mapping(address => bool) approvals;
    }

    struct RequestView {
        uint value;
        address recipient;
        bool complete;
        uint approversCount;
    }

    address public manager;
    uint public minimumContribution;
    uint public contributorsCount;
    mapping(address => bool) public contributors;
    mapping(uint => Request) public requests;
    uint numberOfRequests;

    constructor(uint minimumContributionValue, address sender) {
        manager = sender;
        minimumContribution = minimumContributionValue;
        numberOfRequests = 0;
    }

    modifier restricted {
        require(msg.sender == manager);
        _;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        contributors[msg.sender] = true;
        contributorsCount++;
    }

    function createRequest(uint value, address recipient) public restricted {
        Request storage request = requests[numberOfRequests];
        request.value = value;
        request.recipient = recipient;
        request.complete = false;
        request.approversCount = 0;
        numberOfRequests++;
    }

    function approveRequest(uint index) public {
        require(contributors[msg.sender]);
        Request storage request = requests[index];
        request.approvals[msg.sender] = true;
        request.approversCount++;
    }

    function getRequests() public view returns (RequestView[] memory)  {
        RequestView[] memory views = new RequestView[](numberOfRequests);
        for (uint index = 0; index < numberOfRequests; index++) {
            views[index].value = requests[index].value;
            views[index].recipient = requests[index].recipient;
            views[index].complete = requests[index].complete;
            views[index].approversCount = requests[index].approversCount;
        }
        return views;
    }

    function completeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approversCount > contributorsCount / 2);
        payable(request.recipient).transfer(request.value);
        request.complete;
    }
}