// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import {IERC20Whitelist} from "../interfaces/IERC20Whitelist.sol";
import {IOracleWhitelist} from "../interfaces/IOracleWhitelist.sol";

interface ITokenFactory {
    event TokenCreated(address indexed tokenAddress, IERC20Whitelist.InitializeParams params);
    event OracleWhitelistCreated(address indexed whitelistAddress, IOracleWhitelist.InitializeParams params);
    event ERC20WhitelistImplementationSet(address oldImplementation, address newImplementation);
    event OracleWhitelistImplementationSet(address oldImplementation, address newImplementation);

    struct CreateWhitelistContractsParams {
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 maxAddressCap;
        address quoteToken;
        uint256 allowedWhitelistIndex;
        bool lockBuy;

        uint24 fee;
    }

    function uniswapV3Factory() external view returns (address);
    function erc20WhitelistImplementation() external view returns (address);
    function oracleWhitelistImplementation() external view returns (address);

    function setERC20WhitelistImplementation(address _erc20WhitelistImplementation) external;
    function setOracleWhitelistImplementation(address _oracleWhitelistImplementation) external;

    function createERC20WhitelistToken(IERC20Whitelist.InitializeParams calldata params) external returns (address token);
    function createOracleWhitelist(IOracleWhitelist.InitializeParams calldata params) external returns (address whitelistAddress);
    function createWhitelistContracts(CreateWhitelistContractsParams calldata params) external returns (address token, address whitelistAddress);
    function createStarndardERC20Token(string calldata name, string calldata symbol, uint256 totalSupply) external returns (address token);
}