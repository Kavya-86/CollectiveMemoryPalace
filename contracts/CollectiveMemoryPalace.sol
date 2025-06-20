// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CollectiveMemoryPalace {
    struct MemoryNode {
        uint256 id;
        string title;
        string content;
        string category;
        address contributor;
        uint256 timestamp;
        uint256 upvotes;
        uint256 downvotes;
        bool isVerified;
    }
    
    struct Contributor {
        address addr;
        uint256 reputation;
        uint256 totalContributions;
        uint256 tokensEarned;
        bool isActive;
    }
    
    mapping(uint256 => MemoryNode) public memoryNodes;
    mapping(address => Contributor) public contributors;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(string => uint256[]) public categorizedNodes;
    
    uint256 public nextNodeId;
    uint256 public totalNodes;
    uint256 public constant CONTRIBUTION_REWARD = 10;
    uint256 public constant VERIFICATION_THRESHOLD = 5;
    
    event MemoryNodeCreated(uint256 indexed nodeId, address indexed contributor, string title);
    event NodeVoted(uint256 indexed nodeId, address indexed voter, bool isUpvote);
    event NodeVerified(uint256 indexed nodeId);
    event ReputationUpdated(address indexed contributor, uint256 newReputation);
    
    modifier onlyActiveContributor() {
        require(contributors[msg.sender].isActive, "Not an active contributor");
        _;
    }
    
    modifier nodeExists(uint256 _nodeId) {
        require(_nodeId < nextNodeId, "Node does not exist");
        _;
    }
    
    function contributeMemory(
        string memory _title,
        string memory _content,
        string memory _category
    ) external {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_content).length > 0, "Content cannot be empty");
        
        // Initialize contributor if new
        if (!contributors[msg.sender].isActive) {
            contributors[msg.sender] = Contributor({
                addr: msg.sender,
                reputation: 0,
                totalContributions: 0,
                tokensEarned: 0,
                isActive: true
            });
        }
        
        // Create new memory node
        memoryNodes[nextNodeId] = MemoryNode({
            id: nextNodeId,
            title: _title,
            content: _content,
            category: _category,
            contributor: msg.sender,
            timestamp: block.timestamp,
            upvotes: 0,
            downvotes: 0,
            isVerified: false
        });
        
        // Update categorized nodes
        categorizedNodes[_category].push(nextNodeId);
        
        // Update contributor stats
        contributors[msg.sender].totalContributions++;
        contributors[msg.sender].tokensEarned += CONTRIBUTION_REWARD;
        
        emit MemoryNodeCreated(nextNodeId, msg.sender, _title);
        
        nextNodeId++;
        totalNodes++;
    }
    
    function voteOnMemory(uint256 _nodeId, bool _isUpvote) 
        external 
        nodeExists(_nodeId)
        onlyActiveContributor 
    {
        require(!hasVoted[_nodeId][msg.sender], "Already voted on this node");
        
        hasVoted[_nodeId][msg.sender] = true;
        
        if (_isUpvote) {
            memoryNodes[_nodeId].upvotes++;
        } else {
            memoryNodes[_nodeId].downvotes++;
        }
        
        // Check if node should be verified
        if (memoryNodes[_nodeId].upvotes >= VERIFICATION_THRESHOLD && 
            !memoryNodes[_nodeId].isVerified) {
            memoryNodes[_nodeId].isVerified = true;
            
            // Reward the original contributor
            address originalContributor = memoryNodes[_nodeId].contributor;
            contributors[originalContributor].reputation += 5;
            contributors[originalContributor].tokensEarned += CONTRIBUTION_REWARD * 2;
            
            emit NodeVerified(_nodeId);
            emit ReputationUpdated(originalContributor, contributors[originalContributor].reputation);
        }
        
        emit NodeVoted(_nodeId, msg.sender, _isUpvote);
    }
    
    function searchMemoriesByCategory(string memory _category) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return categorizedNodes[_category];
    }
    
    function getMemoryNode(uint256 _nodeId) 
        external 
        view 
        nodeExists(_nodeId)
        returns (
            string memory title,
            string memory content,
            string memory category,
            address contributor,
            uint256 timestamp,
            uint256 upvotes,
            uint256 downvotes,
            bool isVerified
        ) 
    {
        MemoryNode memory node = memoryNodes[_nodeId];
        return (
            node.title,
            node.content,
            node.category,
            node.contributor,
            node.timestamp,
            node.upvotes,
            node.downvotes,
            node.isVerified
        );
    }
    
    function getContributorStats(address _contributor) 
        external 
        view 
        returns (
            uint256 reputation,
            uint256 totalContributions,
            uint256 tokensEarned,
            bool isActive
        ) 
    {
        Contributor memory contributor = contributors[_contributor];
        return (
            contributor.reputation,
            contributor.totalContributions,
            contributor.tokensEarned,
            contributor.isActive
        );
    }
}
