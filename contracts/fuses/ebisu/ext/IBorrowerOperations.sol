// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IBorrowerOperations {
    function activePool() external view returns (address);

    function setInterestIndividualDelegate(
        uint256 _troveId,
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee,
        uint256 _minInterestRateChangePeriod
    ) external;

    function getInterestIndividualDelegateOf(
        uint256 troveId
    ) external view returns (address account, uint128 minRate, uint128 maxRate, uint256 minChangePeriod);

    function adjustTroveInterestRate(
        uint256 troveId,
        uint256 newAnnualInterestRate,
        uint256 upperHint,
        uint256 lowerHint,
        uint256 maxUpfrontFee
    ) external;
}
