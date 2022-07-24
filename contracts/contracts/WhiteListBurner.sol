// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Whitelist.sol";
import "./Enums.sol";

contract WhiteListBurner is Ownable {
    Whitelist public whitelist;
    IERC20 public starDust;

    address public profitStardustAddress;
    bool public isContractActive = true;

    mapping (uint256 => uint256) public starDustRewardByWhitelistType;

    event ContractActivityChanged(bool indexed newActiveStatus, address indexed caller);
    event ProfitStardustAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event EasterEggBurned(uint256 indexed easterEggType, uint256 indexed easterEggId);

    constructor(Whitelist whitelist_, IERC20 starDust_, address profitStardustAddress_) {
        require(address(starDust_) != address(0), "SD is zero");

        setWhitelist(whitelist_);
        starDust = starDust_;

        setProfitStardustAddress(profitStardustAddress_);

        starDustRewardByWhitelistType[WHITELIST_GOLD] = 2100 ether;
        starDustRewardByWhitelistType[WHITELIST_SILVER] = 1300 ether;
        starDustRewardByWhitelistType[WHITELIST_EPIC] = 3800 ether;
        starDustRewardByWhitelistType[WHITELIST_BRONZE] = 700 ether;
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        emit ContractActivityChanged(isContractActive_, msg.sender);
        isContractActive = isContractActive_;
    }

    function setWhitelist(Whitelist whitelist_) public onlyOwner {
        require(address(whitelist_) != address(0), "Whitelist is zero");
        whitelist = whitelist_;
    }

    function setProfitStardustAddress(address newProfitStardustAddress) public onlyOwner {
        require(newProfitStardustAddress != address(0), "ProfitStardust is zero");
        emit ProfitStardustAddressChanged(profitStardustAddress, newProfitStardustAddress, msg.sender);
        profitStardustAddress = newProfitStardustAddress;
    }


    function setStardustReward(
        uint256 whitelistType,
        uint256 rewardStardustAmount) public onlyOwner {

        starDustRewardByWhitelistType[whitelistType] = rewardStardustAmount;
    }

    function burnWhitelist(uint256 whitelistId) public {
        require(isContractActive, "Not active");
        require(whitelistId > 0, "Whitelist id is invalid");
        require(msg.sender == whitelist.ownerOf(whitelistId), "Not an owner of the whitelist");

        uint256 whitelistType = whitelist.getTokenType(whitelistId);

        uint256 stardustReward = starDustRewardByWhitelistType[whitelistType];
        require(stardustReward > 0, "Looks like reward is not set or incorrect");
        starDust.transferFrom(profitStardustAddress, msg.sender, stardustReward);

        whitelist.burn(whitelistId);
    }
}
