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
    //using SafeERC20 for IERC20;

    IERC20 public gupToken;

    struct User {
        bytes32 name;
        uint256 amount;
        uint256 wokeUpTime;
        string joinProject;
        bool set; // This boolean is used to differentiate between unset and zero struct values
    }

    struct Project {
        uint startDay;
        uint finishDay;
        string name;
        bytes32 host;
        uint joinFee;
        uint penaltyFee;
    }

    Project[] public projects;
    mapping(address => uint256) balances;
    mapping(address => User) public users;
    //mapping(string => Project) public projects;
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
                set: true
            });
    }

    // //参加するときに押してもらう関数
    // function joinProjects() public {
    //     User storage user = users[msg.sender];
    //     require(user.join != true);
    //     user.join = !user.join;
        
    // }



    /* [WIP] この関数で行いたいこと
    1: user.joinProjectに参加するプロジェクトのなんらかの値を持たせたい
    2: そのプロジェクトの参加費をコントラクトアドレスに払って欲しい。
    */
    function joinProject(uint256 amount) external returns (bool) {
        User storage user = users[msg.sender];
        require(user.amount > 0, "Your amount is 0");//現状が0になっているところをproject.joinFeeにしたい！！！
        // user.joinProject = project.name; //こんな感じのことをしたい！
        gupToken.transferFrom(msg.sender, address(this), amount); //ここのamountをprojectのjoinFeeにしたい！！！

        return true;
    }

    function createProject(
        uint _startDay, 
        uint _finishDay, 
        string memory _name,
        uint _joinFee,
        uint _penaltyFee
        ) public {
        User storage user = users[msg.sender];
        Project memory pro;
        pro.startDay = _startDay;
        pro.finishDay = _finishDay;
        pro.name = _name;
        pro.host = user.name;
        pro.joinFee = _joinFee;
        pro.penaltyFee = _penaltyFee;
        // projects[_name] = Project({
        //     startDay: _startDay,
        //     finishDay: _finishDay,
        //     host: user.name,
        //     joinFee: _joinFee
        // });


        projects.push(pro);
    }
}