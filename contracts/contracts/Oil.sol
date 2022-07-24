// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IMintable.sol";
import "./ITokenRecipient.sol";

contract Oil is ERC20, Ownable, IMintableWithAmount {
    mapping (address => bool) public minters;
    mapping (address => bool) public burners;
    bool public canHoldersBurn;
    uint256 public totalSupplyLimit;

    constructor(address team) ERC20("Oil", "OIL") {
        setMinter(msg.sender, true);
        totalSupplyLimit = 1000000000 ether;
        uint256 teamAmount = 50000000 ether;
        _mint(team, teamAmount);
    }

    function approveAndCall(address spenderContract, uint256 amount, bytes memory extraData) public {
        require(Address.isContract(spenderContract), "Spender not contract");

        approve(spenderContract, amount);

        ITokenRecipient(spenderContract).receiveApproval(msg.sender, amount, address(this), extraData);
    }

    function mint(address to, uint256 amount) public override {
        require(minters[msg.sender], "Not minter");
        require(totalSupply() + amount <= totalSupplyLimit, "Limit reached");

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(burners[msg.sender], "Not burner");
        _burn(from, amount);
    }

    function burn(uint256 amount) public {
        require(canHoldersBurn, "Burn not allowed");
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        require(canHoldersBurn, "Burn not allowed");

        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    function setMinter(address to, bool canMint) public onlyOwner {
        require(to != address(0), "Addr is zero");
        minters[to] = canMint;
    }

    function setBurner(address to, bool canBurn) public onlyOwner {
        require(to != address(0), "Addr is zero");
        burners[to] = canBurn;
    }

    function setCanHoldersBurn(bool canBurn) public onlyOwner {
        canHoldersBurn = canBurn;
    }
}