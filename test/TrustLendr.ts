// Import necessary modules
import { ethers } from 'hardhat';
import { expect } from 'chai';

describe('TrustLendr', function () {
  let TrustLendr;
  let trustLendr;
  let owner;
  let borrower;

  before(async function () {
    // Deploy the contract before the tests
    [owner, borrower] = await ethers.getSigners();

    TrustLendr = await ethers.getContractFactory('TrustLendr');
    trustLendr = await TrustLendr.deploy(owner.address);
  });
  
//   beforeEach(async function () {
//     //   await trustLendr.deployer(;
//     // Deploy a new instance of the contract before each test
//   });

  it('Should allow a borrower to request a loan', async function () {
    const initialBalance = await trustLendr.balanceOf(borrower.address);

    // Request a loan
    await trustLendr.connect(borrower).requestLoan(100n, 1699999999n, 10n, 5n);

    // Check if the loan details are updated
    const [score, loan, repayDate, lateFee] = await trustLendr.getUserData(borrower.address);

    expect(score).to.equal(840n + 10n); // Assuming initial credit score is 850 and reduced by 10
    expect(loan).to.equal(210n); // 100 (loan amount) + 10 (interest) + 5 (late fee)
    expect(repayDate).to.equal(1699999999n);
    expect(lateFee).to.equal(5n);
  });

  it('Should allow a borrower to repay a loan', async function () {
    // Request a loan
    await trustLendr.connect(borrower).requestLoan(100n, 1699999999n, 10n, 5n);

    // Repay the loan
    await trustLendr.connect(borrower).repayLoan();

    // Check if the loan details are reset
    const [score, loan, repayDate, lateFee] = await trustLendr.getUserData(borrower.address);

    // expect(score).to.equal(790n);
    expect(loan).to.equal(0n);
    expect(repayDate).to.equal(0n);
    expect(lateFee).to.equal(0n);
  });
});
