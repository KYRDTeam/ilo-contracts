// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import { OracleLibrary } from '../libraries/OracleLibrary.sol';
import { IUniswapV3Oracle } from '../interfaces/IUniswapV3Oracle.sol';

/**
 * @title UniswapV3Oracle
 * @notice For TK/ETH pool, it will return TWAP price for the last 30 mins and add 5% slippage
 * @dev This price will be used in whitelist contract to calculate the ETH tokenIn amount.
 * The actual amount could be different because, the ticks used at the time of purchase won't be the same as this TWAP
 */
abstract contract UniswapV3Oracle is IUniswapV3Oracle {
    /// @inheritdoc IUniswapV3Oracle
    uint32 public constant override PERIOD = 30 minutes;
    /// @inheritdoc IUniswapV3Oracle
    uint128 public constant override BASE_AMOUNT = 1e18; // TK has 18 decimals

    /// @inheritdoc IUniswapV3Oracle
    address public override pool;
    /// @inheritdoc IUniswapV3Oracle
    address public override token;
    /// @inheritdoc IUniswapV3Oracle
    address public override quoteToken;

    /// @notice Returns TWAP price for 1 TK for the last 30 mins
    function _peek(uint256 baseAmount) internal view returns (uint256) {
        uint32 longestPeriod = OracleLibrary.getOldestObservationSecondsAgo(
            pool
        );
        uint32 period = PERIOD < longestPeriod ? PERIOD : longestPeriod;
        int24 tick = OracleLibrary.consult(pool, period);
        uint256 quotedAmount = OracleLibrary.getQuoteAtTick(
            tick,
            BASE_AMOUNT,
            token,
            quoteToken
        );
        // Apply 5% slippage
        return (quotedAmount * baseAmount * 95) / 1e20; // 100 / 1e18
    }
}
