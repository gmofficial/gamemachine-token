pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/MintableToken.sol";

contract GameMachineExchangeToken is MintableToken {
    string public name = "Game Machine Exchange Token";
    string public symbol = "GMEX";
    uint public decimals = 18;

    function GameMachineExchangeToken( uint256 _amount ) {
        owner = msg.sender;
        mint(owner, _amount);
    }
}
