// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DecentralizedKycContract
{ //--start-contract

    address regulator;  //this is regulating body - central bank ethereum address 
                        //they own, deploy and manage the Contract for Banks
 
    struct Bank
    {
        address bank_address; //unique ethereum address for bank
        string  bank_code; //unique given identifier for each bank
        bool    add_customer_permission;
        bool    kyc_privilege;
        int     customers_count;
    }

    struct Customer
    {
        int     customer_id; //unique id or account number for each bank's customer
        string  customer_name;
        string  customer_kyc_data;
        bool    customer_kyc_status;
        string  customer_bank_address; //to whom cutomer account belongs    
    }

    mapping( address => Bank ) map_address2bank;


    constructor()
    {
        regulator = msg.sender;
    }

    function enrollBankToLedger(string memory _bank_code,address _bank_address ) public returns( string memory, string memory )
    {
        if ( isEnrolledBank( _bank_address ))
            return ("Error - Bank Already Exists : ", map_address2bank[ _bank_address ].bank_code);
        map_address2bank[ _bank_address ] = Bank( _bank_address, _bank_code, false, false, 0 );
        return ("Success - New Bank Enrolled : ", map_address2bank[ _bank_address ].bank_code );   
    }

    function isEnrolledBank( address _bank_address ) private view returns ( bool )
    {
        Bank memory current_bank = map_address2bank[ _bank_address ];
        if ( current_bank.bank_address == address(0x0) )
            return false;
        return true;
    }

    function showBankCode() public view returns ( string memory )
    {
        if ( isEnrolledBank( msg.sender) )
            return map_address2bank[ msg.sender ].bank_code;
        return "Bank Not Found - Pl' Enroll the Bank";
    } 
/*
   function addCustomerToBank(string memory _name) public returns ( string memory )
    {
        customers.push(_)
        return "";
    }
*/

} //--end-contract