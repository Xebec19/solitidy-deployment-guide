const assert = require("assert");
const ganache = require("ganache");
const { Web3 } = require("web3");

const web3 = new Web3(ganache.provider());

const campiledCampaign = require("../ethereum/build/Campaign.json");

let accounts;
let factory;
let campaignAddress;
let campaign;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  campaign = await new web3.eth.Contract(
    JSON.parse(campiledCampaign.interface)
  ).deploy({
    data: compiledCampaign.bytecode,
  });
});

describe("Campaigns", () => {
  it("deploys a factory and a campaign", () => {
    assert.ok(factory.options.address);
    assert.ok(campaign.options.address);
  });

  it("marks caller as the campaign manager", async () => {
    const manager = await campaign.methods.manager().call();

    assert.equal(accounts[0], manager);
  });

  it("allows people to contribute money and mark them as approvers", async () => {
    await campaign.methods.contribute().send({
      value: "200",
      from: accounts[1],
    });

    const isContributor = await campaign.methods.approvers(accounts[1]).call();
  });
});
