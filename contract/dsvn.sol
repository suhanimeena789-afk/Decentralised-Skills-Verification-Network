
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Decentralized Skill Verification Network
 * @dev Smart contract for verifiable skill badges and professional reputation
 */
contract DecentralizedSkillVerificationNetwork {
    
    struct SkillBadge {
        string skillName;
        address employer;
        uint256 timestamp;
        string evidenceURI;
        bool isVerified;
    }
    
    struct WorkerProfile {
        address walletAddress;
        string profileURI;
        uint256 totalBadges;
        uint256 reputationScore;
    }
    
    // Mappings
    mapping(address => WorkerProfile) public workers;
    mapping(address => SkillBadge[]) public workerBadges;
    mapping(address => bool) public verifiedEmployers;
    
    // Events
    event BadgeIssued(address indexed worker, address indexed employer, string skillName);
    event BadgeVerified(address indexed worker, uint256 badgeIndex);
    event EmployerRegistered(address indexed employer);
    event ReputationUpdated(address indexed worker, uint256 newScore);
    
    // Modifiers
    modifier onlyVerifiedEmployer() {
        require(verifiedEmployers[msg.sender], "Only verified employers can issue badges");
        _;
    }
    
    /**
     * @dev Register as a verified employer (in production, this would require governance/KYC)
     */
    function registerAsEmployer() external {
        require(!verifiedEmployers[msg.sender], "Already registered as employer");
        verifiedEmployers[msg.sender] = true;
        emit EmployerRegistered(msg.sender);
    }
    
    /**
     * @dev Issue a skill badge to a worker
     * @param worker Address of the worker receiving the badge
     * @param skillName Name of the skill (e.g., "Smart Contract Development", "UI/UX Design")
     * @param evidenceURI IPFS link to evidence (project completion proof, portfolio link, etc.)
     */
    function issueBadge(
        address worker,
        string memory skillName,
        string memory evidenceURI
    ) external onlyVerifiedEmployer {
        require(worker != address(0), "Invalid worker address");
        require(bytes(skillName).length > 0, "Skill name cannot be empty");
        
        // Create new badge
        SkillBadge memory newBadge = SkillBadge({
            skillName: skillName,
            employer: msg.sender,
            timestamp: block.timestamp,
            evidenceURI: evidenceURI,
            isVerified: true
        });
        
        // Add badge to worker's collection
        workerBadges[worker].push(newBadge);
        
        // Update or create worker profile
        if (workers[worker].walletAddress == address(0)) {
            workers[worker] = WorkerProfile({
                walletAddress: worker,
                profileURI: "",
                totalBadges: 1,
                reputationScore: 100
            });
        } else {
            workers[worker].totalBadges++;
            workers[worker].reputationScore += 100;
        }
        
        emit BadgeIssued(worker, msg.sender, skillName);
        emit ReputationUpdated(worker, workers[worker].reputationScore);
    }
    
    /**
     * @dev Get all badges for a specific worker
     * @param worker Address of the worker
     * @return Array of all skill badges for the worker
     */
    function getWorkerBadges(address worker) external view returns (SkillBadge[] memory) {
        return workerBadges[worker];
    }
    
    /**
     * @dev Get worker's reputation score and profile
     * @param worker Address of the worker
     * @return profile Worker's complete profile information
     */
    function getWorkerProfile(address worker) external view returns (WorkerProfile memory) {
        return workers[worker];
    }
    
    /**
     * @dev Check if an address is a verified employer
     * @param employer Address to check
     * @return bool indicating if the address is a verified employer
     */
    function isEmployerVerified(address employer) external view returns (bool) {
        return verifiedEmployers[employer];
    }
}
