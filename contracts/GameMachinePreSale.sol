pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./GameMachineToken.sol";

contract GameMachinePreSale is Ownable {

    using SafeMath for uint;

    GameMachineToken public token;

    uint public rate;

    address public multisig;
    address public restricted;

    uint public startDate;
    uint public endDate;

    uint public hardcap;

    function GameMachinePreSale(address _token, address _multisig, uint _startDate, uint _period) {

        token = GameMachineToken(_token);
        rate = 2000; // Per one ether

        multisig = _multisig;

        startDate = _startDate;
        endDate = _startDate.add(_period * 1 days);

        hardcap = 4000 * 1 ether;
    }

    modifier isSaleActive() {
        require( now > startDate && now < endDate );
        _;
    }

    modifier isUnderHardcap() {
        require(multisig.balance < hardcap);
        _;
    }

    function createTokens() isSaleActive isUnderHardcap payable {
        multisig.transfer(msg.value);
        token.mint(msg.sender, rate.mul(msg.value).div(1 ether));
    }

    function() external payable {
        createTokens();
    }
}
