const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

const buildPath = path.resolve(__dirname, "build");
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, "contracts", "Campaign.sol");

const source = fs.readFileSync(campaignPath, "utf8");
const { contracts: output, errors } = solc.compile(source, 1);

if (errors && errors.length > 0) {
  console.error(errors);
  return;
}

fs.ensureDirSync(buildPath);

for (let contract in output) {
  const outputPath = path.resolve(
    buildPath,
    contract.replace(":", "") + ".json"
  );
  fs.outputJsonSync(outputPath, output[contract]);

  console.log("Contract saved in ", outputPath);
}
