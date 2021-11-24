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
        uint256 firstDeadlineTime;
    }

    Project[] public projects;
    bool dayXbool;
    uint256 dayX;
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
        pro.deadlineTime = _deadlineTime; // ここでは7:30の場合は7.5とする！！！そう記入してもらう！
        pro.maxCanPenaltyNumber = pro.joinFee/pro.penaltyFee; 
        pro.canJoinNumber = _canJoinNumber;
        pro.finishTime = block.timestamp + (pro.startXDaysLater + pro.duration) * 1 days;
        pro.firstDeadlineTime 
        = block.timestamp/86400 + pro.startXDaysLater * 1 days + pro.deadlineTime * 1 hours;

        // block.timestampを86400で割り小数点以下を切り捨てると
        // 実行した日の00:00:00のタイムスタンプがわかる


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
              - user.claimedNumber * canGetAmountOneClaim ; //(他のユーザーがこのユーザーに対してclaimした回数)*(一度claimした際にもらえる量)
        gupToken.transferFrom(address(this), msg.sender, canClaimAmount);
        emit Transfer(address(this), msg.sender, canClaimAmount);

        user.claimedNumber = 0;
        // プロジェクトが終わるとcliamした/された回数は0になる
        user.joined = !user.joined;
        user.joinProject = "";
        return true;
    }
    
    function checkGetUpEarly(uint256 selectedProjectId,address selectedUsersAddress) public {
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
        selectedUser.claimedNumber ++;

    }

    function TodaysHelloWorld(uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        dayX = (block.timestamp - project.firstDeadlineTime)/86400;

        require(block.timestamp >= dayX * 1 days + project.firstDeadlineTime - 3600);//締め切り時間の1時間前
        require(block.timestamp <= dayX * 1 days + project.firstDeadlineTime);//締め切りの時間

        if(user.wokeUpTime < project.firstDeadlineTime) {
            user.canGetUpEarly = !user.canGetUpEarly;//初日はfalse→true.
        }
    }
}