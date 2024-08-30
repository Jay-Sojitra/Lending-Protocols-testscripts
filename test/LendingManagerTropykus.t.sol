// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/LendingManager.sol";

contract LendingManagerTropykusTest is Test {
    LendingManager lendingManager;
    IERC20 token;
    IMToken ctoken;
    uint256 amount;
    uint256 tropykusInterestRate;
    uint256 tropykusExchangeRate;

    // Mainnet fork configuration
    address LENDING_POOL_TROPYKUS = vm.envAddress("KDOC_ADDRESS");
    address DOC_ADDRESS = vm.envAddress("DOC_ADDRESS");
    address USER = vm.envAddress("USER");
    uint256 private constant TOLERANCE = 1e15;

    function setUp() public {
        // Deploy the contract
        lendingManager = new LendingManager(DOC_ADDRESS);

        // setting up underlying token
        token = IERC20(DOC_ADDRESS);

        // setting up ctoken of underlying token
        ctoken = IMToken(LENDING_POOL_TROPYKUS);

        tropykusInterestRate = lendingManager.getInterestRateOfTropykus(
            LENDING_POOL_TROPYKUS
        );
        tropykusExchangeRate = lendingManager.exchangeRateOfTropykus(
            LENDING_POOL_TROPYKUS
        );
        console.log("Tropykus INTEREST RATE", tropykusInterestRate);
        console.log("Tropykus exchange RATE", tropykusExchangeRate);

        // setting up supply/withdraw amount
        amount = 100 * (10 ** 18); // 100 doc
    }

    function testDepositTropykus() public {
        vm.startPrank(USER);
        deal(DOC_ADDRESS, USER, 200 * (10 ** 18));
        // Check user's TOKEN balance
        assertGt(
            token.balanceOf(USER),
            0,
            "USER does not hold the underlying token"
        );

        // Approve and supply TOKEN
        token.approve(address(lendingManager), amount);
        assertGe(
            token.allowance(USER, address(lendingManager)),
            amount,
            "Allowance should be equal to the approved amount"
        );

        console.log(
            "token balance of user before deposit... ",
            token.balanceOf(USER)
        );
        console.log(
            "ctoken balance of contract before deposit... ",
            ctoken.balanceOf(address(lendingManager))
        );

        // supply amount to Tropykus
        lendingManager.depositToTropykus(amount, LENDING_POOL_TROPYKUS);

        console.log(
            "token balance of user after deposit... ",
            token.balanceOf(USER)
        );
        console.log(
            "ctoken balance of contract after deposit... ",
            ctoken.balanceOf(address(lendingManager))
        );

        assertGe(
            ctoken.balanceOf(address(lendingManager)),
            amount,
            "ctoken balance error"
        );
        vm.stopPrank();
    }

    function testWithdrawHalfTropykus() public {
        testDepositTropykus();
        vm.startPrank(USER);
        uint256 DOCBalanceContract = token.balanceOf(address(lendingManager));
        uint256 amountToWithdraw = 50000000000000000000;

        console.log(
            "ctoken balance of lendingManager before withdraw",
            ctoken.balanceOf(address(lendingManager))
        );

        tropykusExchangeRate = lendingManager.exchangeRateOfTropykus(
            LENDING_POOL_TROPYKUS
        );

        uint256 atokenAmount = (amountToWithdraw * (10 ** 18)) /
            tropykusExchangeRate;
        lendingManager.withdrawFromTropykus(
            atokenAmount,
            LENDING_POOL_TROPYKUS
        );

        console.log(
            "ctoken amount from underlying token amount and it should be half of total ctoken balance",
            atokenAmount
        );
        console.log(
            "ctoken balance of lending manager after withdraw",
            ctoken.balanceOf(address(lendingManager))
        );
        //check token balance of lending manager using formula to get underlying balance from atoken.
        assertApproxEqRel(
            token.balanceOf(address(lendingManager)),
            DOCBalanceContract +
                (atokenAmount * tropykusExchangeRate) /
                (10 ** 18),
            TOLERANCE,
            "DOC balance error 1: withdraw"
        );

        //after withdraw check underlying token balance for lendingManager and it should be equal to withdraw amount.
        assertApproxEqRel(
            token.balanceOf(address(lendingManager)),
            amountToWithdraw,
            TOLERANCE,
            "DOC balance error 2: withdraw"
        );

        //cToken balance should decrease after withdraw underlying balance.
        assertGe(
            atokenAmount,
            ctoken.balanceOf(address(lendingManager)),
            "CTOKEN balance error: withdraw"
        );
        vm.stopPrank();
    }

    function testWithdrawFullTropykus() public {
        testDepositTropykus();
        vm.startPrank(USER);
        uint256 DOCBalanceContract = token.balanceOf(address(lendingManager));
        uint256 ctokenBalanceContract = ctoken.balanceOf(
            address(lendingManager)
        );
        uint256 amountToWithdraw = ctokenBalanceContract;
        console.log("before withdraw contract balance is ", DOCBalanceContract);
        lendingManager.withdrawFromTropykus(
            amountToWithdraw,
            LENDING_POOL_TROPYKUS
        );
        console.log(
            "after withdraw contract balance is ",
            token.balanceOf(address(lendingManager))
        );
        console.log(
            "after withdraw contract ctoken balance is ",
            ctoken.balanceOf(address(lendingManager))
        );
        assertGe(
            token.balanceOf(address(lendingManager)),
            DOCBalanceContract +
                (amountToWithdraw * tropykusExchangeRate) /
                (10 ** 18),
            "DOC balance error : withdraw"
        );

        assertEq(
            ctoken.balanceOf(address(lendingManager)),
            0,
            "ctoken balance error : withdraw"
        );
        vm.stopPrank();
    }
}
