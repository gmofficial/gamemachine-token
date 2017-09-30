var SafeMath = artifacts.require("./SafeMath.sol");
var GameMachineSale = artifacts.require("./GameMachineSale.sol");
var GameMachinePreSale = artifacts.require("./GameMachinePreSale.sol");
var GameMachineToken = artifacts.require("./GameMachineToken.sol");

module.exports = function(deployer) {

    deployer.deploy(SafeMath);
    deployer.link(SafeMath, GameMachineToken);
    deployer.link(SafeMath, GameMachineSale);
    deployer.link(SafeMath, GameMachinePreSale);

    deployer.deploy(GameMachineToken).then(function() {
        const multisig = web3.eth.accounts[1];
        const restricted = web3.eth.accounts[2];
        const saleStart = 1506700000;
        const salePeriod = 21;
        const token = GameMachineToken.address;

        deployer.deploy(GameMachinePreSale, token, multisig, saleStart, salePeriod);
        deployer.deploy(GameMachineSale, token, multisig, restricted, saleStart, salePeriod);
    });



};
