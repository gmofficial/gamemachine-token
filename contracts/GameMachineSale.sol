pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./GameMachineToken.sol";

contract GameMachineSale is Ownable {

    using SafeMath for uint;

    /* @var Escrow address to collect crowdsale funds in ether */
    address public multisig;

    /* @var Address to collect percent of total GMEX supply for bounty program and team */
    address public restricted;

    /* @var Percent of total GMEX supply for bounty program and team */
    uint public restrictedPercent;

    /* Hardcaps on pre-sale and sale */
    uint public hardcap;

    /* Sale rate */
    uint public rate;

    /* Sale start daytime */
    uint256 public startDate;

    /* Sale period */
    uint256 public endDate;

    /* Game Machine Exchange Token instance */
    GameMachineToken public token;

    /*
     * Check, if pre-sale or sale is active now
     */
    modifier saleIsOn() {
        require( now > startDate && now < endDate);
        _;
    }

    /*
     * Check, is hardcap not achieved
     */
    modifier isUnderHardCap() {
        require(multisig.balance <= hardcap );
        _;
    }

    /*
     * Basic constructor for Crowdsale contract
     */
    function GameMachineSale(address _token, address _multisig, address _restricted, uint256 _startDate, uint _period) {
        token = GameMachineToken(_token);

        multisig = _multisig;
        restricted = _restricted;

        /*
         * Percents from total GMEX supply to bounty and team.
         * After finishing crowdale transfer to restricted address.
         */
        restrictedPercent = 40;

        startDate = _startDate;
        endDate = _startDate + _period * 1 days;

        /*
         * GMEX's amount gived for 1 ether
         * on pre-sale and on sale
         */
        rate = 1000;
        hardcap = 100000 * 1 ether;
    }

    /*
     * Calculate bonus for investors.
     * It's gave:
     * 1 day — 15% of adding tokens
     * 2 day - 10% of adding tokens
     * 3 day - 5% of adding tokens
     */
    function calculateBonus(uint tokensAmount) private returns (uint){
        uint bonusAmount = 0;

        if ( now > startDate && now < startDate + 1 days ) {
            bonusAmount = tokensAmount.mul(15).div(100);
        } else if ( now > startDate + 1 days && now < startDate + 2 days ) {
            bonusAmount = tokensAmount.mul(10).div(100);
        } else if ( now > startDate + 2 days && now < startDate + 3 days ) {
            bonusAmount = tokensAmount.mul(5).div(100);
        }

        return bonusAmount;
    }

    /*
     * Transfer ether to multisig escrow address and give tokens with bonus to investors.
     */
    function createTokens() isUnderHardCap saleIsOn payable {
        multisig.transfer(msg.value);

        uint tokensAmount;
        uint bonusAmount;


        tokensAmount = rate.mul(msg.value).div(1 ether);

        bonusAmount = calculateBonus(tokensAmount);

        token.mint(msg.sender, tokensAmount.add(bonusAmount) );
    }

    /*
     * Finish minting when sale is over.
     */
    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedTokens).div(100 - restrictedPercent);
        token.mint(restricted, restrictedTokens);
        token.finishMinting();
    }

    /*
     * External payable fallback to start execution contract which ether is received.
     */
    function() external payable saleIsOn {
        createTokens();
    }
}
