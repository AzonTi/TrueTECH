pragma solidity ^0.4.24;

import "./TrueTECH.sol";

contract GameMaster {
  TrueTECH private token;

  constructor(address[] newPlayers, uint256[] newTrValues, uint8[] newTrLimits, bytes32[] hashTable)
    public
  {
    token = new TrueTECH(newPlayers, newTrValues, newTrLimits, hashTable);
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(msg.sender == address(token), "callable only by token");
    return token.approve(spender, value);
  }
}
