// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./GetUpEarly.sol";

contract DailyClaim is UserContract {


    // これも１日に一回だけを付けたい！！！
    
    function dailyClaim(address selectedUsersAddress,uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        User storage selectedUser = users[selectedUsersAddress];//ここでclaimするユーザーを決める
        Project storage project = selectedProject[selectedProjectId];

        require(user.canGetUpEarly = true);
        require(selectedUser.canGetUpEarly = false);
        require(block.timestamp > project.deadlineTime); 
        require (keccak256(abi.encodePacked((user.joinProject))) 
        == keccak256(abi.encodePacked((selectedUser.joinProject))));

        user.claimedNumber ++;
        selectedUser.claimingNumber ++;

    }
}