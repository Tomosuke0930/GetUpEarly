// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./GUPtoken.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';


contract GetUp{    
    IERC20 public gupToken;

    //Userの構造体
    struct User {
        bytes32 name;
        uint256 amount;
        uint256  wokeUpTime; //起きた時間
        string joinProject;
        bool canGetUpEarly; //ユーザーが早起きできたかどうか
        bool joined;
        uint256 claimedNumber; // 他のユーザーが自分にclaimした回数
        bool set; //ユーザーは1アドレス1つ
        bool canHelloWorld;
    }

    //Projectの構造体
    struct Project {
        uint id;
        string name;
        bytes32 host;
        uint joinFee;
        uint duration; 
        uint penaltyFee; // 一度、寝坊した時にかかる費用
        uint finishTime; // プロジェクトの終わる時間
        uint startXDaysLater; // プロジェクトは何日後から始まるのか
        uint256 deadlineTime;// そのプロジェクトの寝坊か否かのライン
        uint256 canJoinNumber; //参加できる人数
        uint256 firstDeadlineTime;
        uint256 maxCanPenaltyNum; //寝坊できる最大の数
    }

    Project[] public projects;
    uint256 dayX; //何日経ったのか
    bool dayXbool; //X日目の真偽値
    address public owner;
    mapping(address => uint256) balances;
    mapping(address => User) public users;
    mapping(uint256 => User) public selectedUsers;
    mapping(uint256 => Project) public selectedProject;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // 異なるコントラクトで作成したtokenを使うため。
    constructor (address _gupToken){
        gupToken = IERC20(_gupToken);
        owner = msg.sender;
    }

    //ユーザーを作成する関数
    function createUser(bytes32 _userName) public {
            User storage user = users[msg.sender];
            require(!user.set); //ユーザー複製禁止のため
            balances[msg.sender] += 100; 
            console.log("I am %s",msg.sender);//これでconsole.logをnpx hardhat testで表示させたい
            users[msg.sender] = User({
                name: _userName,
                amount: 0,
                wokeUpTime: 0,
                joinProject: "",
                canGetUpEarly: true,
                claimedNumber: 0,
                set: true,
                joined: false,
                canHelloWorld: false

            });
            
    }

    // ユーザーがプロジェクトに参加するための関数
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
        require (project.canJoinNumber != project.canJoinNumber,
        "The capacity for this project has already been filled. ");
         
        gupToken.transferFrom(msg.sender, address(this), project.joinFee);
        emit Transfer(msg.sender, address(this), project.joinFee);

        project.canJoinNumber ++; //参加人数を増やす
        user.joined = !user.joined;
        return true;

    }

    // プロジェクトを作成する関数
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
        projects[projects.length] = Project({
            id: projects.length,
            name: _name,
            host: user.name,
            joinFee: _joinFee,
            duration: _duration,
            penaltyFee: _penaltyFee,
            finishTime: (block.timestamp/86400 + (_startXDaysLater + _duration)) * 1 days,
            canJoinNumber: _canJoinNumber,
            startXDaysLater: _startXDaysLater,
            deadlineTime: _deadlineTime,
            firstDeadlineTime: (block.timestamp/86400 + _startXDaysLater) * 1 days + _deadlineTime * 1 hours,
            maxCanPenaltyNum: _joinFee/_penaltyFee//小数点以下は切り捨てられる
         });
    }

    //プロジェクトが終わった際にclaimできる関数
    function claimForFinishProject(uint256 selectedProjectId) public returns (bool){
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        require(block.timestamp > project.finishTime);    
        require (keccak256(abi.encodePacked((user.joinProject))) 
        == keccak256(abi.encodePacked((project.name))));
        
        uint256 canGetAmountOneClaim = project.penaltyFee /project.canJoinNumber;
        uint256 canClaimAmount
              = project.joinFee 
              - user.claimedNumber * canGetAmountOneClaim ; //(他のユーザーがこのユーザーに対してclaimした回数)*(一度claimした際にもらえる量)
        gupToken.transferFrom(address(this), msg.sender, canClaimAmount);
        emit Transfer(address(this), msg.sender, canClaimAmount);

        user.claimedNumber = 0;
        // プロジェクトが終わるとcliamした/された回数は0になる
        user.joined = !user.joined;
        user.joinProject = "";
        return true;
    }
    
    //誰もがプロジェクトに参加している人が起きれているのかをチェックできる関数
    //起きれていない場合はチェックしたユーザーに報酬が入る
    function checkGetUp(uint256 selectedProjectId,address selectedUsersAddress) public {
        Project storage project = selectedProject[selectedProjectId];
        User storage selectedUser = users[selectedUsersAddress];//ここでclaimするユーザーを決める
        dayX = (block.timestamp - project.firstDeadlineTime)/86400;
        //最初のプロジェクトの締め切り時間から何日経ったのか。小数点以下は切り捨てられるため整数になる。
        for(uint i = 0;i < dayX - 1; i++ ) {
            !dayXbool; //初日は初期値がfalseのため起きれない人はfalseのまま
        }

        require(block.timestamp > dayX * 1 days + project.firstDeadlineTime); //時間は過ぎているのか
        require(selectedUser.canGetUpEarly != dayXbool);//初日はfalseの人が対象になる。
        balances[msg.sender] += project.penaltyFee * 3/4; // 1/4は運営に入る。
        !selectedUser.canGetUpEarly;//再発防止
        !selectedUser.canHelloWorld;//再発防止
        selectedUser.claimedNumber ++;

    }

    //ユーザーが起きたことを証明する関数
    function TodaysHelloWorld(uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        dayX = (block.timestamp - project.firstDeadlineTime)/86400;
        
        for(uint i = 0;i < dayX - 1; i++ ) {
            !dayXbool; //初日は初期値がfalseのため起きれない人はfalseのまま
        }
        require(block.timestamp >= dayX * 1 days + project.firstDeadlineTime - 3600);//締め切り時間の1時間前
        require(block.timestamp <= dayX * 1 days + project.firstDeadlineTime);//締め切りの時間
        require(user.canHelloWorld = dayXbool,"You are already done TodaysHelloWorld");

        if(user.wokeUpTime < project.firstDeadlineTime) {
            //ユーザーは一度しかできないようにしないといけない。
            !user.canGetUpEarly;//初日はfalse→true.
            !user.canHelloWorld;
        }
    }
}