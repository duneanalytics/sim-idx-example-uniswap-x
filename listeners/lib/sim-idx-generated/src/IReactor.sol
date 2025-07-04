// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/sim-idx-sol/src/Triggers.sol";
import "lib/sim-idx-sol/src/Context.sol";

function IReactor$Abi() pure returns (Abi memory) {
    return Abi("IReactor");
}
struct IReactor$SignedOrder {
    bytes order;
    bytes sig;
}

struct IReactor$ExecuteFunctionInputs {
    IReactor$SignedOrder order;
}

struct IReactor$ExecuteBatchFunctionInputs {
    IReactor$SignedOrder[] orders;
}

struct IReactor$ExecuteBatchWithCallbackFunctionInputs {
    IReactor$SignedOrder[] orders;
    bytes callbackData;
}

struct IReactor$ExecuteWithCallbackFunctionInputs {
    IReactor$SignedOrder order;
    bytes callbackData;
}

abstract contract IReactor$OnExecuteFunction {
    function onExecuteFunction(FunctionContext memory ctx, IReactor$ExecuteFunctionInputs memory inputs) virtual external;

    function triggerOnExecuteFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x3f62192e),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onExecuteFunction.selector
        });
    }
}

abstract contract IReactor$PreExecuteFunction {
    function preExecuteFunction(PreFunctionContext memory ctx, IReactor$ExecuteFunctionInputs memory inputs) virtual external;

    function triggerPreExecuteFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x3f62192e),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preExecuteFunction.selector
        });
    }
}

abstract contract IReactor$OnExecuteBatchFunction {
    function onExecuteBatchFunction(FunctionContext memory ctx, IReactor$ExecuteBatchFunctionInputs memory inputs) virtual external;

    function triggerOnExecuteBatchFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x0d7a16c3),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onExecuteBatchFunction.selector
        });
    }
}

abstract contract IReactor$PreExecuteBatchFunction {
    function preExecuteBatchFunction(PreFunctionContext memory ctx, IReactor$ExecuteBatchFunctionInputs memory inputs) virtual external;

    function triggerPreExecuteBatchFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x0d7a16c3),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preExecuteBatchFunction.selector
        });
    }
}

abstract contract IReactor$OnExecuteBatchWithCallbackFunction {
    function onExecuteBatchWithCallbackFunction(FunctionContext memory ctx, IReactor$ExecuteBatchWithCallbackFunctionInputs memory inputs) virtual external;

    function triggerOnExecuteBatchWithCallbackFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x13fb72c7),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onExecuteBatchWithCallbackFunction.selector
        });
    }
}

abstract contract IReactor$PreExecuteBatchWithCallbackFunction {
    function preExecuteBatchWithCallbackFunction(PreFunctionContext memory ctx, IReactor$ExecuteBatchWithCallbackFunctionInputs memory inputs) virtual external;

    function triggerPreExecuteBatchWithCallbackFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x13fb72c7),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preExecuteBatchWithCallbackFunction.selector
        });
    }
}

abstract contract IReactor$OnExecuteWithCallbackFunction {
    function onExecuteWithCallbackFunction(FunctionContext memory ctx, IReactor$ExecuteWithCallbackFunctionInputs memory inputs) virtual external;

    function triggerOnExecuteWithCallbackFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x0d335884),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onExecuteWithCallbackFunction.selector
        });
    }
}

abstract contract IReactor$PreExecuteWithCallbackFunction {
    function preExecuteWithCallbackFunction(PreFunctionContext memory ctx, IReactor$ExecuteWithCallbackFunctionInputs memory inputs) virtual external;

    function triggerPreExecuteWithCallbackFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "IReactor",
            selector: bytes4(0x0d335884),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preExecuteWithCallbackFunction.selector
        });
    }
}

contract IReactor$EmitAllEvents {
  function allTriggers() view external returns (Trigger[] memory) {
    Trigger[] memory triggers = new Trigger[](0);

    return triggers;
  }
}