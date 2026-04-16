// SPDX-License-Identifier: (c) RareSkills
pragma solidity 0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


// tokenA and tokenB are stablecoins, so they have the same value, but different
// decimals. This contract allows users to trade one token for another at equal rate
// after correcting for the decimals difference 
contract DecimalSwap {
    using SafeERC20 for IERC20Metadata;

    IERC20Metadata public immutable tokenA;
    IERC20Metadata public immutable tokenB;

    constructor(address tokenA_, address tokenB_) {
      tokenA = IERC20Metadata(tokenA_);
      tokenB = IERC20Metadata(tokenB_);
    }

    function swapAtoB(uint256 amountIn) external {
      swapTokenToToken(tokenA, tokenB, amountIn);
    }

    function swapBtoA(uint256 amountIn) external {
      swapTokenToToken(tokenB, tokenA, amountIn);
    }

    function swapTokenToToken(IERC20Metadata tokenIn, IERC20Metadata tokenOut, uint256 amountIn) private {
      // convert tokenIn amountIn to tokenOut amountOut
      uint256 tokenOutDecimals = uint256(tokenOut.decimals());
      uint256 tokenInDecimals = uint256(tokenIn.decimals());
      uint256 amountOut = (amountIn * 10**tokenOutDecimals) / (10**tokenInDecimals);
      address me = address(this);

      // transfer tokenIn from the user
      tokenIn.safeTransferFrom(msg.sender, me, amountIn);

      // transfer tokenOut to the user
      tokenOut.transfer(msg.sender, amountOut);
    }
}
