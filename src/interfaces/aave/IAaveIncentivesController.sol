// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

interface IAaveIncentivesController {
    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to,
        address reward
    ) external returns (uint256);

    function claimAllRewardsToSelf(
        address[] calldata assets
    )
        external
        returns (address[] memory rewardsList, uint256[] memory claimedAmounts);

    function getUserAccruedRewards(
        address user,
        address reward
    ) external returns (uint256);
}
