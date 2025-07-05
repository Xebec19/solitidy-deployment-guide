pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    address public manager;
    uint public minimumContribution;
    Request[] public requests;
    mapping(address => bool) public approvers;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers[msg.sender] = true;
    }

    function createRequest(
        string description,
        uint value,
        address recipient
    ) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approvalCount > (address(this).balance / 2));

        request.recipient.transfer(request.value);
        request.complete = true;
    }
    function getSummary()
        public
        view
        returns (uint, uint, uint, uint, address)
    {
        return (
            minimumContribution,
            this.balance,
            requests.length,
            requests.length - getIncompleteRequestsCount(),
            manager
        );
    }
    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
    function getIncompleteRequestsCount() public view returns (uint count) {
        for (uint i = 0; i < requests.length; i++) {
            if (!requests[i].complete) {
                count++;
            }
        }
        return count;
    }
    function getApproversCount() public view returns (uint count) {
        for (uint i = 0; i < requests.length; i++) {
            if (approvers[requests[i].recipient]) {
                count++;
            }
        }
        return count;
    }
    function getRequest(
        uint index
    )
        public
        view
        returns (
            string description,
            uint value,
            address recipient,
            bool complete,
            uint approvalCount
        )
    {
        Request storage request = requests[index];
        return (
            request.description,
            request.value,
            request.recipient,
            request.complete,
            request.approvalCount
        );
    }
    function getApprovers() public view returns (address[]) {
        address[] memory approverList = new address[](getApproversCount());
        uint count = 0;
        for (uint i = 0; i < requests.length; i++) {
            if (approvers[requests[i].recipient]) {
                approverList[count] = requests[i].recipient;
                count++;
            }
        }
        return approverList;
    }
    function getManager() public view returns (address) {
        return manager;
    }
    function getMinimumContribution() public view returns (uint) {
        return minimumContribution;
    }
    function getBalance() public view returns (uint) {
        return this.balance;
    }
    function getDeployedCampaigns() public view returns (address[]) {
        CampaignFactory factory = CampaignFactory(msg.sender);
        return factory.getDeployedCampaigns();
    }
    function getCampaignsCount() public view returns (uint) {
        CampaignFactory factory = CampaignFactory(msg.sender);
        return factory.getCampaignsCount();
    }
    function getCampaign(uint index) public view returns (address) {
        CampaignFactory factory = CampaignFactory(msg.sender);
        return factory.getDeployedCampaigns()[index];
    }
    function getRequests() public view returns (Request[]) {
        return requests;
    }
    function getRequestByIndex(uint index) public view returns (Request) {
        require(index < requests.length);
        return requests[index];
    }
    function getRequestCount() public view returns (uint) {
        return requests.length;
    }
    function getApproversList() public view returns (address[]) {
        address[] memory approverList = new address[](getApproversCount());
        uint count = 0;
        for (uint i = 0; i < requests.length; i++) {
            if (approvers[requests[i].recipient]) {
                approverList[count] = requests[i].recipient;
                count++;
            }
        }
        return approverList;
    }
}
