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
        // internal identifier used to validate if college exists in mapping
        bool    exists;
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
        // internal identifier used to validate if college exists in mapping
        bool    exists;
    }

    // course info
    struct Course
    {
        string  name;
        string  college_name;
        uint    start_date;
        bool    classroom_mode;
        // internal identifier used to validate if college exists in mapping
        bool    exists;
    }

    // constructors and modifiers
    constructor()
    {
        eth_universityAdmin = msg.sender;
        number_of_colleges = 0;
    }    

    modifier onlyUniversityAdmin()
    {
        require( msg.sender == eth_universityAdmin, "Only University Admin can perform");
        _;
    }

    modifier onlyCollegeAuthority()
    {
        require( mCollegesLedger[msg.sender].exists,"Only College Authority can perform");
        _;
    }

    // +ve flow test - ok 
    function addNewCollegeToLedger( string memory _name, address _eth_addr, string memory _admin, string memory _reg_no  ) public onlyUniversityAdmin returns ( string memory )
    {
        if( isValidCollege(_eth_addr) )
            return string(abi.encodePacked("The college already exists in ledger - ",_eth_addr ));  

        College storage _new_col = mCollegesLedger[ _eth_addr ];
        _new_col.name = _name;
        _new_col.eth_college = _eth_addr;
        _new_col.admin_name = _admin;
        _new_col.registration_number = _reg_no;
        _new_col.permission_to_add_students = true;
        _new_col.permission_to_add_courses = true;
        _new_col.number_of_students++;
        number_of_colleges++;
        _new_col.exists = true;

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
    function blockCollegeToAddNewStudents(address _col_addr) public onlyUniversityAdmin returns(string memory,string memory)
    {
        if( isValidCollege(_col_addr))
        {
            mCollegesLedger[_col_addr].permission_to_add_students = false;
            return ( "College blocked to add students - ", mCollegesLedger[_col_addr].name );
        }
        else 
            return ( "Invalid College Address - ", mCollegesLedger[_col_addr].name );
    }

    // +ve flow test - ok
    function allowCollegeToAddNewStudents(address _col_addr) public onlyUniversityAdmin returns(string memory,string memory)
    {
        if( isValidCollege(_col_addr))
        {
            mCollegesLedger[_col_addr].permission_to_add_students = true;
            return ( "College allowed to add students - ", mCollegesLedger[_col_addr].name );
        }
        else
            return ( "Invalid College Address - ", mCollegesLedger[_col_addr].name );
    }

    // +ve flow test - ok
    function addNewStudentToCollege(string memory _name,string memory _phone_no) public onlyCollegeAuthority returns(string memory,string memory,string memory)
    {
        if( isValidStudent(_name))
            return ("The Student already registered - ", _name, mCollegesLedger[msg.sender].name); 

        Student storage _new_student = mCollegesLedger[msg.sender].mStudentsLedger[_name];
        _new_student.name = _name;
        _new_student.phone_number = _phone_no;
        mCollegesLedger[msg.sender].number_of_students++;
        _new_student.roll_number = mCollegesLedger[msg.sender].number_of_students;
        _new_student.exists = true;
    
        return ("Student added to college - ", _new_student.name, mCollegesLedger[msg.sender].name); 
    }

    // +ve flow test - ok
    function viewStudentInfo(string memory _name) public view onlyCollegeAuthority returns(string memory,string memory,uint)
    {
        Student storage _new_student = mCollegesLedger[msg.sender].mStudentsLedger[_name];
        return (_new_student.name,_new_student.phone_number,_new_student.roll_number);
    }

    // +ve flow test - ok
    function addNewCourseToCollege(string memory _name,bool _mode) public onlyCollegeAuthority returns(string memory,string memory,bool)
    {
        if( isValidCourse(_name))
        return ("The Course already exists - ", _name, mCollegesLedger[msg.sender].mCoursesLedger[_name].classroom_mode); 

        Course storage _new_course = mCollegesLedger[msg.sender].mCoursesLedger[_name];
        _new_course.name = _name;
        _new_course.classroom_mode = _mode;
        _new_course.start_date = block.timestamp;
        _new_course.exists = true;
    
        return ("Course added to college - ", _new_course.name, _new_course.classroom_mode); 
    }

    // +ve flow test - ok
    function viewCourseInfo(string memory _name) public view onlyCollegeAuthority returns(string memory,bool)
    {
        Course storage _course = mCollegesLedger[msg.sender].mCoursesLedger[_name];
        return (_course.name,_course.classroom_mode);
    }

    // +ve flow test - ok
    function enrollStudentToCourse(string memory _student_name, string memory _course_name ) public onlyCollegeAuthority returns(string memory,string memory,string memory)
    {
        if( isValidCourse(_course_name) && isValidStudent(_student_name))
        {
            Student storage _student = mCollegesLedger[msg.sender].mStudentsLedger[_student_name];
            Course  storage _course = mCollegesLedger[msg.sender].mCoursesLedger[_course_name];
            _student.mCoursesEnrolled[_course_name] = _course;
            return ("Student enrolled in the course - ",_student.name,_course_name);
        }
        else
            return ("Invalid Course or Student info - ",_student_name,_course_name);
    }

    // +ve flow test
    function isStudentEnrolledInTheCourse( string memory _student_name, string memory _course_name) public view onlyCollegeAuthority returns(string memory,bool)
    {
        if( mCollegesLedger[msg.sender].mStudentsLedger[_student_name].mCoursesEnrolled[_course_name].exists )
                return ("Student is enrolled in the course - ", true);
        return ("Student is not enrolled in the course - ", false);
    }

    // +ve flow test - ok
    function changeStudentCourse(string memory _student_name, string memory _current_course, string memory _new_course) public onlyCollegeAuthority returns(string memory,string memory,string memory)
    {
        Course memory nullCourse;
        if( isValidStudent(_student_name) && isValidCourse(_current_course) && isValidCourse(_new_course))
        {
            if( stringCompare(_current_course,_new_course))
                return("Same course hence can't be changed", _student_name,  _current_course);

            mCollegesLedger[msg.sender].mStudentsLedger[_student_name].mCoursesEnrolled[_current_course] = nullCourse; 
            mCollegesLedger[msg.sender].mStudentsLedger[_student_name].mCoursesEnrolled[_new_course] 
            = mCollegesLedger[msg.sender].mCoursesLedger[_new_course]; 

            return ("Student course changed - ",_student_name,_new_course);
        }
        return ("Invalid Student Course info - ",_student_name,_new_course);
    }
 
    //private or internal functions - validators - utility functions

    function isValidCollege(address _college_address) private view returns(bool)
    {
        return mCollegesLedger[_college_address].exists;
    }

    function isValidCourse(string memory _course_name ) private view returns(bool)
    {
        return mCollegesLedger[msg.sender].mCoursesLedger[_course_name].exists;
    }

    function isValidStudent(string memory _student_name) private view returns(bool)
    {
        return mCollegesLedger[msg.sender].mStudentsLedger[_student_name].exists;
    }

    function stringCompare(string memory _str1,string memory _str2) private pure returns(bool)
    {
        // Compare string keccak256 hashes to check equality
        if (keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2)))
            return true;
        return false;
    }

}//end-contract
