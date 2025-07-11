# UniswapX Order Indexer

This app indexes UniswapX order executions across multiple chains. UniswapX is Uniswap's intent-based trading protocol where users submit orders that are filled by third-party fillers, providing better prices and MEV protection.

## Indexing Methodology

We use a `Main.sol` file that implements the following architecture:

### Triggers
Our listener triggers on UniswapX Reactor contract pre-execution functions:
- `preExecuteFunction` - Single order execution
- `preExecuteBatchFunction` - Batch order execution  
- `preExecuteBatchWithCallback` - Batch execution with callback
- `preExecuteWithCallback` - Single order execution with callback

### Order Resolution
We leverage the fact that our indexer acts just like a deployed contract allowing other contracts to interact with it. We inherit from the `OrderQuoter` contract that exposes the `reactorCallback` and `quote` functions which let us:
- Call the reactor's `executeWithCallback` function in order to simulate execution of order fills. These will result in a call to our listener's `reactorCallback` with the resolved order.
- We then revert as we don't want the execution to further proceed and fill the order. We put the resolved order in the reversion reason. 
- Our `quote` function catches the reversion and parses the `ResolvedOrder` from the reversion reason.

This methodology allows us to robustly resolve orders from all types of reactors so long as they implement the `IReactor.sol` interface without having to import complex decoding logic.

### Fee Injection
Reactors may have a `ProcotolFeeController` contract setup. If we detect one, we use the `FeeInjector.sol` library in order to inject the fees into the `ResolvedOrder` struct we've achieved in the previous steps.
This library is an almost identical copy of the [`ProtocolFees.sol`](https://github.com/Uniswap/UniswapX/blob/main/src/base/ProtocolFees.sol) contract with small changes.

## Event Structure

This is the final event emitted for each indexed order:
```json
{
    "name": "Swap",
    "fields":
    {
        "blockNumber": 32309115,
        "blockTimestamp": 1751407577,
        "chainId": 8453,
        "maker": "472470dc29527b56bbfcd8be7cc930898643f6f5",
        "makerAmt": "403078980",
        "makerToken": "833589fcd6edb6e08f4c7c32d4f71b54bda02913",
        "makerTokenDecimals": 6,
        "makerTokenName": "USDC",
        "makerTokenSymbol": "USD Coin",
        "reactor": "000000001ec5656dcdb24d90dfa42742738de729",
        "taker": "f85e95bef8f2de7782b0936ca3480c41a4b6c59b",
        "takerAmt": "10000000000000",
        "takerToken": "768be13e1680b5ebe0024c42c896e3db59ec0149",
        "takerTokenDecimals": 9,
        "takerTokenName": "SKI",
        "takerTokenSymbol": "SKI MASK DOG",
        "txnHash": "2d7e55e0a27eda4d2cda635d239d94f897567f7ff2274889968362002e9cf420",
        "txnOriginator": "133335936a326d0264d64444278b0ca0d75afca5"
    },
    "metadata":
    {
        "blockNumber": 32309115,
        "chainId": 8453
    }
}
```
