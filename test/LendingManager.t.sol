// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

import "../src/LendingManager.sol";
import "../src/interfaces/extrafi/IStakingRewards.sol";
import "../src/interfaces/aave/IAaveIncentivesController.sol";

/**
 * @title LendingManagerTest
 * @dev Comprehensive test suite for the LendingManager contract
 * @notice This contract tests various lending protocols including AAVE, Seamless, ExtraFi, and Moonwell
 */
contract LendingManagerTest is Test {
    // Constants
    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant FIVE_DAYS_IN_SECONDS = 5 * DAY_IN_SECONDS;
    uint256 private constant USDC_DECIMALS = 6;
    uint256 private constant AMOUNT = 1_000_000 * 10 ** USDC_DECIMALS; // 1 million USDC
    uint256 private constant TOLERANCE = 1e15; // 0.1% tolerance for floating-point comparisons
    uint256 private constant RESERVE_ID = 25; // ExtraFi reserve ID

    // Test contract variables
    LendingManager private lendingManager;
    IAaveIncentivesController public aaveController;
    IERC20 private token;
    IERC20 private atoken;
    IERC20 private rewardTokenOfAAVE;
    IERC20 private rewardTokenOfSeamless;
    IERC20 private extraToken;
    IERC20 private atokenSeamless;
    IERC20 private etoken;
    IMToken private mtoken;

    // Protocol-specific variables
    uint128 private aaveInterestRate;
    uint128 private seamlessInterestRate;
    uint256 private extrafiExchangeRate;
    uint256 private moonwellInterestRate;
    uint256 private moonwellExchangeRate;

    // Mainnet fork configuration
    address private LENDING_POOL_AAVE = vm.envAddress("LENDING_POOL_AAVE");
    address private LENDING_POOL_SEAMLESS =
        vm.envAddress("LENDING_POOL_SEAMLESS");
    address private LENDING_POOL_EXTRAFI =
        vm.envAddress("LENDING_POOL_EXTRAFI");
    address private LENDING_POOL_MOONWELL =
        vm.envAddress("LENDING_POOL_MOONWELL");
    address private USDC = vm.envAddress("USDC_ADDRESS");
    address private USER = vm.envAddress("USER");
    address private STAKING_REWARD = vm.envAddress("STAKING_REWARD");
    address private AAVE_USER = vm.envAddress("AAVE_USER");
    address private EXTRA_ADDRESS = vm.envAddress("EXTRA_ADDRESS");

    /**
     * @dev Sets up the test environment before each test
     */
    function setUp() public {
        lendingManager = new LendingManager(USDC);
        token = IERC20(USDC);
        rewardTokenOfAAVE = IERC20(0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da);
        aaveController = IAaveIncentivesController(
            0x8164Cc65827dcFe994AB23944CBC90e0aa80bFcb
        );
        // rewardTokenOfSeamless = IERC20(
        //     0x1C7a460413dD4e964f96D8dFC56E7223cE88CD85 //seam
        // );

        // extraToken = IERC20(EXTRA_ADDRESS);

        // // Setup for AAVE
        // atoken = IERC20(lendingManager.getATokenAddress(LENDING_POOL_AAVE));
        // aaveInterestRate = lendingManager.getInterestRate(LENDING_POOL_AAVE);
        // // console.log("AAVE INTEREST RATE", aaveInterestRate);

        // // Setup for Seamless
        // atokenSeamless = IERC20(
        //     lendingManager.getATokenAddress(LENDING_POOL_SEAMLESS)
        // );
        // seamlessInterestRate = lendingManager.getInterestRate(
        //     LENDING_POOL_SEAMLESS
        // );
        console.log("SEAMLESS INTEREST RATE");

        // // Setup for ExtraFi
        // etoken = IERC20(
        //     lendingManager.getATokenAddressOfExtraFi(
        //         RESERVE_ID,
        //         LENDING_POOL_EXTRAFI
        //     )
        // );
        // extrafiExchangeRate = lendingManager.exchangeRateOfExtraFi(
        //     RESERVE_ID,
        //     LENDING_POOL_EXTRAFI
        // );

        // // console.log("ExtraFi EXCHANGE RATE", extrafiExchangeRate);

        // // Setup for Moonwell
        // mtoken = IMToken(LENDING_POOL_MOONWELL);
        // moonwellInterestRate = lendingManager.getInterestRateOfMoonWell(
        //     LENDING_POOL_MOONWELL
        // );
        // moonwellExchangeRate = lendingManager.exchangeRateOfMoonWell(
        //     LENDING_POOL_MOONWELL
        // );

        // // console.log("Moonwell INTEREST RATE", moonwellInterestRate);
        // // console.log("Moonwell exchange RATE", moonwellExchangeRate);
        // // Fund the USER account with USDC
        // deal(USDC, USER, AMOUNT * 2);
    }

    /**
     * @dev Helper function to approve and deposit tokens to a lending pool
     * @param amount The amount of tokens to deposit
     * @param lendingPool The address of the lending pool
     */
    function approveAndDeposit(uint256 amount, address lendingPool) internal {
        vm.startPrank(USER);
        token.approve(address(lendingManager), amount);
        lendingManager.depositToLendingPool(
            amount,
            address(lendingManager),
            lendingPool
        );
        vm.stopPrank();
    }

    /**
     * @dev Helper function to withdraw tokens from a lending pool
     * @param amount The amount of tokens to withdraw
     * @param lendingPool The address of the lending pool
     */
    function withdraw(uint256 amount, address lendingPool) internal {
        vm.prank(USER);
        lendingManager.withdrawFromLendingPool(
            amount,
            address(lendingManager),
            lendingPool
        );
    }

    // /**
    //  * @dev Test depositing and withdrawing from AAVE lending pool
    //  */
    // function testDepositWithdrawAave() public {
    //     uint256 initialBalance = token.balanceOf(USER);
    //     approveAndDeposit(AMOUNT, LENDING_POOL_AAVE);

    //     assertEq(
    //         atoken.balanceOf(address(lendingManager)),
    //         AMOUNT,
    //         "Incorrect aToken balance after deposit"
    //     );
    //     assertEq(
    //         token.balanceOf(USER),
    //         initialBalance - AMOUNT,
    //         "Incorrect USDC balance after deposit"
    //     );

    //     // Simulate interest accrual
    //     vm.warp(block.timestamp + DAY_IN_SECONDS);

    //     uint256 balanceAfterOneDay = atoken.balanceOf(address(lendingManager));
    //     assertGt(
    //         balanceAfterOneDay,
    //         AMOUNT,
    //         "No interest accrued after one day"
    //     );

    //     // Withdraw half
    //     uint256 halfBalance = balanceAfterOneDay / 2;
    //     withdraw(halfBalance, LENDING_POOL_AAVE);

    //     assertApproxEqRel(
    //         atoken.balanceOf(address(lendingManager)),
    //         halfBalance,
    //         TOLERANCE,
    //         "Incorrect aToken balance after partial withdrawal"
    //     );

    //     // Withdraw remaining balance
    //     vm.warp(block.timestamp + FIVE_DAYS_IN_SECONDS);
    //     uint256 remainingBalance = atoken.balanceOf(address(lendingManager));

    //     // Ensure the aToken balance has increased due to further accrued interest
    //     assertGt(
    //         remainingBalance,
    //         halfBalance,
    //         "aToken balance should have increased due to additional interest accrual"
    //     );

    //     withdraw(remainingBalance, LENDING_POOL_AAVE);

    //     assertEq(
    //         atoken.balanceOf(address(lendingManager)),
    //         0,
    //         "aToken balance should be zero after full withdrawal"
    //     );
    //     assertGt(
    //         token.balanceOf(address(lendingManager)),
    //         AMOUNT,
    //         "Contract should have earned interest"
    //     );
    // }

    function testGetUserAccruedRewards() public {
        // Get user accrued rewards using the delegatecall-based function
        uint256 accruedRewards = lendingManager.getUserAccruedRewards(
            AAVE_USER,
            address(rewardTokenOfAAVE)
        );

        console.log("User Accrued Rewards:", accruedRewards);

        assertGt(accruedRewards, 0, "User should have accrued rewards.");
    }

    // function testClaimRewardsFromAave() public {
    //     //same argument as shows in tx details

    //     address[] memory assets = new address[](1);
    //     assets[0] = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant asset address
    //     // uint256 amount = type(uint256).max;
    //     uint256 amount = 1691231209186197942; //just for check passing small amount for claim
    //     address reward = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant reward token address
    //     address to = AAVE_USER;

    //     // Warp to the block timestamp before the reward claim
    //     // uint256 blockNumber = 20546855;
    //     // vm.rollFork(blockNumber - 20);
    //     console.log("current block num:", block.number);

    //     vm.startPrank(AAVE_USER);
    //     rewardTokenOfAAVE.approve(
    //         0x702B6770A81f75964cA5D479F369eFB31dfa7C32,
    //         600097082369139145335
    //     );
    //     rewardTokenOfAAVE.approve(
    //         address(lendingManager),
    //         600097082369139145335
    //     );

    //     uint256 accruedRewards = lendingManager.getUserAccruedRewards(
    //         AAVE_USER,
    //         reward
    //     );
    //     console.log("User Accrued Rewards before claiming :", accruedRewards);
    //     console.log(
    //         "User token balance before claiming :",
    //         token.balanceOf(AAVE_USER)
    //     );

    //     // vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     // console.log(
    //     //     "User token balance before claiming :",
    //     //     token.balanceOf(AAVE_USER)
    //     // );

    //     // Start claiming rewards
    //     uint256 claimedAmount = lendingManager.claimRewardsFromAave(
    //         assets,
    //         amount,
    //         to,
    //         reward
    //     );
    //     vm.stopPrank();

    //     console.log(
    //         "User token balance after claiming :",
    //         token.balanceOf(AAVE_USER)
    //     );
    //     // vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     // console.log(
    //     //     "User token balance after claiming after 5 days:",
    //     //     token.balanceOf(AAVE_USER)
    //     // );

    //     // Check the claimed amount
    //     console.log("Claimed Rewards Amount:", claimedAmount);

    //     accruedRewards = lendingManager.getUserAccruedRewards(
    //         AAVE_USER,
    //         reward
    //     );

    //     // Log the accrued rewards
    //     console.log("User Accrued Rewards after claiming :", accruedRewards);

    //     // Assert the expected rewards balance
    //     assertGt(claimedAmount, 0, "Rewards should be claimed successfully.");
    // }

    function claimReward() public {
        console.log("hello from c");
        address[] memory assets = new address[](1);
        assets[0] = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant asset address
        // uint256 amount = type(uint256).max;
        uint256 amount = 1691231209186197942; //just for check passing small amount for claim
        address reward = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant reward token address
        address to = AAVE_USER;
        console.log(
            "before claim token balance: ",
            rewardTokenOfAAVE.balanceOf(AAVE_USER)
        );
        vm.startPrank(AAVE_USER);
        //  rewardTokenOfAAVE.approve(
        //         0x702B6770A81f75964cA5D479F369eFB31dfa7C32,
        //         600097082369139145335
        //     );
        //     rewardTokenOfAAVE.approve(
        //         address(lendingManager),
        //         600097082369139145335
        //     );
        uint accruedRewards = aaveController.claimRewards(
            assets,
            amount,
            to,
            reward
        );
        console.log(
            "after claim token balance: ",
            rewardTokenOfAAVE.balanceOf(AAVE_USER)
        );
        assertGt(accruedRewards, 0, "User should have accrued rewards.");

        vm.stopPrank();
    }

    /**
     * @dev Test depositing and staking to ExtraFi lending pool
    //  */
    // function testDepositAndStakeToExtraFi() public {
    //     uint256 initialBalance = token.balanceOf(USER);

    //     // USER approves and deposits to ExtraFi via the LendingManager
    //     vm.startPrank(USER);
    //     token.approve(address(lendingManager), AMOUNT);
    //     lendingManager.depositAndStakeToExtraFi(
    //         RESERVE_ID,
    //         AMOUNT,
    //         address(lendingManager),
    //         LENDING_POOL_EXTRAFI
    //     );
    //     vm.stopPrank();

    //     // Check that the user's underlying balance decreased by the deposited amount
    //     uint256 finalBalance = token.balanceOf(USER);
    //     assertEq(
    //         finalBalance,
    //         initialBalance - AMOUNT,
    //         "Incorrect USDC balance after deposit and stake"
    //     );

    //     // Check that the eToken balance is correctly reflected in the LendingManager contract
    //     uint256 eTokenBalance = etoken.balanceOf(address(lendingManager));
    //     assertEq(
    //         eTokenBalance,
    //         0,
    //         "eToken balance should be greater than zero after deposit and stake"
    //     );

    //     console.log("ExtraFi eToken balance:", eTokenBalance);
    // }

    /**
     * @dev Test unstaking and withdrawing from ExtraFi lending pool
     */
    // function testUnStakeAndWithdrawFromExtraFi() public {
    //     // Initial deposit and stake
    //     vm.startPrank(USER);
    //     uint256 etokenBeforeDeposit = etoken.balanceOf(STAKING_REWARD);
    //     console.log(
    //         "etoken balance before deposit",
    //         etoken.balanceOf(STAKING_REWARD)
    //     );
    //     token.approve(address(lendingManager), AMOUNT);

    //     uint256 lendingManagerETokenBalance = lendingManager
    //         .getETokenBalanceInStakingReward(STAKING_REWARD);

    //     console.log(
    //         "eToken balance in rewardManager contract before deposit:",
    //         etoken.balanceOf(address(lendingManager))
    //     );
    //     console.log(
    //         "eToken balance in Staking Reward contract for LendingManager before deposit:",
    //         lendingManagerETokenBalance
    //     );

    //     lendingManager.depositAndStakeToExtraFi(
    //         RESERVE_ID,
    //         AMOUNT,
    //         address(lendingManager),
    //         LENDING_POOL_EXTRAFI
    //     );
    //     vm.stopPrank();
    //     lendingManagerETokenBalance = lendingManager
    //         .getETokenBalanceInStakingReward(STAKING_REWARD);

    //     console.log(
    //         "eToken balance in Staking Reward contract for LendingManager after deposit:",
    //         lendingManagerETokenBalance
    //     );

    //     console.log(
    //         "eToken balance in rewardManager contract after deposit:",
    //         etoken.balanceOf(address(lendingManager))
    //     );

    //     // Simulate time passing for potential interest accrual
    //     vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     lendingManagerETokenBalance = lendingManager
    //         .getETokenBalanceInStakingReward(STAKING_REWARD);

    //     console.log(
    //         "eToken balance in Staking Reward contract for LendingManager after deposit and after one day:",
    //         lendingManagerETokenBalance
    //     );

    //     // Get the current exchange rate from the lending pool
    //     vm.startPrank(USER);
    //     uint256 exchangeRate = lendingManager.exchangeRateOfExtraFi(
    //         RESERVE_ID,
    //         LENDING_POOL_EXTRAFI
    //     );

    //     console.log("exchangeRate", exchangeRate);
    //     uint256 remainingETokenBalance = etoken.balanceOf(STAKING_REWARD);
    //     console.log(
    //         "eToken amount in reward contract after deposit:",
    //         remainingETokenBalance
    //     );
    //     // Calculate the eToken amount for withdrawal
    //     uint256 eTokenAmount = remainingETokenBalance - etokenBeforeDeposit;
    //     console.log(
    //         "increased etoken balance after deposit:",
    //         eTokenAmount - (AMOUNT * 1e18) / exchangeRate
    //     );

    //     console.log("Calculated eToken amount for withdrawal:", eTokenAmount);

    //     // Unstake and withdraw
    //     remainingETokenBalance = etoken.balanceOf(STAKING_REWARD);
    //     console.log(
    //         "eToken balance in Staking reward contract before withdraw:",
    //         remainingETokenBalance
    //     );

    //     console.log(
    //         "USDC amount before withdraw",
    //         token.balanceOf(address(lendingManager)) / 10 ** 6
    //     );
    //     vm.warp(block.timestamp + FIVE_DAYS_IN_SECONDS);

    //     lendingManagerETokenBalance = lendingManager
    //         .getETokenBalanceInStakingReward(STAKING_REWARD);

    //     console.log(
    //         "eToken balance in Staking Reward contract for LendingManager after deposit and after five day:",
    //         lendingManagerETokenBalance
    //     );

    //     uint256 withdrawnAmount = lendingManager.unStakeAndWithdrawFromExtraFi(
    //         eTokenAmount,
    //         address(lendingManager),
    //         RESERVE_ID,
    //         LENDING_POOL_EXTRAFI
    //     );
    //     vm.stopPrank();

    //     console.log(
    //         "USDC amount after withdraw",
    //         token.balanceOf(address(lendingManager)) / 10 ** 6
    //     );
    //     // Assertions
    //     assertGt(
    //         token.balanceOf(address(lendingManager)),
    //         0,
    //         "User should have received their USDC back after withdrawal"
    //     );

    //     console.log("Withdrawn amount:", withdrawnAmount);

    //     // Check that the eToken balance in the LendingManager contract decreased accordingly
    //     remainingETokenBalance = etoken.balanceOf(STAKING_REWARD);
    //     console.log(
    //         "eToken balance in Staking reward contract after withdraw:",
    //         remainingETokenBalance
    //     );

    //     vm.warp(block.timestamp + FIVE_DAYS_IN_SECONDS);

    //     uint256 userRewardsClaimable = lendingManager.getRewardsForExtraFi(
    //         address(lendingManager),
    //         address(extraToken)
    //     );
    //     console.log(
    //         "accured reward token balance: ",
    //         lendingManager.getRewardsForExtraFi(
    //             address(lendingManager),
    //             address(extraToken)
    //         )
    //     );
    //     console.log(
    //         "extra token balance before claim",
    //         extraToken.balanceOf(address(lendingManager))
    //     );
    //     vm.startPrank(USER);
    //     lendingManager.claimRewardsFromExtraFi();
    //     vm.stopPrank();

    //     assertEq(
    //         userRewardsClaimable,
    //         extraToken.balanceOf(address(lendingManager)),
    //         "Extra token should be match with userRewardsClaimable amount of stakingReward contract."
    //     );

    //     assertEq(
    //         lendingManager.getRewardsForExtraFi(
    //             address(lendingManager),
    //             address(extraToken)
    //         ),
    //         0,
    //         "extra token should be 0 after claim all rewards."
    //     );

    //     console.log(
    //         "extra token balance after claim",
    //         extraToken.balanceOf(address(lendingManager))
    //     );

    //     console.log(
    //         "reward token balance after claim: ",
    //         lendingManager.getRewardsForExtraFi(
    //             address(lendingManager),
    //             address(extraToken)
    //         )
    //     );
    // }

    // function testDepositSeamless() public {
    //     uint256 initialBalance = token.balanceOf(USER);
    //     approveAndDeposit(AMOUNT, LENDING_POOL_SEAMLESS);

    //     assertGe(
    //         atokenSeamless.balanceOf(address(lendingManager)),
    //         AMOUNT,
    //         "Incorrect aToken balance after deposit"
    //     );
    //     console.log(address(atokenSeamless));
    //     console.log(
    //         "atoken balance of manager contract for sUSDC token",
    //         atokenSeamless.balanceOf(address(lendingManager))
    //     );
    //     assertEq(
    //         token.balanceOf(USER),
    //         initialBalance - AMOUNT,
    //         "Incorrect USDC balance after deposit"
    //     );

    //     // Simulate interest accrual
    //     vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     console.log("current timestamp", block.timestamp);
    //     uint256 balanceAfterOneDay = atokenSeamless.balanceOf(
    //         address(lendingManager)
    //     );
    //     assertGt(
    //         balanceAfterOneDay,
    //         AMOUNT,
    //         "No interest accrued after one day"
    //     );
    //     console.log(
    //         "accured rewards after deposit",
    //         testGetUserAccruedRewardsFromSeamless()
    //     );
    // }

    // function testGetUserAccruedRewardsFromSeamless()
    //     public
    //     view
    //     returns (uint256 accruedRewards)
    // {
    //     // Get user accrued rewards using the delegatecall-based function
    //     accruedRewards = lendingManager.getUserAccruedRewardsForSeamless(
    //         address(lendingManager),
    //         address(rewardTokenOfSeamless)
    //     );

    //     console.log("User Accrued Rewards:", accruedRewards);

    //     // assertGt(accruedRewards, 0, "User should have accrued rewards.");
    // }

    // function testClaimRewardsFromSeamless() public {
    //     //same argument as shows in tx details

    //     address[] memory assets = new address[](1);
    //     assets[0] = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant asset address
    //     // uint256 amount = type(uint256).max;
    //     uint256 amount = 1691231209186197942; //just for check passing small amount for claim
    //     address reward = 0xfA1fDbBD71B0aA16162D76914d69cD8CB3Ef92da; // Replace with relevant reward token address
    //     address to = AAVE_USER;

    //     // Warp to the block timestamp before the reward claim
    //     // uint256 blockNumber = 20546855;
    //     // vm.rollFork(blockNumber - 20);
    //     console.log("current block num:", block.number);

    //     vm.startPrank(AAVE_USER);
    //     rewardTokenOfAAVE.approve(
    //         0x702B6770A81f75964cA5D479F369eFB31dfa7C32,
    //         600097082369139145335
    //     );
    //     rewardTokenOfAAVE.approve(
    //         address(lendingManager),
    //         600097082369139145335
    //     );

    //     uint256 accruedRewards = lendingManager.getUserAccruedRewards(
    //         AAVE_USER,
    //         reward
    //     );
    //     console.log("User Accrued Rewards before claiming :", accruedRewards);
    //     console.log(
    //         "User token balance before claiming :",
    //         token.balanceOf(AAVE_USER)
    //     );

    //     // vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     // console.log(
    //     //     "User token balance before claiming :",
    //     //     token.balanceOf(AAVE_USER)
    //     // );

    //     // Start claiming rewards
    //     uint256 claimedAmount = lendingManager.claimRewardsFromAave(
    //         assets,
    //         amount,
    //         to,
    //         reward
    //     );
    //     vm.stopPrank();

    //     console.log(
    //         "User token balance after claiming :",
    //         token.balanceOf(AAVE_USER)
    //     );
    //     // vm.warp(block.timestamp + DAY_IN_SECONDS);
    //     // console.log(
    //     //     "User token balance after claiming after 5 days:",
    //     //     token.balanceOf(AAVE_USER)
    //     // );

    //     // Check the claimed amount
    //     console.log("Claimed Rewards Amount:", claimedAmount);

    //     accruedRewards = lendingManager.getUserAccruedRewards(
    //         AAVE_USER,
    //         reward
    //     );

    //     // Log the accrued rewards
    //     console.log("User Accrued Rewards after claiming :", accruedRewards);

    //     // Assert the expected rewards balance
    //     assertGt(claimedAmount, 0, "Rewards should be claimed successfully.");
    // }
}
