pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract TransferBot is Ownable {
  constructor()
    public
  {}

  function transfer(address to, uint256 value)
    public
  {
    require(IERC20(msg.sender).transfer(to, value), "transfer() failed");
  }
}
