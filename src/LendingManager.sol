// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/aave/IPool.sol";
import "./interfaces/extrafi/ILendingPool.sol";
import "./interfaces/moonwell/IMToken.sol";

//if usdc is final then we should make it static wherver asset address we are getting. (and also chnage extrafi and moonwell functions if needed)
//for extraFi reserveId can be static.
//For moonWell lendingPool means Mtoken so wherver written lendingPool means Mtoken

/**
 * @title LendingManager
 * @author Bhumi Sadariya
 * @dev A contract to manage deposits and withdrawals to and from lending pools.
 */
contract LendingManager {
    /**
     * @dev Deposits the specified amount of the asset to the lending pool. (Aave/Seamless)
     * @param _asset The address of the asset to deposit.
     * @param _amount The amount of the asset to deposit.
     * @param _onBehalfOf The address on whose behalf the deposit is made.
     * @param lendingPool The address of the lending pool.
     */
    function depositToLendingPool(
        address _asset,
        uint256 _amount,
        address _onBehalfOf,
        address lendingPool
    ) public {
        IPool pool = IPool(lendingPool);
        // IERC20(_asset).transferFrom(msg.sender, address(this), _amount); // to test this contract individually uncomment it.
        IERC20(_asset).approve(address(pool), _amount);
        pool.deposit(_asset, _amount, _onBehalfOf, 0);
    }

    function depositExtraFi(
        address _asset,
        uint256 reserveId,
        uint256 _amount,
        address lendingPool
    ) external {
        ILendingPool pool = ILendingPool(lendingPool);
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        IERC20(_asset).approve(address(pool), _amount);
        uint256 shares = pool.deposit(reserveId, _amount, address(this), 0);
    }

    function depositMoonWell(
        address _asset,
        uint256 _amount,
        address lendingPool
    ) external {
        IMToken pool = IMToken(lendingPool);
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        IERC20(_asset).approve(address(pool), _amount);
        pool.mint(_amount);
    }

   
    /**
     * @dev Withdraws the specified amount of the asset from the lending pool. (Aave/Seamless)
     * @param _asset The address of the asset to withdraw.
     * @param _amount The amount of the asset to withdraw.
     * @param to The address to which the withdrawn asset is sent.
     * @param lendingPool The address of the lending pool.
     * @return The amount withdrawn.
     */
    function withdrawFromLendingPool(
        address _asset,
        uint256 _amount,
        address to,
        address lendingPool
    ) external returns (uint256) {
        IPool pool = IPool(lendingPool);
        IERC20(getATokenAddress(_asset, lendingPool)).approve(
            address(pool),
            _amount
        );
        return pool.withdraw(_asset, _amount, to);
    }

    function withdrawExtraFi(
        uint256 eTokenAmount,
        address to,
        uint256 reserveId,
        address lendingPool
    ) external returns (uint256) {
        ILendingPool pool = ILendingPool(lendingPool);
        IERC20(getATokenAddressOfExtraFi(reserveId, lendingPool)).approve(
            address(pool),
            eTokenAmount
        );
        return pool.redeem(reserveId, eTokenAmount, to, false); //can be static first and last value (receiveNativeEth = false)
    }

    //here main contract is Mtoken so no need to give approvation.
    function withdrawMoonWell(
        uint256 redeemTokens,
        address lendingPool
    ) external returns (uint256) {
        IMToken pool = IMToken(lendingPool);
        return pool.redeem(redeemTokens); //can be static first and last value
    }

    /**
     * @dev Gets the address of the aToken for the specified asset and lending pool. (Aave/Seamless)
     * @param _asset The address of the asset.
     * @param lendingPool The address of the lending pool.
     * @return The address of the aToken.
     */
    function getATokenAddress(
        address _asset,
        address lendingPool
    ) public view returns (address) {
        IPool pool = IPool(lendingPool);
        IPool.ReserveData memory reserveData = pool.getReserveData(_asset);
        return reserveData.aTokenAddress;
    }

    function getATokenAddressOfExtraFi(
        //can be static valur for reserveId
        uint256 reserveId,
        address lendingPool
    ) public view returns (address eTokenAddress) {
        ILendingPool pool = ILendingPool(lendingPool);
        eTokenAddress = pool.getETokenAddress(reserveId);
    }

    /**
     * @dev Gets the current liquidity rate for a given asset from the lending pool. (Aave/Seamless)
     * @param _asset The address of the asset.
     * @param lendingPool The address of the lending pool.
     * @return The current liquidity rate in human-readable APR format (annual percentage rate).
     */
    function getInterestRate(
        address _asset,
        address lendingPool
    ) public view returns (uint128) {
        IPool pool = IPool(lendingPool);
        IPool.ReserveData memory reserveData = pool.getReserveData(_asset);
        uint128 liquidityRate = reserveData.currentLiquidityRate;
        return liquidityRate / 1e9; // Convert ray (1e27) to a percentage (1e2)
    }

    // function getInterestRateOfExtraFi(address _asset, address lendingPool) public view returns (uint128) {
    //     IPool pool = IPool(lendingPool);
    //     IPool.ReserveData memory reserveData = pool.getReserveData(_asset);
    //     return reserveData.currentLiquidityRate;
    // }

    //need to change this
    function getInterestRateOfMoonWell(
        address lendingPool
    ) public view returns (uint256 rate) {
        IMToken pool = IMToken(lendingPool);
        rate = pool.supplyRatePerTimestamp();
    }

    function exchangeRateOfExtraFi(
        uint256 reserveId,
        address lendingPool
    ) public view returns (uint256 rate) {
        ILendingPool pool = ILendingPool(lendingPool);
        rate = pool.exchangeRateOfReserve(reserveId);
    }

    function exchangeRateOfMoonWell(
        address lendingPool
    ) public view returns (uint256 rate) {
        IMToken pool = IMToken(lendingPool);
        rate = pool.exchangeRateStored();
    }
}
