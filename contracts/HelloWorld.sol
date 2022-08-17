// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/*
HellowWord contract is a trial ethereum contract for self learning
*/
contract HelloWorld
{
    string public name;

    constructor()
    {
        name = "Hello World !.. - ";
    }

    function set(string memory mName ) public
    {
        name = string(abi.encodePacked(name, mName));
    }

    function hi() view public returns (string memory)
    {
        return name;       
    }    
    
}