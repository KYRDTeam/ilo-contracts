// SPDX-License-Identifier: MIT 
pragma solidity =0.7.6;
pragma abicoder v2;

import "./interfaces/IILOManager.sol";

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';


contract ILOManager is IILOManager {

    mapping(address => Project) _cachedProject;

    address private _uniV3Factory;

    constructor(address uniV3Factory) {
        _uniV3Factory = uniV3Factory;
    }

    function initProject (
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint64 refundDeadline,
        uint8 investorShares,  // percentage of user shares
        LinearVest[] calldata projectVestConfigs
    ) external override returns(address uniV3PoolAddress) {

        _validateSharesPercentage(investorShares, projectVestConfigs);
        require(launchTime < refundDeadline, "invalid launch time");

        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(saleToken, raiseToken, fee);
        uniV3PoolAddress = _initUniV3PoolIfNecessary(poolKey, initialPoolPriceX96);
        
        _cacheProject(uniV3PoolAddress, saleToken, raiseToken, fee, initialPoolPriceX96, launchTime, refundDeadline, investorShares, projectVestConfigs);
    }

    function project(address uniV3PoolAddress) external override view returns (Project memory) {
        return _cachedProject[uniV3PoolAddress];
    }

    function initILOPool(
        uint256 projectId,
        address poolAdmin,
        int24 tickLower,
        int24 tickUpper,
        uint256 hardCap, // total amount of raise tokens
        uint256 softCap, // minimum amount of raise token needed for launch pool
        uint256 maxCapPerUser, // TODO: user tiers
        uint64 start,
        uint64 end,
        LinearVest[] calldata investorVestConfigs
    ) external override {
        // TODO: implement
    }

    function _initUniV3PoolIfNecessary(PoolAddress.PoolKey memory poolKey, uint160 sqrtPriceX96) internal returns (address pool) {
        pool = IUniswapV3Factory(_uniV3Factory).getPool(poolKey.token0, poolKey.token1, poolKey.fee);
        if (pool == address(0)) {
            pool = IUniswapV3Factory(_uniV3Factory).createPool(poolKey.token0, poolKey.token1, poolKey.fee);
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool).slot0();
            if (sqrtPriceX96Existing == 0) {
                IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            } else if (sqrtPriceX96Existing != sqrtPriceX96) {
                revert("uni v3 pool already exists");
            }
        }
    }

    function _cacheProject(
        address uniV3PoolAddress,
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint64 refundDeadline,
        uint8 investorShares,  // percentage of user shares
        LinearVest[] calldata projectVestConfigs
    ) internal {
        Project storage _project = _cachedProject[uniV3PoolAddress];
        require(_project.uniV3PoolAddress != address(0), "project already initialized");

        uint256 projectVestConfigsLength = projectVestConfigs.length;
        for (uint256 index = 0; index < projectVestConfigsLength; index++) {
            _project.projectVestConfigs.push(projectVestConfigs[index]);
        }

        _project.saleToken = saleToken;
        _project.raiseToken = raiseToken;
        _project.fee = fee;
        _project.initialPoolPriceX96 = initialPoolPriceX96;
        _project.launchTime = launchTime;
        _project.refundDeadline = refundDeadline;
        _project.investorShares = investorShares;
        _project.uniV3PoolAddress = uniV3PoolAddress;

        _cachedProject[uniV3PoolAddress] = _project;
    }

    function _validateSharesPercentage(uint8 investorShares, LinearVest[] calldata projectVestConfigs) internal pure {
        require(investorShares <= 100);
        uint8 totalShares = investorShares;
        uint256 configLength = projectVestConfigs.length;
        for (uint256 index = 0; index < configLength; index++) {
            require(100 - totalShares >= projectVestConfigs[index].percentage);
            totalShares += projectVestConfigs[index].percentage;
        }
    }
}