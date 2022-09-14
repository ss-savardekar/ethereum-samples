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

    // KYC Request Info
    struct KycRequest
    {
        string  kyc_reuqest_customer_name;
        address kyc_request_bank_address;
        // KYC is sensitive data hence only hash refrence stored
        string  kyc_request_data_hash;
        // date tracking 
        uint    kyc_request_date;
        uint    kyc_request_fulfill_date;   
    }
    // Map to store KYC Requests
    mapping( string => KycRequest ) mKycRequests;

    // initialises the deployer of the contract to be KYC admin regulator
    constructor()
    {
        regulator = msg.sender;
    }

    // critical permission operations to be performed by only kyc admin regulator
    modifier onlyRegulator()
    {
        require( msg.sender == regulator, "Only KYC Admin Regulator can call" );
        _;
    }

    // bank specific operations to be performed only by the bank
    modifier onlyBank()
    {
        require( mBanks[ msg.sender ].bank_address != address(0x0),"Only Bank can call");
        _;
    } 

    /*
    * -- Function Details --
    * name          : addNewBankToLedger
    * scope         : public
    * restrictions  : access only to Banks Contract deployer or regulator
    * input params  :
        - string bank name
        - addresss ethereum address for the bank 
    * output params :
        - string success / error status
        - string bank name
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - exec permissions test ok   
    */
    function addNewBankToLedger(string memory _bank_name,address _bank_address ) public onlyRegulator returns( string memory, string memory )
    {
        if ( isEnrolledBank( _bank_address ))
            return ("Error - Bank Already Exists in Ledger: ", mBanks[ _bank_address ].bank_name);
        mBanks[ _bank_address ] = Bank( _bank_address, _bank_name, false, false, 0, 0 );
        return ("Success - New Bank Enrolled in Ledger: ", mBanks[ _bank_address ].bank_name );   
    }

    // this is a private function to help check if Bank detaols already exists in ledger
    function isEnrolledBank( address _bank_address ) private view returns ( bool )
    {
        Bank memory current_bank = mBanks[ _bank_address ];
        if ( current_bank.bank_address == address(0x0) )
            return false;
        return true;
    }

    /*
    * -- Function Details --
    * name          : showBankDetails
    * scope         : public
    * restrictions  : anyone can access who knows the banks ethereum address
    * input params  :
        - addresss ethereum address for the bank 
    * output params :
        - ethereum address of the bank
        - string bank name
        - bool permission to add customers
        - bool permission to perform kyc
        - uint number of customers for the bank
        - uint number of kycs performed by the bank
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - invalid bank address test ok   
    */
    function showBankDetails(address _bank_address) public view returns ( address, string memory, bool, bool, int, int )
    {
        if ( isEnrolledBank(_bank_address) )
            return ( mBanks[ _bank_address ].bank_address, mBanks[ _bank_address ].bank_name,
            mBanks[ _bank_address ].bank_add_customer_permission, mBanks[ _bank_address ].bank_kyc_privilege,
            mBanks[ _bank_address ].bank_customers_count, mBanks[ _bank_address ].bank_kyc_count );
        return (address(0),"Bank Not Found",false,false,0,0);
    } 

    /*
    * -- Function Details --
    * name          : addNewCustomerToBank
    * scope         : public
    * restrictions  : only Banks can add their own customers
    * input params  :
        - string customer name
        - bool kyc status of the new customer 
    * output params :
        - string success / error status of the function
        - string customer name
        - string bank name
    * +ve tests    :
        - sample data test ok
        - permission to add customer test ok
    * -ve tests    :
        - already existing customer test ok
        - blocked to add customer test ok   
    */
   function addNewCustomerToBank(string memory _name, string memory _data, bool _status) public onlyBank returns ( string memory, string memory, string memory )
    {
        if( mBanks[ msg.sender].bank_add_customer_permission )
        {
            if( isEnrolledCustomer(_name) == false)
            {
                mCustomers[ _name ] = Customer( _name, msg.sender,_data,_status );
                mBanks[ msg.sender ].bank_customers_count = mBanks[ msg.sender ].bank_customers_count++;
                return ("Customer added sucessfully to the bank", _name, mBanks[ msg.sender ].bank_name );    
            }
            return ("Already existing customer for the bank", _name, mBanks[ msg.sender ].bank_name );
        }
        return ("Bank is blocked to add new Customers", _name, mBanks[ msg.sender ].bank_name );
    }

    // private function to check if the customer is already enrolled for the bank
    function isEnrolledCustomer( string memory _name ) private view returns ( bool )
    {
        if ( mCustomers[ _name ].customer_bank_address == address(0x0) )
            return false;
        return true;
    }

    /*
    * -- Function Details --
    * name          : showCustomerData
    * scope         : public
    * restrictions  : only Banks can view their own customers
    * input params  :
        - string customer name
    * output params :
        - string success / error status of the function
        - string customer name
        - string bank name
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing customer test ok
        - customer belonging to different bank test ok
        - customer not found for the bank test ok   
    */
   function showCustomerData( string memory _name ) public view onlyBank returns ( string memory, string memory, string memory )
    {
        if ( isEnrolledCustomer( _name) ){
            if( mCustomers[_name].customer_bank_address == msg.sender)      
                return("Customer info for the Bank", _name, mCustomers[ _name ].customer_data);
            return("The Customer belongs to the different Bank so cant view details", _name, "");
        }
        return("Customer Not Found for the Bank - Pl' Enroll the Customer",_name,"");
    }

    /*
    * -- Function Details --
    * name          : checkKycStatusOfCustomer
    * scope         : public
    * restrictions  : only Banks can view their own customers kyc status
    * input params  :
        - string customer name
    * output params :
        - string success / error status of the function
        - string customer name
        - bool kyc status of the customer
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing customer test ok
        - customer belonging to different bank test ok
        - customer not found for the bank test ok   
    */
    function checkKycStatusOfCustomer( string memory _name ) public view onlyBank returns ( string memory, string memory, bool )
    {
        if ( isEnrolledCustomer( _name) )
        {
            if( mCustomers[_name].customer_bank_address == msg.sender)      
                return ( "Customer KYC status for the Bank", mCustomers[ _name ].customer_name, mCustomers[ _name ].customer_kyc_status );
            return("The Customer belongs to the different Bank so cant view KYC details", _name,false);
        }
        return ( "Customer Not Found for the Bank", _name, false );
    } 

    /*
    * -- Function Details --
    * name          : blockBankToAddNewCustomer
    * scope         : public
    * restrictions  : only central regulator can block permission to add bank customers 
    * input params  :
        - address ethereum bank address
    * output params :
        - string success / error status of the function
        - string bank name
        - bool permission to add customer for the bank
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing bank test ok
        - bank does not exists test ok
    */
    function blockBankToAddNewCustomer( address _bank_address ) public onlyRegulator returns( string memory, string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_add_customer_permission = false;
                return ( "The bank blocked to add Customers", mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_add_customer_permission );
        }
        return ("Bank Not Found - The Bank need to enrolled ", "", false);
    }

    /*
    * -- Function Details --
    * name          : allowBankToAddNewCustomer
    * scope         : public
    * restrictions  : only central regulator can allow permission to add bank customers 
    * input params  :
        - address ethereum bank address
    * output params :
        - string success / error status of the function
        - string bank name
        - bool permission to add customer for the bank
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing bank test ok
        - bank does not exists test ok
    */
    function allowBankToAddNewCustomer( address _bank_address ) public onlyRegulator returns( string memory, string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_add_customer_permission = true;
                return ( "The Bank allowed to add Customers", mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_add_customer_permission );
        }
        return ("Bank Not Found - The Bank need to enrolled ", "", false);
    }

    /*
    * -- Function Details --
    * name          : blockBankToDoKyc
    * scope         : public
    * restrictions  : only central regulator can block permission to do KYC for bank customers 
    * input params  :
        - address ethereum bank address
    * output params :
        - string success / error status of the function
        - string bank name
        - bool permission to add customer for the bank
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing bank test ok
        - bank does not exists test ok
    */
    function blockBankToDoKyc( address _bank_address ) public onlyRegulator returns( string memory, string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_kyc_privilege = false;
                return ( "The Bank blocked to do KYC", mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_kyc_privilege );
        }
        return ("Bank Not Found - The Bank need to enrolled ","", false);
    }

    /*
    * -- Function Details --
    * name          : allowBankToDoKyc
    * scope         : public
    * restrictions  : only central regulator can allow permission to do KYC for bank customers 
    * input params  :
        - address ethereum bank address
    * output params :
        - string success / error status of the function
        - string bank name
        - bool permission to add customer for the bank
    * +ve tests    :
        - sample data test ok
    * -ve tests    :
        - already existing bank test ok
        - bank does not exists test ok
    */
    function allowBankToDoKyc( address _bank_address ) public onlyRegulator returns( string memory, string memory, bool )
    {
        if ( isEnrolledBank( _bank_address ) )
        {
            mBanks[ _bank_address ].bank_kyc_privilege = true;
                return ( "The Bank allowed to do KYC", mBanks[ _bank_address ].bank_name, mBanks[ _bank_address ].bank_kyc_privilege );
        }
        return ("Bank Not Found - The Bank need to enrolled ","", false);
    }

    /*
    * -- Function Details --
    * name          : performKycRequest
    * scope         : public
    * restrictions  : only Bank can to do KYC for bank customers 
    * input params  :
        - string customer name
    * output params :
        - string success / error status of the function
        - string bank name
    * +ve tests    :
        - sample data test ok
        - bank kyc privilege set test ok
    * -ve tests    :
        - already existing bank customer test ok
        - bank kyc privilege blocked test ok
    */
    function performKycRequest( string memory _name ) public onlyBank returns( string memory, string memory )
    {
        if( mBanks[msg.sender].bank_kyc_privilege)
        {
            if ( mCustomers[ _name ].customer_bank_address == msg.sender )
            {
                mKycRequests[ _name ] = KycRequest( _name, msg.sender, "", block.timestamp, 0 );
                mBanks[ msg.sender ].bank_kyc_count = mBanks[ msg.sender ].bank_kyc_count++; 
                return ("Customer KYC request added for the Bank Customer", _name);
            }
            return ("The Bank doesnot have the customer", _name);
        }
        return ("The Bank blocked to do Customers KYC", _name);
    }
} //--end-contract