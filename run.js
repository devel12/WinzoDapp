const main = async () => {
  const WalletFactory = await hre.ethers.getContractFactory("Wallet");
  const Wallet = await WalletFactory.deploy();
  await Wallet.deployed();
  console.log("Contract deployed to:", Wallet.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
