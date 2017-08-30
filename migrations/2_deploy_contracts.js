var GMCEX = artifacts.require("./GMCEX.sol");

module.exports = function(deployer) {
    const tokenAmount = 50000000;
    deployer.deploy(GMCEX, tokenAmount);
};
