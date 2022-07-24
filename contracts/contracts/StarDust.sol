// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMintable.sol";

contract StarDust is ERC20, Ownable, IMintableWithAmount {
    mapping (address => bool) public minters;
    mapping (address => bool) public burners;

    constructor() ERC20("Stardust", "STARDUST") {
        setMinter(msg.sender, true);
    }

    function mint(address to, uint256 amount) public override {
        require(minters[msg.sender], "Not minter");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(burners[msg.sender], "Not burner");
        _burn(from, amount);
    }

    function setMinter(address to, bool canMint) public onlyOwner {
        require(to != address(0), "Addr is zero");
        minters[to] = canMint;
    }

    function setBurner(address to, bool canBurn) public onlyOwner {
        require(to != address(0), "Addr is zero");
        burners[to] = canBurn;
    }

}