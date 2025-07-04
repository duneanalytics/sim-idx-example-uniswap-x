# UniswapX Order Indexer

This app indexes UniswapX order executions across multiple chains. UniswapX is Uniswap's intent-based trading protocol where users submit orders that are filled by third-party fillers, providing better prices and MEV protection.

## Supported Chains

This indexer currently supports:
- **Ethereum Mainnet** (Chain ID: 1)
- **Unichain** (Chain ID: 130)
- **Base** (Chain ID: 8453)

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
