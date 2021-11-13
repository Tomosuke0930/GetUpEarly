// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// GetUpEarly.solをimportする方法を調べよう！
import "./GetUpEarly.sol";

contract HelloWorld is UserContract {

    // 一日に一度しか押せない関数
    // その押した時間をストレージに書き込む
    // その時間をuser.wokeUpTimeとする
    // この関数の目的：ユーザーの起きた時間がdeadline よりどうかどうか。
    // 1
    function TodaysHelloWorld(uint256 selectedProjectId) public {
        User storage user = users[msg.sender];
        Project storage project = selectedProject[selectedProjectId];
        user.wokeUpTime = block.timestamp;

        // wokeUpTime とdeadlineTimeを比べられるのかな？
        // ただこれだとユーザーが起きない限りはそのユーザーの状態はtrueのままでclaimできない。
        //　元々はtrueだけどdeadlineを過ぎてもuserがHelloWorldしなければclaimできるにしないとね！
        // →deadlineになったら発動ってなんだろう？また0時を過ぎたらユーザーの
        if(user.wokeUpTime > project.deadlineTime) {
            user.canGetUpEarly = false;
        }
    }
}