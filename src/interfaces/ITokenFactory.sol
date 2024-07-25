// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

interface ITokenFactory {
    struct CreateOracleWhitelistParams {
        address owner;
        uint256 maxAddressCap;
        address token;
        address pool;
        address quoteToken;
        bool lockBuy;
    }

    struct CreateERC20WhitelistTokenParams {
        address owner;
        string name;
        string symbol;
        uint256 totalSupply;
        address whitelistContract;
    }

    struct CreateStarndardERC20TokenParams {
        address owner;
        string name;
        string symbol;
        uint256 totalSupply;
    }

    event TokenCreated(address indexed tokenAddress, CreateERC20WhitelistTokenParams params);
    event OracleWhitelistCreated(address indexed whitelistAddress, CreateOracleWhitelistParams params);
    event ERC20WhitelistImplementationSet(address oldImplementation, address newImplementation);
    event OracleWhitelistImplementationSet(address oldImplementation, address newImplementation);

    struct CreateWhitelistContractsParams {
        address owner;
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

    function createERC20WhitelistToken(CreateERC20WhitelistTokenParams calldata params) external returns (address token);
    function createOracleWhitelist(CreateOracleWhitelistParams calldata params) external returns (address whitelistAddress);
    function createWhitelistContracts(CreateWhitelistContractsParams calldata params) external returns (address token, address whitelistAddress);
    function createStarndardERC20Token(CreateStarndardERC20TokenParams calldata params) external returns (address token);
}