// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import {ITokenFactory} from "./interfaces/ITokenFactory.sol";
import {ChainId} from "./libraries/ChainId.sol";
import {PoolAddress} from "./libraries/PoolAddress.sol";
import {Initializable} from "./base/Initializable.sol";
import {ERC20Standard} from "./base/ERC20Standard.sol";
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {ERC20Whitelist} from './ERC20Whitelist.sol';
import {OracleWhitelist} from './OracleWhitelist.sol';

contract TokenFactory is Ownable, ITokenFactory, Initializable {
    uint256 private nonce = 1;
    address public override uniswapV3Factory;

    constructor() {
        transferOwnership(tx.origin);
    }

    function initialize(address _owner, address _uniswapV3Factory) external whenNotInitialized() {
        transferOwnership(_owner);
        uniswapV3Factory = _uniswapV3Factory;
    }

    function createERC20WhitelistToken(CreateERC20WhitelistTokenParams calldata params) external override returns (address token) {
        // adding the salt to the address to make it cross-chain unique
        bytes32 salt = keccak256(abi.encodePacked(
                params.owner,
                ChainId.get(),
                nonce++
            ));
        ERC20Whitelist _token = new ERC20Whitelist{
            salt: salt
        }(params.owner, params.name, params.symbol, params.totalSupply);
        _token.setWhitelistContract(params.whitelistContract);
        token = address(_token);
        emit TokenCreated(token, params);
    }

    function createOracleWhitelist(CreateOracleWhitelistParams calldata params) external override returns (address whitelistAddress) {
        // adding the salt to the address to make it cross-chain unique
        bytes32 salt = keccak256(abi.encodePacked(
                params.owner,
                ChainId.get(),
                nonce++
            ));
        OracleWhitelist _whitelist = new OracleWhitelist{
            salt: salt
        }(params.owner, params.pool, params.quoteToken, params.lockBuy, params.maxAddressCap);
        _whitelist.setToken(params.token);
        whitelistAddress = address(_whitelist);
        emit OracleWhitelistCreated(whitelistAddress, params);
    }

    /// @notice Create a new ERC20 token and its corresponding whitelist contract
    function createWhitelistContracts(CreateWhitelistContractsParams calldata params) external override returns (address token, address whitelistAddress) {
        bytes32 salt = keccak256(abi.encodePacked(
                params.owner,
                ChainId.get(),
                nonce++
            ));

        // deploy token
        ERC20Whitelist _token = new ERC20Whitelist{
            salt: salt
        }(params.owner, params.name, params.symbol, params.totalSupply);
        token = address(_token);

        // deploy whitelist
        address pool = PoolAddress.computeAddress(uniswapV3Factory ,PoolAddress.PoolKey({
            token0: token,
            token1: params.quoteToken,
            fee: params.fee
        }));
        OracleWhitelist _whitelist = new OracleWhitelist{
            salt: salt
        }(params.owner, pool, params.quoteToken, params.lockBuy, params.maxAddressCap);
        whitelistAddress = address(_whitelist);

        _token.setWhitelistContract(whitelistAddress);
        _whitelist.setToken(token);

        emit TokenCreated(token, CreateERC20WhitelistTokenParams({
            owner: params.owner,
            name: params.name,
            symbol: params.symbol,
            totalSupply: params.totalSupply,
            whitelistContract: whitelistAddress
        }));

        emit OracleWhitelistCreated(whitelistAddress, CreateOracleWhitelistParams({
            owner: params.owner,
            maxAddressCap: params.maxAddressCap,
            token: token,
            pool: pool,
            quoteToken: params.quoteToken,
            lockBuy: params.lockBuy
        }));
    }

    function createStarndardERC20Token(CreateStarndardERC20TokenParams calldata params) external override returns (address token) {
        bytes32 salt = keccak256(abi.encodePacked(
                params.owner,
                ChainId.get(),
                nonce++
            ));
        token = address(new ERC20Standard{
            salt: salt
        }(params.owner, params.name, params.symbol, params.totalSupply));
        emit TokenCreated(token, CreateERC20WhitelistTokenParams({
            name: params.name,
            symbol: params.symbol,
            totalSupply: params.totalSupply,
            owner: params.owner,
            whitelistContract: address(0)
        }));
    }
}