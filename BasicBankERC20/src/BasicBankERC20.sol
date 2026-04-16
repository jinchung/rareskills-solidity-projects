// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Create a Basic Bank that allows the user to deposit and withdraw any ERC20 token
// Disallow any fee on transfer tokens
contract BasicBankERC20 {
    using SafeERC20 for IERC20;

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);

    error FeeOnTransferNotSupported();
    error InsufficientBalance();

    mapping(address => mapping(address => uint256)) public userTokenBalance;

    /*
     * @notice Deposit any ERC20 token into the bank
     * @dev reverts with FeeOnTransferNotSupported if the token is a fee on transfer token
     * @param token The address of the token to deposit
     * @param amount The amount of tokens to deposit
     */
    function deposit(address token, uint256 amount) external {
      address bankAddress = address(this);
      IERC20 anyToken = IERC20(token);
      // check my balance of this token before I do this deposit
      uint256 existingBalance = anyToken.balanceOf(bankAddress);
      // token - transfer it from user to me the bank
      anyToken.safeTransferFrom(msg.sender, bankAddress, amount);
      // check my balance of this token after
      uint256 postBalance = anyToken.balanceOf(bankAddress);
      uint256 balanceDifference = postBalance - existingBalance;
      // if my balance is not what I expect, revert with FeeOnTransferNotSupported();
      require(balanceDifference == amount, FeeOnTransferNotSupported());
      userTokenBalance[msg.sender][token] = amount;
      emit Deposit(msg.sender, token, amount);
    }

    /*
     * @notice Withdraw any ERC20 token from the bank
     * @dev reverts with InsufficientBalance() if the user does not have enough balance
     * @param token The address of the token to withdraw
     * @param amount The amount of tokens to withdraw
     */
    function withdraw(address token, uint256 amount) external {
      address bankAddress = address(this);
      require(userTokenBalance[msg.sender][token] >= amount, InsufficientBalance());
      IERC20 anyToken = IERC20(token);
      anyToken.transfer(msg.sender, amount);
      userTokenBalance[msg.sender][token] -= amount;
      emit Withdraw(msg.sender, token, amount);
    }
}
