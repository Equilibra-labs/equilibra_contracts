// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {OwnableUpgradeable} from "@oz-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@oz-upgradeable/security/PausableUpgradeable.sol";
import {Initializable} from "@oz-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {BeaconProxy} from "@oz/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@oz/proxy/beacon/UpgradeableBeacon.sol";

import {MimeToken, MimeTokenFactory} from "libr/mime/MimeTokenFactory.sol";

import {OwnableProjectList} from "./projects/OwnableProjectList.sol";

import {OsmoticPool, OsmoticParams} from "./OsmoticPool.sol";



contract OsmoticController is Initializable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    uint256 public immutable version;
    uint256 public immutable claimTimestamp;
    address public immutable projectRegistry;
    address public immutable mimeTokenFactory;
    UpgradeableBeacon public immutable beacon;

    uint256 public claimDuration;

    /**
     * @notice Aca mover todos estos a un struct con unico mapping ybagregar getters 
     * @custom:razon := Para no ocupar slots de memoria al pedo
     *  mapping(address => bool) public isPool;
     *  mapping(address => bool) public isList
     *  mapping(address => bool) public isToken
     * @custom:problema De la forma anterior se ocupan 3 slots de memoria diferentes con un solo byte ocupado (de 32)
     * @custom:sol Armamos un struct que contenga las 3 variables y las poenmos en el mismo mapping, asi ocupamos 3/32 de un unico slot de memoria.
     * Agregamos los getters, con el mismo nombre y funcion. Esto no modifica mucho el bytecode del contrato ya que al hacer un mapping `public` le carga un bytecode interesante para devolver el valor
     * 
    */
    struct AddrInfo {
        // Slot0 := 3/32 bytes
        bool isPool;
        bool isList;
        bool isToken;
    }



    mapping (address => AddrInfo) internal addressInfo;

    function isPool(address _poolAddr)external view  returns (bool) {
        return addressInfo[_poolAddr].isPool;
    }
    function isList(address _listAddr)external view  returns (bool) {
        return addressInfo[_listAddr].isList;
    }
    function isToken(address _tokenAdd)external view  returns (bool) {
        return addressInfo[_poolA_tokenAddddr].isToken;
    }
    function getAddInfo(address _addr) external view returns (AddrInfo memory) {
        return addressInfo[_addr];
    }


    /* *************************************************************************************************************************************/
    /* ** Events                                                                                                                         ***/
    /* *************************************************************************************************************************************/

    event MimeTokenCreated(address indexed token);
    event OsmoticPoolCreated(address indexed pool);
    event ProjectListCreated(address indexed list);

    constructor(uint256 _version, address _osmoticPool, address _projectRegistry, address _mimeTokenFactory) {
        _disableInitializers();

        beacon = new UpgradeableBeacon(_osmoticPool);
        // We transfer the ownership of the beacon to the deployer
        beacon.transferOwnership(msg.sender);

        version = _version;
        claimTimestamp = block.timestamp;
        projectRegistry = _projectRegistry;
        mimeTokenFactory = _mimeTokenFactory;
    }

    function initialize(uint256 _claimDuration) public initializer {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        claimDuration = _claimDuration;
        // We set the registry as the default list
        // AddrInfo memory _addInfo= AddrInfo(false,false,false);
        // _addInfo.isList=true;
        addressInfo[projectRegistry].isList= true;
    }

    /* *************************************************************************************************************************************/
    /* ** Pausability Functions                                                                                                          ***/
    /* *************************************************************************************************************************************/

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /* *************************************************************************************************************************************/
    /* ** Upgradeability Functions                                                                                                       ***/
    /* *************************************************************************************************************************************/

    function implementation() external view returns (address) {
        return _getImplementation();
    }

    function osmoticPoolImplementation() external view returns (address) {
        return beacon.implementation();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /* *************************************************************************************************************************************/
    /* ** Setter Functions                                                                                                               ***/
    /* *************************************************************************************************************************************/

    function setClaimDuration(uint256 _claimDuration) external onlyOwner {
        claimDuration = _claimDuration;
    }

    /* *************************************************************************************************************************************/
    /* ** Creation Functions                                                                                                             ***/
    /* *************************************************************************************************************************************/

    function createProjectList(string calldata _name) external whenNotPaused returns (address list_) {
        list_ = address(new OwnableProjectList(projectRegistry, _name));

        OwnableProjectList(list_).transferOwnership(msg.sender);
        
        // AddrInfo memory _addInfo= AddrInfo(false,false,false);
        // _addInfo.isList=true;
        // addressInfo[list_]= _addInfo;
        addressInfo[pool_].isList= true;

        // isList[list_] = true;

        emit ProjectListCreated(list_);
    }

    function createOsmoticPool(bytes calldata _initPayload) external whenNotPaused returns (address pool_) {
        pool_ = address(new BeaconProxy(address(beacon), _initPayload));

        OsmoticPool(pool_).transferOwnership(msg.sender);

        // AddrInfo memory _addInfo= AddrInfo(false,false,false);
        // _addInfo.isPool=true;
        // addressInfo[pool_]= _addInfo;
        addressInfo[pool_].isPool= true;

        // isPool[pool_] = true;

        emit OsmoticPoolCreated(pool_);
    }

    function createMimeToken(bytes calldata _initPayload) external whenNotPaused returns (address token_) {
        token_ = MimeTokenFactory(mimeTokenFactory).createMimeToken(_initPayload);

        require(MimeToken(token_).timestamp() == claimTimestamp, "OsmoticController: Invalid timestamp for token");
        require(
            MimeToken(token_).roundDuration() == claimDuration, "OsmoticController: Invalid round duration for token"
        );

        MimeToken(token_).transferOwnership(msg.sender);

        // isToken[token_] = true;
        addressInfo[token_].isToken= true;


        emit MimeTokenCreated(token_);
    }
}