// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract DecentralizedCollegeCatalogContract
{//start-contract 

    /*
    This is education regulator which deploys and manages the smart contract
    */
    address eth_educationRegulatorBodyAddress;

    // college info
    struct College
    {
        string  name;
        address eth_college;
        string  admin_name;
        string  registration_number;
        // regulatory permissions
        bool    permission_to_add_students;
        bool    permission_to_add_courses;
        // college -> registered students info
        uint    number_of_students;
        uint    number_of_courses;
        // college -> conducted courses info
        mapping( string => Student ) mStudentsLedger;
        mapping( string => Course ) mCoursesLedger;
       }
    // colleges ledger
    mapping( address => College ) mCollegesLedger;
    uint256    number_of_colleges;     

    // student info
    struct Student
    {
        string  name;
        string  phone_number;
        // student -> enrolled courses info
        mapping( string => Course ) mCoursesEnrolled;
        uint    number_of_courses_enrolled;
    }

    // course info
    struct Course
    {
        string  name;
        string  college_name;
        uint    start_date;
        bool    classroom_mode;
    }

    constructor()
    {
        eth_educationRegulatorBodyAddress = msg.sender;
        number_of_colleges = 0;
    }    

    function addNewCollegeToLedger( string memory _name, address _eth_addr, string memory _admin, string memory _reg_no  ) public returns ( string memory )
    {
        College storage _new_col = mCollegesLedger[ _eth_addr ];
        _new_col.name = _name;
        _new_col.eth_college = _eth_addr;
        _new_col.admin_name = _admin;
        _new_col.registration_number = _reg_no;
        _new_col.permission_to_add_students = true;
        _new_col.permission_to_add_courses = true;
        number_of_colleges++;
        return string(abi.encodePacked("New College added to ledger - ", _new_col.name ));  
    }

    function viewCollegeInfo(address _col_addr) public view returns (string memory, string memory)
    {
        return (mCollegesLedger[_col_addr].name,mCollegesLedger[_col_addr].registration_number);
    }

}//end-contract
