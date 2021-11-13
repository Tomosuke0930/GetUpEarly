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
        bytes32 name;
        uint256 amount;
        uint256  wokeUpTime;
        string joinProject;
        bool canGetUpEarly;
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
        uint256 deadlineTime;
    }

    Project[] public projects;
    mapping(address => uint256) balances;
    mapping(address => User) public users;
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
                set: true
            });
    }

    function joinProject(uint256 choicedProjectId) external returns (bool) {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[choicedProjectId];
        require(
            user.amount > project.joinFee, 
            "Your amount is less than the join fee of this project."
        );
        gupToken.transferFrom(msg.sender, address(this), project.joinFee);

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


}