// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

interface ITokenFactory {
    struct CreateOracleWhitelistParams {
        uint256 maxAddressCap;
        address token;
        address pool;
        address quoteToken;
        bool lockBuy;
    }

    struct CreateERC20WhitelistTokenParams {
        string name;
        string symbol;
        uint256 totalSupply;
        address whitelistContract;
    }

    struct CreateStarndardERC20TokenParams {
        string name;
        string symbol;
        uint256 totalSupply;
    }

    event TokenCreated(address indexed tokenAddress, CreateERC20WhitelistTokenParams params);
    event OracleWhitelistCreated(address indexed whitelistAddress, CreateOracleWhitelistParams params);
    event ERC20WhitelistImplementationSet(address oldImplementation, address newImplementation);
    event OracleWhitelistImplementationSet(address oldImplementation, address newImplementation);

    struct CreateWhitelistContractsParams {
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 maxAddressCap;
        address quoteToken;
        bool lockBuy;

        uint24 fee;
    }

    function uniswapV3Factory() external view returns (address);

    function createWhitelistContracts(CreateWhitelistContractsParams calldata params) external returns (address token, address whitelistAddress);
    function createStandardERC20Token(CreateStarndardERC20TokenParams calldata params) external returns (address token);

    function initialize(address _owner, address _uniswapV3Factory) external;
}