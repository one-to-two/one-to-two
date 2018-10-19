pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

import "./ScoreInterface.sol";

contract Score is Whitelist, ScoreInterface {
  using SafeMath for uint256;

  uint256 public maxLength = 10;

  mapping(address => uint256) public balances;
  address[] public top;

  function getTopCount() public view returns (uint256) {
    return top.length;
  }

  function getTopPlayer(uint _index) public constant returns(address, uint256) {
    if (_index < top.length) {
      address player = top[_index];
      uint256 gain = balances[player];
      return (player, gain);
    } else {
      return (address(0), 0);
    }
  }

  function setMaxLength(uint256 _maxLength) public onlyOwner {
    maxLength = _maxLength;
  }

  function addAmount(address _player, uint256 _amount) public onlyWhitelisted {
    balances[_player] = balances[_player].add(_amount);
    bool existent = false;
    for (uint256 i = 0; i < top.length; i++) {
      if (top[i] == _player) {
        existent = true;
        break;
      }
    }
    if (!existent) {
      top.push(_player);
    }
    sort(top);
    if (top.length > maxLength) {
      top.length = maxLength;
    }
  }

  function sort(address[] storage _arr) internal {
    if (_arr.length <= 1) {
        return;
    }
    quickSort(_arr, 0, int(_arr.length - 1));
  }

  function quickSort(address[] storage _arr, int _left, int _right) internal {
    int i = _left;
    int j = _right;
    if (_left < _right) {
      uint pivot = balances[_arr[uint(_left)]];
      while (i <= j) {
          while (pivot < balances[_arr[uint(i)]]) {
            i++;
          }
          while (balances[_arr[uint(j)]] < pivot) {
            j--;
          }
          if (i <= j) {
            uint256 v1 = balances[_arr[uint(i)]];
            uint256 v2 = balances[_arr[uint(j)]];
            if (v1 != v2) {
              (_arr[uint(i)], _arr[uint(j)]) = (_arr[uint(j)], _arr[uint(i)]);
            }
            i++;
            j--;
          }
      }
      if (_left < j) {
        quickSort(_arr, _left, j);
      }
      if (i < _right) {
        quickSort(_arr, i, _right);
      }
    }
  }

}
