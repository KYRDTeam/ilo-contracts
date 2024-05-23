// SPDX-License-Identifier: MIT 
pragma solidity =0.7.6;
pragma abicoder v2;

import "./interfaces/IILOManager.sol";
import "./interfaces/IILOPool.sol";
import "./libraries/ChainId.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/proxy/Clones.sol';

contract ILOManager is IILOManager, Ownable {

    event PoolImplementationChanged(address indexed oldPoolImplementation, address indexed newPoolImplementation);
    event ProjectAdminChanged(address indexed uniV3PoolAddress, address oldAdmin, address newAdmin);
    uint16 constant BPS = 10000;
    uint16 PLATFORM_FEE;
    address ILO_POOL_IMPLEMENTATION;
    address private _uniV3Factory;

    mapping(address => Project) private _cachedProject; // map uniV3Pool => project (aka projectId => project)
    mapping(address => address[]) private _initializedILOPools; // map uniV3Pool => list of initialized ilo pools

    constructor(
        address initialOwner, 
        address uniV3Factory, 
        uint16 platformFee
    ) {
        PLATFORM_FEE = platformFee;
        transferOwnership(initialOwner);
        _uniV3Factory = uniV3Factory;
    }

    modifier onlyProjectAdmin(address uniV3Pool) {
        require(_cachedProject[uniV3Pool].admin == msg.sender, "unauthorized");
        _;
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

    function initILOPool(InitPoolParams calldata params) external override onlyProjectAdmin(params.uniV3Pool) {
        require(ILO_POOL_IMPLEMENTATION != address(0), "no pool implementation!");

        // this salt make sure that pool address can not be represented in any other chains
        bytes32 salt = keccak256(abi.encodePacked(
            ChainId.get(),
            params.uniV3Pool,
            _initializedILOPools[params.uniV3Pool].length
        ));
        address iloPoolAddress = Clones.cloneDeterministic(ILO_POOL_IMPLEMENTATION, salt);
        IILOPool(iloPoolAddress).initialize(params);
        _initializedILOPools[params.uniV3Pool].push(iloPoolAddress);
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

        _project.platformFee = PLATFORM_FEE;
        _project.admin = msg.sender;
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
        require(investorShares <= BPS);
        uint8 totalShares = investorShares;
        uint256 configLength = projectVestConfigs.length;
        for (uint256 index = 0; index < configLength; index++) {
            require(BPS - totalShares >= projectVestConfigs[index].shares);
            totalShares += projectVestConfigs[index].shares;
        }
    }

    function setPlatformFee(uint16 _platformFee) external onlyOwner() {
        PLATFORM_FEE = _platformFee;
    }

    function setILOPoolImplementation(address iloPoolImplementation) external onlyOwner() {
        emit PoolImplementationChanged(ILO_POOL_IMPLEMENTATION, iloPoolImplementation);
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
    }

    function transferAdminProject(address admin, address uniV3Pool) external {
        Project storage _project = _cachedProject[uniV3Pool];
        require(msg.sender == _project.admin);
        _project.admin = admin;
        _cachedProject[uniV3Pool] = _project;
        emit ProjectAdminChanged(uniV3Pool, msg.sender, _project.admin);
    }
}
