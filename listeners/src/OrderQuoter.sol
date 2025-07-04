// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IReactor} from "./interfaces/IReactor.sol";
import {ResolvedOrder, SignedOrder} from "./interfaces/ReactorStructs.sol";

/// @title Originally a lens contract for UniswapX, now used as an order resolver for sim.
/// @author Tal Vaizman (UniswapX)
/// @notice Resolves orders and returns the current input and output token amounts required to satisfy them.
/// @notice Chain agnostic.
contract OrderQuoter {
    /// @notice thrown if reactorCallback receives more than one order
    error OrdersLengthIncorrect();

    /// @notice offset bytes into the order object to the head of the order info struct
    uint256 private constant ORDER_INFO_OFFSET = 64;

    /// @notice minimum length of a resolved order object in bytes
    uint256 private constant RESOLVED_ORDER_MIN_LENGTH = 192;

    /// @notice Quote the given order, returning the ResolvedOrder object which defines
    /// the current input and output token amounts required to satisfy it
    /// Also bubbles up any reverts that would occur during the processing of the order
    /// @param order abi-encoded order, including `reactor` as the first encoded struct member
    /// @param sig The order signature
    /// @return result The ResolvedOrder
    function quote(bytes memory order, bytes memory sig) external returns (ResolvedOrder memory result) {
        try IReactor(getReactor(order)).executeWithCallback(SignedOrder(order, sig), bytes("")) {}
        catch (bytes memory reason) {
            result = parseRevertReason(reason);
        }
    }

    /// @notice Return the reactor of a given order (abi.encoded bytes).
    /// @param order abi-encoded order, including `reactor` as the first encoded struct member
    /// @return reactor
    function getReactor(bytes memory order) internal pure returns (IReactor reactor) {
        /// @solidity memory-safe-assembly
        assembly {
            let orderInfoOffsetPointer := add(order, ORDER_INFO_OFFSET)
            reactor := mload(add(orderInfoOffsetPointer, mload(orderInfoOffsetPointer)))
        }
    }

    /// @notice Return the order info of a given order (abi-encoded bytes).
    /// @param reason The revert reason
    /// @return abi-encoded order, including `reactor` as the first encoded struct member
    function parseRevertReason(bytes memory reason) private pure returns (ResolvedOrder memory) {
        if (reason.length < RESOLVED_ORDER_MIN_LENGTH) {
            /// @solidity memory-safe-assembly
            assembly {
                revert(add(32, reason), mload(reason))
            }
        } else {
            return abi.decode(reason, (ResolvedOrder));
        }
    }

    /// @notice Reactor callback function
    /// @dev reverts with the resolved order as reason
    /// @param resolvedOrders The resolved orders
    function reactorCallback(ResolvedOrder[] memory resolvedOrders, bytes memory) external pure {
        if (resolvedOrders.length != 1) {
            revert OrdersLengthIncorrect();
        }
        bytes memory order = abi.encode(resolvedOrders[0]);
        /// @solidity memory-safe-assembly
        assembly {
            revert(add(32, order), mload(order))
        }
    }
}
