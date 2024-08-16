// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Test, console} from "forge-std/Test.sol";
// import "../src/LendingManager.sol";

// contract LendingManagerMoonwellTest is Test {
//     LendingManager lendingManager;
//     IERC20 token;
//     IMToken mtoken;
//     uint256 amount;
//     uint256 moonwellInterestRate;
//     uint256 moonwellExchangeRate;

//     // Mainnet fork configuration
//     address LENDING_POOL_MOONWELL = vm.envAddress("LENDING_POOL_MOONWELL");
//     address USDC = vm.envAddress("USDC_ADDRESS");
//     address USER = vm.envAddress("USER");

//     function setUp() public {
//         // Deploy the contract
//         lendingManager = new LendingManager();

//         // setting up underlying token
//         token = IERC20(USDC);

//         // setting up mToken of underlying token
//         mtoken = IMToken(LENDING_POOL_MOONWELL);

//         moonwellInterestRate = lendingManager.getInterestRateOfMoonWell(
//             LENDING_POOL_MOONWELL
//         );
//         moonwellExchangeRate = lendingManager.exchangeRateOfMoonWell(
//             LENDING_POOL_MOONWELL
//         );
//         console.log("Moonwell INTEREST RATE", moonwellInterestRate);
//         console.log("Moonwell exchange RATE", moonwellExchangeRate);

//         // setting up supply/withdraw amount
//         amount = 100000000; // 100 USDC
//     }

//     function testDepositMoonwell() public {
//         vm.startPrank(USER);
//         deal(USDC, USER, 200000000);
//         // Check user's TOKEN balance
//         assertGt(
//             token.balanceOf(USER),
//             0,
//             "USER does not hold the underlying token"
//         );

//         // Approve and supply TOKEN
//         token.approve(address(lendingManager), amount);
//         assertGe(
//             token.allowance(USER, address(lendingManager)),
//             amount,
//             "Allowance should be equal to the approved amount"
//         );

//         console.log(
//             "token balance of user before deposit... ",
//             token.balanceOf(USER)
//         );
//         console.log(
//             "mtoken balance of contract before deposit... ",
//             mtoken.balanceOf(address(lendingManager))
//         );

//         // supply amount to Moonwell
//         lendingManager.depositMoonWell(USDC, amount, LENDING_POOL_MOONWELL);

//         console.log(
//             "token balance of user after deposit... ",
//             token.balanceOf(USER)
//         );
//         console.log(
//             "mtoken balance of contract after deposit... ",
//             mtoken.balanceOf(address(lendingManager))
//         );

//         assertGe(
//             mtoken.balanceOf(address(lendingManager)),
//             amount,
//             "MTOKEN balance error"
//         );
//         vm.stopPrank();
//     }

//     function testWithdrawHalfMoonwell() public {
//         testDepositMoonwell();
//         vm.startPrank(USER);
//         uint256 usdcBalanceContract = token.balanceOf(address(lendingManager));
//         uint256 amountToWithdraw = 50000000;

//         console.log(
//             "mtoken balance before withdraw",
//             mtoken.balanceOf(address(lendingManager))
//         );
//         uint256 atokenAmount = (amountToWithdraw * (10 ** 18)) /
//             moonwellExchangeRate;
//         lendingManager.withdrawMoonWell(atokenAmount, LENDING_POOL_MOONWELL);

//         console.log(
//             "atoken amount from underlying token amount and it should be half of total",
//             atokenAmount
//         );
//         console.log(
//             "mtoken balance after withdraw",
//             mtoken.balanceOf(address(lendingManager))
//         );
//         assertGe(
//             token.balanceOf(address(lendingManager)),
//             usdcBalanceContract +
//                 (amountToWithdraw * moonwellExchangeRate) /
//                 (10 ** 18),
//             "USDC balance error : withdraw"
//         );

//         assertGe(
//             token.balanceOf(address(lendingManager)),
//             amountToWithdraw,
//             "USDC balance error : withdraw"
//         );

//         assertGe(
//             atokenAmount,
//             mtoken.balanceOf(address(lendingManager)),
//             "ETOKEN balance error : withdraw"
//         );
//         vm.stopPrank();
//     }

//     function testWithdrawFullMoonwell() public {
//         testDepositMoonwell();
//         vm.startPrank(USER);
//         uint256 usdcBalanceContract = token.balanceOf(address(lendingManager));
//         uint256 mTokenBalanceContract = mtoken.balanceOf(
//             address(lendingManager)
//         );
//         uint256 amountToWithdraw = mTokenBalanceContract;
//         console.log(
//             "before withdraw contract balance is ",
//             usdcBalanceContract
//         );
//         lendingManager.withdrawMoonWell(
//             amountToWithdraw,
//             LENDING_POOL_MOONWELL
//         );
//         console.log(
//             "after withdraw contract balance is ",
//             token.balanceOf(address(lendingManager))
//         );
//         assertGe(
//             token.balanceOf(address(lendingManager)),
//             usdcBalanceContract +
//                 (amountToWithdraw * moonwellExchangeRate) /
//                 (10 ** 18),
//             "USDC balance error : withdraw"
//         );

//         assertEq(
//             mtoken.balanceOf(address(lendingManager)),
//             0,
//             "MTOKEN balance error : withdraw"
//         );
//         vm.stopPrank();
//     }
// }
