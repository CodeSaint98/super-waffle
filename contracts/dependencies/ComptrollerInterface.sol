// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.2;

abstract contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) virtual external returns (uint[] memory);
    function exitMarket(address vToken) virtual external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address vToken, address minter, uint mintAmount) virtual external returns (uint);
    function mintVerify(address vToken, address minter, uint mintAmount, uint mintTokens) virtual external;

    function redeemAllowed(address vToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    function redeemVerify(address vToken, address redeemer, uint redeemAmount, uint redeemTokens) virtual external;

    function borrowAllowed(address vToken, address borrower, uint borrowAmount) virtual external returns (uint);
    function borrowVerify(address vToken, address borrower, uint borrowAmount) virtual external;

    function repayBorrowAllowed(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount) virtual external returns (uint);
    function repayBorrowVerify(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) virtual external;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) virtual external returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) virtual external;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) virtual external returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) virtual external;

    function transferAllowed(address vToken, address src, address dst, uint transferTokens) virtual external returns (uint);
    function transferVerify(address vToken, address src, address dst, uint transferTokens) virtual external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) virtual external view returns (uint, uint);
    function setMintedVAIOf(address owner, uint amount) virtual external returns (uint);
}

abstract contract ComptrollerInterfaceG2 is ComptrollerInterfaceG1 {
    function liquidateVAICalculateSeizeTokens(
        address vTokenCollateral,
        uint repayAmount) virtual external view returns (uint, uint);
}

abstract contract ComptrollerInterface is ComptrollerInterfaceG2 {
}

interface IVAIVault {
    function updatePendingRewards()  external;
}

interface IComptroller {
    /*** Treasury Data ***/
    function treasuryAddress()  external view returns (address);
    function treasuryPercent()  external view returns (uint);
}
