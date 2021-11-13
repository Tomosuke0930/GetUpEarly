// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';


contract GUPToken is ERC20,Ownable {
    //initialSupplyに発行量を記入してtokenを発行
    constructor(uint256 initialSupply) ERC20("GetUpEarly", "GUP") {
        _mint(msg.sender, initialSupply);
    }
    
}

contract UserContract{

    IERC20 public gupToken;

    struct User {
        // uint256 id;
        bytes32 name;
        uint256 amount;
        uint256  wokeUpTime;
        string joinProject;
        bool canGetUpEarly;
        bool joined;
        uint256 claimingNumber; //ユーザーが他のユーザーにclaimした回数
        uint256 claimedNumber; //他のユーザーが自分にclaimした回数
        bool set; // This boolean is used to differentiate between unset and zero struct values
    }

    struct Project {
        uint startDay;
        uint finishDay;
        string name;
        bytes32 host;
        uint joinFee;
        uint penaltyFee;
        uint256 id;
        uint256 partipantsNumber;
        uint256 deadlineTime;
    }

    Project[] public projects;
    mapping(address => uint256) balances;
    mapping(address => User) public users;
    mapping(uint256 => User) public selectedUsers;
    mapping(uint256 => Project) public selectedProject;
    //mapping(string => Project) private projects;
    mapping(address => mapping(address => uint256)) private _allowances; 


    constructor (address _gupToken){
        gupToken = IERC20(_gupToken);
    }


    function createUser(bytes32 _userName) public {
            User storage user = users[msg.sender];
            require(!user.set); 
            balances[msg.sender] += 100;
            users[msg.sender] = User({
                name: _userName,
                amount: 0,
                wokeUpTime: 0,
                joinProject: "",
                canGetUpEarly: true,
                claimingNumber: 0,
                claimedNumber: 0,
                set: true,
                joined: false
            });
    }

    function joinProject(uint256 selectedProjectId) external returns (bool) {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        require (user.joined = false);
        require(
            user.amount > project.joinFee, 
            "Your amount is less than the join fee of this project."
        );
        gupToken.transferFrom(msg.sender, address(this), project.joinFee);
        project.partipantsNumber ++;
        user.joined = !user.joined;
        return true;
    }

    function createProject(
        uint _startDay, 
        uint _finishDay, 
        string memory _name,
        uint _joinFee,
        uint _penaltyFee,
        uint _deadlineTime
        ) public {
        User storage user = users[msg.sender];
        Project memory pro;

        pro.name = _name;
        pro.host = user.name;
        pro.joinFee = _joinFee;
        pro.id = projects.length; // projectのidはその長さによって決まる。
        pro.startDay = _startDay;
        pro.finishDay = _finishDay;
        pro.penaltyFee = _penaltyFee;
        pro.deadlineTime = _deadlineTime;

        projects.push(pro);
    }

    function claimForFinishProject(uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        require(block.timestamp > project.finishDay);
        require (keccak256(abi.encodePacked((user.joinProject))) 
        == keccak256(abi.encodePacked((project.name))));

        uint256 canGetAmountOneClaim = project.penaltyFee /project.partipantsNumber;
        uint256 canClaimAmount
              = project.joinFee
              + user.claimingNumber *canGetAmountOneClaim
              - user.claimedNumber * canGetAmountOneClaim ;
        gupToken.transferFrom(msg.sender, address(this), canClaimAmount);

        user.claimedNumber = 0;
        user.claimingNumber = 0;
        user.joined = !user.joined;
        user.joinProject = "";
    }
}