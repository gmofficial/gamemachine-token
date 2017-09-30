pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/StandardToken.sol";


contract GameMachineToken is StandardToken, Ownable {
    string public name = "Game Machine Token";
    string public symbol = "GMT";
    uint public decimals = 18;

    bool mintingIsFinished = false;

    modifier canMint() {
        require(!mintingIsFinished);
        _;
    }

    function mint(address _holder, uint256 _value) canMint external {
        balances[_holder] += _value;
        totalSupply += _value;

        Transfer(0x0, _holder, _value);
    }

    function finishMinting() {
        mintingIsFinished = true;
    }

}
