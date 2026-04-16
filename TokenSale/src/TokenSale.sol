// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// the token should have a maximum supply of 100,000,000 tokens
// the token contract should have 10 decimals
// the price of one token should be 0.001 ether
// tokens should not exist until someone buys them using `buyTokens`
// users should also be able to buy tokens by sending ether to the contract
// then the contract calculates the amount of tokens to mint
contract TokenSale is ERC20("TokenSale", "TS") {
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 10;
    uint256 public constant PRICE_PER_UNIT = 0.001 ether / 10**10;

    error MaxSupplyReached();

    function decimals() public pure override returns (uint8) {
      return 10;
    }

    function buyTokens() public payable returns (bool) {
      uint256 tokensToMint = msg.value / PRICE_PER_UNIT;
      _mint(msg.sender, tokensToMint);
    }

    receive() external payable {
      buyTokens();
    }

    function _update(address from, address to, uint256 value) internal override {
      if (from == address(0)) {
        require(totalSupply() + value <= MAX_SUPPLY, MaxSupplyReached());
      }
      super._update(from, to, value);
    }
}
