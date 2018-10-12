const GameMaster = artifacts.require('./GameMaster.sol')
const keccak256 = require('js-sha3').keccak256

module.exports = function (deployer) {
  const treasures = [
    {
      secret: 'omaeno',
      value: 10,
      limit: 10
    }, {
      secret: 'system',
      value: 100,
      limit: 1
    }, {
      secret: 'gabagaba',
      value: 2,
      limit: 1000
    }, {
      secret: 'janeeka',
      value: 3,
      limit: 100
    }
  ]
  const players = [
    '0x8af550A98CD0fDD79c8C2186FFE8bBAe821A9952',
    '0x67cf56DB3b60E3A99ff802c54FD44C757ed63386'
  ]
  const hashTable = []
  for (const a of players.map(player => Uint8Array.from({ length: (player.length - 2) / 2 }, (e, i) => parseInt(player.substr(i * 2 + 2, 2), 16)))) {
    for (const b of treasures.map(treasure => Uint8Array.from(treasure.secret, (e, i) => e.charCodeAt()))) {
      const raw = new Uint8Array(a.length + b.length)
      raw.set(a)
      raw.set(b, a.length)
      hashTable.push(keccak256(raw.subarray(raw.length - 20)))
    }
  }
  deployer.deploy(GameMaster, players, treasures.map(treasure => treasure.value), treasures.map(treasure => treasure.limit), hashTable)
}
