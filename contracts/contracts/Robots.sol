// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Enums.sol";

contract Robots is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    
    struct RobotDetails {
        uint element;
        uint rarity;
        uint race;
        uint eggLevel;
        uint256 level;
        uint256 generation;
    }

    string private _robotBaseURI;
    Counters.Counter private _counter;
    mapping(uint256 => RobotDetails) public details;
    
    mapping(address => bool) public minters;

    constructor () ERC721("Moon Robots Robot", "MRR") {
        _robotBaseURI = "https://moonrobots.one/robot?tokenId=";
    }

    /// @dev Must be called only by hatchery
    function mint(address to, uint element, uint rarity, uint eggLevel, uint256 generation) external returns (uint256 robotId) {
        require(minters[msg.sender], "Not allowed");

        robotId = _counter.current();
        _mint(to, robotId);

        RobotDetails storage newDetails = details[robotId];
        newDetails.element = element;
        newDetails.rarity = rarity;
        newDetails.race = 0;
        newDetails.level = 0;
        newDetails.eggLevel = eggLevel;
        newDetails.generation = generation;

        // TODO Generate skills race and stats

        // TODO claim all OIL

        _counter.increment();
        return robotId;
    }

    /**
     * @dev See {ERC721-_baseURI}.
     */
    function _baseURI() internal view override returns (string memory) {
        return _robotBaseURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory uri) public onlyOwner {
        _robotBaseURI = uri;
    }

    function setMinter(address minter, bool enabled) public onlyOwner {
        minters[minter] = enabled;
    }
}
