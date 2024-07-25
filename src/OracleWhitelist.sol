// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {UniswapV3Oracle} from "./base/UniswapV3Oracle.sol";
import {Initializable} from "./base/Initializable.sol";
import {IOracleWhitelist} from "./interfaces/IOracleWhitelist.sol";

/**
 * @title The contract handles whitelist related features
 * @notice The main functionalities are:
 * - Ownable: Add whitelisted addresses
 * - Ownable: Set max quote token amount to buy(default 3 quote token)
 * - Ownable: Set univ3 TWAP oracle
 * - Token contract `_beforeTokenTransfer` hook will call `checkWhitelist` function and this function will check if buyer is eligible
 */
contract OracleWhitelistWhitelist is IOracleWhitelist, UniswapV3Oracle, Ownable, Initializable {
    /// @dev Maximum quote token amount to contribute
    uint256 private _maxAddressCap;
    /// @dev Flag for locked period
    bool private _locked;
    /// @dev Token token contract address
    uint256 private _whitelistCount;
    /// @dev Max index allowed
    uint256 private _allowedWhitelistIndex;
    /// @dev Whitelist index for each whitelisted address
    mapping(address => uint256) private _whitelistIndex;

    mapping(address => uint256) private _contributed;

    constructor() {
        _disableInitialize();
    }

    /// @notice Check if called from token contract.
    modifier onlyToken() {
        require(_msgSender() == token, "not token");
        _;
    }

    function initialize(InitializeParams calldata params) external override whenNotInitialized() {
        _maxAddressCap = params.maxAddressCap;
        token = params.token;
        pool = params.pool;
        quoteToken = params.quoteToken;
        _allowedWhitelistIndex = params.allowedWhitelistIndex;
        _locked = params.lockBuy; // Initially, liquidity will be locked
        transferOwnership(params.owner);
    }

    /// @notice Returns max address cap
    function maxAddressCap() external view returns (uint256) {
        return _maxAddressCap;
    }

    /// @notice Returns the whitelisted index. If not whitelisted, then it will be 0
    /// @param account The address to be checked
    function whitelistIndex(address account) external view returns (uint256) {
        return _whitelistIndex[account];
    }

    /// @notice Returns current whitelisted address count
    function whitelistCount() external view returns (uint256) {
        return _whitelistCount;
    }

    /// @notice Returns current allowed whitelist index
    function allowedWhitelistIndex() external view returns (uint256) {
        return _allowedWhitelistIndex;
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
    function setToken(address newToken) external onlyOwner {
        token = newToken;
    }

    /// @notice Setter for Univ3 pool
    /// @param newPool New pool address
    function setPool(address newPool) external onlyOwner {
        pool = newPool;
    }

    /// @notice Setter for allowed whitelist index
    /// @param newIndex New index for allowed whitelist
    function setAllowedWhitelistIndex(uint256 newIndex) external onlyOwner {
        _allowedWhitelistIndex = newIndex;
    }

    /// @notice Add whitelisted address
    /// @param whitelisted Address to be added
    function addWhitelistedAddress(address whitelisted) external onlyOwner {
        _addWhitelistedAddress(whitelisted);
    }

    /// @notice Add batch whitelists
    /// @param whitelisted Array of addresses to be added
    function addBatchWhitelist(address[] calldata whitelisted) external onlyOwner {
        for (uint i = 0; i < whitelisted.length; i++) {
            _addWhitelistedAddress(whitelisted[i]);
        }
    }

    /// @notice Check if address to is eligible for whitelist
    /// @param from sender address
    /// @param to recipient address
    /// @param amount Number of tokens to be transferred
    /// @dev Check WL should be applied only
    /// @dev Revert if locked, not whitelisted or already contributed more than capped amount
    /// @dev Update contributed amount
    function checkWhitelist(address from, address to, uint256 amount) external override onlyToken {
        if (from == pool && to != owner()) {
            // We only add limitations for buy actions via uniswap v3 pool
            // Still need to ignore WL check if it's owner related actions
            require(!_locked, "locked");

            if (
                _allowedWhitelistIndex == 0 || _whitelistIndex[to] == 0 || _whitelistIndex[to] > _allowedWhitelistIndex
            ) {
                revert("not whitelisted");
            }

            // // Calculate rough ETH amount for TK amount
            uint256 estimatedETHAmount = peek(amount);
            if (_contributed[to] + estimatedETHAmount > _maxAddressCap) {
                revert("exceed cap");
            }

            _contributed[to] += estimatedETHAmount;
        }
    }

    /// @notice Internal function used for whitelisting. Only increase whitelist count if address is not whitelisted before
    /// @param whitelisted Address to be added
    function _addWhitelistedAddress(address whitelisted) private {
        if (_whitelistIndex[whitelisted] == 0) {
            _whitelistIndex[whitelisted] = ++_whitelistCount;
        }
    }
}
