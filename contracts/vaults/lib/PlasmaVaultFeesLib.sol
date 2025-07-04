// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {PlasmaVaultStorageLib} from "../../libraries/PlasmaVaultStorageLib.sol";
import {PlasmaVaultLib} from "../../libraries/PlasmaVaultLib.sol";
import {FeeManager} from "../../managers/fee/FeeManager.sol";
import {FeeAccount} from "../../managers/fee/FeeAccount.sol";

library PlasmaVaultFeesLib {
    using SafeCast for uint256;

    uint256 private constant FEE_PERCENTAGE_DECIMALS_MULTIPLIER = 1e4; /// @dev 10000 = 100% (2 decimal places for fee percentage)

    function prepareForAddPerformanceFee(
        uint256 totalSupply_,
        uint256 decimals_,
        uint256 decimalsOffset_,
        uint256 actualExchangeRate_
    ) internal returns (address recipient, uint256 feeShares) {
        PlasmaVaultStorageLib.PerformanceFeeData memory feeData = PlasmaVaultLib.getPerformanceFeeData();

        (recipient, feeShares) = FeeManager(FeeAccount(feeData.feeAccount).FEE_MANAGER())
            .calculateAndUpdatePerformanceFee(
                actualExchangeRate_.toUint128(),
                totalSupply_,
                feeData.feeInPercentage,
                decimals_ - decimalsOffset_
            );
    }

    function prepareForRealizeManagementFee(
        uint256 totalAssetsBefore_
    ) internal returns (address recipient, uint256 unrealizedFeeInUnderlying) {
        PlasmaVaultStorageLib.ManagementFeeData memory feeData = PlasmaVaultLib.getManagementFeeData();

        recipient = feeData.feeAccount;

        unrealizedFeeInUnderlying = getUnrealizedManagementFee(totalAssetsBefore_);

        PlasmaVaultLib.updateManagementFeeData();
    }

    function getUnrealizedManagementFee(uint256 totalAssets_) internal view returns (uint256) {
        PlasmaVaultStorageLib.ManagementFeeData memory feeData = PlasmaVaultLib.getManagementFeeData();

        uint256 blockTimestamp = block.timestamp;

        if (
            feeData.feeInPercentage == 0 ||
            feeData.lastUpdateTimestamp == 0 ||
            blockTimestamp <= feeData.lastUpdateTimestamp
        ) {
            return 0;
        }
        return
            Math.mulDiv(
                totalAssets_ * (blockTimestamp - feeData.lastUpdateTimestamp),
                feeData.feeInPercentage,
                365 days * FEE_PERCENTAGE_DECIMALS_MULTIPLIER
            );
    }
}
