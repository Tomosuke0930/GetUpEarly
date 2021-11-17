// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

// Tokenの作成
contract GUPToken is ERC20 {
    //initialSupplyに発行量を記入してtokenを発行
    constructor(uint256 initialSupply) ERC20("GetUpEarly", "GUP") {
        _mint(msg.sender, initialSupply);
    }
    
}

contract UserContract{    
    IERC20 public gupToken;

    // 作成するUserの構造体
    struct User {
        bytes32 name;
        uint256 amount;
        uint256  wokeUpTime; //起きた時間
        string joinProject;
        bool canGetUpEarly; //ユーザーが早起きできたかどうか
        bool joined;
        uint256 claimingNumber; // ユーザーが他のユーザーにclaimした回数
        uint256 claimedNumber; // 他のユーザーが自分にclaimした回数
        bool set; 
    }

    struct Project {
        uint finishTime; // プロジェクトの終わる時間
        uint startXDaysLater; // プロジェクトは何日後から始まるのか
        uint duration; 
        string name;
        bytes32 host;
        uint joinFee;
        uint penaltyFee; // 一度、寝坊した時にかかる費用
        uint256 id;
        uint256 maxCanPenaltyNumber; //寝坊できる最大の数
        uint256 joinNumber;//参加する人数
        uint256 canJoinNumber; //参加できる人数
        uint256 deadlineTime;// そのプロジェクトの寝坊か否かのライン
    }

    Project[] public projects;
    mapping(address => uint256) balances;
    mapping(address => User) public users;
    mapping(uint256 => User) public selectedUsers;
    mapping(uint256 => Project) public selectedProject;
    mapping(address =>mapping(address => bool)) private canClaim; 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // 異なるコントラクトで作成したtokenを使うため。
    constructor (address _gupToken){
        gupToken = IERC20(_gupToken);
    }

    
    function createUser(bytes32 _userName) public {
            User storage user = users[msg.sender];
            require(!user.set); //ユーザー複製禁止のため
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
        // 実際はいろんなプロジェクトがある中でクリックしたプロジェクトのidがselectedProjectIdになる！
        Project storage project = selectedProject[selectedProjectId];
        require (user.joined != true);
        require(
            //この書き方は違う可能性が高い。amountなんて何もなかった。
            balances[msg.sender] > project.joinFee, 
            "Your amount is less than the join fee of this project."
        ); 
        require (project.joinNumber != project.canJoinNumber,
        "The capacity for this project has already been filled. ");
         
        gupToken.transferFrom(msg.sender, address(this), project.joinFee);
        emit Transfer(msg.sender, address(this), project.joinFee);

        project.joinNumber ++; //参加人数を増やす
        user.joined = !user.joined;
        return true;
    }

    function createProject(
        uint _startXDaysLater, 
        uint _duration, 
        string memory _name,
        uint _joinFee,
        uint _penaltyFee,
        uint _deadlineTime,
        uint256 _canJoinNumber
        ) public {
        User storage user = users[msg.sender];
        Project memory pro;

        pro.name = _name;
        pro.host = user.name;
        pro.joinFee = _joinFee;
        pro.id = projects.length; // projectのidはその長さによって決まる。
        pro.startXDaysLater = _startXDaysLater;
        pro.duration = _duration;
        pro.penaltyFee = _penaltyFee;
        pro.deadlineTime = _deadlineTime;
        pro.maxCanPenaltyNumber = pro.joinFee/pro.penaltyFee; 
        pro.canJoinNumber = _canJoinNumber;
        pro.finishTime = block.timestamp + (pro.startXDaysLater + pro.duration) * 1 days;
        // こちらでプロジェクトの終了時間は = プロジェクトを作成した時間 
        // + (プロジェクトは何日後から始まるか + 何日間するのか) * 1daysとした

        require(pro.maxCanPenaltyNumber >= 1,
         "The joinFee is greater than the penaltyFee, please raise the joinFee or lower the penaltyFee.");
        projects.push(pro);
    }

    function claimForFinishProject(uint256 selectedProjectId) public returns (bool){
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        require(block.timestamp > project.finishTime);    
        require (keccak256(abi.encodePacked((user.joinProject))) 
        == keccak256(abi.encodePacked((project.name))));
        
        uint256 canGetAmountOneClaim = project.penaltyFee /project.joinNumber;
        uint256 canClaimAmount
              = project.joinFee
              + user.claimingNumber *canGetAmountOneClaim//(ユーザーが他のユーザーに対してclaimした回数)*(一度claimした際にもらえる量)
              - user.claimedNumber * canGetAmountOneClaim ; //(他のユーザーがこのユーザーに対してclaimした回数)*(一度claimした際にもらえる量)
        gupToken.transferFrom(address(this), msg.sender, canClaimAmount);
        emit Transfer(address(this), msg.sender, canClaimAmount);

        user.claimedNumber = 0;
        user.claimingNumber = 0;
        // プロジェクトが終わるとcliamした/された回数は0になる
        user.joined = !user.joined;
        user.joinProject = "";
        return true;
    }

    function dailyClaim(address selectedUsersAddress,uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        User storage selectedUser = users[selectedUsersAddress];//ここでclaimするユーザーを決める
        Project storage project = selectedProject[selectedProjectId];

        require(user.canGetUpEarly != false,"You haven't woken up yet, so please do HelloWorld.");
        require(selectedUser.canGetUpEarly != true,"The selected user is able to wake up early.");
        require(block.timestamp > project.deadlineTime,"The deadline for the project has not yet passed.");
        require(canClaim[msg.sender][selectedUsersAddress] != false, 
        "You have already made a claim for this user. You can only claim the same user once."); 
        require (keccak256(abi.encodePacked((user.joinProject))) 
        == keccak256(abi.encodePacked((selectedUser.joinProject))),
        "The project you are participating in does not match the project of the user you are selecting.");
        if(selectedUser.claimedNumber < project.maxCanPenaltyNumber) {
            user.claimingNumber ++;
            selectedUser.claimedNumber ++;
            canClaim[msg.sender][selectedUsersAddress] = false; //1日に1回にするため。
        } else {
            user.joinProject = ""; //ユーザーの参加しているプロジェクトをからにする
            project.joinNumber --; //参加者を1減らす。
            revert("The maximum number of penalties for this user has been exceeded and cannot be claimed");
        }
    }

    function TodaysHelloWorld(uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        user.wokeUpTime = block.timestamp;

        //Q1. block.timestampとdeadlineTimeの比較方法は？
        // 懸念点: block.timestamp自体の値が増え続けるなら毎日の決まった時間との比較が難しそう。。

        if(user.wokeUpTime < project.deadlineTime) {
            // userが起きた時間が参加しているプロジェクトの締め切りよりも早かったらcanGetUpEarlyはtrueになる
            // ともすけが6:00に起きた。参加しているプロジェクトの締め切りは7:00
            // ⇨この関数をともすけが6:15に実行したらcanGetUpEarlyはtrueになる！
            user.canGetUpEarly = true;
        }
    }
}