pragma solidity ^0.4.11;

contract Crowdsale {

    using SafeMath for uint;

    address owner;

    /* @var Escrow address to collect crowdsale funds in ether */
    address multisig;

    /* @var Address to collect percent of total GMEX supply for bounty program and team */
    address restricted;

    /* @var Percent of total GMEX supply for bounty program and team */
    uint restrictedPercent;

    /* Hardcaps on pre-sale and sale */
    uint presaleHardcap;
    uint saleHardcap;

    uint saleRate;
    uint preSaleRate;

    uint preSaleStart;
    uint preSalePeriod;

    uint saleStart;
    uint salePeriod;

    /* Game Machine Exchange Token instance */
    GameMachineExchangeToken public token = new GameMachineExchangeToken();

    /*
     * Check, if pre-sale or sale is active now
     */
    modifier saleIsOn() {
        require(
            isPreSale() ||
            isSale()
        );
        _;
    }

    /*
     * Check, is hardcap not achieved
     */
    modifier isUnderHardCap() {
        if ( isPreSale() ) {
            require(multisig.balance <= presaleHardcap);
        } else if ( isSale() ) {
            require(multisig.balance <= saleHardcap )
        }
        _;
    }

    /*
     * Basic constructor for Crowdsale contract
     */
    function Crowdsale(address _mulitsig, address _restricted, uint _preSaleStart, uint _preSalePeriod, uint _saleStart, uint _salePeriod) {
        owner = msg.sender;
        multisig = _mulitsig;
        restricted = _restricted;

        /*
         * Percents from total GMEX supply to bounty and team.
         * After finishing crowdale transfer to restricted address.
         */
        restrictedPercent = 20;

        /*
         * Pre-sale and sale starts dates and periods in days
         */
        preSaleStart = _preSaleStart;
        preSalePeriod = _preSalePeriod * 1 days;

        saleStart = _saleStart;
        salePeriod = _salePeriod * 1 days;

        /*
         * GMEX's amount gived for 1 ether
         * on pre-sale and on sale
         */
        preSaleRate = 1500;
        saleRate = 1000;
    }

    /*
     * Check pre-sale is active
     */
    function isPreSale() returns (bool) {
        return (now > preSaleStart && now < preSaleStart + preSalePeriod);
    }

    /*
     * Check sale is active
     */
    function isSale() returns (bool) {
        return (now > saleStart && now < saleStart + salePeriod);
    }

    /*
     * Calculate bonus for investors.
     * It's gave:
     * 1 day — 15% of adding tokens
     * 2 day - 10% of adding tokens
     * 3 day - 5% of adding tokens
     */
    function calculateBonus(uint tokensAmount) private returns (uint bonusAmount){
        uint bonusAmount = 0;

        if ( now > saleStart && now < saleStart + 1 days ) {
            bonusAmount = tokensAmount.mul(15).div(100);
        } else if ( now > saleStart + 1 days && now < saleStart + 2 days ) {
            bonusAmount = tokensAmount.mul(10).div(100);
        } else if ( now > saleStart + 2 days && now < saleStart + 3 days ) {
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

        if ( isPreSale() ) {
            tokensAmount = preSaleRate.mul(msg.value).div(1 ether);
        } else if ( isSale() ) {
            tokensAmount = saleRate.mul(msg.value).div(1 ether);
        }

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
