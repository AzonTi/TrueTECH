pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TransferBot.sol";


contract TrueTECH is ERC20, ERC20Detailed, Ownable {
  using SafeMath for uint256;

  struct Treasure {
    uint256 value;
    uint8 count;
    uint8 limit;
  }

  TransferBot richman;
  address[] players;
  mapping(bytes32 => address) private playerFromHash;
  Treasure[] treasures;
  mapping(bytes32 => Treasure) private treasureFromHash;

  constructor(address newRichman, address[] newPlayers, uint256[] newTrValues, uint8[] newTrLimits, bytes32[] hashTable)
    public
    ERC20Detailed("TrueTECH", "TTECH", 2)
  {
    require(newTrValues.length == newTrLimits.length, "invalid newTrLimits");
    require(newPlayers.length * newTrValues.length == hashTable.length, "invalid hashTable");
    richman = TransferBot(newRichman);
    _mint(richman, uint256(10**9).sub(newPlayers.length.mul(10**3)));
    for (uint i = 0; i < newPlayers.length; i++) {
      _mint(newPlayers[i], 10**3);
      players.push(newPlayers[i]);
      for (uint j = 0; j < newTrValues.length; j++) {
        playerFromHash[hashTable[i * newTrValues.length + j]] = newPlayers[i];
        Treasure memory newTreasure;
        newTreasure.value = newTrValues[j];
        newTreasure.limit = newTrLimits[j];
        treasures.push(newTreasure);
        treasureFromHash[hashTable[i * newTrValues.length + j]] = newTreasure;
      }
    }
  }

  function addPlayers(address[] newPlayers, bytes32[] hashTable)
    public
    onlyOwner
  {
    require(newPlayers.length * treasures.length == hashTable.length, "invalid hashTable");
    for (uint i = 0; i < newPlayers.length; i++) {
      richman.transfer(newPlayers[i], 10**3);
      players.push(newPlayers[i]);
      for (uint j = 0; j < treasures.length; j++) {
        playerFromHash[hashTable[i * treasures.length + j]] = newPlayers[i];
        treasureFromHash[hashTable[i * treasures.length + j]] = treasures[j];
      }
    }
  }

  function addTreasures(uint256[] newTrValues, uint8[] newTrLimits, bytes32[] hashTable)
    public
    onlyOwner
  {
    require(newTrValues.length == newTrLimits.length, "invalid newTrLimits");
    require(players.length * newTrValues.length == hashTable.length, "invalid hashTable");
    for (uint i = 0; i < players.length; i++) {
      for (uint j = 0; j < newTrValues.length; j++) {
        playerFromHash[hashTable[i * newTrValues.length + j]] = players[i];
        Treasure memory newTreasure;
        newTreasure.value = newTrValues[j];
        newTreasure.limit = newTrLimits[j];
        treasures.push(newTreasure);
        treasureFromHash[hashTable[i * newTrValues.length + j]] = newTreasure;
      }
    }
  }

  function transfer(address to, uint256 value)
    public
    returns (bool)
  {
    bytes32 hash = keccak256(abi.encodePacked(to));
    Treasure memory treasure = treasureFromHash[hash];
    if (msg.sender == playerFromHash[hash] && treasure.count < treasure.limit) {
      richman.transfer(msg.sender, treasure.value.mul(value));
      playerFromHash[hash] = address(0);
      treasure.count++;
    }

    return super.transfer(to, value);
  }
}
