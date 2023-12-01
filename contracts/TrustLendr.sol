//  SPDX-License-Identifier: MIT

/// @title TrustLendr - A smart contract for p2p lending system
/// @author @arewageek
/// @notice This contract was written originally for practical applications enabling a smooth understanding of smart contract development, testing, application in dApps
/// @dev Anyone with a clear understanding of how to work with smart contracts is free to learn, test an build with it.

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TrustLendr is ERC20 {
    using SafeERC20 for IERC20; 

    IERC20 public token;
    address payable owner;

    mapping(address => uint256) public creditScores;
    mapping(address => uint256) public loanAmounts;
    mapping(address => uint256) public loanRepaymentDates;
    mapping(address => uint256) public lateRepaymentFees;  

    constructor (address _owner) ERC20("TrustLendr Token", "TLT") {
        owner = payable (_owner);
        _mint(owner, 1000000000);
    }

    event LoanRequested(address indexed borrower, uint256 amount, uint256 repaymentDate, uint256 lateRepaymentFee);
    event LoanRepaid(address indexed borrower, uint256 amount, uint256 repaymentDate, uint256 lateRepaymentFee);
    event CreditScoreUpdated(address indexed borrower, uint256 newCreditScore);

    function getUserData(address account) public view returns (uint256[4] memory) {
        uint256 score = creditScores[account];
        uint256 loan = loanAmounts[account];
        uint256 repayDate = loanRepaymentDates[account];
        uint256 lateFee = lateRepaymentFees[account];
        uint256[4] memory userData;
        userData[0] = score;
        userData[1] = loan;
        userData[2] = repayDate;
        userData[3] = lateFee;
        return userData;
    }
    function requestLoan(uint256 _amount, uint256 _repaymentDate, uint256 _interestRate, uint256 _lateRepaymentFee) external {
        require(_amount > 0, "Invalid loan amount");

        // Apply interest rate to the loan amount
        uint256 totalRepaymentAmount = _amount + (_amount * _interestRate / 100);

        // Update loan details
        loanAmounts[msg.sender] = totalRepaymentAmount;
        loanRepaymentDates[msg.sender] = _repaymentDate;
        lateRepaymentFees[msg.sender] = _lateRepaymentFee;

        uint score = creditScores[msg.sender];

        if(score == 0){
            creditScores[msg.sender] = 850;
        }

        emit LoanRequested(msg.sender, totalRepaymentAmount, _repaymentDate, _lateRepaymentFee);
        _mint(msg.sender, _amount);
    }

    function repayLoan() external {
        // Ensure the borrower has an outstanding loan
        require(loanRepaymentDates[msg.sender] != 0, "No outstanding loan");

        // Calculate total repayment amount
        uint256 totalRepaymentAmount = calculateAccruedInterest(msg.sender);

        // Update credit score based on repayment date
        updateCreditScore(msg.sender);

        // Reset loan details
        loanAmounts[msg.sender] = 0;
        loanRepaymentDates[msg.sender] = 0;
        lateRepaymentFees[msg.sender] = 0;

        emit LoanRepaid(msg.sender, totalRepaymentAmount, block.timestamp, lateRepaymentFees[msg.sender]);
        _burn(msg.sender, loanAmounts[msg.sender]);
    }

    function updateCreditScore(address _user) internal {
        // Ensure the user has an outstanding loan
        if (loanRepaymentDates[_user] != 0) {
            // Check if the loan is overdue
            if (block.timestamp > loanRepaymentDates[_user]) {
                // Penalize the credit score for overdue loans
                creditScores[_user] = creditScores[_user] > 50 ? creditScores[_user] - 50 : 0;
            } else {
                // Reward the credit score for early repayments
                creditScores[_user] += 25;
            }

            // Ensure credit score is capped at 100
            if (creditScores[_user] > 850) {
                creditScores[_user] = 850;
            }

            emit CreditScoreUpdated(_user, creditScores[_user]);
        }
    }

    function calculateTotalLoanAmount(uint256 _amount) internal view returns (uint256) {
        // Calculate accrued interest
        uint256 accruedInterestAmount = calculateAccruedInterest(msg.sender);

        // Calculate total loan amount with interest
        return _amount + accruedInterestAmount;
    }

    function calculateAccruedInterest(address _user) internal view returns (uint256) {
        // Calculate interest accrued since the last update
        uint256 currentTime = block.timestamp;
        uint256 timeElapsed = currentTime - loanRepaymentDates[_user];
        // increase loan amount every 30 days
        uint256 accruedInterestAmount = (loanAmounts[_user] + (lateRepaymentFees[_user] * (timeElapsed % 30)));

        return accruedInterestAmount;
    }
}
