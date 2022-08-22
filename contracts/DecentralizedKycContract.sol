// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DecentralizedKycContract
{ //--start-contract

    /*
    This is the KYC admin or rgulatory body which deploys the KYC contract
    */    
    address regulator;
 
    // Bank info
    struct Bank
    {
        address bank_address;
        string  bank_name;
        bool    bank_add_customer_permission;
        bool    bank_kyc_privilege;
        int     bank_customers_count;
        int     bank_kyc_count;
    }
    // Map to store Banks
    mapping( address => Bank ) mBanks;
 
    // Customer info
    struct Customer
    {
        string  customer_name;
        address customer_bank_address;  
        string  customer_data;
        bool    customer_kyc_status;
    }
    // Map to store Customers
    mapping( string => Customer ) mCustomers;

    struct KycRequest
    {
        string  customer_name;
        uint    customer_birthdate;
        string  customer_email;
        string  customer_phone;
        string  customer_contact_address;
        string  customer_kyc_reference_document;
        uint    customer_kyc_date;   
    }

    // initialises the deployer of the contract to be KYC admin regulator
    constructor()
    {
        regulator = msg.sender;
    }

    // critical operations to be performed by only kyc admin regulator
    modifier onlyRegulator()
    {
        require( msg.sender == regulator, "Only KYC Admin Regulator can call" );
        _;
    }

    // some operations to be performed only by bank
    modifier onlyBank()
    {
        require( mBanks[ msg.sender ].bank_address != address(0x0),"Only Bank can call");
        _;
    } 

    function addNewBankToLedger(string memory _bank_name,address _bank_address ) public onlyRegulator returns( string memory, string memory )
    {
        if ( isEnrolledBank( _bank_address ))
            return ("Error - Bank Already Exists in Ledger: ", mBanks[ _bank_address ].bank_name);
        mBanks[ _bank_address ] = Bank( _bank_address, _bank_name, false, false, 0, 0 );
        return ("Success - New Bank Enrolled in Ledger: ", mBanks[ _bank_address ].bank_name );   
    }

    function isEnrolledBank( address _bank_address ) private view returns ( bool )
    {
        Bank memory current_bank = mBanks[ _bank_address ];
        if ( current_bank.bank_address == address(0x0) )
            return false;
        return true;
    }

    function showBankDetails() public view returns ( address, string memory, bool, bool, int, int )
    {
        if ( isEnrolledBank( msg.sender) )
            return ( mBanks[ msg.sender ].bank_address, mBanks[ msg.sender ].bank_name,
            mBanks[ msg.sender ].bank_add_customer_permission, mBanks[ msg.sender ].bank_kyc_privilege,
            mBanks[ msg.sender ].bank_customers_count, mBanks[ msg.sender ].bank_kyc_count );
        return (address(0),"Bank Not Found",false,false,0,0);
    } 

   function addNewCustomerToBank(string memory _name, address _bank, string memory _data, bool _status) public onlyBank returns ( string memory )
    {
        mCustomers[ _name ] = Customer(_name,_bank,_data,_status );
        return "";
    }

    function isEnrolledCustomer( string memory _name ) private view returns ( bool )
    {
        if ( mCustomers[ _name ].customer_bank_address == address(0x0) )
            return false;
        return true;
    }

   function showCustomerData( string memory _name ) public view onlyBank returns ( string memory )
    {
        if ( isEnrolledCustomer( _name) ){
            if( mCustomers[_name].customer_bank_address == msg.sender)      
                return mCustomers[ _name ].customer_data;
            return "Only Customer Bank can access the own Customer data";
        }
        return "Customer Not Found - Pl' Enroll the Customer";
    }

    function checkKycStatusOfCustomer( string memory _name ) public view returns ( string memory, bool )
    {
        if ( isEnrolledCustomer( _name) )
            return ( mCustomers[ _name ].customer_name, mCustomers[ _name ].customer_kyc_status );
        return ( "Customer Not Found", false );
    } 

    function blockBankToAddNewCustomer( address _bank_address ) public onlyRegulator returns( string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_add_customer_permission = false;
                return ( mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_add_customer_permission );
        }
        return ("Bank Not Found - The Bank need to enrolled ", false);
    }

    function allowBankToAddNewCustomer( address _bank_address ) public onlyRegulator returns( string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_add_customer_permission = true;
                return ( mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_add_customer_permission );
        }
        return ("Bank Not Found - The Bank need to enrolled ", false);
    }

    function blockBankToDoKyc( address _bank_address ) public onlyRegulator returns( string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_kyc_privilege = false;
                return ( mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_kyc_privilege );
        }
        return ("Bank Not Found - The Bank need to enrolled ", false);
    }

    function allowBankToDoKyc( address _bank_address ) public onlyRegulator returns( string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_kyc_privilege = true;
                return ( mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_kyc_privilege );
        }
        return ("Bank Not Found - The Bank need to enrolled ", false);
    }

} //--end-contract