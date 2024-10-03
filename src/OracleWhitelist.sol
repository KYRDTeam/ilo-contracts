// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import { UniswapV3Oracle } from './base/UniswapV3Oracle.sol';
import { IOracleWhitelist } from './interfaces/IOracleWhitelist.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { EnumerableSet } from '@openzeppelin/contracts/utils/EnumerableSet.sol';

/**
 * @title The contract handles whitelist related features
 * @notice The main functionalities are:
 * - Ownable: Add whitelisted addresses
 * - Ownable: Set max quote token amount to buy(default 3 quote token)
 * - Ownable: Set univ3 TWAP oracle
 * - Token contract `_beforeTokenTransfer` hook will call `checkWhitelist` function and this function will check if buyer is eligible
 */
contract OracleWhitelist is IOracleWhitelist, UniswapV3Oracle, Ownable {
    /// @dev Maximum quote token amount to contribute
    uint256 private _maxAddressCap;
    /// @dev Flag for locked period
    bool private _locked;

    EnumerableSet.AddressSet private _whitelistedAddresses;
    /// @dev Whitelist index for each whitelisted address
    mapping(address => uint256) private _contributed;

    /// @notice Check if called from token contract.
    modifier onlyToken() {
        require(_msgSender() == token, 'token');
        _;
    }

    constructor(
        address owner,
        address _quoteToken,
        bool _lockBuy,
        uint256 _maxCap
    ) {
        transferOwnership(owner);
        quoteToken = _quoteToken;
        _locked = _lockBuy; // Initially, liquidity will be locked
        _maxAddressCap = _maxCap;
    }

    /// @notice Check if address to is eligible for whitelist
    /// @param from sender address
    /// @param to recipient address
    /// @param amount Number of tokens to be transferred
    /// @dev Check WL should be applied only
    /// @dev Revert if locked, not whitelisted or already contributed more than capped amount
    /// @dev Update contributed amount
    function checkWhitelist(
        address from,
        address to,
        uint256 amount
    ) external override onlyToken {
        if (from == pool && to != owner()) {
            // We only add limitations for buy actions via uniswap v3 pool
            // Still need to ignore WL check if it's owner related actions
            require(!_locked, 'locked');

            require(
                EnumerableSet.contains(_whitelistedAddresses, to),
                'whitelist'
            );

            // // Calculate rough ETH amount for TK amount
            uint256 estimatedETHAmount = _peek(amount);
            if (_contributed[to] + estimatedETHAmount > _maxAddressCap) {
                revert('cap');
            }

            _contributed[to] += estimatedETHAmount;
        }
    }

    /// @notice Setter for locked flag
    /// @param newLocked New flag to be set
    function setLocked(bool newLocked) external onlyOwner {
        _locked = newLocked;
    }

    /// @notice Setter for max address cap
    /// @param newCap New cap for max ETH amount
    function setMaxAddressCap(uint256 newCap) external onlyOwner {
        _maxAddressCap = newCap;
    }

    /// @notice Setter for token
    /// @param newToken New token address
    function setToken(address newToken) external override onlyOwner {
        token = newToken;
    }

    /// @notice Setter for Univ3 pool
    /// @param newPool New pool address
    function setPool(address newPool) external override onlyOwner {
        pool = newPool;
    }

    /// @notice Add batch whitelists
    /// @param whitelisted Array of addresses to be added
    function addBatchWhitelist(
        address[] calldata whitelisted
    ) external onlyOwner {
        for (uint256 i = 0; i < whitelisted.length; i++) {
            EnumerableSet.add(_whitelistedAddresses, whitelisted[i]);
        }
    }

    /// @notice Remove batch whitelists
    /// @param whitelisted Array of addresses to be removed
    function removeBatchWhitelist(
        address[] calldata whitelisted
    ) external onlyOwner {
        for (uint256 i = 0; i < whitelisted.length; i++) {
            EnumerableSet.remove(_whitelistedAddresses, whitelisted[i]);
        }
    }

    /// @notice Returns max address cap
    function maxAddressCap() external view returns (uint256) {
        return _maxAddressCap;
    }

    /// @notice Returns contributed ETH amount for address
    /// @param to The address to be checked
    function contributed(address to) external view returns (uint256) {
        return _contributed[to];
    }

    /// @notice If token transfer is locked or not
    function locked() external view returns (bool) {
        return _locked;
    }

    /// @notice whitelist count
    function whitelistCount() external view returns (uint256) {
        return EnumerableSet.length(_whitelistedAddresses);
    }

    /// @notice check if address is whitelisted
    /// @param whitelisted Address to be checked
    function isWhitelisted(address whitelisted) external view returns (bool) {
        return EnumerableSet.contains(_whitelistedAddresses, whitelisted);
    }
}
