var GameMachinePreSale = artifacts.require("GameMachinePreSale");
var GameMachineToken = artifacts.require("GameMachineToken");

contract('GameMachinePreSale', function(accounts) {


    beforeEach(async function() {
        this.founder = accounts[0];

        this.startDate = 1506700000;
        this.period = 21; //21 days

        this.multisig = accounts[1];

        this.testingTransactionAmount = 1;

        this.rate = 2000;

        this.token =  await GameMachineToken.new();
        this.presale = await GameMachinePreSale.new(this.token.address, this.multisig, this.startDate, this.period);

        //this.token.transfer(this.presale.address, web3.toWei(5000, "ether"));
    });

    it("Should multisig account equals accounts[1]", async function() {

        var multisig = await this.presale.multisig.call();

        assert.equal(multisig, this.multisig, "Should be equals");
    });

    it("Should contains right start date", async function() {
        var startDate = await this.presale.startDate.call();
        assert.equal(startDate, this.startDate, "Start dates not equal");
    });

    it("Should contains right end date", async function() {
        var endDate = await this.presale.endDate.call();
        assert.equal(endDate, this.startDate + this.period*24*60*60, "End dates not equal");
    });

    it("Should be active", async function() {
        var startDate = await this.presale.startDate.call();
        var endDate = await this.presale.endDate.call();

        var now = Date.now();

        assert.equal( now > startDate.valueOf()*1000 && now < endDate.valueOf()*1000, true, "Presale not active");
    })

    it("Should send token to purchaser", async function() {
        this.multisigStartBalance = await web3.eth.getBalance(this.multisig);

        await this.presale.sendTransaction({value: 1 * 10 ** 18, from: accounts[3]});

        const balance = await this.token.balanceOf(accounts[3]);

        assert.equal(balance.valueOf(), this.testingTransactionAmount * this.rate );
    });

    it("Should be change multisig balance in ether", async function() {
        const balance = await web3.eth.getBalance(this.multisig);

        assert.equal(balance.valueOf(), this.multisigStartBalance.add(1 * 10 ** 18).valueOf());
    });

    it("Try to call mint and mint 100000. Should be 0 tokens.", async function() {
        var result = await this.token.mint.call(accounts[5], 100000);

        const balance = await this.token.balanceOf(accounts[5]);

        assert.equal(balance.valueOf(), 0 );
    })

})
