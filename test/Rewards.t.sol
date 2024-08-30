// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/interfaces/aave/IAaveIncentivesController.sol";

contract LendingManagerTest is Test {
    IAaveIncentivesController public aaveController;
    IERC20 private rewardTokenOfAAVE;
    address private AAVE_USER = vm.envAddress("AAVE_USER");

    function setUp() public {
        // Create a fork of the mainnet at block number 20546855
        vm.createSelectFork(
            "https://eth-mainnet.g.alchemy.com/v2/9-2O3J1H0d0Z-xDdDwZHHCBM2mwzVMwT",
            20546845
        );

        rewardTokenOfAAVE = IERC20(0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da);
        aaveController = IAaveIncentivesController(
            0x8164Cc65827dcFe994AB23944CBC90e0aa80bFcb
        );

        console.log("Forked mainnet at block 20546855");
    }

    function testClaimReward() public {
        console.log("Starting claimReward test...");
        address[] memory assets = new address[](1);
        assets[0] = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da;
        uint256 amount = 1691231209186197942; // Just for check passing small amount for claim
        address reward = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da;
        address to = AAVE_USER;

        console.log(
            "Before claim, token balance of user:",
            rewardTokenOfAAVE.balanceOf(AAVE_USER)
        );

        vm.startPrank(AAVE_USER);
        uint256 rewardsBefore = aaveController.getUserAccruedRewards(
            AAVE_USER,
            reward
        );
        console.log("before", rewardsBefore);
        uint accruedRewards = aaveController.claimRewards(
            assets,
            amount,
            to,
            reward
        );
        
        // aaveController.claimAllRewardsToSelf(
        //     assets
        // );

        uint256 rewardsAfter = aaveController.getUserAccruedRewards(
            AAVE_USER,
            reward
        );
        console.log("after", rewardsAfter);
        vm.stopPrank();

        console.log(
            "After claim, token balance of user:",
            rewardTokenOfAAVE.balanceOf(AAVE_USER)
        );
        // assertGt(accruedRewards, 0, "User should have accrued rewards.");
    }
}
