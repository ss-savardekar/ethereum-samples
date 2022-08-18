// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BankContract
{ //--start contract--

    struct client_account
    {
        int client_id;
        address client_address;
        uint client_balance_in_ether;
    }

    client_account[] clients;

    int clientCounter;

    address payable manager;
    mapping( address => uint ) public interestDate;

    constructor() 
    {
        clientCounter = 0;
    }

    modifier onlyManager()
    {
        require( msg.sender == manager, "Only Manager Can Call !.." );
        _;
    }

    modifier onlyClients()
    {
        bool isClient=false;
        for( uint i=0; i < clients.length; i++)
        {
            if( clients[i].client_address == msg.sender )
            {
                isClient = true;
                break;
            }
            require( isClient, "Only Clients Can Call !.." );
            _;
        }
    }

    receive() external payable
    {
    } 

    function setManager( address managerAdderess ) public returns( string memory )
    {
        manager = payable( managerAdderess );
        return "";        
    }

    function joinAsClient() public payable returns( string memory)
    {
        interestDate[ msg.sender ] = block.timestamp;
        clients.push( client_account( clientCounter++, msg.sender, address(msg.sender).balance) );
        return "";
    }

    function deposit() public payable onlyClients
    {
        payable(address(this)).transfer(msg.value);
    }

    function withdraw( uint amount ) public payable onlyClients
    {
        payable(msg.sender).transfer( amount * 1 ether );
    }

    function getContractBalance() public view returns( uint )
    {
        return address(this).balance;
    }

    function sendInterest() public payable onlyManager
    {
        for ( uint i = 0; i < clients.length; i++ )
        {
            address initialAddress = clients[i].client_address;
            uint lastInterestDate = interestDate[ initialAddress ];
            if( block.timestamp < lastInterestDate + 10 seconds )
            {
                revert( "It's just been less than 10 seconds" );
            }
            payable( initialAddress ).transfer( 1 ether);
            interestDate[ initialAddress ] = block.timestamp; 
        }
    }

    function sendBonus(address clientAddress) public payable onlyManager
    {
        payable( clientAddress ).transfer(1 ether);
    }

} //--end contract--