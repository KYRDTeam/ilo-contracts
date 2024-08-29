// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { ITokenFactory } from './interfaces/ITokenFactory.sol';
import { ChainId } from './libraries/ChainId.sol';
import { PoolAddress } from './libraries/PoolAddress.sol';
import { Initializable } from './base/Initializable.sol';
import { ERC20Standard } from './base/ERC20Standard.sol';
import { ERC20Whitelist } from './ERC20Whitelist.sol';
import { OracleWhitelist } from './OracleWhitelist.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract TokenFactory is Ownable, ITokenFactory, Initializable {
    uint256 private _nonce = 1;
    address public override uniswapV3Factory;

    constructor() {
        transferOwnership(tx.origin);
    }

    function initialize(
        address _owner,
        address _uniswapV3Factory
    ) external override whenNotInitialized {
        transferOwnership(_owner);
        uniswapV3Factory = _uniswapV3Factory;
    }

    /// @notice Create a new ERC20 token and its corresponding whitelist contract
    function createWhitelistContracts(
        CreateWhitelistContractsParams calldata params
    ) external override returns (address token, address whitelistAddress) {
        bytes32 salt = keccak256(
            abi.encodePacked(msg.sender, ChainId.get(), _nonce++)
        );

        // deploy token
        ERC20Whitelist _token = new ERC20Whitelist{ salt: salt }(
            address(this),
            params.name,
            params.symbol,
            params.totalSupply
        );
        token = address(_token);

        // deploy whitelist
        address pool = PoolAddress.computeAddress(
            uniswapV3Factory,
            PoolAddress.getPoolKey(token, params.quoteToken, params.fee)
        );
        OracleWhitelist _whitelist = new OracleWhitelist{ salt: salt }(
            address(this),
            pool,
            params.quoteToken,
            params.lockBuy,
            params.maxAddressCap
        );
        whitelistAddress = address(_whitelist);

        _token.setWhitelistContract(whitelistAddress);
        _whitelist.setToken(token);

        _token.transferOwnership(msg.sender);
        _token.transfer(msg.sender, params.totalSupply);
        _whitelist.transferOwnership(msg.sender);

        emit TokenCreated(
            token,
            CreateERC20WhitelistTokenParams({
                name: params.name,
                symbol: params.symbol,
                totalSupply: params.totalSupply,
                whitelistContract: whitelistAddress
            })
        );

        emit OracleWhitelistCreated(
            whitelistAddress,
            CreateOracleWhitelistParams({
                maxAddressCap: params.maxAddressCap,
                token: token,
                pool: pool,
                quoteToken: params.quoteToken,
                lockBuy: params.lockBuy
            })
        );
    }

    function createStandardERC20Token(
        CreateStandardERC20TokenParams calldata params
    ) external override returns (address token) {
        bytes32 salt = keccak256(
            abi.encodePacked(msg.sender, ChainId.get(), _nonce++)
        );
        token = address(
            new ERC20Standard{ salt: salt }(
                msg.sender,
                params.name,
                params.symbol,
                params.totalSupply
            )
        );
        emit TokenCreated(
            token,
            CreateERC20WhitelistTokenParams({
                name: params.name,
                symbol: params.symbol,
                totalSupply: params.totalSupply,
                whitelistContract: address(0)
            })
        );
    }
}
