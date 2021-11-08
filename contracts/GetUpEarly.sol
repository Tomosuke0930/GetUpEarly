// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract GUPToken is ERC20,Ownable {
    //initialSupplyに発行量を記入してtokenを発行
    constructor(uint256 initialSupply) ERC20("GetUpEarly", "GUE") {
        _mint(msg.sender, initialSupply);
    }
    
// }

// contract Sample is ERC20,Ownable{

//     constructor(){
//         address masterAddress;
//     }

    mapping(address => uint256) balances;
    mapping(address => User) public users;
    mapping(address => mapping(address => uint256)) private _allowances;
        
    struct User {
        uint256 id;
        bytes32 name;
        uint256 amount;
        bool join;
        bool set; // This boolean is used to differentiate between unset and zero struct values
    }

    function createUser(address _userAddress,uint256 _userId, bytes32 _userName, uint256 _userAmount) public {
            User storage user = users[_userAddress];
            require(!user.set); 
            users[_userAddress] = User({
                id: _userId,
                name: _userName,
                amount: _userAmount,
                join: false,
                set: true
            });
    }

    //参加者の参加・不参加を決める関数
    function toggleJoined() public {
        User storage user = users[msg.sender];
        user.join = !user.join;
    }

    //名前を入れてもらえたら出席かどうかわかる
    function check() public view returns (bool){
        User storage user = users[msg.sender];
        return (user.join);
    }

    //参加する人をオーナーが確認してmasterAddressに送る
    function transferFrom(
        address joinUser,
        address masterAddress,
        uint256 amount
    ) public onlyOwner virtual override returns (bool) {
        User storage user = users[msg.sender];
        require((user.join)=!false);
        _transfer(joinUser, masterAddress, amount);
        uint256 currentAllowance = _allowances[joinUser][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(joinUser, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
}

/* 
task
コイン作成
userにコインを渡す
その上でコインをロックする
*/