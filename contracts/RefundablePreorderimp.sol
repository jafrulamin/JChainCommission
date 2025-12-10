// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RefundablePreorder.sol";

contract RefundablePreorderImp is RefundablePreorder {

    //types 
    struct BuyerInfo{
        uint256 quantity;
        uint256 amountpaid;
        bool refunded;
    }
    
    //State
    string private _productName;
    uint256 private _unitPrice;
    uint256 private _deadline;
    address private _seller;

    bool private _delivered;
    bool private _fundsWithdrawn;

    uint256 private _totalQuantity;
    uint256 private _totalCollected;

    //modifer
    modifier OnlySeller(){
        require(msg.sender == _seller, "only Seller");
        _;
    }

    //constructors
    constructor(string memory productName_, uint256 unitPrice_, uint256 deadline_){
        require(bytes(productName_).length > 0, "Product name is required");
        require(unitPrice_ > 0, "Unit price must be greater than 0");
        require(deadline_ > block.timestamp, "Deadline has to be more an a day");

        _productName = productName_;
        _unitPrice = unitPrice_;
        _deadline = deadline_;

    }

    //inherited functions
    function placePreorder(uint256 quantity) external payable override{

    }

    function claimRefund() external override {
    require(block.timestamp >= _deadline, "Deadline not reached");
    require(!_delivered, "Product already delivered");
    BuyerInfo storage buyer = _buyers[msg.sender];
    require(buyer.amountpaid > 0, "No preorder found");
    require(!buyer.refunded, "Already refunded");
    buyer.refunded = true;
    uint256 refundAmount = buyer.amountpaid;
    buyer.amountpaid = 0; 
    (bool success, ) = msg.sender.call{value: refundAmount}("");
    require(success, "Refund failed");

    emit RefundClaimed(msg.sender, refundAmount);
}


    function markProductDelivered() external override OnlySeller(){
        require(!_delivered, "Already delivered");
        _delivered = true;

        emit ProductDelivered(block.timestamp);
    }

    function withdrawFunds() external override OnlySeller(){

    }

     mapping(address => BuyerInfo) private _buyers;

    function getBuyerInfo(address buyer)
        external
        view
        override
        returns (uint256 quantity, uint256 amountPaid, bool refunded)
    {
        BuyerInfo storage info = _buyers[buyer];
        return (info.quantity, info.amountpaid, info.refunded);
    }

    function getPreorderInfo() external view override returns(string memory productName_, uint256 unitPrice_, uint256 deadline_, uint256 totalQuantity_, uint256 totalCollected_, address seller_, bool delivered_, bool fundswithdrawn_){
        return (
        productName_ = _productName,
        unitPrice_ = _unitPrice,
        deadline_ = _deadline,
        totalQuantity_ = _totalQuantity,
        totalCollected_ = _totalCollected,
        seller_ = _seller,
        delivered_ = _delivered,
        fundswithdrawn_ = _fundsWithdrawn
        );
    }
}
