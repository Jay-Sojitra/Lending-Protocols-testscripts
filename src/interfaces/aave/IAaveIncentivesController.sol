// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

interface IAaveIncentivesController {
    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to,
        address reward
    ) external returns (uint256);
}
