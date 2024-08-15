// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

interface IApproveAndCallReceiver {
    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extraData
    ) external;
}
