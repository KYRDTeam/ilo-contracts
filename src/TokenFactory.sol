// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import {ITokenFactory, IERC20Whitelist, IOracleWhitelist} from "./interfaces/ITokenFactory.sol";
import {ChainId} from "./libraries/ChainId.sol";
import {PoolAddress} from "./libraries/PoolAddress.sol";
import {Initializable} from "./base/Initializable.sol";
import {ERC20Standard} from "./base/ERC20Standard.sol";
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/proxy/Clones.sol';


contract TokenFactory is Ownable, ITokenFactory, Initializable {
    uint256 private nonce = 1;
    address public override erc20WhitelistImplementation;
    address public override oracleWhitelistImplementation;
    address public override uniswapV3Factory;

    constructor() {
        transferOwnership(tx.origin);
    }

    function initialize(address _erc20WhitelistImplementation, address _oracleWhitelistImplementation, address _uniswapV3Factory) external whenNotInitialized() {
        erc20WhitelistImplementation = _erc20WhitelistImplementation;
        oracleWhitelistImplementation = _oracleWhitelistImplementation;
        uniswapV3Factory = _uniswapV3Factory;
    }

    // Set the implementation address for the ERC20Whitelist contract
    function setERC20WhitelistImplementation(address _erc20WhitelistImplementation) external override onlyOwner {
        emit ERC20WhitelistImplementationSet(erc20WhitelistImplementation, _erc20WhitelistImplementation);
        erc20WhitelistImplementation = _erc20WhitelistImplementation;
    }

    // Set the implementation address for the OracleWhitelist contract
    function setOracleWhitelistImplementation(address _oracleWhitelistImplementation) external override onlyOwner {
        emit OracleWhitelistImplementationSet(oracleWhitelistImplementation, _oracleWhitelistImplementation);
        oracleWhitelistImplementation = _oracleWhitelistImplementation;
    }

    function createERC20WhitelistToken(IERC20Whitelist.InitializeParams calldata params) external override returns (address token) {
        // adding the salt to the address to make it cross-chain unique
        bytes32 salt = keccak256(abi.encodePacked(
                ChainId.get(),
                nonce++
            ));
        token = Clones.cloneDeterministic(erc20WhitelistImplementation, salt);
        IERC20Whitelist(token).initialize(params);
        emit TokenCreated(token, params);
    }

    function createOracleWhitelist(IOracleWhitelist.InitializeParams calldata params) external override returns (address whitelistAddress) {
        // adding the salt to the address to make it cross-chain unique
        bytes32 salt = keccak256(abi.encodePacked(
                ChainId.get(),
                nonce++
            ));
        whitelistAddress = Clones.cloneDeterministic(oracleWhitelistImplementation, salt);
        IOracleWhitelist(whitelistAddress).initialize(params);
        emit OracleWhitelistCreated(whitelistAddress, params);
    }

    /// @notice Create a new ERC20 token and its corresponding whitelist contract
    function createWhitelistContracts(CreateWhitelistContractsParams calldata params) external override returns (address token, address whitelistAddress) {
        bytes32 salt = keccak256(abi.encodePacked(
                ChainId.get(),
                nonce++
            ));
        token = Clones.cloneDeterministic(erc20WhitelistImplementation, salt);

        whitelistAddress = Clones.cloneDeterministic(oracleWhitelistImplementation, salt);

        IERC20Whitelist.InitializeParams memory createTokenParams = IERC20Whitelist.InitializeParams({
            name: params.name,
            symbol: params.symbol,
            totalSupply: params.totalSupply,
            owner: msg.sender,
            whitelistContract: whitelistAddress
        });
        IERC20Whitelist(token).initialize(createTokenParams);
        emit TokenCreated(token, createTokenParams);

        address pool = PoolAddress.computeAddress(uniswapV3Factory ,PoolAddress.PoolKey({
            token0: token,
            token1: params.quoteToken,
            fee: params.fee
        }));

        IOracleWhitelist.InitializeParams memory createWhitelistParams = IOracleWhitelist.InitializeParams({
            maxAddressCap: params.maxAddressCap,
            token: token,
            pool: pool,
            quoteToken: params.quoteToken,
            allowedWhitelistIndex: params.allowedWhitelistIndex,
            owner: msg.sender,
            lockBuy: params.lockBuy
        });
        IOracleWhitelist(whitelistAddress).initialize(createWhitelistParams);
        emit OracleWhitelistCreated(whitelistAddress, createWhitelistParams);
    }

    function createStarndardERC20Token(string calldata name, string calldata symbol, uint256 totalSupply) external override returns (address token) {
        bytes32 salt = keccak256(abi.encodePacked(
                ChainId.get(),
                nonce++
            ));
        token = address(new ERC20Standard{
            salt: salt
        }(msg.sender, name, symbol, totalSupply));
        emit TokenCreated(token, IERC20Whitelist.InitializeParams({
            name: name,
            symbol: symbol,
            totalSupply: totalSupply,
            owner: msg.sender,
            whitelistContract: address(0)
        }));
    }
}