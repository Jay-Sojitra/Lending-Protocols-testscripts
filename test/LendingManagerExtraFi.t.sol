// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Test, console} from "forge-std/Test.sol";
// import "../src/LendingManager.sol";

// contract LendingManagerExtraFiTest is Test {
//     LendingManager lendingManager;
//     IERC20 token;
//     IERC20 etoken;
//     uint256 amount;
//     uint256 extrafiExchangeRate;
//     uint128 extrafiInterestRate;

//     // Mainnet fork configuration
//     address LENDING_POOL_EXTRAFI = vm.envAddress("LENDING_POOL_EXTRAFI");
//     address USDC = vm.envAddress("USDC_ADDRESS");
//     address USER = vm.envAddress("USER");
//     uint256 RESERVE_ID = 25; // Assuming 1 is the static reserve ID for ExtraFi

//     function setUp() public {
//         // Deploy the contract
//         lendingManager = new LendingManager(USDC);

//         // setting up underlying token
//         token = IERC20(USDC);

//         // fetching eToken for underlying token
//         address eTOKEN = lendingManager.getATokenAddressOfExtraFi(
//             RESERVE_ID,
//             LENDING_POOL_EXTRAFI
//         );

//         // setting up eToken of underlying token
//         etoken = IERC20(eTOKEN);

//         extrafiExchangeRate = lendingManager.exchangeRateOfExtraFi(
//             RESERVE_ID,
//             LENDING_POOL_EXTRAFI
//         );
//         console.log("ExtraFi EXCHANGE RATE", extrafiExchangeRate);

//         // setting up supply/withdraw amount
//         amount = 200000000; // 100 USDC
//     }

//     function testDepositExtraFi() public {
//         address ca = address(lendingManager);

//         vm.startPrank(USER);
//         deal(USDC, USER, 200000000);
//         // Check user's TOKEN balance
//         assertGt(
//             token.balanceOf(USER),
//             0,
//             "USER does not hold the underlying token"
//         );

//         console.log("token balance of user ", token.balanceOf(USER));
//         // Approve and supply TOKEN
//         token.approve(address(lendingManager), amount);
//         assertGe(
//             token.allowance(USER, address(lendingManager)),
//             amount,
//             "Allowance should be equal to the approved amount"
//         );

//         console.log(
//             "user Etoken balance before deposit",
//             etoken.balanceOf(address(lendingManager))
//         );

//         // supply amount to ExtraFi
//         lendingManager.depositToExtraFi(
//             USDC,
//             RESERVE_ID,
//             100000000,
//             LENDING_POOL_EXTRAFI
//         );
//         console.log(
//             "token balance of user after deposit ",
//             token.balanceOf(USER)
//         );

//         console.log(
//             "user Etoken balance after deposit",
//             etoken.balanceOf(address(lendingManager))
//         );
//         assertLe(
//             etoken.balanceOf(address(lendingManager)),
//             amount,
//             "ETOKEN balance error"
//         );
//         vm.stopPrank();
//     }

//     function testWithdrawHalfExtraFi() public {
//         testDepositExtraFi();
//         vm.startPrank(USER);
//         uint256 usdcBalance = token.balanceOf(USER);
//         uint256 eTokenBalanceContract = etoken.balanceOf(
//             address(lendingManager)
//         );
//         uint256 amountToWithdraw = 50000000;
//         console.log("amountToWithdraw", amountToWithdraw);
//         console.log("user balance before withdraw...", token.balanceOf(USER));

//         lendingManager.withdrawExtraFi(
//             amountToWithdraw,
//             USER,
//             RESERVE_ID,
//             LENDING_POOL_EXTRAFI
//         );
//         console.log("user balance after withdraw...", token.balanceOf(USER));
//         assertGe(
//             usdcBalance + (amountToWithdraw * extrafiExchangeRate) / (10 ** 18),
//             token.balanceOf(USER),
//             "USDC balance error : withdraw"
//         );
//         console.log("eTokenBalanceContract", eTokenBalanceContract);
//         console.log(
//             "eTokenBalanceContract after withdraw",
//             eTokenBalanceContract - amountToWithdraw
//         );
//         assertEq(
//             eTokenBalanceContract - amountToWithdraw,
//             etoken.balanceOf(address(lendingManager)),
//             "ETOKEN balance error : withdraw"
//         );
//         vm.stopPrank();
//     }

//     function testWithdrawFullExtraFi() public {
//         testDepositExtraFi();
//         vm.startPrank(USER);
//         uint256 usdcBalanceContract = token.balanceOf(address(lendingManager));
//         uint256 eTokenBalanceContract = etoken.balanceOf(
//             address(lendingManager)
//         );
//         uint256 amountToWithdraw = eTokenBalanceContract;
//         console.log(
//             "user balance after withdraw  amount before second withdraw",
//             token.balanceOf(USER)
//         );
//         lendingManager.withdrawExtraFi(
//             amountToWithdraw,
//             USER,
//             RESERVE_ID,
//             LENDING_POOL_EXTRAFI
//         );
//         // assertEq(
//         //     usdcBalanceContract + amountToWithdraw,
//         //     amountToWithdraw,
//         //     "USDC balance error : withdraw"
//         // );
//         console.log(
//             "user balance after withdraw whole amount",
//             token.balanceOf(USER)
//         );
//         assertEq(
//             eTokenBalanceContract - amountToWithdraw,
//             0,
//             "ETOKEN balance error : withdraw"
//         );
//         vm.stopPrank();
//     }
// }
