function calculateGasCost(gasUsed, gasPriceGwei) {
  const gasPriceEth = gasPriceGwei / 1e9;
  const gasCostEth = gasUsed * gasPriceEth;
  return gasCostEth;
}

const gasUsed = 3467813; // Gas units consumed by the operation
const gasPriceGwei = 13; // Gas price in Gwei

const gasCostEth = calculateGasCost(gasUsed, gasPriceGwei);
console.log(`Gas Cost in ETH: ${gasCostEth} ETH`);
