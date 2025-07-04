// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "sim-idx-sol/Simidx.sol";
import "sim-idx-generated/Generated.sol";
import {OrderQuoter} from "./OrderQuoter.sol";
import {ResolvedOrder, InputToken, OutputToken} from "./interfaces/ReactorStructs.sol";
import {getMetadata} from "./utils/MetadataUtils.sol";

contract Triggers is BaseTriggers {
    function triggers() external virtual override {
        Listener listener = new Listener();
        addTrigger(ChainIdAbi(1, IReactor$Abi()), listener.triggerPreExecuteFunction());
        addTrigger(ChainIdAbi(1, IReactor$Abi()), listener.triggerPreExecuteBatchFunction());
        addTrigger(ChainIdAbi(1, IReactor$Abi()), listener.triggerPreExecuteBatchWithCallbackFunction());
        addTrigger(ChainIdAbi(1, IReactor$Abi()), listener.triggerPreExecuteWithCallbackFunction());
        addTrigger(ChainIdAbi(130, IReactor$Abi()), listener.triggerPreExecuteFunction());
        addTrigger(ChainIdAbi(130, IReactor$Abi()), listener.triggerPreExecuteBatchFunction());
        addTrigger(ChainIdAbi(130, IReactor$Abi()), listener.triggerPreExecuteBatchWithCallbackFunction());
        addTrigger(ChainIdAbi(130, IReactor$Abi()), listener.triggerPreExecuteWithCallbackFunction());
        addTrigger(ChainIdAbi(8453, IReactor$Abi()), listener.triggerPreExecuteFunction());
        addTrigger(ChainIdAbi(8453, IReactor$Abi()), listener.triggerPreExecuteBatchFunction());
        addTrigger(ChainIdAbi(8453, IReactor$Abi()), listener.triggerPreExecuteBatchWithCallbackFunction());
        addTrigger(ChainIdAbi(8453, IReactor$Abi()), listener.triggerPreExecuteWithCallbackFunction());
    }
}

contract Listener is
    OrderQuoter,
    IReactor$PreExecuteFunction,
    IReactor$PreExecuteBatchFunction,
    IReactor$PreExecuteBatchWithCallbackFunction,
    IReactor$PreExecuteWithCallbackFunction
{
    bytes32 internal txnHash;

    struct SwapData {
        uint64 chainId;
        bytes32 txnHash;
        uint64 blockNumber;
        uint64 blockTimestamp;
        address makerToken;
        uint256 makerAmt;
        string makerTokenSymbol;
        string makerTokenName;
        uint64 makerTokenDecimals;
        address takerToken;
        uint256 takerAmt;
        string takerTokenSymbol;
        string takerTokenName;
        uint64 takerTokenDecimals;
        address txnOriginator;
        address maker;
        address taker;
        address reactor;
    }

    event Swap(SwapData);

    function preExecuteFunction(PreFunctionContext memory ctx, IReactor$executeFunctionInputs memory inputs)
        external
        override
    {
        txnHash = ctx.txn.hash;
        ResolvedOrder memory order = this.quote(inputs.order.order, inputs.order.sig);
        emitTradesFromOrder(order, ctx.txn.call.caller);
    }

    function preExecuteBatchFunction(PreFunctionContext memory ctx, IReactor$executeBatchFunctionInputs memory inputs)
        external
        override
    {
        txnHash = ctx.txn.hash;
        for (uint256 i = 0; i < inputs.orders.length; i++) {
            ResolvedOrder memory order = this.quote(inputs.orders[i].order, inputs.orders[i].sig);
            emitTradesFromOrder(order, ctx.txn.call.caller);
        }
    }

    function preExecuteBatchWithCallbackFunction(
        PreFunctionContext memory ctx,
        IReactor$executeBatchWithCallbackFunctionInputs memory inputs
    ) external override {
        txnHash = ctx.txn.hash;
        for (uint256 i = 0; i < inputs.orders.length; i++) {
            ResolvedOrder memory order = this.quote(inputs.orders[i].order, inputs.orders[i].sig);
            emitTradesFromOrder(order, ctx.txn.call.caller);
        }
    }

    function preExecuteWithCallbackFunction(
        PreFunctionContext memory ctx,
        IReactor$executeWithCallbackFunctionInputs memory inputs
    ) external override {
        if (ctx.txn.call.caller != address(this)) {
            txnHash = ctx.txn.hash;
            ResolvedOrder memory order = this.quote(inputs.order.order, inputs.order.sig);
            emitTradesFromOrder(order, ctx.txn.call.caller);
        }
    }

    function emitUniswapXTrade(
        address makingToken,
        address takingToken,
        address maker,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        address platformContract
    ) internal {
        (string memory makingTokenSymbol, string memory makingTokenName, uint256 makingTokenDecimals) =
            makingToken == address(0) ? ("ETH", "Ether", 18) : getMetadata(makingToken);
        (string memory takingTokenSymbol, string memory takingTokenName, uint256 takingTokenDecimals) =
            takingToken == address(0) ? ("ETH", "Ether", 18) : getMetadata(takingToken);
        emit Swap(
            SwapData(
                uint64(block.chainid),
                txnHash,
                uint64(block.number),
                uint64(block.timestamp),
                makingToken,
                makingAmount,
                makingTokenSymbol,
                makingTokenName,
                uint64(makingTokenDecimals),
                takingToken,
                takingAmount,
                takingTokenSymbol,
                takingTokenName,
                uint64(takingTokenDecimals),
                tx.origin,
                maker,
                taker,
                platformContract
            )
        );
    }

    function emitTradesFromOrder(ResolvedOrder memory order, address taker) internal {
        (InputToken memory input, OutputToken memory output) = getIOTokensFromOrder(order);
        emitUniswapXTrade(
            input.token, output.token, output.recipient, taker, input.amount, output.amount, address(order.info.reactor)
        );
    }

    function getIOTokensFromOrder(ResolvedOrder memory order)
        internal
        pure
        returns (InputToken memory input, OutputToken memory output)
    {
        input = order.input;
        uint256 outputIndex;
        uint256 outputAmount;
        unchecked {
            for (uint256 i = 0; i < order.outputs.length; i++) {
                if (order.outputs[i].recipient == order.info.swapper) return (input, order.outputs[i]);
                if (order.outputs[i].amount > outputAmount) outputIndex = i;
            }
        }
        output = order.outputs[outputIndex];
        return (input, output);
    }
}
