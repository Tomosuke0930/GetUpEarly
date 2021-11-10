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
        uint256 id;
        bytes32 name;
        uint256 amount;
        address lockedAddress; //①とこれによって、locked
        bool join;
        bool set; // This boolean is used to differentiate between unset and zero struct values
    }
    mapping(address => uint256) balances;
    mapping(address => User) public users;
    mapping(address => uint256) lockedBalances; // ①
    mapping(address => mapping(address => uint256)) private _allowances; 

    constructor (address _gupToken){
        gupToken = IERC20(_gupToken);
    }


    function createUser(address _userAddress,uint256 _userId, bytes32 _userName, uint256 _userAmount) public {
            User storage user = users[_userAddress];
            require(!user.set); 
            balances[msg.sender] += 100; //作成したユーザーに100tokenあげる
            users[_userAddress] = User({
                id: _userId,
                name: _userName,
                amount: _userAmount,
                lockedAddress: msg.sender, //ここはどのようにアドレスを作成したらいいんだろうか？？
                join: false,
                set: true
            });
    }

    //参加するときに押してもらう関数
    function toggleJoined() public {
        User storage user = users[msg.sender];
        user.join = !user.join;
        
    }

    //参加をキャンセルする際の関数

    //名前を入れてもらえたら出席かどうかわかる
    function check() public view returns (bool){
        User storage user = users[msg.sender];
        return (user.join);
    }

    //参加する人が自分のロックアドレスに対してお金を送る！
    // joinがtrueであればいい！！！
    // 今のところキャンセルはできないです！にしておく。
    // 
    function payJoinFee(uint256 amount) public returns (bool) {
        User storage user = users[msg.sender];
        require((user.join)=!false);
        
        //gupToken.safeTransferFrom(joinUser, user.lockedAddress, amount);
        // ここのsafe.TransferFromの時点でtransferFromが完成している！！！  
        gupToken.transferFrom(msg.sender, user.lockedAddress, amount);
        return true;
    }
}