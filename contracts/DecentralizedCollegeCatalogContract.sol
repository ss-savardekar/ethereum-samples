// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract DecentralizedCollegeCatalogContract
{//start-contract 

    /*
    This is education regulator which deploys and manages the smart contract
    */
    address eth_universityAdmin;

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
        uint    roll_number;    
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
        eth_universityAdmin = msg.sender;
        number_of_colleges = 0;
    }    

    // +ve flow test - ok 
    function addNewCollegeToLedger( string memory _name, address _eth_addr, string memory _admin, string memory _reg_no  ) public returns ( string memory )
    {
        College storage _new_col = mCollegesLedger[ _eth_addr ];
        _new_col.name = _name;
        _new_col.eth_college = _eth_addr;
        _new_col.admin_name = _admin;
        _new_col.registration_number = _reg_no;
        _new_col.permission_to_add_students = true;
        _new_col.permission_to_add_courses = true;
        _new_col.number_of_students++;
        number_of_colleges++;
        return string(abi.encodePacked("New College added to ledger - ", _new_col.name ));  
    }

    // +ve flow test - ok
    function viewCollegeInfo(address _col_addr) public view returns (string memory, address, string memory, string memory, bool, bool)
    {
        return (    mCollegesLedger[_col_addr].name,
                    mCollegesLedger[_col_addr].eth_college,
                    mCollegesLedger[_col_addr].admin_name,
                    mCollegesLedger[_col_addr].registration_number,
                    mCollegesLedger[_col_addr].permission_to_add_students,
                    mCollegesLedger[_col_addr].permission_to_add_courses
                );
    }

    // +ve flow test - ok
    function blockCollegeToAddNewStudents(address _col_addr) public returns(string memory,string memory)
    {
        mCollegesLedger[_col_addr].permission_to_add_students = false;
        return ( "College blocked to add students - ", mCollegesLedger[_col_addr].name );
    }

    // +ve flow test - ok
    function allowCollegeToAddNewStudents(address _col_addr) public returns(string memory,string memory)
    {
        mCollegesLedger[_col_addr].permission_to_add_students = true;
        return ( "College allowed to add students - ", mCollegesLedger[_col_addr].name );
    }

    // +ve flow test - ok
    function addNewStudentToCollege(string memory _name,string memory _phone_no) public returns(string memory,string memory,string memory)
    {
        Student storage _new_student = mCollegesLedger[msg.sender].mStudentsLedger[_name];
        _new_student.name = _name;
        _new_student.phone_number = _phone_no;
        _new_student.roll_number = mCollegesLedger[msg.sender].number_of_students++;
    
        return ("Student added to college - ", _new_student.name, mCollegesLedger[msg.sender].name); 
    }

    // +ve flow test - ok
    function viewStudentInfo(string memory _name) public view returns(string memory,string memory,uint)
    {
        Student storage _new_student = mCollegesLedger[msg.sender].mStudentsLedger[_name];

        return (_new_student.name,_new_student.phone_number,_new_student.roll_number);
    }

    // +ve flow test - ok
    function addNewCourseToCollege(string memory _name,bool _mode) public returns(string memory,string memory,bool)
    {
        Course storage _new_course = mCollegesLedger[msg.sender].mCoursesLedger[_name];
        _new_course.name = _name;
        _new_course.classroom_mode = _mode;
        _new_course.start_date = block.timestamp;
    
        return ("Course added to college - ", _new_course.name, _new_course.classroom_mode); 
    }

    // +ve flow test - ok
    function viewCourseInfo(string memory _name) public view returns(string memory,bool)
    {
        Course storage _course = mCollegesLedger[msg.sender].mCoursesLedger[_name];

        return (_course.name,_course.classroom_mode);
    }

    // +ve flow test - ok
    function enrollStudentToCourse(string memory _student_name, string memory _course_name ) public returns(string memory,string memory,string memory)
    {
        Student storage _student = mCollegesLedger[msg.sender].mStudentsLedger[_student_name];
        Course  storage _course = mCollegesLedger[msg.sender].mCoursesLedger[_course_name];
        _student.mCoursesEnrolled[_course.name] = _course;

        return ("Student enrolled in the course - ",_student.name,_course_name);    
    }

    // +ve flow test
    function isStudentEnrolledInTheCourse(string memory _student_name, string memory _course_name) public view returns(string memory,bool)
    {
        Student storage _student = mCollegesLedger[msg.sender].mStudentsLedger[_student_name];
        //Course  storage _course = mCollegesLedger[msg.sender].mCoursesLedger[_course_name];

        if( abi.encodePacked((_student.mCoursesEnrolled[_course_name]).name).length > 0)
            return ("Student is enrolled in the course - ", true);
        return ("Student is not enrolled in the course - ", false);
    }

    // +ve flow test - ok
    function changeStudentCourse(string memory _student_name, string memory _curr_course, string memory _new_course) public returns(string memory,string memory,string memory)
    {
        Student storage _student = mCollegesLedger[msg.sender].mStudentsLedger[_student_name];
        _student.mCoursesEnrolled[_curr_course] = _student.mCoursesEnrolled[_new_course];

        return ("Student course changed - ",_student.name,_new_course);
    }

}//end-contract
