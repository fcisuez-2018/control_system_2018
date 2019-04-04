-- phpMyAdmin SQL Dump
-- version 4.8.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 04, 2019 at 09:12 PM
-- Server version: 10.1.31-MariaDB
-- PHP Version: 7.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cgpa_points` ()  BEGIN
set @strQuery=CONCAT('SELECT Course_points.StudentID, Course_points.StudentName, Course_points.StudentCode, Round(Sum(`Course_points`.`Course_cr_points`),2) AS CGPA_Total_points, Sum(Course.Credits) AS CGPA_SumOfCredits,

 ( select Grade_English from GPA_Grade where Max(`Course_semester`.`SemesterID`)=GPA_Grade.SemesterID AND Points<=  ifnull(Round(Sum(`Course_points`.`Course_cr_points`)/Sum(`Course`.`Credits`),2),0)limit 1) AS CGPA_grade, 
ifnull(Round(Sum(`Course_points`.`Course_cr_points`)/Sum(`Course`.`Credits`),2),0) AS CGPA_Points, Sum(Course_points.CourseCredits_Completed) AS CGPA_Credits_Completed
FROM Course inner JOIN (Course_semester inner JOIN (Course_points inner JOIN Registration ON Course_points.RegID = Registration.ID) ON Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID
WHERE (((Course_points.CourseMarks)>=0) AND ((Registration.statusID)<2) AND ((Registration.FinalExam) Not In (-300,-200)))
GROUP BY Course_points.StudentID, Course_points.StudentName, Course_points.StudentCode
ORDER BY Course_points.StudentID, Course_points.StudentCode');
PREPARE stmt1 FROM @strQuery;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_course_point` ()  begin
SET @strQuery =CONCAT('SELECT Registration.ID AS RegID, student.StudentEductionalNumber AS StudentCode, Registration.StudentID, Course_semester.SemesterID, student.StudentName, Semester.SemesterEnumID, Semester.StatusID AS SemesterStatusID, Semester.Semester, Course.Credits AS CourseCredits, Course.ArabicName AS CourseArabicName, Course.Prerequisits, Course.Code AS CourseCode, if(ifnull(`Registration`.`FinalExam`,0) <0, ifnull(`Registration`.`FinalExam`,0), ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)) AS CourseMarks, if(`Registration`.`FinalExam`=-300, ( SELECT Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Ordercode=54 limit 1) ,if(`Registration`.`FinalExam`=-200,  (select Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID  AND Ordercode=53 limit 1) ,if(`Registration`.`FinalExam`=-100, ( select Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Ordercode=52 limit 1) ,if(ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)< (`Course`.`FinalExam`+`Course`.`Year Work Grades O`+`Course`.`Year Work Grades PE`+`Course`.`YearWorkGrades G`+`Course`.`MidTerm`)*0.5  ,(select Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =SemesterID AND Ordercode=50 limit 1) ,if(ifnull(`Registration`.`FinalExam`,0)<`Course`.`FinalExam`*0.4 ,(select Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =SemesterID AND Ordercode=51 limit 1) , (select Grade_English from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Percentage<=  ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)limit 1) ) )) )) AS Grade_English, if(`Registration`.`FinalExam`=-300, (select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Ordercode=54 limit 1) ,if(`Registration`.`FinalExam`=-200, (select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Ordercode=53 limit 1) ,if(`Registration`.`FinalExam`=-100, (select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Ordercode=52 limit 1) ,if(ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)< (`Course`.`FinalExam`+`Course`.`Year Work Grades O`+`Course`.`Year Work Grades PE`+`Course`.`YearWorkGrades G`+`Course`.`MidTerm`)*0.5 ,(select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =SemesterID AND Ordercode=50 limit 1) ,if(ifnull(`Registration`.`FinalExam`,0)<`Course`.`FinalExam`*0.4  ,(select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =SemesterID AND Ordercode=51 limit 1)  ,(select Grade_Arabic from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Percentage<=  ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)limit 1) ) ))))  AS Grade_Arabic, if(ifnull(`Registration`.`FinalExam`,0)<`Course`.`FinalExam`*0.4,0, if(ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)<=0,"",  Round((select Points from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Percentage<=  ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)limit 1 ),2))) AS Course_Points,  Round( (select Points from Course_Grade where ifnull(Course_semester.SemesterID,1) =Course_Grade.SemesterID AND Percentage<=  ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)limit 1) *`Course`.`Credits`,2) AS Course_cr_points,    if((ifnull(`Registration`.`FinalExam`,0)<`Course`.`FinalExam`*0.4) Or (ifnull(`Registration`.`FinalExam`,0)+ifnull(`Registration`.`YearWork`,0)+ifnull(`Registration`.`MidTermExam`,0)<(ifnull(`Course`.`MidTerm`,0)+ifnull(`Course`.`Year Work Grades O`,0)+ifnull(`Course`.`Year Work Grades PE`,0)+ifnull(`Course`.`YearWorkGrades G`,0)+ifnull(`Course`.`FinalExam`,0))*0.5),0,ifnull(`Credits`,0)) AS CourseCredits_Completed, Student.MajorDepartmentID AS DepartmentID FROM student INNER JOIN (Semester INNER JOIN (Course INNER JOIN (Course_semester INNER JOIN Registration ON Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID) ON Semester.ID = Course_semester.SemesterID) ON student.ID = Registration.StudentID \r\nWHERE Registration.statusID!=',2,'\r\nORDER BY student.StudentEductionalNumber');


PREPARE stmt1 FROM @strQuery;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_course_semester` (IN `semesterID` INT, IN `LevelID` INT)  begin
SET @strQuery = CONCAT(' SELECT course.code, Course.Course , doctor.NameTxt  FROM Semester INNER JOIN ( doctor INNER JOIN(Course INNER JOIN Course_semester ON Course.ID = Course_semester.CourseID )ON   doctor.ID = Course_semester.DoctorID)ON Semester.ID = Course_semester.SemesterID WHERE Course_semester.semesterID=', 
semesterID, ' and Course.LeveLID=',LevelID );

PREPARE stmt1 FROM @strQuery;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DemoOneSqlCourse` ()  BEGIN
SELECT CONCAT(Student_CourseGrade.StudentEductionalNumber , char(10) , Student_CourseGrade.`حالة القيد` )as StudentEductionalNumber,' ', Student_CourseGrade.StudentName , 
if(CS241.CourseMarks= -100 ,CS241.Grade_English,if(CS241.CourseMarks <=0 ,'-', CS241.CourseMarks)) AS CS241_CourseMarks, if(CS241.CourseMarks=-100 OR CS241.CourseMarks>0 , CS241.Grade_English,'-') AS CS241_Grade_English, if(CS241.Course_Points is null OR CS241.Course_Points <= 0,'-', CS241.Course_Points) AS CS241_Course_Points, if(CS241.Course_cr_points <= 0 , '-', (Round(CS241.Course_cr_points,1))) AS CS241_CR_points,

Round(
ifnull(`CS241`.`Course_cr_points`,0)
,3) AS Total_CR_points,
(select Grade_English from GPA_Grade where SemesterID=GPA_Grade.SemesterID AND Points<= Round((
ifnull(`CS241`.`Course_cr_points`,0)
)/(
ifnull(`CS241`.`CourseCredits`,0)
),3) limit 1) AS GPA_Semester,
Round((
ifnull(`CS241`.`Course_cr_points`,0)
)/(
ifnull(`CS241`.`CourseCredits`,0)
),3) AS Total_points,
Round(
ifnull(`CS241`.`CourseCredits_Completed`,0)
,3) AS SumOfCredits,

CGPA_points.CGPA_Total_points,CGPA_points.CGPA_grade, CGPA_points.CGPA_Points, CGPA_points.CGPA_SumOfCredits

FROM CGPA_points RIGHT JOIN 
((SELECT Registration.ID AS CS241,student.ID as studentID, StudentEductionalNumber,StudentName, `حالة القيد` 
FROM student INNER JOIN ((Course INNER JOIN Course_semester ON Course.ID = Course_semester.CourseID) INNER JOIN Registration ON Course_semester.ID = Registration.Course_semesterID) ON student.ID = Registration.StudentID
WHERE Course.Code="CS241") as Student_CourseGrade
LEFT JOIN Course_points AS CS241 ON Student_CourseGrade.CS241 = CS241.RegID) 

ON (CGPA_points.StudentID = Student_CourseGrade.StudentID ) where 1=1;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gpa_points` (IN `semesterID` INT)  BEGIN
set @strQuery=CONCAT('SELECT Course_points.StudentID, Course_points.StudentName, Course_points.StudentCode, Round(Sum(`Course_points`.`Course_cr_points`),2) AS GPA_Total_points, Sum(Course.Credits) AS GPA_SumOfCredits,

 ( select Grade_English from GPA_Grade where Max(`Course_semester`.`SemesterID`)=GPA_Grade.SemesterID AND Points<=  ifnull(Round(Sum(`Course_points`.`Course_cr_points`)/Sum(`Course`.`Credits`),2),0)limit 1) AS GPA_grade, 
ifnull(Round(Sum(`Course_points`.`Course_cr_points`)/Sum(`Course`.`Credits`),2),0) AS GPA_Points, Sum(Course_points.CourseCredits_Completed) AS GPA_Credits_Completed
FROM Course inner JOIN (Course_semester inner JOIN (Course_points inner JOIN Registration ON Course_points.RegID = Registration.ID) ON Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID
WHERE (((Course_points.CourseMarks)>=0) AND ((Registration.statusID)<2) AND ((Registration.FinalExam) Not In (-300,-200)))and course_semester.SemesterID=',semesterID,'
GROUP BY Course_points.StudentID, Course_points.StudentName, Course_points.StudentCode
ORDER BY Course_points.StudentID, Course_points.StudentCode');
PREPARE stmt1 FROM @strQuery;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_StudentCourseList_Semester` (IN `semesterID` INT, IN `LevelID` INT, IN `MajorDepartmentID` INT)  BEGIN
if LevelID is null then 
set LevelID=-1;
END if;
if MajorDepartmentID is null then set MajorDepartmentID=-1;
END if;
set @strQuery=CONCAT('SELECT Course.Code, Course.ArabicName, ',
' (Course.Midterm+Course.`Year Work Grades O`+Course.`Year Work Grades PE`+ ',
' Course.`YearWorkGrades G`+Course.FinalExam) AS ttotal, ',
' student.MajorDepartmentID ',
' FROM student INNER JOIN (Course INNER JOIN (Course_semester INNER JOIN  ',
' (Registration INNER JOIN StudentLevel ON Registration.StudentID = StudentLevel.StudentID) ',
' ON Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID) ',
' ON student.ID = Registration.StudentID WHERE (1=1) ',
' GROUP BY Course.Code, Course.ArabicName, (Course.Midterm+Course.`Year Work Grades O`+Course.`Year Work Grades PE`+ ',
' Course.`YearWorkGrades G`+Course.FinalExam), Course_semester.CourseID, Course_semester.SemesterID,',
' Course.Course, student.MajorDepartmentID ',
' HAVING  (2=2 AND (Course_semester.SemesterID= ' , semesterID , '))');
If MajorDepartmentID > -1 Then
 set @strQuery = Replace(@strQuery, '2=2',CONCAT( 'student.MajorDepartmentID = ' , MajorDepartmentID));
End If ;

If LevelID <> -1 Then
set @strQuery = Replace(@strQuery, '1=1',CONCAT( '1=1 AND StudentLevel.StudLevelID=' , LevelID));
End If ;



PREPARE stmt1 FROM @strQuery;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CGPA_Semester` (`pStudentID` LONG, `pSemesterID` LONG) RETURNS DECIMAL(29,2) BEGIN
declare CGPA_grade decimal(29,2);
 select  `course_points`.`StudentCode`,
 (select `gpa_grade`.`Grade_English` from `gpa_grade`
 where ((`gpa_grade`.`semesterID` = max(`course_semester`.`SemesterID`)) 
 and (`gpa_grade`.`Points` <= 
 ifnull(round((sum(`course_points`.`Course_cr_points`) / 
 sum(`course`.`Credits`)),2),0))) limit 1)   into CGPA_grade
 from (`course` join (`course_semester` join (`course_points` join `registration` 
 on((`course_points`.`RegID` = `registration`.`ID`)))
 on((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
 on((`course`.`ID` = `course_semester`.`CourseID`))) 
 where ((`course_points`.`CourseMarks` >= 0)
 and (`registration`.`statusID` < 2) and (`registration`.`FinalExam` not in (-(300),-(200)))) 
 and
 `Course_semester`.`SemesterID`<=pSemesterID
 And `Course_points`.`StudentID` = pStudentID
 group by 
 `course_points`.`StudentCode`
;
RETURN CGPA_grade;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `activity`
--

CREATE TABLE `activity` (
  `ID` int(11) DEFAULT NULL,
  `ActivityTxt` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `activity`
--

INSERT INTO `activity` (`ID`, `ActivityTxt`) VALUES
(1, 'رياضى');

-- --------------------------------------------------------

--
-- Table structure for table `advisorapproval`
--

CREATE TABLE `advisorapproval` (
  `ID` int(11) DEFAULT NULL,
  `AdvisorApprovalTXT` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `advisorapproval`
--

INSERT INTO `advisorapproval` (`ID`, `AdvisorApprovalTXT`) VALUES
(1, 'Not revised'),
(2, 'Approved'),
(3, 'Rejected');

-- --------------------------------------------------------

--
-- Stand-in structure for view `cgpa_points`
-- (See below for the actual view)
--
CREATE TABLE `cgpa_points` (
`StudentID` int(11)
,`StudentName` varchar(255)
,`StudentCode` int(11)
,`CGPA_Total_points` double(19,2)
,`CGPA_SumOfCredits` decimal(32,0)
,`CGPA_grade` varchar(255)
,`CGPA_Points` double(19,2)
,`CGPA_Credits_Completed` decimal(41,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `changetype`
--

CREATE TABLE `changetype` (
  `ID` int(11) DEFAULT NULL,
  `ChangeType` varchar(255) DEFAULT NULL,
  `fieldName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `changetype`
--

INSERT INTO `changetype` (`ID`, `ChangeType`, `fieldName`) VALUES
(1, 'اضافة', 'AllowAdd'),
(2, 'تعديل', 'AllowEdit'),
(3, 'حذف', 'AllowDelete'),
(4, 'استرجاع', 'AllowRestore'),
(5, 'فتح', 'Enable'),
(6, 'تجاوز حدود المرتجع', 'AllowAcceptOverReturns'),
(7, 'صلاحية التحاسب', 'IsAccountant');

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `ID` int(11) NOT NULL,
  `Code` varchar(255) DEFAULT NULL,
  `ArabicName` varchar(255) DEFAULT NULL,
  `Course` varchar(255) DEFAULT NULL,
  `Credits` int(11) DEFAULT NULL,
  `Prerequisits` varchar(255) DEFAULT NULL,
  `CourseTypeID` int(11) DEFAULT NULL,
  `Teaching Hours Lecture` int(11) DEFAULT NULL,
  `Teching Hours Tutorial` varchar(255) DEFAULT NULL,
  `TeachingHours Practical` int(11) DEFAULT NULL,
  `Midterm` decimal(8,2) DEFAULT NULL,
  `Year Work Grades O` decimal(8,2) DEFAULT NULL,
  `Year Work Grades PE` decimal(8,2) DEFAULT NULL,
  `YearWorkGrades G` decimal(8,2) DEFAULT NULL,
  `FinalExam` decimal(8,2) DEFAULT NULL,
  `TimeofExam` int(11) DEFAULT NULL,
  `LeveLID` int(11) DEFAULT NULL,
  `DepartmentID` int(11) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `CurriculumID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`ID`, `Code`, `ArabicName`, `Course`, `Credits`, `Prerequisits`, `CourseTypeID`, `Teaching Hours Lecture`, `Teching Hours Tutorial`, `TeachingHours Practical`, `Midterm`, `Year Work Grades O`, `Year Work Grades PE`, `YearWorkGrades G`, `FinalExam`, `TimeofExam`, `LeveLID`, `DepartmentID`, `OrderCode`, `StatusID`, `CurriculumID`) VALUES
(11, 'CS141', 'أساسيات البرمجة', 'Programming Fundamentals', 3, 'CS121', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 1, 110, 1, 1),
(12, 'CS121', 'أساسيات تكنولوجيا المعلومات', 'CS Fundamentals', 3, '-', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 1, 120, 1, 1),
(13, 'MATH101', 'رياضيات 1', 'Mathematics I', 3, '-', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 130, 1, 1),
(14, 'MATH102', 'رياضيات 2', 'Mathematics II', 3, 'MATH101', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 140, 1, 1),
(15, 'PHYS101', 'الفيزياء 1', 'Physics I', 3, '-', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 150, 1, 1),
(16, 'PHYS102', 'الفيزياء 2', 'Physics II', 3, '-', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 160, 1, 1),
(17, 'PHYS103', 'الإلكترونيات', 'Electronics', 3, '-', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 170, 1, 1),
(18, 'PHYS104', 'الدوائر الرقمية', 'Digital Circuits', 3, 'PHYS103', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 180, 1, 1),
(19, 'HUM111', 'لغة إنجليزية', 'English Language', 3, '-', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 190, 1, 1),
(23, 'HUM131', 'سلوكيات الهيئات', 'Organizational Behavior and Scientific Thinking', 3, '-', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 230, 1, 1),
(24, 'HUM132', 'التواصل الشخصي', 'Interpersonal Communication', 3, '-', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 240, 1, 1),
(25, 'HUM133', 'اقتصاديات الحوسبة', 'Computing Economics', 3, '-', 2, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 250, 1, 1),
(26, 'HUM141', 'قوانين الحاسبات', 'Computer Law', 3, '-', 2, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 260, 1, 1),
(28, 'HUM151', 'الرسم باليد', 'Hand Drawing', 3, '-', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 280, 1, 1),
(29, 'HUM121', 'السياق الاجتماعي للحوسبة', 'Social Context  & History of Computing', 3, '-', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 5, 290, 1, 1),
(30, 'HUM153', 'الثقافة الإسلامية', 'Islamic  Culture', 3, '-', 2, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 300, 1, 1),
(32, 'CS101', 'هياكل متقطعة', 'Discrete Structures', 3, '-', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 1, 320, 1, 1),
(33, 'CS211', 'هياكل البيانات والخوارزميات', 'Data Structures and Algorithms', 3, 'CS241', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 1, 330, 1, 1),
(34, 'CS241', 'البرمجة الشيئية', 'Object-Oriented Programming', 3, 'CS141', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 1, 340, 1, 1),
(35, 'IS201', 'أساسيات نظم المعلومات', 'Foundations of Information Systems', 3, 'CS121', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 2, 350, 1, 1),
(36, 'IS211', 'تنظيم الملفات', 'File Organization', 3, 'CS241', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 2, 360, 1, 1),
(37, 'IS212', 'قواعد البيانات', 'Databases', 3, 'IS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 2, 370, 1, 1),
(38, 'IS221', 'إدارة المشروعات', 'Project Management', 3, 'CS121', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 2, 380, 1, 1),
(39, 'IS231', 'تحليل وتصميم النظم', 'Systems Analysis and Design', 3, 'CS121', 2, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 2, 2, 390, 1, 1),
(40, 'IT251', 'تراسل البيانات', 'Data Communications', 3, 'CS121', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 3, 400, 1, 1),
(41, 'IT271', 'البرمجة العنكبوتية', 'Web Programming', 3, 'CS141, IT251', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 3, 410, 1, 1),
(42, 'MATH201', 'رياضيات ٣', 'Mathematics III', 3, 'MATH102', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 2, 5, 420, 1, 1),
(43, 'MATH202', 'الاحتمالات والاحصاء', 'Probability and Statistics', 3, 'MATH102', 1, 2, NULL, 2, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 2, 5, 430, 1, 1),
(44, 'CS251', 'معالجة الاشارات الرقمية', 'Digital Signal Processing', 3, 'MATH201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 2, 1, 440, 1, 1),
(45, 'HUM231', 'إدارة الأعمال', 'Business Administration', 3, '−', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 2, 5, 450, 1, 1),
(46, 'HUM112', 'كتابة فنية باللغة الإنجليزية', '  Technical English Writing', 3, 'HUM111', 1, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 1, 5, 460, 1, 1),
(47, 'HUM241', 'الحاسبات والأخلاقيات', '  Intellectual Property,Privacy& Computers  Ethics', 3, '−', 2, 2, '2', NULL, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 2, 5, 470, 1, 1),
(48, 'IS322', NULL, 'Operation Research', 3, 'CS201', 1, 2, NULL, 2, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 3, 2, 480, 1, 1),
(49, 'CS302', 'النمذجة والمحاكاه', 'Simulation and Modeling', 3, 'MATH202', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 490, 1, 1),
(50, 'CS311', 'تصميم وتحليل الخوارزميات', 'Algorithm Design and Analysis', 3, 'CS211', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 500, 1, 1),
(51, 'CS321', 'معماريات الحاسب', 'Computer Architecture', 3, 'CS141, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 510, 1, 1),
(52, 'CS322', 'نظم التشغيل', 'Operating Systems', 3, 'CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 520, 1, 1),
(53, 'CS342', 'نظرية الآليات واللغات', 'Automata and Language Theory', 3, 'CS141, CS201', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 530, 1, 1),
(54, 'CS341', 'البرمجة المرئية', 'Visual Programming', 3, 'CS211', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 540, 1, 1),
(55, 'CS351', 'الرسم بالحاسب', 'Computer Graphics', 3, 'IT101, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 550, 1, 1),
(56, 'CS352', 'معاجة الصور', 'Image Processing', 3, 'CS211', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 560, 1, 1),
(57, 'CS353', 'الرسم بالحاسب المتقدم', 'Advanced Computer Graphics', 3, 'CS351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 570, 1, 1),
(58, 'CS361', 'الذكاء الاصطناعي', 'Artificial Intelligence', 3, 'IT101, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 580, 1, 1),
(59, 'CS381', 'تطوير البرمجيات والممارسة المهنية', 'Software Development and Professional Practice', 3, 'CS211, CS391', 1, 2, NULL, 3, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 590, 1, 1),
(60, 'SE301', 'هندسة البرمجيات', 'Software Engineering', 3, 'CS211', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 600, 1, 1),
(61, 'IT351', 'شبكات الحاسب', 'Computer Networks', 3, 'IT251, CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 610, 1, 1),
(62, 'IT381', 'مقدمة في تكنولوجيا الوسائط المتعددة', 'Introduction to Multimedia Technology', 3, 'CS241', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 620, 1, 1),
(63, 'MATH301', 'تحليل عددي', 'Numerical Analysis', 3, 'MATH102', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 5, 630, 1, 1),
(64, 'CS421', 'نظم التشغيل المتقدمة', 'Advanced Operating Systems', 3, 'CS322', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 640, 1, 1),
(65, 'CS431', 'الحسابات المتوازية', 'Parallel Computation', 3, 'CS311,CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 650, 1, 1),
(66, 'CS441', 'بناء المترجمات', 'Compiler Construction', 3, 'CS211, CS342', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 660, 1, 1),
(67, 'CS442', 'تصميم لغات البرمجة', 'Programming\nLanguage Design', 3, 'CS211', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 670, 1, 1),
(68, 'CS451', 'الحركة بالحاسب', 'Computer Animation', 3, 'CS352', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 680, 1, 1),
(69, 'CS452', 'الرؤية بالحاسب', 'Computer Vision', 3, 'CS241, PHYS102', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 690, 1, 1),
(70, 'CS461', 'النظم الذكية', 'Intelligent Systems', 3, 'CS361', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 700, 1, 1),
(71, 'CS462', 'تعلم الآلة', 'Machine Learning', 3, 'CS361', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 710, 1, 1),
(72, 'CS463', 'التعرف بالنماذج', 'Pattern Recognition', 3, 'CS361', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 720, 1, 1),
(73, 'CS471', 'مقدمة أمن الحاسب', 'Introduction to Computer\n Security', 3, 'CS211, IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 730, 1, 1),
(74, 'CS472', 'التشفير', 'Cryptography', 3, 'CS211, IT351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 740, 1, 1),
(75, 'CS481', 'مشروع التخرج ۱', 'Capstone Project I', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 750, 1, 1),
(76, 'CS482', 'مشروع التخرج ۲', 'Capstone Project II', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 760, 1, 1),
(77, 'SE422', 'ضمان جودة البرمجيات واختبارها', 'Software Quality Assurance and Testing', 3, 'SE301', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 770, 1, 1),
(78, 'IS411', 'قواعد البيانات المتقدمة', 'Advanced Database', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 780, 1, 1),
(79, 'IS412', 'قواعد البيانات الموزعة والشيئية', 'Distributed \nand Object Databases', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 790, 1, 1),
(80, 'IS414', 'استخلاص البيانات وذكاء الأعمال', 'Data Mining and Business Intelligence', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 800, 1, 1),
(81, 'IT431', 'الحوسبة اللاسكية والمحمولة', 'Wireless and\n Mobile Computing', 3, 'IT251', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 810, 1, 1),
(82, 'IT432', 'برمجة الشبكات', 'Network Programming', 3, 'IT351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 820, 1, 1),
(83, 'IT481', NULL, 'Virtual Reality', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 830, 1, 1),
(84, 'CS422', 'معمارية الحاسب المتقدمة', 'Advanced Computer Architecture', 3, 'CS321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 840, 1, 1),
(85, 'CS423', 'الأنظمة المدمجة', 'Embedded Systems', 3, 'CS321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 850, 1, 1),
(88, 'IS322', 'بحوث عمليات', 'Operation Research', 3, 'CS201', 1, 2, NULL, 2, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 3, 2, 480, 1, 1),
(93, 'CS302', 'النمذجة والمحاكاه', 'Simulation and Modeling', 3, 'MATH202', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 490, 1, 1),
(94, 'CS321', 'معماريات الحاسب', 'Computer Architecture', 3, 'CS141, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 510, 1, 1),
(95, 'CS341', 'البرمجة المرئية', 'Visual Programming', 3, 'CS211', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 540, 1, 1),
(96, 'CS351', 'الرسم بالحاسب', 'Computer Graphics', 3, 'IT101, CS201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 550, 1, 1),
(102, 'CS381', 'تطوير البرمجيات والممارسة المهنية', 'Software Development and Professional Practice', 3, 'CS211,SE301', 1, 2, NULL, 3, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 590, 1, 1),
(104, 'SE301', 'هندسة البرمجيات', 'Software Engineering', 3, 'CS211', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 600, 1, 1),
(105, 'IS311', 'نظم المعلومات الجغرافية', 'Geographical Information Systems', 3, 'IS201, IS212', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 930, 1, 1),
(106, 'IS321', 'إدارة المشروعات المتقدمة', 'Advanced Project Management', 3, 'IS221', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 940, 1, 1),
(107, 'IS341', 'نظم دعم اتخاذ القرار', 'Decision Support Systems', 3, 'IS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 950, 1, 1),
(108, 'IS342', 'استراتيجية وإدارة واكتساب نظم المعلومات', 'IS Strategy, Management and Acquisition', 3, 'IS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 960, 1, 1),
(109, 'IT351', 'شبكات الحاسب', 'Computer Networks', 3, 'IT251', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 610, 1, 1),
(110, 'IT381', 'مقدمة في تكنولوجيا الوسائط المتعددة', 'Introduction to Multimedia Technology', 3, 'CS241', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 620, 1, 1),
(111, 'MATH301', 'تحليل عددي', 'Numerical Analysis', 3, 'MATH102', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 5, 630, 1, 1),
(112, 'IS411', 'قواعد البيانات المتقدمة', 'Advanced Database', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 780, 1, 1),
(113, 'IS412', 'قواعد البيانات الموزعة والشيئية', 'Distributed and Object Databases', 3, 'IS212', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1020, 1, 1),
(114, 'IS413', 'نظم المعلومات الشبكية', 'Web Information Systems', 3, 'IS201, IT271', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1020, 1, 1),
(126, 'IS414', 'استخلاص البيانات وذكاء الأعمال', 'Data Mining and Business Intelligence', 3, 'IS201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 800, 1, 1),
(127, 'IS415', 'إدارة قواعد البيانات', 'Database Administration', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1040, 1, 1),
(129, 'IS416', 'معالجة المعاملات', 'Transaction Processing', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1050, 1, 1),
(133, 'IS417', 'قواعد بيانات الوسائط المتعددة', 'Multimedia Databases', 3, 'IS212, CS241', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1060, 1, 1),
(137, 'IS441', 'ضمان جودة نظم المعلومات', 'Quality Assurance of Information Systems', 3, 'IS201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1070, 1, 1),
(138, 'IS442', 'تطوير تطبيقات نظم المعلومات', 'IS Application Development', 3, 'IS212, IS413', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1080, 1, 1),
(139, 'IS451', 'نظم المعلومات الاجتماعية', 'Social Information Systems', 3, 'IS413', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1090, 1, 1),
(178, 'IS452', 'مشروع التخرج 1', 'Capstone Project I', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1100, 1, 1),
(179, 'IS453', 'مشروع التخرج 2', 'Capstone Project II', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1110, 1, 1),
(180, 'IT411', 'ضمان المعلومات وحمايتها', 'Information Assurance and Security', 3, 'IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1120, 1, 1),
(182, 'IT441', 'المعمارية التكنولوجية للشركات', 'Enterprise Architecture', 3, 'IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1130, 1, 1),
(183, 'IT471', 'التجارة الإلكترونية', 'E-commerce', 3, 'IT271', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1140, 1, 1),
(184, 'IT482', 'تفاعل الإنسان والحاسب', 'Human Computer Interaction', 3, 'CS341', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1150, 1, 1),
(185, 'IS322', 'بحوث عمليات', 'Operation Research', 3, 'CS201', 1, 2, NULL, 2, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 3, 2, 480, 1, 1),
(186, 'CS302', 'النمذجة والمحاكاه', 'Simulation and Modeling', 3, 'MATH202', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 490, 1, 1),
(187, 'CS321', 'معماريات الحاسب', 'Computer Architecture', 3, 'CS141, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 510, 1, 1),
(188, 'CS322', 'نظم التشغيل', 'Operating Systems', 3, 'CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 520, 1, 1),
(189, 'CS341', 'البرمجة المرئية', 'Visual Programming', 3, 'CS211', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 540, 1, 1),
(190, 'CS351', 'الرسم بالحاسب', 'Computer Graphics', 3, 'CS121, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 550, 1, 1),
(191, 'CS352', 'معاجة الصور', 'Image Processing', 3, 'CS211', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 560, 1, 1),
(192, 'CS381', 'تطوير البرمجيات والممارسة المهنية', 'Software Development and Professional Practice', 3, 'CS211, CE301', 1, 2, NULL, 3, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 590, 1, 1),
(193, 'SE301', 'هندسة البرمجيات', 'Software Engineering', 3, 'IS231', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 600, 1, 1),
(194, 'IS321', 'إدارة المشروعات المتقدمة', 'Advanced Project Management', 3, 'IS221', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 940, 1, 1),
(195, 'IT311', 'أمن الشبكات', 'Network Security', 3, 'IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 1260, 1, 1),
(196, 'IT331', 'إدارة الشبكات', 'Network Management', 3, 'IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 1270, 1, 1),
(200, 'IT351', 'شبكات الحاسب', 'Computer Networks', 3, 'IT251', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 610, 1, 1),
(201, 'IT361', NULL, 'Field Training', 3, 'IS221', 1, 2, NULL, NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 1290, 1, 1),
(202, 'IT381', 'مقدمة في تكنولوجيا الوسائط المتعددة', 'Introduction to Multimedia Technology', 3, 'CS241', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 620, 1, 1),
(203, 'MATH301', 'تحليل عددي', 'Numerical Analysis', 3, 'MATH102', 2, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 5, 630, 1, 1),
(204, 'IT431', 'الحوسبة اللاسكية والمحمولة', 'Wireless and\n Mobile Computing', 3, 'IT251', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 810, 1, 1),
(205, 'IT451', 'تحليل وتصميم الشبكات', 'Network Analysis and Design', 3, 'IT351, MATH202', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1330, 1, 1),
(206, 'IT432', 'برمجة الشبكات', 'Network Programming', 3, 'IT351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 820, 1, 1),
(207, 'IT441', 'المعمارية التكنولوجية للشركات', 'Enterprise Architecture', 3, 'IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1130, 1, 1),
(211, 'IT471', 'التجارة الإلكترونية', 'E-commerce', 3, 'IT271', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1140, 1, 1),
(212, 'IT433', 'الأدلة الشرعية في الشبكات', 'Network Forensics', 3, 'IT351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1370, 1, 1),
(213, 'IT452', 'الأنظمة المدمجة الشبكية', 'Networked Embedded Systems', 3, 'IT351,', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1380, 1, 1),
(214, 'IT461', 'مشروع التخرج ۱', 'Capstone Project I', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1390, 1, 1),
(215, 'IT462', 'مشروع التخرج ۲', 'Capstone Project II', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1400, 1, 1),
(216, 'CS451', 'الحركة بالحاسب', 'Computer Animation', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 680, 1, 1),
(217, 'CS431', 'الحسابات المتوازية', 'Parallel Computation', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 650, 1, 1),
(218, 'CS452', 'الرؤية بالحاسب', 'Computer Vision', 3, 'CS241, PHYS102', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 690, 1, 1),
(219, 'CS461', 'النظم الذكية', 'Intelligent Systems', 3, 'CS361', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 700, 1, 1),
(220, 'IS411', 'قواعد البيانات المتقدمة', 'Advanced Database', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 780, 1, 1),
(221, 'IS412', 'قواعد البيانات الموزعة والشيئية', 'Distributed \nand Object Databases', 3, 'IS212', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 790, 1, 1),
(222, 'IT481', NULL, 'Virtual Reality', 3, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 830, 1, 1),
(223, 'CS422', 'معمارية الحاسب المتقدمة', 'Advanced Computer Architecture', 3, 'CS321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 840, 1, 1),
(224, 'CS423', 'الأنظمة المدمجة', 'Embedded Systems', 3, 'CS321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 850, 1, 1),
(225, 'IS322', 'بحوث عمليات', 'Operation Research', 3, 'CS201', 1, 2, NULL, 2, '15.00', '15.00', '0.00', '10.00', '60.00', 3, 3, 2, 480, 1, 1),
(226, 'CS302', 'النمذجة والمحاكاه', 'Simulation and Modeling', 3, 'MATH202', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 490, 1, 1),
(227, 'CS321', 'معماريات الحاسب', 'Computer Architecture', 3, 'CS141, CS201', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 510, 1, 1),
(228, 'CS322', 'نظم التشغيل', 'Operating Systems', 3, 'CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 520, 1, 1),
(229, 'CS341', 'البرمجة المرئية', 'Visual Programming', 3, 'CS211', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 540, 1, 1),
(234, 'SE301', 'هندسة البرمجيات', 'Software Engineering', 3, 'CS211', 1, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 600, 1, 1),
(235, 'SE331', 'تصمیم ومعماریة البرمجیات', 'Software Design & Architecture', 3, 'SE301', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1560, 1, 1),
(236, 'SE302', 'هندسة تطبيقات الويب', 'Web Applications Engineering', 3, 'SE301, CS141', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1570, 1, 1),
(237, 'CS381', 'تطوير البرمجيات والممارسة المهنية', 'Software Development and Professional Practice', 3, 'CS211', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 1, 590, 1, 1),
(248, 'IT351', 'شبكات الحاسب', 'Computer Networks', 3, 'IT251,CS321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 3, 610, 1, 1),
(249, 'SE332', 'بناء البرمجيات', 'Software Construction', 3, 'SE331', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1600, 1, 1),
(250, 'SE321', 'تحليل متطلبات البرمجيات', 'Software Requirements Analysis', 3, 'SE301', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1610, 1, 1),
(251, 'SE333', 'الطرق الرشيقة  لهندسة البرمجيات', 'Agile Methods', 3, 'SE332', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1620, 1, 1),
(252, 'SE311', 'تطوير البرمجيات مفتوحة المصدر', 'Open Source Software Development', 3, 'SE331', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1630, 1, 1),
(253, 'SE322', 'نظم و برمجيات الوقت الحقيقى', 'Real-Time Software and Systems', 3, 'SE331', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 1640, 1, 1),
(254, 'IS341', 'نظم دعم اتخاذ القرار', 'Decision Support Systems', 3, 'IS201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 2, 950, 1, 1),
(255, 'MATH301', 'تحليل عددي', 'Numerical Analysis', 3, 'MATH102', 2, 2, '2', NULL, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 5, 630, 1, 1),
(260, 'SE422', 'ضمان جودة البرمجيات واختبارها', 'Software Quality Assurance and Testing', 3, 'SE301', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 3, 4, 770, 1, 1),
(261, 'SE412', 'تقدير تكاليف تطوير وصيانة مشاريع البرمجيات', 'Estimating Software Development. & Maintenance Projects', 3, 'SE321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1680, 1, 1),
(262, 'SE411', 'ادرة مشروعات البرمجيات', 'SoftwareProject Management', 3, 'SE422, SE321', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1710, 1, 1),
(267, 'IT482', 'تفاعل الإنسان والحاسب', 'Human Computer Interaction', 3, 'IT271', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1150, 1, 1),
(268, 'SE431', 'تصميم برمجيات الشبكات المتنقلة', 'Mobile Software Design', 3, 'SE331, IT351', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1740, 1, 1),
(272, 'CS423', 'الأنظمة المدمجة', 'Embedded Systems', 3, 'CS321', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 850, 1, 1),
(273, 'SE431', 'مشروع التخرج ۱', 'Capstone Project I', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1770, 1, 1),
(274, 'SE432', 'تصميم برمجيات الشبكات المتنقلة', 'Capstone Project II', 3, 'CS381, IS221', 1, 1, NULL, 4, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1780, 1, 1),
(275, 'SE432', 'مشروع التخرج ۲', 'Embedded Systems Software Design', 3, 'CS423', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1790, 1, 1),
(276, 'CS471', 'مقدمة أمن الحاسب', 'Introduction to Computer\n Security', 3, 'CS211, IT351', 1, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 1, 730, 1, 1),
(277, 'SE433', 'تطوير البرمجيات العالمية', 'Global Software Development', 3, 'IT351, SE331', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 4, 1800, 1, 1),
(278, 'IT431', 'الحوسبة اللاسكية والمحمولة', 'Wireless and\n Mobile Computing', 3, 'IT251', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 810, 1, 1),
(279, 'IT451', 'تحليل وتصميم الشبكات', 'Network Analysis and Design', 3, 'IT351, MATH202', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 3, 1330, 1, 1),
(280, 'IS441', 'ضمان جودة نظم المعلومات', 'Quality Assurance of Information Systems', 3, 'IS201', 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 4, 2, 1070, 1, 1),
(281, 'CS000', 'منقطع عن الدراسة', 'منقطع عن الدراسة', 0, NULL, 2, 2, NULL, 2, '15.00', '10.00', '10.00', '5.00', '60.00', 3, 1, 1, 5000000, 1, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `coursesemestercount`
-- (See below for the actual view)
--
CREATE TABLE `coursesemestercount` (
`StudentID` int(11)
,`StudentEductionalNumber` int(11)
,`StudentName` varchar(255)
,`CountOfCourseID` bigint(21)
,`SemesterID` int(11)
,`SemesterFullName` varchar(255)
,`Semester` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `coursetype`
--

CREATE TABLE `coursetype` (
  `ID` int(11) NOT NULL,
  `CourseType` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coursetype`
--

INSERT INTO `coursetype` (`ID`, `CourseType`) VALUES
(1, 'Required'),
(2, 'Elective');

-- --------------------------------------------------------

--
-- Table structure for table `course_grade`
--

CREATE TABLE `course_grade` (
  `ID` int(11) DEFAULT NULL,
  `Grade_English` varchar(255) DEFAULT NULL,
  `Grade_Arabic` varchar(255) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `Points` float DEFAULT NULL,
  `Percentage` float DEFAULT NULL,
  `CurriculumID` int(11) DEFAULT NULL,
  `semesterID` int(11) DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `course_grade`
--

INSERT INTO `course_grade` (`ID`, `Grade_English`, `Grade_Arabic`, `OrderCode`, `Points`, `Percentage`, `CurriculumID`, `semesterID`, `Notes`) VALUES
(1, 'A+', 'ممتاز', 10, 4, 90, 1, 1, NULL),
(2, 'A', 'ممتاز', 15, 3.7, 85, 1, 1, NULL),
(3, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 1, NULL),
(4, 'B', 'جيد جدا', 25, 3, 75, 1, 1, NULL),
(5, 'C+', 'جيد', 30, 2.7, 70, 1, 1, NULL),
(6, 'C', 'جيد', 35, 2.4, 65, 1, 1, NULL),
(7, 'D+', 'مقبول', 40, 2, 60, 1, 1, NULL),
(8, 'D', 'مقبول', 45, 1.7, 50, 1, 1, NULL),
(9, 'F', 'راسب', 50, 0, 0, 1, 1, NULL),
(10, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 1, NULL),
(11, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 1, NULL),
(12, 'A+', 'ممتاز', 10, 4, 90, 1, 2, NULL),
(13, 'A', 'ممتاز', 15, 3.7, 85, 1, 2, NULL),
(14, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 2, NULL),
(15, 'B', 'جيد جدا', 25, 3, 75, 1, 2, NULL),
(16, 'C+', 'جيد', 30, 2.7, 70, 1, 2, NULL),
(17, 'C', 'جيد', 35, 2.4, 65, 1, 2, NULL),
(18, 'D+', 'مقبول', 40, 2, 60, 1, 2, NULL),
(19, 'D', 'مقبول', 45, 1.7, 50, 1, 2, NULL),
(20, 'F', 'راسب', 50, 0, 0, 1, 2, NULL),
(21, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 2, NULL),
(22, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 2, NULL),
(23, 'ر ل', 'راسب ل', 51, 0, 0, 1, 1, NULL),
(24, 'ر ل', 'راسب ل', 51, 0, 0, 1, 2, NULL),
(25, 'A+', 'ممتاز', 10, 4, 90, 1, 3, NULL),
(26, 'A', 'ممتاز', 15, 3.7, 85, 1, 3, NULL),
(27, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 3, NULL),
(28, 'B', 'جيد جدا', 25, 3, 75, 1, 3, NULL),
(29, 'C+', 'جيد', 30, 2.7, 70, 1, 3, NULL),
(30, 'C', 'جيد', 35, 2.4, 65, 1, 3, NULL),
(31, 'D+', 'مقبول', 40, 2, 60, 1, 3, NULL),
(32, 'D', 'مقبول', 45, 1.7, 50, 1, 3, NULL),
(33, 'F', 'راسب', 50, 0, 0, 1, 3, NULL),
(34, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 3, NULL),
(35, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 3, NULL),
(36, 'ر ل', 'راسب ل', 51, 0, 0, 1, 3, NULL),
(37, 'A+', 'ممتاز', 10, 4, 90, 1, 4, NULL),
(38, 'A', 'ممتاز', 15, 3.7, 85, 1, 4, NULL),
(39, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 4, NULL),
(40, 'B', 'جيد جدا', 25, 3, 75, 1, 4, NULL),
(41, 'C+', 'جيد', 30, 2.7, 70, 1, 4, NULL),
(42, 'C', 'جيد', 35, 2.4, 65, 1, 4, NULL),
(43, 'D+', 'مقبول', 40, 2, 60, 1, 4, NULL),
(44, 'D', 'مقبول', 45, 1.7, 50, 1, 4, NULL),
(45, 'F', 'راسب', 50, 0, 0, 1, 4, NULL),
(46, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 4, NULL),
(47, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 4, NULL),
(48, 'ر ل', 'راسب ل', 51, 0, 0, 1, 4, NULL),
(51, 'غ', 'غ', 52, 0, 0, 1, 4, NULL),
(52, 'غ ب', 'غ بعذر', 53, 0, 0, 1, 4, NULL),
(53, 'A+', 'ممتاز', 10, 4, 90, 1, 5, NULL),
(54, 'A', 'ممتاز', 15, 3.7, 85, 1, 5, NULL),
(55, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 5, NULL),
(56, 'B', 'جيد جدا', 25, 3, 75, 1, 5, NULL),
(57, 'C+', 'جيد', 30, 2.7, 70, 1, 5, NULL),
(58, 'C', 'جيد', 35, 2.4, 65, 1, 5, NULL),
(59, 'D+', 'مقبول', 40, 2, 60, 1, 5, NULL),
(60, 'D', 'مقبول', 45, 1.7, 50, 1, 5, NULL),
(61, 'F', 'راسب', 50, 0, 0, 1, 5, 'Total<50'),
(62, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 5, NULL),
(63, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 5, NULL),
(64, 'ر ل', 'راسب ل', 51, 0, 0, 1, 5, 'Final <24'),
(65, 'غ', 'غ', 52, 0, 0, 1, 5, '-100'),
(66, 'غ ب', 'غ بعذر', 53, 0, 0, 1, 5, '-200'),
(67, 'مقيد', 'مقيد', 54, 0, 0, 1, 5, '-300'),
(68, 'A+', 'ممتاز', 10, 4, 90, 1, 6, NULL),
(69, 'A', 'ممتاز', 15, 3.7, 85, 1, 6, NULL),
(70, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 6, NULL),
(71, 'B', 'جيد جدا', 25, 3, 75, 1, 6, NULL),
(72, 'C+', 'جيد', 30, 2.7, 70, 1, 6, NULL),
(73, 'C', 'جيد', 35, 2.4, 65, 1, 6, NULL),
(74, 'D+', 'مقبول', 40, 2, 60, 1, 6, NULL),
(75, 'D', 'مقبول', 45, 1.7, 50, 1, 6, NULL),
(76, 'F', 'راسب', 50, 0, 0, 1, 6, 'Total<50'),
(77, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 6, NULL),
(78, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 6, NULL),
(79, 'ر ل', 'راسب ل', 51, 0, 0, 1, 6, 'Final <24'),
(80, 'غ', 'غ', 52, 0, 0, 1, 6, '-100'),
(81, 'غ ب', 'غ بعذر', 53, 0, 0, 1, 6, '-200'),
(82, 'مقيد', 'مقيد', 54, 0, 0, 1, 6, '-300'),
(83, 'A+', 'ممتاز', 10, 4, 90, 1, 7, NULL),
(84, 'A', 'ممتاز', 15, 3.7, 85, 1, 7, NULL),
(85, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 7, NULL),
(86, 'B', 'جيد جدا', 25, 3, 75, 1, 7, NULL),
(87, 'C+', 'جيد', 30, 2.7, 70, 1, 7, NULL),
(88, 'C', 'جيد', 35, 2.4, 65, 1, 7, NULL),
(89, 'D+', 'مقبول', 40, 2, 60, 1, 7, NULL),
(90, 'D', 'مقبول', 45, 1.7, 50, 1, 7, NULL),
(91, 'F', 'راسب', 50, 0, 0, 1, 7, 'Total<50'),
(92, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 7, NULL),
(93, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 7, NULL),
(94, 'ر ل', 'راسب ل', 51, 0, 0, 1, 7, 'Final <24'),
(95, 'غ', 'غ', 52, 0, 0, 1, 7, '-100'),
(96, 'غ ب', 'غ بعذر', 53, 0, 0, 1, 7, '-200'),
(97, 'مقيد', 'مقيد', 54, 0, 0, 1, 7, '-300'),
(98, 'A+', 'ممتاز', 10, 4, 90, 1, 7, NULL),
(99, 'A', 'ممتاز', 15, 3.7, 85, 1, 7, NULL),
(100, 'B+', 'جيد جدا', 20, 3.3, 80, 1, 7, NULL),
(101, 'B', 'جيد جدا', 25, 3, 75, 1, 7, NULL),
(102, 'C+', 'جيد', 30, 2.7, 70, 1, 7, NULL),
(103, 'C', 'جيد', 35, 2.4, 65, 1, 7, NULL),
(104, 'D+', 'مقبول', 40, 2, 60, 1, 7, NULL),
(105, 'D', 'مقبول', 45, 1.7, 50, 1, 7, NULL),
(106, 'F', 'راسب', 50, 0, 0, 1, 7, 'Total<50'),
(107, 'DROPPED', 'منسحب', 60, NULL, NULL, 1, 7, NULL),
(108, 'INCOMPLETE', 'غير مكتمل', 100, NULL, NULL, 1, 7, NULL),
(109, 'ر ل', 'راسب ل', 51, 0, 0, 1, 7, 'Final <24'),
(110, 'غ', 'غ', 52, 0, 0, 1, 7, '-100'),
(111, 'غ ب', 'غ بعذر', 53, 0, 0, 1, 7, '-200'),
(112, 'مقيد', 'مقيد', 54, 0, 0, 1, 7, '-300');

-- --------------------------------------------------------

--
-- Stand-in structure for view `course_points`
-- (See below for the actual view)
--
CREATE TABLE `course_points` (
`RegID` int(11)
,`CurriculumID` int(11)
,`StudentCode` int(11)
,`StudentID` int(11)
,`SemesterID` int(11)
,`StudentName` varchar(255)
,`SemesterEnumID` int(11)
,`SemesterStatusID` int(11)
,`Semester` varchar(255)
,`CourseCredits` int(11)
,`CourseArabicName` varchar(255)
,`Prerequisits` varchar(255)
,`CourseCode` varchar(255)
,`CourseMarks` decimal(20,4)
,`Grade_English` varchar(255)
,`Grade_Arabic` varchar(255)
,`Course_Points` varchar(19)
,`Course_cr_points` double(19,2)
,`CourseCredits_Completed` bigint(11)
,`DepartmentID` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `course_points_lvl`
-- (See below for the actual view)
--
CREATE TABLE `course_points_lvl` (
`RegID` int(11)
,`StudentCode` int(11)
,`StudentID` int(11)
,`SemesterID` int(11)
,`StudentName` varchar(255)
,`SemesterEnumID` int(11)
,`CountOfSemester` bigint(21)
,`SemesterStatusID` int(11)
,`Semester` varchar(255)
,`CourseCredits_Completed` bigint(11)
,`DepartmentID` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `course_semester`
--

CREATE TABLE `course_semester` (
  `ID` int(11) NOT NULL,
  `SemesterID` int(11) DEFAULT NULL,
  `CourseID` int(11) DEFAULT NULL,
  `DoctorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `course_semester`
--

INSERT INTO `course_semester` (`ID`, `SemesterID`, `CourseID`, `DoctorID`) VALUES
(1, 1, 12, 2),
(4, 1, 13, 7),
(6, 1, 24, 5),
(7, 1, 17, 8),
(8, 1, 15, 9),
(9, 1, 19, 10),
(16, 2, 32, 5),
(18, 2, 26, 12),
(19, 2, 29, 11),
(20, 2, 11, 3),
(21, 2, 14, 13),
(22, 2, 46, 15),
(23, 3, 14, 13),
(25, 3, 17, 16),
(26, 3, 11, 3),
(27, 4, 12, 3),
(28, 4, 24, 5),
(29, 4, 34, 14),
(32, 4, 40, 12),
(38, 4, 35, 11),
(39, 4, 39, 11),
(41, 4, 13, 20),
(42, 4, 15, 16),
(43, 4, 17, 17),
(44, 4, 42, 18),
(45, 4, 19, 15),
(46, 4, 45, 19),
(47, 4, 14, 21),
(48, 5, 11, 1),
(49, 5, 14, 22),
(50, 5, 23, 5),
(51, 5, 29, 4),
(52, 5, 32, 5),
(53, 5, 46, 15),
(54, 5, 33, 14),
(55, 5, 37, 4),
(56, 5, 38, 19),
(57, 5, 41, 12),
(58, 5, 43, 20),
(59, 5, 44, 23),
(60, 5, 13, 24),
(61, 5, 19, 15),
(62, 5, 42, 18),
(64, 5, 12, 12),
(72, 6, 33, 14),
(73, 6, 37, 4),
(74, 6, 38, 19),
(75, 6, 43, 24),
(76, 7, NULL, NULL),
(78, 7, 12, 3),
(79, 7, 13, 7),
(80, 7, 15, 16),
(81, 7, 17, 17),
(82, 7, 19, 15),
(83, 7, 24, 25),
(84, 7, 14, 26),
(85, 7, 39, 11),
(86, 7, 34, 1),
(87, 7, 35, 11),
(88, 7, 40, 12),
(89, 7, 42, 18),
(90, 7, 45, 19),
(91, 7, 60, 14),
(92, 7, 58, 4),
(93, 7, 51, 3),
(94, 7, 56, 14),
(95, 7, 59, 5),
(96, 7, 61, 12),
(97, 7, 33, 14),
(98, 5, 281, 8),
(99, 7, 281, 9),
(100, 4, 281, 9),
(101, 8, 11, 1),
(102, 8, 14, 13),
(103, 8, 32, 15),
(104, 8, 46, 15),
(105, 8, 29, 4),
(106, 8, 23, 27),
(107, 8, 33, 30),
(108, 8, 37, 11),
(109, 8, 38, 19),
(110, 8, 41, 12),
(111, 8, 43, 24),
(112, 8, 44, 29),
(113, 8, 52, 3),
(114, 8, 53, 5),
(115, 8, 80, 11),
(116, 8, 88, 20),
(117, 8, 50, 4),
(120, 8, 63, 28),
(121, 8, 195, 29),
(122, 8, 196, 12),
(123, 8, 62, 34),
(124, 8, 42, 32),
(125, 8, 45, 19),
(126, 8, 12, 14);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum`
--

CREATE TABLE `curriculum` (
  `ID` int(11) NOT NULL,
  `CurriculumEngName` varchar(255) DEFAULT NULL,
  `CurriculumArabicName` varchar(255) DEFAULT NULL,
  `DepartmentID` int(11) DEFAULT NULL,
  `statusID` int(11) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `FacultyID` int(11) DEFAULT NULL,
  `Limit_Fail_Final` decimal(18,4) DEFAULT NULL,
  `Limit_Fail_Total` decimal(18,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `curriculum`
--

INSERT INTO `curriculum` (`ID`, `CurriculumEngName`, `CurriculumArabicName`, `DepartmentID`, `statusID`, `OrderCode`, `FacultyID`, `Limit_Fail_Final`, `Limit_Fail_Total`) VALUES
(1, 'FCI_2016', 'كلية الحاسبات و المعلومات 2016', 1, 1, 20, 1, '0.4000', '0.5000'),
(6, 'FC_CS_2014_new', 'كلية علوم علوم الحاسب جديد', NULL, 1, 110, 3, '0.5000', '0.6000'),
(7, 'Mass_communication_2017', 'كلية اعلام 2017', NULL, 1, 30, 4, '0.5000', '0.6000'),
(8, 'Petrolum_MinningEngineering_2010', 'كلية هندسة البترول و التعدين', NULL, 1, 50, 2, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `ID` int(11) NOT NULL,
  `Departmenttxt` varchar(255) DEFAULT NULL,
  `DeptartmentCode` varchar(255) DEFAULT NULL,
  `FacultyID` int(11) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `CurriculumID` mediumtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`ID`, `Departmenttxt`, `DeptartmentCode`, `FacultyID`, `OrderCode`, `CurriculumID`) VALUES
(1, 'علوم الحاسب', 'CS', 1, 2, '1'),
(2, 'نظم المعلومات', 'IS', 1, 4, '1'),
(3, 'تكنولوجيا المعلومات', 'IT', 1, 3, '1'),
(4, 'هندسة البرمجيات', 'SE', 1, 5, '1'),
(5, 'الحاسبات_عام', 'GE', 1, 1, '1'),
(6, 'كلية علوم علوم الحاسب', 'FC_CS', 3, 7, '6'),
(7, 'اعلام_عام', 'GE_Macc_communication', 4, 10, '7'),
(8, 'هندسة إستكشاف وإنتاج البترول', NULL, 2, 50, '8');

-- --------------------------------------------------------

--
-- Table structure for table `doctor`
--

CREATE TABLE `doctor` (
  `ID` int(11) NOT NULL,
  `NameTxt` varchar(255) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `Arabic_doctorName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`ID`, `NameTxt`, `StatusID`, `OrderCode`, `Arabic_doctorName`) VALUES
(1, 'Dr.Yasser Fouaad Ramadan', 1, 1, 'د/ياسر فؤاد رمضان'),
(2, 'Dr. Mohamed Abd Raboo Ahmed', 1, NULL, 'د/محمد عبدربه احمد'),
(3, 'Dr. Mohamed  Ali Atia', 1, 2, 'د/محمد علي عطيه'),
(4, 'Dr.Wael Mohammed Fawaz', 1, 3, 'د/وائل محمد فواز'),
(5, 'Dr.Hussein Mohammed Sharaf', 1, 4, 'د/حسين محمد شرف'),
(7, 'Dr. Mohamed Ramadan', 1, NULL, 'د/محمد رمضان'),
(8, 'Dr. Doaa Elrefaey', 1, NULL, 'د/دعاء الرفاعى'),
(9, 'Dr. Yasser Amoun', 1, NULL, 'د/ياسر امون'),
(10, 'Dr. Shaker Elsayed  Rizk', 1, NULL, 'د/شاكر السيد رزق'),
(11, 'Dr. Samah Ahmed Zaki', 1, 6, 'د/سماح احمد ذكى'),
(12, 'Dr. Fayza Ahmed Elsayed', 1, 5, 'د/فايزه احمد السيد'),
(13, 'Dr.Taha Hussein Elghareeb', 1, NULL, 'د/طه حسين الغريب'),
(14, 'Dr.Haitham Farook Abd Elfattah', 1, 7, 'د/هيثم فاروق عبدالفتاح'),
(15, 'Dr.Dalia Said EL-Kalla', 1, NULL, 'د/داليا سعيد القلا'),
(16, 'Dr. Hesham Yousef', 1, NULL, 'د/هشام يوسف'),
(17, 'Dr.Ehab El Falky', 0, 0, 'د/ايهاب الفلكى'),
(18, 'Dr.Mohammed saleh Metwaly', 0, 0, 'د/محمد صالح متولي'),
(19, 'Dr.Rania Abd Elmenim Shamaa', 0, 0, 'د/رانية عبدالمنعم شمعه'),
(20, 'Dr.Yasser Mahmoud Aid', 0, 0, 'د/ياسر محمود عايد'),
(21, 'Dr. Mohamed Ismail Bsher', 1, 0, 'د/محمد اسماعيل بشير'),
(22, 'Dr.khaled Abd Elkader', 1, 0, 'د/خالد عبدالقادر'),
(23, 'HAMED ANWAR EBRAHEM', 0, 0, 'د/حامد انور ابراهيم'),
(24, 'Mohamed El Shahat', 0, 0, 'د/محمد الشحات'),
(25, 'Reda EL Sawe', 0, 0, 'د/ رضا الصاوى'),
(26, 'Khlid Abd Elkader', 0, 0, 'د/ خالد عبد القادر'),
(27, 'Dr.Hasan Abd Elsalam', 1, 0, 'د/ حسن عبد السلام'),
(28, 'Dr.Mohamed Nageb', 1, 0, 'د/ محمد نجيب'),
(29, 'Dr.Mohamed Saied', 1, 0, 'د/ محمد سعيد'),
(30, 'Dr.Maher Wasfee', NULL, NULL, 'د/ ماهر وصفى'),
(32, 'Dr. Karema EL Orabee', 0, 0, 'د/ كريمة العرابى'),
(34, 'Dr. Ahmed Mohamed Moneir', 0, 0, 'د أحمد محمد منير/');

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `ID` int(11) NOT NULL,
  `FacultyName_Arabic` varchar(255) DEFAULT NULL,
  `FacultyDescription` mediumtext,
  `OrderCode` int(11) DEFAULT NULL,
  `FacultyName_English` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`ID`, `FacultyName_Arabic`, `FacultyDescription`, `OrderCode`, `FacultyName_English`) VALUES
(1, 'كلية الحاسبات و المعلومات', 'Computers and Information', 10, 'Computers and Information'),
(2, 'كلية هندسة البترول و التعدين', 'Petrolum and Minning Engineering', 20, 'Petrolum and Minning Engineering'),
(3, 'كلية علوم', 'Faculty of science', 30, 'Faculty of science'),
(4, 'كلية اعلام', 'Mass communication', 15, 'Faculty of Mass communication');

-- --------------------------------------------------------

--
-- Table structure for table `gender`
--

CREATE TABLE `gender` (
  `ID` int(11) DEFAULT NULL,
  `GenderTxt` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gender`
--

INSERT INTO `gender` (`ID`, `GenderTxt`) VALUES
(1, 'انثى'),
(2, 'ذكر');

-- --------------------------------------------------------

--
-- Table structure for table `gpa_grade`
--

CREATE TABLE `gpa_grade` (
  `ID` int(11) DEFAULT NULL,
  `Grade_English` varchar(255) DEFAULT NULL,
  `Grade_Arabic` varchar(255) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `Points` float DEFAULT NULL,
  `semesterID` int(11) DEFAULT NULL,
  `Course_Points` double DEFAULT NULL,
  `Course_cr_points` double DEFAULT NULL,
  `CurriculumID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `gpa_grade`
--

INSERT INTO `gpa_grade` (`ID`, `Grade_English`, `Grade_Arabic`, `OrderCode`, `Points`, `semesterID`, `Course_Points`, `Course_cr_points`, `CurriculumID`) VALUES
(1, 'A+', 'ممتاز', 10, 4, 1, NULL, NULL, NULL),
(2, 'A', 'ممتاز', 15, 3.7, 1, NULL, NULL, NULL),
(3, 'B+', 'جيد جدا', 20, 3.3, 1, NULL, NULL, NULL),
(4, 'B', 'جيد جدا', 25, 3, 1, NULL, NULL, NULL),
(5, 'C+', 'جيد', 30, 2.7, 1, NULL, NULL, NULL),
(6, 'C', 'جيد', 35, 2.3, 1, NULL, NULL, NULL),
(7, 'D+', 'مقبول', 40, 2, 1, NULL, NULL, NULL),
(8, 'D', 'مقبول', 45, 1.7, 1, NULL, NULL, NULL),
(9, 'F', 'ضعيف', 50, 0, 1, NULL, NULL, NULL),
(10, 'DROPPED', 'منسحب', 60, NULL, 1, NULL, NULL, NULL),
(11, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 1, NULL, NULL, NULL),
(12, 'A+', 'ممتاز', 10, 4, 2, NULL, NULL, NULL),
(13, 'A', 'ممتاز', 15, 3.7, 2, NULL, NULL, NULL),
(14, 'B+', 'جيد جدا', 20, 3.3, 2, NULL, NULL, NULL),
(15, 'B', 'جيد جدا', 25, 3, 2, NULL, NULL, NULL),
(16, 'C+', 'جيد', 30, 2.7, 2, NULL, NULL, NULL),
(17, 'C', 'جيد', 35, 2.3, 2, NULL, NULL, NULL),
(18, 'D+', 'مقبول', 40, 2, 2, NULL, NULL, NULL),
(19, 'D', 'مقبول', 45, 1.7, 2, NULL, NULL, NULL),
(20, 'F', 'ضعيف', 50, 0, 2, NULL, NULL, NULL),
(21, 'DROPPED', 'منسحب', 60, NULL, 2, NULL, NULL, NULL),
(22, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 2, NULL, NULL, NULL),
(23, 'A+', 'ممتاز', 10, 4, 3, NULL, NULL, NULL),
(24, 'A', 'ممتاز', 15, 3.7, 3, NULL, NULL, NULL),
(25, 'B+', 'جيد جدا', 20, 3.3, 3, NULL, NULL, NULL),
(26, 'B', 'جيد جدا', 25, 3, 3, NULL, NULL, NULL),
(27, 'C+', 'جيد', 30, 2.7, 3, NULL, NULL, NULL),
(28, 'C', 'جيد', 35, 2.3, 3, NULL, NULL, NULL),
(29, 'D+', 'مقبول', 40, 2, 3, NULL, NULL, NULL),
(30, 'D', 'مقبول', 45, 1.7, 3, NULL, NULL, NULL),
(31, 'F', 'ضعيف', 50, 0, 3, NULL, NULL, NULL),
(32, 'DROPPED', 'منسحب', 60, NULL, 3, NULL, NULL, NULL),
(33, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 3, NULL, NULL, NULL),
(34, 'A+', 'ممتاز', 10, 4, 4, NULL, NULL, NULL),
(35, 'A', 'ممتاز', 15, 3.7, 4, NULL, NULL, NULL),
(36, 'B+', 'جيد جدا', 20, 3.3, 4, NULL, NULL, NULL),
(37, 'B', 'جيد جدا', 25, 3, 4, NULL, NULL, NULL),
(38, 'C+', 'جيد', 30, 2.7, 4, NULL, NULL, NULL),
(39, 'C', 'جيد', 35, 2.3, 4, NULL, NULL, NULL),
(40, 'D+', 'مقبول', 40, 2, 4, NULL, NULL, NULL),
(41, 'D', 'مقبول', 45, 1.7, 4, NULL, NULL, NULL),
(42, 'F', 'ضعيف', 50, 0, 4, NULL, NULL, NULL),
(43, 'DROPPED', 'منسحب', 60, NULL, 4, NULL, NULL, NULL),
(44, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 4, NULL, NULL, NULL),
(45, 'A+', 'ممتاز', 10, 4, 5, NULL, NULL, NULL),
(46, 'A', 'ممتاز', 15, 3.7, 5, NULL, NULL, NULL),
(47, 'B+', 'جيد جدا', 20, 3.3, 5, NULL, NULL, NULL),
(48, 'B', 'جيد جدا', 25, 3, 5, NULL, NULL, NULL),
(49, 'C+', 'جيد', 30, 2.7, 5, NULL, NULL, NULL),
(50, 'C', 'جيد', 35, 2.3, 5, NULL, NULL, NULL),
(51, 'D+', 'مقبول', 40, 2, 5, NULL, NULL, NULL),
(52, 'D', 'مقبول', 45, 1.7, 5, NULL, NULL, NULL),
(53, 'F', 'ضعيف', 50, 0, 5, NULL, NULL, NULL),
(54, 'DROPPED', 'منسحب', 60, NULL, 5, NULL, NULL, NULL),
(55, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 5, NULL, NULL, NULL),
(56, 'A+', 'ممتاز', 10, 4, 6, 0, 0, NULL),
(57, 'A', 'ممتاز', 15, 3.7, 6, 0, 0, NULL),
(58, 'B+', 'جيد جدا', 20, 3.3, 6, 0, 0, NULL),
(59, 'B', 'جيد جدا', 25, 3, 6, 0, 0, NULL),
(60, 'C+', 'جيد', 30, 2.7, 6, 0, 0, NULL),
(61, 'C', 'جيد', 35, 2.3, 6, 0, 0, NULL),
(62, 'D+', 'مقبول', 40, 2, 6, 0, 0, NULL),
(63, 'D', 'مقبول', 45, 1.7, 6, 0, 0, NULL),
(64, 'F', 'ضعيف', 50, 0, 6, 0, 0, NULL),
(65, 'DROPPED', 'منسحب', 60, NULL, 6, 0, 0, NULL),
(66, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 6, 0, 0, NULL),
(67, 'A+', 'ممتاز', 10, 4, 7, 0, 0, NULL),
(68, 'A', 'ممتاز', 15, 3.7, 7, 0, 0, NULL),
(69, 'B+', 'جيد جدا', 20, 3.3, 7, 0, 0, NULL),
(70, 'B', 'جيد جدا', 25, 3, 7, 0, 0, NULL),
(71, 'C+', 'جيد', 30, 2.7, 7, 0, 0, NULL),
(72, 'C', 'جيد', 35, 2.3, 7, 0, 0, NULL),
(73, 'D+', 'مقبول', 40, 2, 7, 0, 0, NULL),
(74, 'D', 'مقبول', 45, 1.7, 7, 0, 0, NULL),
(75, 'F', 'ضعيف', 50, 0, 7, 0, 0, NULL),
(76, 'DROPPED', 'منسحب', 60, NULL, 7, 0, 0, NULL),
(77, 'INCOMPLETE', 'غير مكتمل', 100, NULL, 7, 0, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `level`
--

CREATE TABLE `level` (
  `ID` int(11) NOT NULL,
  `LevelTxt` varchar(255) DEFAULT NULL,
  `LevelNumber` int(11) DEFAULT NULL,
  `LevelCreditHours` int(11) DEFAULT NULL,
  `LevelTxt_Arabic` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `level`
--

INSERT INTO `level` (`ID`, `LevelTxt`, `LevelNumber`, `LevelCreditHours`, `LevelTxt_Arabic`) VALUES
(1, 'First', 1, 36, 'الاولى'),
(2, 'Second', 2, 72, 'الثانية'),
(3, 'Third', 3, 108, 'الثالثة'),
(4, 'Fourth', 4, 200, 'خريج');

-- --------------------------------------------------------

--
-- Table structure for table `military`
--

CREATE TABLE `military` (
  `ID` int(11) NOT NULL,
  `Status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `military`
--

INSERT INTO `military` (`ID`, `Status`) VALUES
(1, '-------------------'),
(2, 'مؤجل لسن 28'),
(3, 'دون السن المطلوب للتجنيد');

-- --------------------------------------------------------

--
-- Table structure for table `militaryeducation`
--

CREATE TABLE `militaryeducation` (
  `Id` int(11) DEFAULT NULL,
  `MilitaryEducation` varchar(255) DEFAULT NULL,
  `Order` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `militaryeducation`
--

INSERT INTO `militaryeducation` (`Id`, `MilitaryEducation`, `Order`) VALUES
(1, 'غير مطلوب', 10),
(2, 'لم يؤدى', 20),
(3, 'راسب', 40),
(4, 'ناجح', 30);

-- --------------------------------------------------------

--
-- Table structure for table `nationality`
--

CREATE TABLE `nationality` (
  `ID` int(11) NOT NULL,
  `NationalityTxt` varchar(255) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nationality`
--

INSERT INTO `nationality` (`ID`, `NationalityTxt`, `OrderCode`) VALUES
(1, 'مصرى', NULL),
(2, 'سورى', NULL),
(3, 'فلسطينى', NULL),
(4, 'عراقى', NULL),
(5, 'يمنى', NULL),
(6, 'سودانى', NULL),
(7, 'غانا', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `programsettings`
--

CREATE TABLE `programsettings` (
  `VersionDate` varchar(255) DEFAULT NULL,
  `VersionNo` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `programsettings`
--

INSERT INTO `programsettings` (`VersionDate`, `VersionNo`) VALUES
('16-Oct-2018', 1.5);

-- --------------------------------------------------------

--
-- Table structure for table `recyclebin`
--

CREATE TABLE `recyclebin` (
  `ID` int(11) DEFAULT NULL,
  `RecycleBinTxt` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `recyclebin`
--

INSERT INTO `recyclebin` (`ID`, `RecycleBinTxt`) VALUES
(1, 'محذوف');

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `ID` int(11) NOT NULL,
  `Course_semesterID` int(11) DEFAULT NULL,
  `StudentID` int(11) DEFAULT NULL,
  `YearWork` decimal(18,4) DEFAULT NULL,
  `Practical` decimal(18,4) DEFAULT NULL,
  `MidTermExam` decimal(18,4) DEFAULT NULL,
  `FinalExam` decimal(18,4) DEFAULT NULL,
  `statusID` int(11) DEFAULT NULL,
  `AdvisorApprovalID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `registration`
--

INSERT INTO `registration` (`ID`, `Course_semesterID`, `StudentID`, `YearWork`, `Practical`, `MidTermExam`, `FinalExam`, `statusID`, `AdvisorApprovalID`) VALUES
(1, 1, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2, 1, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(3, 1, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(4, 1, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(5, 1, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(6, 1, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(7, 1, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(8, 1, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(9, 1, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(10, 1, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(11, 1, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(12, 1, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(13, 1, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(14, 1, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(15, 1, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(16, 1, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(17, 1, 22, '15.0000', '0.0000', '2.0000', '7.0000', 2, 1),
(18, 1, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(19, 1, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(20, 1, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(21, 1, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(22, 1, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(23, 1, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(24, 1, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(25, 1, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(26, 1, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(27, 1, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(28, 1, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(29, 1, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(30, 1, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(31, 1, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(32, 1, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(33, 1, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(34, 1, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(35, 1, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(36, 1, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(37, 1, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(38, 1, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(39, 1, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(40, 1, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(41, 1, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(42, 1, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(43, 1, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(44, 1, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(45, 1, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(46, 1, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(47, 1, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(49, 1, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(50, 1, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(51, 1, 56, '17.0000', '0.0000', '4.0000', '22.0000', 2, 1),
(52, 4, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(53, 4, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(54, 4, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(55, 4, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(56, 4, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(57, 4, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(58, 4, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(59, 4, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(60, 4, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(61, 4, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(62, 4, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(63, 4, 15, '18.0000', '0.0000', '6.0000', '17.0000', 2, 1),
(64, 4, 16, '10.0000', '0.0000', '3.0000', '16.0000', 2, 1),
(65, 4, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(66, 4, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(67, 4, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(68, 4, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(69, 4, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(70, 4, 22, '15.0000', '0.0000', '2.0000', '7.0000', 2, 1),
(71, 4, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(72, 4, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(73, 4, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(74, 4, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(75, 4, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(76, 4, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(77, 4, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(78, 4, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(79, 4, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(80, 4, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(81, 4, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(82, 4, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(83, 4, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(84, 4, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(85, 4, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(86, 4, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(87, 4, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(88, 4, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(89, 4, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(90, 4, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(91, 4, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(92, 4, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(93, 4, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(94, 4, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(95, 4, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(96, 4, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(97, 4, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(98, 4, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(100, 4, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(101, 4, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(102, 4, 56, '17.0000', '0.0000', '4.0000', '22.0000', 2, 1),
(154, 6, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(155, 6, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(156, 6, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(157, 6, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(158, 6, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(159, 6, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(160, 6, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(161, 6, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(162, 6, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(163, 6, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(164, 6, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(165, 6, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(166, 6, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(167, 6, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(168, 6, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(169, 6, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(170, 6, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(171, 6, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(172, 6, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(173, 6, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(174, 6, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(175, 6, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(176, 6, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(177, 6, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(178, 6, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(179, 6, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(180, 6, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(181, 6, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(182, 6, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(183, 6, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(184, 6, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(185, 6, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(186, 6, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(187, 6, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(188, 6, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(189, 6, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(190, 6, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(191, 6, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(192, 6, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(193, 6, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(194, 6, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(195, 6, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(196, 6, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(197, 6, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(198, 6, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(199, 6, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(200, 6, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(202, 6, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(203, 6, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(204, 6, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(205, 7, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(206, 7, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(207, 7, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(208, 7, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(209, 7, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(210, 7, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(211, 7, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(212, 7, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(213, 7, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(214, 7, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(215, 7, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(216, 7, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(217, 7, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(218, 7, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(219, 7, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(220, 7, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(221, 7, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(222, 7, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(223, 7, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(224, 7, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(225, 7, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(226, 7, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(227, 7, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(228, 7, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(229, 7, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(230, 7, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(231, 7, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(232, 7, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(233, 7, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(234, 7, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(235, 7, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(236, 7, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(237, 7, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(238, 7, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(239, 7, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(240, 7, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(241, 7, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(242, 7, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(243, 7, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(244, 7, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(245, 7, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(246, 7, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(247, 7, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(248, 7, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(249, 7, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(250, 7, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(251, 7, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(253, 7, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(254, 7, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(255, 7, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(256, 8, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(257, 8, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(258, 8, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(259, 8, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(260, 8, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(261, 8, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(262, 8, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(263, 8, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(264, 8, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(265, 8, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(266, 8, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(267, 8, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(268, 8, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(269, 8, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(270, 8, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(271, 8, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(272, 8, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(273, 8, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(274, 8, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(275, 8, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(276, 8, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(277, 8, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(278, 8, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(279, 8, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(280, 8, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(281, 8, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(282, 8, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(283, 8, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(284, 8, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(285, 8, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(286, 8, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(287, 8, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(288, 8, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(289, 8, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(290, 8, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(291, 8, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(292, 8, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(293, 8, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(294, 8, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(295, 8, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(296, 8, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(297, 8, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(298, 8, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(299, 8, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(300, 8, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(301, 8, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(302, 8, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(304, 8, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(305, 8, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(306, 8, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(307, 9, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(308, 9, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(309, 9, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(310, 9, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(311, 9, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(312, 9, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(313, 9, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(314, 9, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(315, 9, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(316, 9, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(317, 9, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(318, 9, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(319, 9, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(320, 9, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(321, 9, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(322, 9, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(323, 9, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(324, 9, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(325, 9, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(326, 9, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(327, 9, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(328, 9, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(329, 9, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(330, 9, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(331, 9, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(332, 9, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(333, 9, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(334, 9, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(335, 9, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(336, 9, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(337, 9, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(338, 9, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(339, 9, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(340, 9, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(341, 9, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(342, 9, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(343, 9, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(344, 9, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(345, 9, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(346, 9, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(347, 9, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(348, 9, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(349, 9, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(350, 9, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(351, 9, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(352, 9, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(353, 9, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(355, 9, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(356, 9, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(357, 9, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(358, 1, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(359, 4, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(360, 6, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(361, 7, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(362, 8, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(363, 9, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(364, 16, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(365, 16, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(366, 16, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(367, 16, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(368, 16, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(369, 16, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(370, 16, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(371, 16, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(372, 16, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(373, 16, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(374, 16, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(375, 16, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(376, 16, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(377, 16, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(378, 16, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(379, 16, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(380, 16, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(381, 16, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(382, 16, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(383, 16, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(384, 16, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(385, 16, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(386, 16, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(387, 16, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(388, 16, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(389, 16, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(390, 16, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(391, 16, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(393, 16, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(394, 16, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(395, 16, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(396, 16, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(397, 16, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(398, 16, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(399, 16, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(400, 16, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(402, 16, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(403, 16, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(404, 16, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(405, 16, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(406, 16, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(407, 16, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(408, 16, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(409, 16, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(410, 16, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(411, 16, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(412, 16, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(413, 16, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(415, 16, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(416, 18, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(417, 18, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(418, 18, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(419, 18, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(420, 18, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(421, 18, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(422, 18, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(423, 18, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(424, 18, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(425, 18, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(426, 18, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(427, 18, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(428, 18, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(429, 18, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(430, 18, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(431, 18, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(432, 18, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(433, 18, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(434, 18, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(435, 18, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(436, 18, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(437, 18, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(438, 18, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(439, 18, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(440, 18, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(441, 18, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(442, 18, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(443, 18, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(444, 18, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(445, 18, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(446, 18, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(447, 18, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(448, 18, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(449, 18, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(450, 18, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(451, 18, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(452, 18, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(453, 18, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(454, 18, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(455, 18, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(456, 18, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(457, 18, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(458, 18, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(459, 18, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(460, 18, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(461, 18, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(462, 18, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(463, 18, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(464, 18, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(465, 19, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(466, 19, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(467, 19, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(468, 19, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(469, 19, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(470, 19, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(471, 19, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(472, 19, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(473, 19, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(474, 19, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(475, 19, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(476, 19, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(477, 19, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(478, 19, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(479, 19, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(480, 19, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(481, 19, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(482, 19, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(483, 19, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(484, 19, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(485, 19, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(486, 19, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(487, 19, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(488, 19, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(489, 19, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(490, 19, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(491, 19, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(492, 19, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(493, 19, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(494, 19, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(495, 19, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(496, 19, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(497, 19, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(498, 19, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(499, 19, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(500, 19, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(501, 19, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(502, 19, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(503, 19, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(504, 19, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(505, 19, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(506, 19, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(507, 19, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(508, 19, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(509, 19, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(510, 19, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(511, 19, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(512, 19, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(513, 19, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(514, 20, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(515, 20, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(516, 20, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(517, 20, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(518, 20, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(520, 20, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(521, 20, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(522, 20, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(523, 20, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(524, 20, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(525, 20, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(527, 20, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(528, 20, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(529, 20, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(530, 20, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(531, 20, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(533, 20, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(534, 20, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(535, 20, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(536, 20, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(537, 20, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(538, 20, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(539, 20, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(540, 20, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(541, 20, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(542, 20, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(543, 20, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(544, 20, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(545, 20, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(546, 20, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(547, 20, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(548, 20, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(549, 20, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(550, 20, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(551, 20, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(552, 20, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(553, 20, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(554, 20, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(555, 20, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(556, 20, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(557, 20, 49, '20.0000', '0.0000', '6.0000', '25.0000', 2, 1),
(558, 20, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(559, 20, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(560, 20, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(562, 20, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(563, 21, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(564, 21, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(565, 21, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(566, 21, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(567, 21, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(568, 21, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(569, 21, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(570, 21, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(571, 21, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(572, 21, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(573, 21, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(576, 21, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(577, 21, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(578, 21, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(579, 21, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(580, 21, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(582, 21, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(583, 21, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(584, 21, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(585, 21, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(586, 21, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(587, 21, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(588, 21, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(589, 21, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(590, 21, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(591, 21, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(592, 21, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(593, 21, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(594, 21, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(595, 21, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(596, 21, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(597, 21, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(598, 21, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(599, 21, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(600, 21, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(601, 21, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(602, 21, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(603, 21, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(604, 21, 47, '23.0000', '0.0000', '6.0000', '27.0000', 2, 1),
(605, 21, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(606, 21, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(607, 21, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(611, 21, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(612, 22, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(613, 22, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(614, 22, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(615, 22, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(616, 22, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(617, 22, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(618, 22, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(619, 22, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(620, 22, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(621, 22, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(622, 22, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(623, 22, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(624, 22, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(625, 22, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(626, 22, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(627, 22, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(628, 22, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(629, 22, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(630, 22, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(631, 22, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(632, 22, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(633, 22, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(634, 22, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(635, 22, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(636, 22, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(637, 22, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(638, 22, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(639, 22, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(640, 22, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(641, 22, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(642, 22, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(643, 22, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(644, 22, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(645, 22, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(646, 22, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(647, 22, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(648, 22, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(649, 22, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(650, 22, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(651, 22, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(652, 22, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(653, 22, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(654, 22, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(655, 22, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(656, 22, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(657, 22, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(658, 22, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(659, 22, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(660, 22, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(661, 18, 32, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(662, 18, 41, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(663, 23, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(665, 23, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(666, 23, 30, '19.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(667, 23, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(668, 26, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(669, 23, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(670, 23, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(671, 23, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(672, 23, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(673, 23, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(674, 25, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(675, 25, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(676, 39, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(677, 29, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(678, 38, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(679, 32, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(680, 44, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(681, 46, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(682, 39, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(683, 29, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(684, 38, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(685, 32, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(686, 44, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(687, 46, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(688, 39, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(689, 29, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(690, 38, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(691, 32, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(692, 44, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(693, 46, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(694, 41, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(695, 43, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(700, 39, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(701, 29, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(702, 38, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(703, 32, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(704, 44, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(705, 46, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(706, 38, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(707, 39, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(708, 29, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(709, 32, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(710, 44, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(711, 46, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(712, 39, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(713, 29, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(714, 38, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(715, 32, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(716, 44, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(717, 46, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(718, 39, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(719, 29, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(720, 38, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(721, 32, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(722, 44, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(723, 46, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(724, 29, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(725, 32, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(726, 38, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(727, 44, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(728, 39, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(729, 46, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(730, 29, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(731, 32, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(732, 38, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(733, 39, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(734, 44, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(735, 46, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(736, 41, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(753, 29, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(754, 32, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(755, 38, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(756, 39, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(757, 44, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(758, 46, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(759, 29, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(760, 32, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(761, 38, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(762, 39, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(763, 44, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(764, 46, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(765, 29, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(766, 32, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(767, 38, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(768, 39, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(769, 44, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(770, 46, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(771, 29, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(772, 32, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(773, 38, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(774, 39, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(775, 44, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(776, 46, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(777, 29, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(778, 32, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(779, 38, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(780, 39, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(781, 44, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(782, 46, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(783, 29, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(784, 32, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(785, 38, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(786, 39, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(787, 44, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(788, 46, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(789, 29, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(790, 32, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(791, 38, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(792, 39, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(793, 44, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(794, 27, 62, '23.0000', '0.0000', '10.0000', '35.0000', 1, 1),
(795, 28, 62, '24.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(796, 41, 62, '17.0000', '0.0000', '12.0000', '24.0000', 1, 1),
(797, 42, 62, '18.0000', '0.0000', '12.0000', '33.0000', 1, 1),
(798, 43, 62, '20.0000', '0.0000', '14.0000', '38.0000', 1, 1),
(799, 45, 62, '17.0000', '0.0000', '13.0000', '24.0000', 1, 1),
(800, 27, 58, '21.0000', '0.0000', '7.0000', '36.0000', 1, 1),
(801, 28, 58, '25.0000', '0.0000', '13.0000', '56.0000', 1, 1),
(802, 41, 58, '24.0000', '0.0000', '13.0000', '36.0000', 1, 1),
(803, 42, 58, '24.0000', '0.0000', '9.0000', '30.0000', 1, 1),
(804, 43, 58, '19.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(805, 45, 58, '15.0000', '0.0000', '12.0000', '19.0000', 1, 1),
(806, 27, 94, '9.0000', '0.0000', '6.0000', '24.0000', 1, 1),
(807, 27, 60, '24.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(808, 28, 60, '23.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(809, 41, 60, '23.0000', '0.0000', '14.0000', '40.0000', 1, 1),
(810, 42, 60, '20.0000', '0.0000', '15.0000', '40.0000', 1, 1),
(811, 43, 60, '22.0000', '0.0000', '15.0000', '41.0000', 1, 1),
(812, 45, 60, '18.0000', '0.0000', '14.0000', '36.0000', 1, 1),
(813, 27, 64, '24.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(814, 28, 64, '23.0000', '0.0000', '15.0000', '48.0000', 1, 1),
(815, 41, 64, '24.0000', '0.0000', '13.0000', '40.0000', 1, 1),
(816, 42, 64, '20.0000', '0.0000', '10.0000', '32.0000', 1, 1),
(817, 45, 64, '19.0000', '0.0000', '12.0000', '37.0000', 1, 1),
(818, 43, 64, '19.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(819, 27, 61, '25.0000', '0.0000', '13.0000', '44.0000', 1, 1),
(820, 28, 61, '24.0000', '0.0000', '15.0000', '45.0000', 1, 1),
(821, 41, 61, '18.0000', '0.0000', '11.0000', '33.0000', 1, 1),
(822, 42, 61, '17.0000', '0.0000', '7.0000', '31.0000', 1, 1),
(823, 43, 61, '18.0000', '0.0000', '14.0000', '41.0000', 1, 1),
(824, 45, 61, '20.0000', '0.0000', '13.0000', '32.0000', 1, 1),
(825, 27, 65, '25.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(826, 28, 65, '22.0000', '0.0000', '14.0000', '47.0000', 1, 1),
(827, 41, 65, '25.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(828, 42, 65, '23.0000', '0.0000', '9.0000', '43.0000', 1, 1),
(829, 43, 65, '21.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(830, 45, 65, '17.0000', '0.0000', '12.0000', '25.0000', 1, 1),
(831, 27, 66, '24.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(832, 28, 66, '25.0000', '0.0000', '15.0000', '52.0000', 1, 1),
(833, 41, 66, '15.0000', '0.0000', '13.0000', '28.0000', 1, 1),
(834, 42, 66, '20.0000', '0.0000', '8.0000', '39.0000', 1, 1),
(835, 43, 66, '20.0000', '0.0000', '13.0000', '44.0000', 1, 1),
(836, 45, 66, '18.0000', '0.0000', '11.0000', '28.0000', 1, 1),
(838, 27, 67, '23.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(839, 28, 67, '25.0000', '0.0000', '14.0000', '40.0000', 1, 1),
(840, 41, 67, '22.0000', '0.0000', '13.0000', '35.0000', 1, 1),
(841, 42, 67, '17.0000', '0.0000', '10.0000', '55.0000', 1, 1),
(842, 43, 67, '19.0000', '0.0000', '12.0000', '46.0000', 1, 1),
(843, 45, 67, '17.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(844, 27, 68, '17.0000', '0.0000', '8.0000', '30.0000', 1, 1),
(845, 28, 68, '23.0000', '0.0000', '15.0000', '36.0000', 1, 1),
(846, 41, 68, '16.0000', '0.0000', '11.0000', '0.0000', 1, 1),
(847, 42, 68, '18.0000', '0.0000', '9.0000', '30.0000', 1, 1),
(848, 43, 68, '19.0000', '0.0000', '13.0000', '39.0000', 1, 1),
(849, 45, 68, '16.0000', '0.0000', '11.0000', '31.0000', 1, 1),
(850, 27, 69, '25.0000', '0.0000', '12.0000', '40.0000', 1, 1),
(851, 28, 69, '25.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(852, 41, 69, '23.0000', '0.0000', '12.0000', '38.0000', 1, 1),
(853, 42, 69, '20.0000', '0.0000', '12.0000', '34.0000', 1, 1),
(854, 43, 69, '22.0000', '0.0000', '13.0000', '37.0000', 1, 1),
(855, 45, 69, '17.0000', '0.0000', '12.0000', '16.0000', 1, 1),
(856, 27, 70, '24.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(857, 28, 70, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(858, 41, 70, '24.0000', '0.0000', '13.0000', '40.0000', 1, 1),
(859, 42, 70, '18.0000', '0.0000', '14.0000', '35.0000', 1, 1),
(860, 43, 70, '18.0000', '0.0000', '15.0000', '40.0000', 1, 1),
(861, 45, 70, '18.0000', '0.0000', '13.0000', '24.0000', 1, 1),
(862, 27, 71, '22.0000', '0.0000', '11.0000', '38.0000', 1, 1),
(863, 28, 71, '22.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(864, 41, 71, '18.0000', '0.0000', '12.0000', '25.0000', 1, 1),
(865, 42, 71, '15.0000', '0.0000', '7.0000', '41.0000', 1, 1),
(866, 43, 71, '22.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(867, 45, 71, '16.0000', '0.0000', '12.0000', '13.0000', 1, 1),
(868, 27, 72, '25.0000', '0.0000', '12.0000', '42.0000', 1, 1),
(869, 28, 72, '25.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(870, 41, 72, '22.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(871, 42, 72, '18.0000', '0.0000', '12.0000', '24.0000', 1, 1),
(872, 43, 72, '22.0000', '0.0000', '15.0000', '42.0000', 1, 1),
(873, 45, 72, '17.0000', '0.0000', '13.0000', '28.0000', 1, 1),
(880, 27, 74, '18.0000', '0.0000', '11.0000', '54.0000', 1, 1),
(881, 28, 74, '23.0000', '0.0000', '11.0000', '52.0000', 1, 1),
(882, 41, 74, '17.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(883, 42, 74, '24.0000', '0.0000', '9.0000', '26.0000', 1, 1),
(884, 43, 74, '16.0000', '0.0000', '15.0000', '45.0000', 1, 1),
(885, 45, 74, '18.0000', '0.0000', '12.0000', '25.0000', 1, 1),
(886, 27, 75, '25.0000', '0.0000', '8.0000', '40.0000', 1, 1),
(887, 28, 75, '25.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(888, 41, 75, '23.0000', '0.0000', '12.0000', '0.0000', 1, 1),
(889, 42, 75, '20.0000', '0.0000', '10.0000', '53.0000', 1, 1),
(890, 43, 75, '18.0000', '0.0000', '13.0000', '47.0000', 1, 1),
(891, 45, 75, '19.0000', '0.0000', '11.0000', '26.0000', 1, 1),
(892, 27, 76, '7.0000', '0.0000', '7.0000', '44.0000', 1, 1),
(893, 28, 76, '22.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(894, 41, 76, '22.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(895, 42, 76, '23.0000', '0.0000', '9.0000', '57.0000', 1, 1),
(896, 43, 76, '20.0000', '0.0000', '14.0000', '55.0000', 1, 1),
(897, 45, 76, '16.0000', '0.0000', '11.0000', '23.0000', 1, 1),
(898, 27, 77, '16.0000', '0.0000', '10.0000', '42.0000', 1, 1),
(899, 28, 77, '24.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(900, 41, 77, '24.0000', '0.0000', '11.0000', '28.0000', 1, 1),
(901, 42, 77, '15.0000', '0.0000', '9.0000', '30.0000', 1, 1),
(902, 43, 77, '18.0000', '0.0000', '15.0000', '38.0000', 1, 1),
(903, 45, 77, '15.0000', '0.0000', '12.0000', '25.0000', 1, 1),
(905, 28, 78, '24.0000', '0.0000', '13.0000', '36.0000', 1, 1),
(906, 41, 78, '24.0000', '0.0000', '11.0000', '0.0000', 1, 1),
(907, 42, 78, '24.0000', '0.0000', '11.0000', '0.0000', 1, 1),
(908, 43, 78, '20.0000', '0.0000', '14.0000', '42.0000', 1, 1),
(909, 45, 78, '17.0000', '0.0000', '12.0000', '26.0000', 1, 1),
(910, 27, 79, '12.0000', '0.0000', '6.0000', '0.0000', 2, 1),
(911, 28, 79, '22.0000', '0.0000', '11.0000', '27.0000', 1, 1),
(912, 41, 79, '19.0000', '0.0000', '7.0000', '0.0000', 2, 1),
(913, 42, 79, '18.0000', '0.0000', '5.0000', '0.0000', 1, 1),
(914, 43, 79, '15.0000', '0.0000', '14.0000', '43.0000', 1, 1),
(915, 45, 79, '16.0000', '0.0000', '12.0000', '14.0000', 2, 1),
(916, 27, 80, '25.0000', '0.0000', '15.0000', '42.0000', 1, 1);
INSERT INTO `registration` (`ID`, `Course_semesterID`, `StudentID`, `YearWork`, `Practical`, `MidTermExam`, `FinalExam`, `statusID`, `AdvisorApprovalID`) VALUES
(917, 28, 80, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(918, 41, 80, '25.0000', '0.0000', '14.0000', '38.0000', 1, 1),
(919, 42, 80, '23.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(920, 43, 80, '21.0000', '0.0000', '15.0000', '46.0000', 1, 1),
(921, 45, 80, '17.0000', '0.0000', '13.0000', '30.0000', 1, 1),
(922, 27, 81, '25.0000', '0.0000', '7.0000', '42.0000', 1, 1),
(923, 28, 81, '24.0000', '0.0000', '15.0000', '29.0000', 1, 1),
(924, 41, 81, '25.0000', '0.0000', '14.0000', '33.0000', 1, 1),
(925, 42, 81, '23.0000', '0.0000', '10.0000', '40.0000', 1, 1),
(926, 43, 81, '19.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(927, 45, 81, '16.0000', '0.0000', '12.0000', '10.0000', 1, 1),
(928, 27, 83, '23.0000', '0.0000', '8.0000', '24.0000', 1, 1),
(929, 28, 83, '22.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(930, 41, 83, '25.0000', '0.0000', '13.0000', '31.0000', 1, 1),
(931, 42, 83, '23.0000', '0.0000', '9.0000', '37.0000', 1, 1),
(932, 43, 83, '21.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(933, 45, 83, '18.0000', '0.0000', '11.0000', '25.0000', 1, 1),
(940, 27, 84, '24.0000', '0.0000', '7.0000', '26.0000', 1, 1),
(941, 28, 84, '24.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(942, 41, 84, '16.0000', '0.0000', '8.0000', '0.0000', 1, 1),
(943, 42, 84, '20.0000', '0.0000', '13.0000', '24.0000', 1, 1),
(944, 43, 84, '19.0000', '0.0000', '12.0000', '45.0000', 1, 1),
(945, 45, 84, '18.0000', '0.0000', '14.0000', '26.0000', 1, 1),
(946, 27, 85, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(947, 28, 85, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(948, 41, 85, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(949, 42, 85, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(950, 43, 85, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(951, 45, 85, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(952, 27, 86, '24.0000', '0.0000', '10.0000', '37.0000', 1, 1),
(953, 28, 86, '23.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(954, 41, 86, '18.0000', '0.0000', '14.0000', '36.0000', 1, 1),
(955, 42, 86, '20.0000', '0.0000', '10.0000', '35.0000', 1, 1),
(956, 43, 86, '19.0000', '0.0000', '15.0000', '44.0000', 1, 1),
(957, 45, 86, '16.0000', '0.0000', '13.0000', '35.0000', 1, 1),
(958, 27, 87, '25.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(959, 28, 87, '25.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(960, 41, 87, '25.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(961, 42, 87, '22.0000', '0.0000', '15.0000', '49.0000', 1, 1),
(962, 43, 87, '21.0000', '0.0000', '15.0000', '60.0000', 1, 1),
(963, 45, 87, '17.0000', '0.0000', '13.0000', '43.0000', 1, 1),
(964, 27, 88, '18.0000', '0.0000', '7.0000', '34.0000', 1, 1),
(965, 28, 88, '23.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(966, 41, 88, '16.0000', '0.0000', '13.0000', '24.0000', 1, 1),
(967, 42, 88, '24.0000', '0.0000', '12.0000', '0.0000', 1, 1),
(968, 43, 88, '21.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(969, 45, 88, '18.0000', '0.0000', '12.0000', '32.0000', 1, 1),
(970, 27, 89, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(971, 28, 89, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(972, 41, 89, '16.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(973, 42, 89, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(974, 43, 89, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(975, 45, 89, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(976, 27, 90, '24.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(977, 28, 90, '24.0000', '0.0000', '14.0000', '51.0000', 1, 1),
(978, 41, 90, '23.0000', '0.0000', '14.0000', '34.0000', 1, 1),
(979, 42, 90, '18.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(980, 43, 90, '20.0000', '0.0000', '14.0000', '42.0000', 1, 1),
(981, 45, 90, '18.0000', '0.0000', '13.0000', '35.0000', 1, 1),
(982, 27, 91, '12.0000', '0.0000', '12.0000', '39.0000', 1, 1),
(983, 28, 91, '22.0000', '0.0000', '13.0000', '27.0000', 1, 1),
(984, 41, 91, '20.0000', '0.0000', '13.0000', '39.0000', 1, 1),
(985, 42, 91, '24.0000', '0.0000', '5.0000', '34.0000', 1, 1),
(986, 43, 91, '20.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(987, 45, 91, '17.0000', '0.0000', '12.0000', '23.0000', 1, 1),
(988, 27, 92, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(989, 28, 92, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(990, 41, 92, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(991, 42, 92, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(992, 43, 92, '0.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(993, 45, 92, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(994, 27, 93, '24.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(995, 28, 93, '24.0000', '0.0000', '15.0000', '49.0000', 1, 1),
(996, 41, 93, '25.0000', '0.0000', '14.0000', '47.0000', 1, 1),
(997, 42, 93, '20.0000', '0.0000', '15.0000', '49.0000', 1, 1),
(998, 43, 93, '19.0000', '0.0000', '13.0000', '59.0000', 1, 1),
(999, 45, 93, '18.0000', '0.0000', '13.0000', '39.0000', 1, 1),
(1000, 27, 63, '16.0000', '0.0000', '5.0000', '11.0000', 1, 1),
(1001, 28, 63, '22.0000', '0.0000', '2.0000', '6.0000', 1, 1),
(1002, 41, 63, '16.0000', '0.0000', '2.0000', '0.0000', 1, 1),
(1003, 42, 63, '0.0000', '0.0000', '5.0000', '0.0000', 1, 1),
(1004, 43, 63, '20.0000', '0.0000', '10.0000', '10.0000', 1, 1),
(1005, 45, 63, '15.0000', '0.0000', '10.0000', '2.0000', 1, 1),
(1006, 28, 94, '22.0000', '0.0000', '6.0000', '44.0000', 1, 1),
(1007, 41, 94, '16.0000', '0.0000', '9.0000', '9.0000', 1, 1),
(1008, 42, 94, '18.0000', '0.0000', '6.0000', '10.0000', 1, 1),
(1009, 43, 94, '18.0000', '0.0000', '14.0000', '41.0000', 1, 1),
(1010, 45, 94, '17.0000', '0.0000', '12.0000', '31.0000', 1, 1),
(1011, 27, 95, '17.0000', '0.0000', '7.0000', '29.0000', 1, 1),
(1012, 28, 95, '24.0000', '0.0000', '13.0000', '43.0000', 1, 1),
(1013, 41, 95, '23.0000', '0.0000', '9.0000', '11.0000', 1, 1),
(1014, 42, 95, '15.0000', '0.0000', '11.0000', '24.0000', 1, 1),
(1015, 43, 95, '18.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1016, 45, 95, '17.0000', '0.0000', '12.0000', '21.0000', 1, 1),
(1017, 29, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1018, 32, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1019, 38, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1020, 39, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1021, 44, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1022, 46, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1023, 29, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1024, 32, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1025, 38, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1026, 39, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1027, 44, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1028, 46, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1029, 29, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1030, 32, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1031, 38, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1032, 39, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1033, 44, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1034, 46, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1035, 29, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1036, 32, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1037, 38, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1038, 39, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1039, 44, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1040, 46, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1041, 29, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1042, 32, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1043, 38, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1044, 39, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1045, 44, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1046, 46, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1047, 27, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1048, 28, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1050, 29, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1051, 32, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1052, 38, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1053, 39, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1054, 44, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1055, 46, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1056, 29, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1057, 32, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1058, 38, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1059, 39, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1060, 44, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1061, 46, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1062, 46, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1063, 29, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1064, 32, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1065, 38, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1066, 39, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1067, 44, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1068, 46, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1074, 41, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1080, 39, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1081, 29, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1082, 38, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1083, 32, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1084, 44, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1085, 46, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1086, 29, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1087, 38, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1088, 32, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1089, 39, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1090, 44, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1091, 46, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1092, 27, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1093, 41, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1094, 28, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1095, 43, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1097, 27, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1098, 41, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1099, 28, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1101, 42, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1103, 29, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1104, 32, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1105, 38, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1106, 39, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1107, 44, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1108, 46, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1109, 29, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1110, 32, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1111, 38, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1112, 39, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1113, 44, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1114, 46, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1115, 38, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1116, 29, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1117, 32, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1118, 39, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1119, 44, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1120, 46, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1121, 29, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1122, 32, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1123, 38, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1124, 39, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1125, 44, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1126, 46, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1127, 27, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1128, 41, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1129, 43, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1130, 42, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1137, 29, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1138, 32, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1139, 38, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1140, 39, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1141, 44, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1142, 46, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1143, 29, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1144, 32, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1145, 38, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1146, 39, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1147, 44, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1148, 46, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1149, 29, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1150, 32, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1151, 38, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1152, 39, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1153, 44, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1154, 46, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1155, 29, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1156, 32, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1157, 38, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1158, 39, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1159, 44, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1160, 46, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1161, 29, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1162, 32, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1163, 38, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1164, 39, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1165, 44, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1166, 46, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1167, 29, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1168, 32, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1169, 38, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1170, 39, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1171, 44, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1172, 46, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1173, 27, 78, '25.0000', '0.0000', '5.0000', '39.0000', 1, 1),
(1174, 47, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1175, 29, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1176, 32, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1177, 38, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1178, 39, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1179, 44, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1180, 46, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1181, 29, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1182, 32, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1183, 38, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1184, 39, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1185, 44, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1186, 46, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1187, 29, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(1188, 38, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(1189, 39, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(1190, 32, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(1191, 44, 40, '22.0000', '0.0000', '11.0000', '37.0000', 2, 1),
(1192, 46, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(1193, 46, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1194, 32, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1195, 39, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1196, 38, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1197, 29, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1198, 32, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1199, 39, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1200, 38, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1201, 29, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1202, 46, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1203, 44, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1204, 32, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1206, 39, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1207, 38, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1208, 46, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1209, 32, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1210, 46, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1211, 38, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1212, 39, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1213, 32, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1214, 39, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1215, 38, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1216, 29, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1217, 46, 55, '18.0000', '0.0000', '7.0000', '19.0000', 1, 1),
(1218, 29, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1219, 54, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1220, 55, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1221, 57, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1222, 58, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1223, 59, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1224, 56, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1225, 54, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1226, 55, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1227, 57, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1228, 58, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1229, 59, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1230, 56, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1231, 54, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1232, 55, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1233, 57, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1234, 58, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1235, 59, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1236, 56, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1237, 54, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1238, 55, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1239, 57, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1240, 58, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1241, 59, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1242, 56, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1243, 54, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1244, 55, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1245, 57, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1246, 58, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1247, 59, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1248, 56, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1249, 54, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1250, 55, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1251, 57, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1252, 58, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1253, 59, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1254, 56, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1255, 48, 74, '20.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1256, 49, 74, '12.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1257, 52, 74, '14.0000', '0.0000', '8.0000', '57.0000', 1, 1),
(1258, 53, 74, '20.0000', '0.0000', '10.0000', '51.0000', 1, 1),
(1259, 51, 74, '19.0000', '0.0000', '15.0000', '24.0000', 1, 1),
(1260, 50, 74, '19.0000', '0.0000', '11.0000', '50.0000', 1, 1),
(1261, 48, 75, '23.0000', '0.0000', '12.0000', '42.0000', 1, 1),
(1262, 52, 75, '18.0000', '0.0000', '13.0000', '49.0000', 1, 1),
(1263, 53, 75, '23.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(1264, 51, 75, '21.0000', '0.0000', '14.0000', '32.0000', 1, 1),
(1265, 50, 75, '21.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1266, 48, 76, '24.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(1267, 49, 76, '18.0000', '0.0000', '12.0000', '58.0000', 1, 1),
(1268, 52, 76, '19.0000', '0.0000', '10.0000', '52.0000', 1, 1),
(1269, 51, 76, '20.0000', '0.0000', '15.0000', '33.0000', 1, 1),
(1270, 61, 76, '23.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(1271, 48, 77, '24.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(1272, 49, 77, '16.0000', '0.0000', '10.0000', '54.0000', 1, 1),
(1273, 52, 77, '21.0000', '0.0000', '8.0000', '30.0000', 1, 1),
(1274, 53, 77, '22.0000', '0.0000', '10.0000', '47.0000', 1, 1),
(1275, 51, 77, '21.0000', '0.0000', '11.0000', '26.0000', 1, 1),
(1276, 48, 78, '24.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(1277, 52, 78, '13.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1278, 51, 78, '23.0000', '0.0000', '14.0000', '28.0000', 1, 1),
(1279, 54, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1280, 55, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1281, 57, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1282, 58, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1283, 59, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1284, 56, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1285, 54, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1286, 54, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1287, 55, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1288, 57, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1289, 58, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1290, 59, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1291, 56, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1292, 54, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1293, 55, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1294, 57, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1295, 58, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1296, 59, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1297, 56, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1298, 54, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1299, 55, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1300, 57, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1301, 58, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1302, 59, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1303, 56, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1304, 54, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1305, 55, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1306, 57, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1307, 58, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1308, 59, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1309, 56, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1310, 48, 84, '14.0000', '0.0000', '10.0000', '22.0000', 1, 1),
(1311, 52, 84, '17.0000', '0.0000', '7.0000', '37.0000', 1, 1),
(1312, 51, 84, '17.0000', '0.0000', '7.0000', '13.0000', 1, 1),
(1313, 60, 84, '25.0000', '0.0000', '13.0000', '37.0000', 1, 1),
(1317, 48, 86, '22.0000', '0.0000', '12.0000', '46.0000', 1, 1),
(1318, 49, 86, '16.0000', '0.0000', '8.0000', '52.0000', 1, 1),
(1319, 52, 86, '22.0000', '0.0000', '9.0000', '46.0000', 1, 1),
(1320, 53, 86, '22.0000', '0.0000', '10.0000', '54.0000', 1, 1),
(1321, 51, 86, '22.0000', '0.0000', '15.0000', '34.0000', 1, 1),
(1322, 48, 87, '24.0000', '0.0000', '14.0000', '57.0000', 1, 1),
(1323, 49, 87, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1324, 52, 87, '25.0000', '0.0000', '12.0000', '56.0000', 1, 1),
(1325, 53, 87, '24.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(1326, 51, 87, '22.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(1327, 48, 88, '22.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(1328, 49, 88, '15.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1329, 52, 88, '22.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1330, 53, 88, '22.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(1331, 51, 88, '19.0000', '0.0000', '13.0000', '30.0000', 1, 1),
(1332, 54, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1333, 55, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1334, 57, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1335, 58, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1336, 59, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1337, 56, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(1338, 54, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1339, 55, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1340, 57, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1341, 58, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1342, 59, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1343, 56, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1344, 54, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1345, 55, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1346, 57, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1347, 58, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1348, 59, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1349, 56, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1350, 54, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1351, 55, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1352, 57, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1353, 58, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1354, 59, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1355, 56, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1356, 54, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1357, 55, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1358, 57, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1359, 58, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1360, 59, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1361, 56, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1362, 54, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1363, 55, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1364, 57, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1365, 58, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1366, 59, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1367, 56, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(1368, 54, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1369, 55, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1370, 56, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1371, 57, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1372, 58, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1373, 59, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1374, 60, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1375, 52, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1376, 50, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1377, 51, 22, '15.0000', '0.0000', '2.0000', '7.0000', 1, 1),
(1378, 60, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1379, 48, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1380, 52, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1381, 56, 16, '10.0000', '0.0000', '3.0000', '16.0000', 1, 1),
(1382, 54, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1383, 55, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1384, 56, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1385, 57, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1386, 58, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1387, 59, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1388, 54, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1389, 55, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1390, 56, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1391, 57, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1392, 58, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1393, 59, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1394, 60, 75, '25.0000', '0.0000', '15.0000', '49.0000', 1, 1),
(1395, 50, 76, '19.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1396, 50, 77, '20.0000', '0.0000', '9.0000', '55.0000', 1, 1),
(1397, 60, 78, '25.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(1398, 50, 86, '18.0000', '0.0000', '11.0000', '54.0000', 1, 1),
(1399, 50, 87, '23.0000', '0.0000', '13.0000', '58.0000', 1, 1),
(1400, 50, 88, '21.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1401, 48, 70, '24.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1402, 49, 70, '21.0000', '0.0000', '8.0000', '59.0000', 1, 1),
(1403, 52, 70, '20.0000', '0.0000', '8.0000', '52.0000', 1, 1),
(1404, 53, 70, '23.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(1405, 50, 70, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1406, 51, 70, '23.0000', '0.0000', '15.0000', '36.0000', 1, 1),
(1407, 48, 71, '21.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1408, 49, 71, '10.0000', '0.0000', '11.0000', '13.0000', 1, 1),
(1409, 52, 71, '11.0000', '0.0000', '8.0000', '54.0000', 1, 1),
(1410, 50, 71, '21.0000', '0.0000', '11.0000', '38.0000', 1, 1),
(1411, 51, 71, '17.0000', '0.0000', '11.0000', '17.0000', 1, 1),
(1412, 61, 71, '22.0000', '0.0000', '7.0000', '47.0000', 1, 1),
(1413, 48, 72, '23.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(1414, 49, 72, '19.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(1415, 52, 72, '19.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(1416, 53, 72, '23.0000', '0.0000', '12.0000', '49.0000', 1, 1),
(1417, 50, 72, '21.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1418, 51, 72, '22.0000', '0.0000', '10.0000', '24.0000', 1, 1),
(1423, 60, 68, '22.0000', '0.0000', '14.0000', '36.0000', 1, 1),
(1424, 48, 68, '24.0000', '0.0000', '9.0000', '38.0000', 1, 1),
(1425, 52, 68, '20.0000', '0.0000', '5.0000', '42.0000', 1, 1),
(1426, 51, 68, '20.0000', '0.0000', '12.0000', '32.0000', 1, 1),
(1427, 48, 65, '24.0000', '0.0000', '14.0000', '51.0000', 1, 1),
(1428, 49, 65, '18.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1429, 50, 65, '21.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(1430, 52, 65, '23.0000', '0.0000', '8.0000', '52.0000', 1, 1),
(1431, 53, 65, '22.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(1432, 51, 65, '22.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(1433, 48, 66, '23.0000', '0.0000', '11.0000', '41.0000', 1, 1),
(1434, 49, 66, '15.0000', '0.0000', '9.0000', '56.0000', 1, 1),
(1435, 50, 66, '15.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(1436, 51, 66, '17.0000', '0.0000', '15.0000', '24.0000', 1, 1),
(1437, 52, 66, '21.0000', '0.0000', '5.0000', '41.0000', 1, 1),
(1438, 53, 66, '23.0000', '0.0000', '10.0000', '50.0000', 1, 1),
(1439, 48, 67, '21.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1440, 49, 67, '16.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1441, 50, 67, '20.0000', '0.0000', '10.0000', '44.0000', 1, 1),
(1442, 51, 67, '20.0000', '0.0000', '13.0000', '47.0000', 1, 1),
(1443, 52, 67, '21.0000', '0.0000', '10.0000', '50.0000', 1, 1),
(1444, 53, 67, '22.0000', '0.0000', '12.0000', '45.0000', 1, 1),
(1445, 48, 61, '21.0000', '0.0000', '13.0000', '37.0000', 1, 1),
(1446, 49, 61, '15.0000', '0.0000', '5.0000', '43.0000', 1, 1),
(1447, 50, 61, '20.0000', '0.0000', '8.0000', '54.0000', 1, 1),
(1448, 51, 61, '21.0000', '0.0000', '11.0000', '24.0000', 1, 1),
(1449, 52, 61, '20.0000', '0.0000', '8.0000', '41.0000', 1, 1),
(1450, 53, 61, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1451, 54, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1452, 55, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1453, 56, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1454, 57, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1455, 58, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1456, 59, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1457, 54, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1458, 55, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1459, 57, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1460, 58, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1461, 59, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1462, 56, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1463, 54, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1464, 55, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1465, 57, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1466, 58, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1467, 59, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1468, 56, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1469, 54, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1470, 55, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1471, 57, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1472, 58, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1473, 59, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1474, 56, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1475, 54, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1476, 55, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1477, 57, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1478, 58, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1479, 59, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1480, 56, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1481, 54, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1482, 55, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1483, 57, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1484, 58, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1485, 59, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1486, 56, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1487, 48, 80, '24.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(1488, 49, 80, '20.0000', '0.0000', '15.0000', '33.0000', 1, 1),
(1489, 52, 80, '25.0000', '0.0000', '13.0000', '57.0000', 1, 1),
(1490, 53, 80, '22.0000', '0.0000', '10.0000', '52.0000', 1, 1),
(1491, 50, 80, '20.0000', '0.0000', '14.0000', '57.0000', 1, 1),
(1492, 51, 80, '21.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(1493, 48, 81, '24.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(1494, 49, 81, '16.0000', '0.0000', '11.0000', '52.0000', 1, 1),
(1495, 52, 81, '25.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1496, 50, 81, '21.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(1497, 51, 81, '22.0000', '0.0000', '15.0000', '42.0000', 1, 1),
(1498, 61, 81, '24.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(1499, 48, 83, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1500, 49, 83, '18.0000', '0.0000', '12.0000', '35.0000', 1, 1),
(1501, 52, 83, '22.0000', '0.0000', '9.0000', '50.0000', 1, 1),
(1502, 53, 83, '22.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(1503, 50, 83, '18.0000', '0.0000', '10.0000', '54.0000', 1, 1),
(1504, 51, 83, '21.0000', '0.0000', '15.0000', '38.0000', 1, 1),
(1505, 54, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1506, 55, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1507, 57, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1508, 58, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1509, 59, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1510, 56, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1511, 54, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1512, 55, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1513, 57, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1514, 58, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1515, 59, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1516, 56, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1517, 54, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1518, 55, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1519, 57, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1520, 58, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1521, 59, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1522, 56, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1523, 54, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1524, 55, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1525, 57, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1526, 58, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1527, 62, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1528, 56, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(1529, 54, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1530, 55, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1531, 57, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1532, 58, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1533, 59, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1534, 56, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1535, 54, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1536, 55, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1537, 57, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1538, 58, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1539, 59, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1540, 56, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1541, 48, 62, '22.0000', '0.0000', '14.0000', '43.0000', 1, 1),
(1542, 49, 62, '12.0000', '0.0000', '11.0000', '38.0000', 1, 1),
(1543, 52, 62, '13.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(1544, 53, 62, '23.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1545, 50, 62, '20.0000', '0.0000', '11.0000', '52.0000', 1, 1),
(1546, 51, 62, '23.0000', '0.0000', '15.0000', '24.0000', 1, 1),
(1547, 48, 58, '24.0000', '0.0000', '13.0000', '57.0000', 1, 1),
(1548, 49, 58, '16.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1549, 52, 58, '16.0000', '0.0000', '11.0000', '42.0000', 1, 1),
(1550, 50, 58, '21.0000', '0.0000', '13.0000', '56.0000', 1, 1),
(1551, 51, 58, '23.0000', '0.0000', '15.0000', '32.0000', 1, 1),
(1552, 61, 58, '24.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(1553, 48, 60, '23.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(1554, 49, 60, '21.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1555, 52, 60, '18.0000', '0.0000', '7.0000', '46.0000', 1, 1),
(1556, 53, 60, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(1557, 50, 60, '20.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(1558, 51, 60, '23.0000', '0.0000', '15.0000', '34.0000', 1, 1),
(1559, 48, 64, '22.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(1560, 49, 64, '16.0000', '0.0000', '12.0000', '46.0000', 1, 1),
(1561, 52, 64, '17.0000', '0.0000', '10.0000', '43.0000', 1, 1),
(1562, 53, 64, '24.0000', '0.0000', '10.0000', '47.0000', 1, 1),
(1563, 50, 64, '22.0000', '0.0000', '11.0000', '55.0000', 1, 1),
(1564, 51, 64, '21.0000', '0.0000', '15.0000', '27.0000', 1, 1),
(1565, 54, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1566, 55, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1567, 57, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1568, 58, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1569, 59, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1570, 56, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1571, 54, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1572, 55, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1573, 57, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1574, 58, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1575, 59, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1576, 56, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1577, 49, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1578, 54, 54, '20.0000', '0.0000', '12.0000', '22.0000', 2, 1),
(1579, 55, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1580, 57, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1581, 58, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1582, 56, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1584, 54, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1585, 55, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1586, 57, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1587, 58, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1588, 59, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1589, 56, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1594, 48, 90, '24.0000', '0.0000', '12.0000', '44.0000', 1, 1),
(1595, 49, 90, '20.0000', '0.0000', '8.0000', '52.0000', 1, 1),
(1596, 52, 90, '19.0000', '0.0000', '6.0000', '33.0000', 1, 1),
(1597, 53, 90, '22.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1598, 50, 90, '21.0000', '0.0000', '9.0000', '55.0000', 1, 1),
(1599, 51, 90, '19.0000', '0.0000', '10.0000', '24.0000', 1, 1),
(1600, 48, 91, '24.0000', '0.0000', '14.0000', '51.0000', 1, 1),
(1601, 49, 91, '13.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1602, 52, 91, '13.0000', '0.0000', '8.0000', '46.0000', 1, 1),
(1603, 61, 91, '23.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(1608, 48, 93, '22.0000', '0.0000', '10.0000', '47.0000', 1, 1),
(1609, 49, 93, '21.0000', '0.0000', '9.0000', '54.0000', 1, 1),
(1610, 52, 93, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1611, 53, 93, '23.0000', '0.0000', '10.0000', '54.0000', 1, 1),
(1612, 50, 93, '20.0000', '0.0000', '14.0000', '60.0000', 1, 1),
(1613, 51, 93, '21.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(1614, 60, 63, '5.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(1615, 61, 63, '5.0000', '0.0000', '5.0000', '13.0000', 1, 1),
(1616, 50, 63, '1.0000', '0.0000', '1.0000', '7.0000', 1, 1),
(1617, 51, 63, '3.0000', '0.0000', '0.0000', '0.0000', 1, 1),
(1618, 60, 94, '22.0000', '0.0000', '11.0000', '42.0000', 1, 1),
(1619, 52, 94, '13.0000', '0.0000', '1.0000', '38.0000', 1, 1),
(1620, 53, 94, '24.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(1621, 50, 94, '15.0000', '0.0000', '7.0000', '41.0000', 1, 1),
(1622, 60, 95, '24.0000', '0.0000', '12.0000', '33.0000', 1, 1),
(1623, 48, 95, '22.0000', '0.0000', '12.0000', '30.0000', 1, 1),
(1624, 52, 95, '14.0000', '0.0000', '6.0000', '37.0000', 1, 1),
(1625, 51, 95, '20.0000', '0.0000', '12.0000', '14.0000', 1, 1),
(1626, 60, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1627, 49, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1628, 54, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1629, 55, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1630, 57, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1631, 56, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(1632, 55, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1633, 57, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1634, 58, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1635, 59, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1636, 56, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1637, 49, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1638, 55, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1639, 57, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1640, 56, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1642, 58, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1643, 57, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1644, 55, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1645, 56, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1646, 62, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1647, 54, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1648, 48, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1649, 55, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1650, 57, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1651, 56, 49, '20.0000', '0.0000', '6.0000', '25.0000', 1, 1),
(1653, 64, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1654, 60, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1655, 49, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1656, 51, 56, '17.0000', '0.0000', '4.0000', '22.0000', 1, 1),
(1657, 54, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1658, 55, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1659, 57, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1660, 58, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1661, 56, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1662, 62, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1663, 60, 79, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(1664, 61, 79, '5.0000', '0.0000', '5.0000', '-100.0000', 1, 1),
(1665, 52, 79, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(1666, 51, 79, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(1667, 48, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1668, 58, 9, '18.0000', '0.0000', '6.0000', '35.0000', 2, 1),
(1669, 56, 9, '18.0000', '0.0000', '6.0000', '35.0000', 2, 1),
(1670, 62, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1671, 61, 69, '24.0000', '0.0000', '10.0000', '43.0000', 1, 1),
(1672, 48, 69, '23.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(1673, 49, 69, '16.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1674, 52, 69, '23.0000', '0.0000', '9.0000', '50.0000', 1, 1),
(1675, 50, 69, '21.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(1676, 51, 69, '22.0000', '0.0000', '15.0000', '41.0000', 1, 1),
(1681, 72, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1682, 72, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1683, 72, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1684, 72, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1685, 72, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1686, 73, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(1687, 74, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1688, 74, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(1689, 75, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(1690, 75, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(1691, 75, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(1692, 75, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(1693, 75, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1694, 75, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(1695, NULL, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(1699, 84, 78, '22.0000', '0.0000', '10.0000', '45.0000', 1, 1),
(1700, 85, 78, '24.0000', '0.0000', '10.0000', '44.0000', 1, 1),
(1701, 86, 78, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1702, 87, 78, '18.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(1703, 88, 78, '23.0000', '0.0000', '15.0000', '48.0000', 1, 1),
(1705, 90, 78, '25.0000', '0.0000', '14.0000', '47.0000', 1, 1),
(1706, 84, 75, '25.0000', '0.0000', '15.0000', '49.0000', 1, 1),
(1707, 85, 75, '25.0000', '0.0000', '11.0000', '57.0000', 1, 1),
(1708, 86, 75, '21.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(1709, 87, 75, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1710, 88, 75, '23.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(1712, 90, 75, '25.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(1713, 91, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1714, 92, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1715, 93, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1716, 94, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1717, 95, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1718, 96, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1719, 91, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1720, 92, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1721, 93, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1722, 94, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1723, 95, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1724, 96, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1725, 85, 77, '23.0000', '0.0000', '13.0000', '56.0000', 1, 1),
(1726, 86, 77, '23.0000', '0.0000', '9.0000', '41.0000', 1, 1),
(1727, 87, 77, '16.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(1729, 88, 77, '22.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(1730, 89, 77, '24.0000', '0.0000', '14.0000', '28.0000', 1, 1),
(1731, 90, 77, '25.0000', '0.0000', '12.0000', '42.0000', 1, 1),
(1732, 91, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1733, 92, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1734, 93, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1735, 94, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1736, 95, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1737, 96, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(1738, 91, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1739, 92, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1740, 93, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1741, 94, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1742, 95, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1743, 96, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(1744, 91, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1745, 92, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1746, 93, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1747, 94, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1748, 95, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1749, 96, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1750, 91, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1751, 92, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1752, 93, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1753, 94, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1754, 95, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1755, 96, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1756, 85, 74, '25.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1757, 86, 74, '21.0000', '0.0000', '12.0000', '37.0000', 1, 1),
(1758, 87, 74, '20.0000', '0.0000', '13.0000', '47.0000', 1, 1),
(1759, 88, 74, '21.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1760, 89, 74, '24.0000', '0.0000', '13.0000', '31.0000', 1, 1),
(1761, 90, 74, '25.0000', '0.0000', '10.0000', '52.0000', 1, 1),
(1763, 78, 144, '23.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(1764, 79, 144, '21.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1765, 80, 144, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(1766, 81, 144, '23.0000', '0.0000', '14.0000', '43.0000', 1, 1),
(1767, 82, 144, '23.0000', '0.0000', '9.0000', '41.0000', 1, 1),
(1768, 83, 144, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1769, 78, 120, '25.0000', '0.0000', '13.0000', '59.0000', 1, 1),
(1770, 79, 120, '20.0000', '0.0000', '13.0000', '47.0000', 1, 1);
INSERT INTO `registration` (`ID`, `Course_semesterID`, `StudentID`, `YearWork`, `Practical`, `MidTermExam`, `FinalExam`, `statusID`, `AdvisorApprovalID`) VALUES
(1771, 80, 120, '16.0000', '0.0000', '12.0000', '34.0000', 1, 1),
(1772, 81, 120, '16.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1773, 82, 120, '22.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1774, 83, 120, '25.0000', '0.0000', '12.0000', '44.0000', 1, 1),
(1775, 78, 122, '25.0000', '0.0000', '10.0000', '59.0000', 1, 1),
(1776, 79, 122, '21.0000', '0.0000', '10.0000', '43.0000', 1, 1),
(1777, 80, 122, '22.0000', '0.0000', '14.0000', '40.0000', 1, 1),
(1778, 81, 122, '22.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(1779, 82, 122, '22.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(1780, 83, 122, '24.0000', '0.0000', '9.0000', '52.0000', 1, 1),
(1781, 78, 119, '25.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1782, 79, 119, '23.0000', '0.0000', '12.0000', '34.0000', 1, 1),
(1783, 80, 119, '21.0000', '0.0000', '11.0000', '38.0000', 1, 1),
(1784, 81, 119, '21.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1785, 82, 119, '22.0000', '0.0000', '10.0000', '50.0000', 1, 1),
(1786, 83, 119, '24.0000', '0.0000', '8.0000', '41.0000', 1, 1),
(1787, 78, 121, '24.0000', '0.0000', '8.0000', '59.0000', 1, 1),
(1788, 79, 121, '22.0000', '0.0000', '14.0000', '41.0000', 1, 1),
(1789, 80, 121, '22.0000', '0.0000', '10.0000', '38.0000', 1, 1),
(1790, 81, 121, '22.0000', '0.0000', '13.0000', '57.0000', 1, 1),
(1791, 82, 121, '22.0000', '0.0000', '11.0000', '55.0000', 1, 1),
(1792, 83, 121, '23.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(1793, 84, 84, '23.0000', '0.0000', '8.0000', '31.0000', 1, 1),
(1794, 85, 84, '24.0000', '0.0000', '12.0000', '30.0000', 1, 1),
(1795, 87, 84, '19.0000', '0.0000', '14.0000', '30.0000', 1, 1),
(1796, 88, 84, '20.0000', '0.0000', '10.0000', '39.0000', 1, 1),
(1797, 91, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1798, 92, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1799, 93, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1800, 94, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1801, 95, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1802, 96, 46, '22.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(1803, 91, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1804, 92, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1805, 93, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1806, 94, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1807, 95, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1808, 96, 48, '23.0000', '0.0000', '11.0000', '30.0000', 1, 1),
(1809, 91, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1810, 92, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1811, 93, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1812, 94, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1813, 95, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1814, 96, 45, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1819, 85, 88, '25.0000', '0.0000', '14.0000', '55.0000', 1, 1),
(1820, 86, 88, '22.0000', '0.0000', '7.0000', '48.0000', 1, 1),
(1821, 87, 88, '23.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1822, 89, 88, '16.0000', '0.0000', '13.0000', '24.0000', 1, 1),
(1823, 88, 88, '21.0000', '0.0000', '12.0000', '46.0000', 1, 1),
(1824, 90, 88, '25.0000', '0.0000', '12.0000', '51.0000', 1, 1),
(1825, 91, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1826, 92, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1827, 93, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1828, 94, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1829, 95, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1830, 96, 44, '20.0000', '0.0000', '8.0000', '49.0000', 1, 1),
(1831, 85, 86, '25.0000', '0.0000', '7.0000', '50.0000', 1, 1),
(1832, 86, 86, '21.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(1833, 87, 86, '19.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1834, 88, 86, '22.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(1835, 89, 86, '24.0000', '0.0000', '14.0000', '21.0000', 1, 1),
(1836, 90, 86, '25.0000', '0.0000', '10.0000', '47.0000', 1, 1),
(1837, 85, 87, '25.0000', '0.0000', '15.0000', '60.0000', 1, 1),
(1838, 86, 87, '25.0000', '0.0000', '15.0000', '52.0000', 1, 1),
(1839, 87, 87, '25.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(1840, 88, 87, '23.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(1841, 89, 87, '24.0000', '0.0000', '14.0000', '24.0000', 1, 1),
(1842, 90, 87, '25.0000', '0.0000', '14.0000', '58.0000', 1, 1),
(1843, 78, 131, '24.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(1844, 79, 131, '21.0000', '0.0000', '11.0000', '33.0000', 1, 1),
(1845, 80, 131, '22.0000', '0.0000', '10.0000', '40.0000', 1, 1),
(1846, 81, 131, '22.0000', '0.0000', '13.0000', '56.0000', 1, 1),
(1847, 82, 131, '22.0000', '0.0000', '10.0000', '51.0000', 1, 1),
(1848, 83, 131, '23.0000', '0.0000', '12.0000', '53.0000', 1, 1),
(1849, 78, 132, '25.0000', '0.0000', '15.0000', '59.0000', 1, 1),
(1850, 79, 132, '22.0000', '0.0000', '13.0000', '33.0000', 1, 1),
(1851, 80, 132, '23.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(1852, 81, 132, '23.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(1853, 82, 132, '24.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1854, 83, 132, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(1855, 78, 133, '25.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(1856, 79, 133, '24.0000', '0.0000', '12.0000', '45.0000', 1, 1),
(1857, 80, 133, '20.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1858, 81, 133, '20.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(1859, 82, 133, '23.0000', '0.0000', '9.0000', '42.0000', 1, 1),
(1860, 83, 133, '24.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1861, 78, 129, '25.0000', '0.0000', '15.0000', '59.0000', 1, 1),
(1862, 79, 129, '23.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(1863, 80, 129, '19.0000', '0.0000', '12.0000', '46.0000', 1, 1),
(1864, 81, 129, '19.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1865, 82, 129, '23.0000', '0.0000', '14.0000', '57.0000', 1, 1),
(1866, 83, 129, '23.0000', '0.0000', '14.0000', '47.0000', 1, 1),
(1869, 91, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1870, 92, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1871, 93, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1872, 94, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1873, 95, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1874, 96, 43, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1875, 91, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1876, 92, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1877, 93, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1878, 94, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1879, 95, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1880, 96, 12, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1881, 78, 130, '24.0000', '0.0000', '13.0000', '59.0000', 1, 1),
(1882, 79, 130, '20.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(1883, 80, 130, '19.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(1884, 81, 130, '19.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1885, 82, 130, '22.0000', '0.0000', '10.0000', '56.0000', 1, 1),
(1886, 83, 130, '23.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1887, 78, 101, '20.0000', '0.0000', '7.0000', '43.0000', 1, 1),
(1888, 79, 101, '22.0000', '0.0000', '12.0000', '41.0000', 1, 1),
(1889, 80, 101, '22.0000', '0.0000', '5.0000', '38.0000', 1, 1),
(1890, 81, 101, '22.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1891, 82, 101, '20.0000', '0.0000', '6.0000', '43.0000', 1, 1),
(1892, 83, 101, '24.0000', '0.0000', '7.0000', '37.0000', 1, 1),
(1893, 78, 143, '25.0000', '0.0000', '7.0000', '46.0000', 1, 1),
(1894, 79, 143, '21.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1895, 80, 143, '19.0000', '0.0000', '15.0000', '42.0000', 1, 1),
(1896, 81, 143, '19.0000', '0.0000', '13.0000', '59.0000', 1, 1),
(1897, 82, 143, '22.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(1898, 83, 143, '23.0000', '0.0000', '9.0000', '48.0000', 1, 1),
(1899, 78, 126, '24.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(1900, 79, 126, '22.0000', '0.0000', '13.0000', '44.0000', 1, 1),
(1901, 80, 126, '21.0000', '0.0000', '13.0000', '44.0000', 1, 1),
(1902, 81, 126, '21.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1903, 82, 126, '22.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(1904, 83, 126, '24.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(1905, 78, 128, '5.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(1906, 79, 128, '10.0000', '0.0000', '5.0000', '-100.0000', 1, 1),
(1907, 80, 128, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(1908, 81, 128, '0.0000', '0.0000', '10.0000', '-100.0000', 1, 1),
(1909, 82, 128, '10.0000', '0.0000', '10.0000', '-100.0000', 1, 1),
(1910, 83, 128, '2.0000', '0.0000', '7.0000', '-100.0000', 1, 1),
(1911, 78, 125, '23.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(1912, 79, 125, '22.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(1913, 80, 125, '22.0000', '0.0000', '15.0000', '44.0000', 1, 1),
(1914, 81, 125, '22.0000', '0.0000', '14.0000', '51.0000', 1, 1),
(1915, 82, 125, '22.0000', '0.0000', '12.0000', '44.0000', 1, 1),
(1916, 83, 125, '23.0000', '0.0000', '10.0000', '45.0000', 1, 1),
(1917, 91, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1918, 92, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1919, 93, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1920, 94, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1921, 95, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1922, 96, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(1923, 91, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1924, 92, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1925, 93, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1926, 94, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1927, 95, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1928, 96, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(1929, 91, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1930, 92, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1931, 93, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1932, 94, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1933, 95, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1934, 96, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(1935, 91, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1936, 92, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1937, 93, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1938, 94, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1939, 95, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1940, 96, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1941, 91, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1942, 92, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1943, 93, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1944, 94, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1945, 95, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1946, 96, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(1947, 85, 65, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(1948, 86, 65, '23.0000', '0.0000', '12.0000', '49.0000', 1, 1),
(1949, 87, 65, '16.0000', '0.0000', '14.0000', '47.0000', 1, 1),
(1950, 88, 65, '22.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(1951, 89, 65, '24.0000', '0.0000', '14.0000', '35.0000', 1, 1),
(1952, 90, 65, '25.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(1953, 85, 67, '25.0000', '0.0000', '14.0000', '55.0000', 1, 1),
(1954, 86, 67, '21.0000', '0.0000', '11.0000', '31.0000', 1, 1),
(1955, 87, 67, '23.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(1956, 88, 67, '23.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(1957, 89, 67, '16.0000', '0.0000', '14.0000', '37.0000', 1, 1),
(1958, 90, 67, '25.0000', '0.0000', '15.0000', '48.0000', 1, 1),
(1959, 85, 61, '25.0000', '0.0000', '10.0000', '57.0000', 1, 1),
(1960, 86, 61, '21.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(1961, 87, 61, '20.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(1962, 88, 61, '23.0000', '0.0000', '13.0000', '46.0000', 1, 1),
(1963, 89, 61, '12.0000', '0.0000', '12.0000', '28.0000', 1, 1),
(1964, 90, 61, '25.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1965, 85, 68, '25.0000', '0.0000', '11.0000', '50.0000', 1, 1),
(1966, 86, 68, '21.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(1967, 87, 68, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1968, 88, 68, '22.0000', '0.0000', '11.0000', '25.0000', 1, 1),
(1970, 90, 68, '25.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(1971, 78, 123, '25.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(1972, 79, 123, '25.0000', '0.0000', '15.0000', '53.0000', 1, 1),
(1973, 80, 123, '21.0000', '0.0000', '10.0000', '42.0000', 1, 1),
(1974, 81, 123, '21.0000', '0.0000', '13.0000', '55.0000', 1, 1),
(1975, 82, 123, '23.0000', '0.0000', '11.0000', '54.0000', 1, 1),
(1976, 83, 123, '23.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(1977, 78, 79, '14.0000', '0.0000', '8.0000', '24.0000', 1, 1),
(1978, 79, 79, '10.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(1979, 80, 79, '21.0000', '0.0000', '5.0000', '24.0000', 1, 1),
(1980, 82, 79, '22.0000', '0.0000', '11.0000', '34.0000', 1, 1),
(1981, 91, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1982, 92, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1983, 93, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1984, 94, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1985, 95, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1986, 96, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(1987, 91, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1988, 92, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1989, 93, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1990, 94, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1991, 95, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1992, 96, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(1993, 91, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1994, 92, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1995, 93, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1996, 94, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1997, 95, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1998, 96, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(1999, 91, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2000, 92, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2001, 93, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2002, 94, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2003, 95, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2004, 96, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2005, 91, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2006, 92, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2007, 93, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2008, 94, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2009, 95, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2010, 96, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2011, 85, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2012, 86, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2013, 88, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2014, 90, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2015, 89, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2016, 87, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2017, 91, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2018, 92, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2019, 93, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2020, 94, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2021, 95, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2022, 96, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2023, 85, 81, '23.0000', '0.0000', '15.0000', '46.0000', 1, 1),
(2024, 86, 81, '21.0000', '0.0000', '9.0000', '43.0000', 1, 1),
(2025, 87, 81, '16.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(2026, 88, 81, '23.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2027, 89, 81, '24.0000', '0.0000', '14.0000', '28.0000', 1, 1),
(2028, 90, 81, '25.0000', '0.0000', '10.0000', '42.0000', 1, 1),
(2029, 85, 83, '23.0000', '0.0000', '14.0000', '60.0000', 1, 1),
(2030, 86, 83, '20.0000', '0.0000', '13.0000', '47.0000', 1, 1),
(2031, 87, 83, '16.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(2032, 88, 83, '23.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(2033, 89, 83, '24.0000', '0.0000', '14.0000', '38.0000', 1, 1),
(2034, 90, 83, '25.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(2035, 85, 80, '23.0000', '0.0000', '15.0000', '60.0000', 1, 1),
(2036, 86, 80, '22.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2037, 87, 80, '16.0000', '0.0000', '15.0000', '45.0000', 1, 1),
(2038, 88, 80, '25.0000', '0.0000', '15.0000', '57.0000', 1, 1),
(2039, 89, 80, '24.0000', '0.0000', '14.0000', '33.0000', 1, 1),
(2040, 90, 80, '25.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2041, 78, 138, '22.0000', '0.0000', '11.0000', '34.0000', 1, 1),
(2042, 79, 138, '22.0000', '0.0000', '10.0000', '44.0000', 1, 1),
(2043, 80, 138, '17.0000', '0.0000', '10.0000', '50.0000', 1, 1),
(2044, 81, 138, '15.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2045, 82, 138, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2046, 83, 138, '25.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(2047, 78, 110, '24.0000', '0.0000', '14.0000', '59.0000', 1, 1),
(2048, 79, 110, '22.0000', '0.0000', '12.0000', '49.0000', 1, 1),
(2049, 80, 110, '20.0000', '0.0000', '10.0000', '50.0000', 1, 1),
(2050, 81, 110, '20.0000', '0.0000', '13.0000', '57.0000', 1, 1),
(2051, 82, 110, '24.0000', '0.0000', '10.0000', '56.0000', 1, 1),
(2052, 83, 110, '24.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2053, 78, 111, '23.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(2054, 79, 111, '19.0000', '0.0000', '9.0000', '46.0000', 1, 1),
(2055, 80, 111, '24.0000', '0.0000', '15.0000', '44.0000', 1, 1),
(2056, 81, 111, '24.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2057, 82, 111, '24.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(2058, 83, 111, '23.0000', '0.0000', '12.0000', '53.0000', 1, 1),
(2059, 78, 108, '25.0000', '0.0000', '11.0000', '58.0000', 1, 1),
(2060, 79, 108, '23.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(2061, 80, 108, '24.0000', '0.0000', '15.0000', '36.0000', 1, 1),
(2062, 81, 108, '24.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(2063, 82, 108, '22.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2064, 83, 108, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2065, 78, 109, '25.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(2066, 79, 109, '20.0000', '0.0000', '11.0000', '40.0000', 1, 1),
(2067, 80, 109, '20.0000', '0.0000', '7.0000', '36.0000', 1, 1),
(2068, 81, 109, '20.0000', '0.0000', '13.0000', '50.0000', 1, 1),
(2069, 82, 109, '24.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(2070, 83, 109, '24.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(2071, 78, 73, '23.0000', '0.0000', '15.0000', '59.0000', 1, 1),
(2072, 79, 73, '20.0000', '0.0000', '10.0000', '42.0000', 1, 1),
(2075, 82, 73, '24.0000', '0.0000', '9.0000', '58.0000', 1, 1),
(2076, 83, 73, '23.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(2077, 78, 114, '23.0000', '0.0000', '15.0000', '38.0000', 1, 1),
(2078, 79, 114, '20.0000', '0.0000', '11.0000', '43.0000', 1, 1),
(2079, 80, 114, '19.0000', '0.0000', '7.0000', '38.0000', 1, 1),
(2080, 81, 114, '17.0000', '0.0000', '12.0000', '43.0000', 1, 1),
(2081, 82, 114, '23.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(2082, 83, 114, '23.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(2083, 78, 115, '22.0000', '0.0000', '14.0000', '58.0000', 1, 1),
(2084, 79, 115, '21.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2085, 81, 115, '22.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(2086, 82, 115, '23.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(2087, 83, 115, '24.0000', '0.0000', '8.0000', '51.0000', 1, 1),
(2088, 80, 115, '22.0000', '0.0000', '13.0000', '46.0000', 1, 1),
(2089, 78, 116, '23.0000', '0.0000', '5.0000', '46.0000', 1, 1),
(2090, 79, 116, '22.0000', '0.0000', '13.0000', '37.0000', 1, 1),
(2091, 80, 116, '19.0000', '0.0000', '6.0000', '44.0000', 1, 1),
(2092, 81, 116, '19.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2093, 82, 116, '23.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(2094, 83, 116, '23.0000', '0.0000', '12.0000', '43.0000', 1, 1),
(2095, 78, 117, '24.0000', '0.0000', '13.0000', '58.0000', 1, 1),
(2096, 79, 117, '21.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2097, 80, 117, '18.0000', '0.0000', '8.0000', '48.0000', 1, 1),
(2098, 81, 117, '18.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(2099, 82, 117, '23.0000', '0.0000', '10.0000', '41.0000', 1, 1),
(2100, 83, 117, '24.0000', '0.0000', '13.0000', '43.0000', 1, 1),
(2101, 78, 145, '16.0000', '0.0000', '8.0000', '39.0000', 1, 1),
(2102, 79, 145, '23.0000', '0.0000', '8.0000', '26.0000', 1, 1),
(2103, 80, 145, '22.0000', '0.0000', '10.0000', '30.0000', 1, 1),
(2104, 81, 145, '22.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2105, 82, 145, '24.0000', '0.0000', '12.0000', '45.0000', 1, 1),
(2106, 83, 145, '23.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(2107, 91, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2108, 92, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2109, 93, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2110, 94, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2111, 95, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2112, 96, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2113, 91, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2114, 92, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2115, 93, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2116, 94, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2117, 95, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2118, 96, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2119, 91, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2120, 92, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2121, 93, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2122, 94, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2123, 95, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2124, 96, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2125, 91, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2126, 92, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2127, 93, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2128, 94, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2129, 95, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2130, 96, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2131, 91, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2132, 92, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2133, 93, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2134, 94, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2135, 95, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2136, 96, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2137, 91, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2138, 92, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2139, 93, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2140, 94, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2141, 95, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2142, 96, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2143, 91, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2144, 92, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2145, 93, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2146, 94, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2147, 95, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2148, 96, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2149, 85, 69, '25.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2150, 86, 69, '22.0000', '0.0000', '9.0000', '51.0000', 1, 1),
(2151, 87, 69, '25.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2152, 88, 69, '24.0000', '0.0000', '11.0000', '54.0000', 1, 1),
(2153, 89, 69, '12.0000', '0.0000', '12.0000', '36.0000', 1, 1),
(2154, 90, 69, '25.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2155, 85, 70, '25.0000', '0.0000', '12.0000', '54.0000', 1, 1),
(2156, 86, 70, '21.0000', '0.0000', '12.0000', '54.0000', 1, 1),
(2157, 87, 70, '23.0000', '0.0000', '14.0000', '58.0000', 1, 1),
(2158, 88, 70, '22.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(2159, 89, 70, '24.0000', '0.0000', '14.0000', '39.0000', 1, 1),
(2160, 90, 70, '25.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2161, 85, 71, '25.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2162, 86, 71, '20.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(2163, 87, 71, '23.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2164, 88, 71, '21.0000', '0.0000', '10.0000', '48.0000', 1, 1),
(2165, 84, 71, '25.0000', '0.0000', '15.0000', '43.0000', 1, 1),
(2166, 90, 71, '25.0000', '0.0000', '11.0000', '41.0000', 1, 1),
(2167, 85, 72, '25.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(2168, 86, 72, '23.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2169, 87, 72, '23.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(2170, 88, 72, '23.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(2171, 89, 72, '16.0000', '0.0000', '14.0000', '39.0000', 1, 1),
(2172, 90, 72, '25.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2173, 78, 113, '25.0000', '0.0000', '15.0000', '60.0000', 1, 1),
(2174, 79, 113, '23.0000', '0.0000', '10.0000', '43.0000', 1, 1),
(2175, 80, 113, '20.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(2176, 81, 113, '20.0000', '0.0000', '14.0000', '58.0000', 1, 1),
(2177, 82, 113, '23.0000', '0.0000', '12.0000', '51.0000', 1, 1),
(2178, 83, 113, '23.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2179, 82, 95, '22.0000', '0.0000', '9.0000', '40.0000', 1, 1),
(2180, 86, 95, '21.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(2181, 87, 95, '23.0000', '0.0000', '14.0000', '45.0000', 1, 1),
(2182, 88, 95, '23.0000', '0.0000', '12.0000', '35.0000', 1, 1),
(2189, 91, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2190, 92, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2191, 93, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2192, 94, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2193, 95, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2194, 96, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2195, 78, 141, '25.0000', '0.0000', '11.0000', '58.0000', 1, 1),
(2196, 79, 141, '23.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(2197, 80, 141, '25.0000', '0.0000', '14.0000', '38.0000', 1, 1),
(2198, 81, 141, '25.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(2199, 82, 141, '23.0000', '0.0000', '11.0000', '56.0000', 1, 1),
(2200, 83, 141, '24.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(2201, 78, 140, '25.0000', '0.0000', '15.0000', '55.0000', 1, 1),
(2202, 79, 140, '23.0000', '0.0000', '15.0000', '43.0000', 1, 1),
(2203, 80, 140, '22.0000', '0.0000', '8.0000', '44.0000', 1, 1),
(2204, 81, 140, '22.0000', '0.0000', '15.0000', '47.0000', 1, 1),
(2205, 82, 140, '22.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(2206, 83, 140, '24.0000', '0.0000', '14.0000', '49.0000', 1, 1),
(2207, 78, 142, '25.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2208, 79, 142, '24.0000', '0.0000', '15.0000', '45.0000', 1, 1),
(2209, 80, 142, '22.0000', '0.0000', '15.0000', '46.0000', 1, 1),
(2210, 81, 142, '22.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(2211, 82, 142, '24.0000', '0.0000', '11.0000', '59.0000', 1, 1),
(2212, 83, 142, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2213, 78, 135, '9.0000', '0.0000', '2.0000', '34.0000', 1, 1),
(2214, 79, 135, '21.0000', '0.0000', '5.0000', '18.0000', 1, 1),
(2215, 80, 135, '19.0000', '0.0000', '10.0000', '24.0000', 1, 1),
(2216, 81, 135, '19.0000', '0.0000', '11.0000', '31.0000', 1, 1),
(2217, 82, 135, '22.0000', '0.0000', '9.0000', '30.0000', 1, 1),
(2218, 83, 135, '22.0000', '0.0000', '9.0000', '24.0000', 1, 1),
(2219, 78, 94, '20.0000', '0.0000', '10.0000', '45.0000', 1, 1),
(2220, 80, 94, '20.0000', '0.0000', '6.0000', '36.0000', 1, 1),
(2221, 90, 94, '25.0000', '0.0000', '11.0000', '41.0000', 1, 1),
(2222, 84, 94, '22.0000', '0.0000', '8.0000', '38.0000', 1, 1),
(2223, 85, 90, '25.0000', '0.0000', '7.0000', '54.0000', 1, 1),
(2224, 86, 90, '22.0000', '0.0000', '11.0000', '48.0000', 1, 1),
(2225, 87, 90, '23.0000', '0.0000', '13.0000', '50.0000', 1, 1),
(2226, 88, 90, '20.0000', '0.0000', '12.0000', '44.0000', 1, 1),
(2227, 89, 90, '24.0000', '0.0000', '14.0000', '37.0000', 1, 1),
(2228, 90, 90, '25.0000', '0.0000', '9.0000', '41.0000', 1, 1),
(2229, 85, 93, '25.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(2230, 86, 93, '24.0000', '0.0000', '10.0000', '47.0000', 1, 1),
(2231, 87, 93, '24.0000', '0.0000', '14.0000', '54.0000', 1, 1),
(2232, 88, 93, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2233, 89, 93, '24.0000', '0.0000', '14.0000', '33.0000', 1, 1),
(2234, 90, 93, '25.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2235, 91, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2236, 92, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2237, 93, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2238, 94, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2239, 95, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2240, 96, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2241, 91, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2242, 92, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2243, 93, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2244, 94, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2245, 95, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2246, 96, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2247, 78, 134, '25.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2248, 79, 134, '21.0000', '0.0000', '10.0000', '34.0000', 1, 1),
(2249, 80, 134, '20.0000', '0.0000', '7.0000', '38.0000', 1, 1),
(2250, 81, 134, '20.0000', '0.0000', '13.0000', '50.0000', 1, 1),
(2251, 82, 134, '23.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(2252, 83, 134, '24.0000', '0.0000', '14.0000', '50.0000', 1, 1),
(2253, 85, 91, '23.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2254, 86, 91, '21.0000', '0.0000', '10.0000', '41.0000', 1, 1),
(2255, 87, 91, '23.0000', '0.0000', '12.0000', '44.0000', 1, 1),
(2256, 88, 91, '23.0000', '0.0000', '15.0000', '51.0000', 1, 1),
(2257, 89, 91, '24.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2258, 90, 91, '25.0000', '0.0000', '10.0000', '40.0000', 1, 1),
(2259, 91, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2260, 92, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2261, 93, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2262, 94, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2263, 95, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2264, 96, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2265, 78, 105, '23.0000', '0.0000', '8.0000', '46.0000', 1, 1),
(2266, 79, 105, '21.0000', '0.0000', '7.0000', '35.0000', 1, 1),
(2267, 80, 105, '20.0000', '0.0000', '10.0000', '38.0000', 1, 1),
(2268, 81, 105, '17.0000', '0.0000', '11.0000', '50.0000', 1, 1),
(2269, 82, 105, '24.0000', '0.0000', '10.0000', '56.0000', 1, 1),
(2270, 83, 105, '24.0000', '0.0000', '13.0000', '47.0000', 1, 1),
(2271, 78, 102, '22.0000', '0.0000', '12.0000', '59.0000', 1, 1),
(2272, 79, 102, '19.0000', '0.0000', '15.0000', '31.0000', 1, 1),
(2273, 80, 102, '21.0000', '0.0000', '12.0000', '42.0000', 1, 1),
(2274, 81, 102, '21.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2275, 82, 102, '24.0000', '0.0000', '12.0000', '57.0000', 1, 1),
(2276, 83, 102, '25.0000', '0.0000', '10.0000', '51.0000', 1, 1),
(2277, 78, 100, '22.0000', '0.0000', '7.0000', '41.0000', 1, 1),
(2278, 79, 100, '20.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2279, 80, 100, '21.0000', '0.0000', '7.0000', '40.0000', 1, 1),
(2280, 81, 100, '20.0000', '0.0000', '10.0000', '43.0000', 1, 1),
(2281, 82, 100, '24.0000', '0.0000', '11.0000', '52.0000', 1, 1),
(2282, 83, 100, '23.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2283, 85, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2284, 86, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2285, 87, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2286, 88, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2287, 92, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2288, 93, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2289, 91, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2290, 92, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2291, 93, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2292, 94, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2293, 95, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2294, 96, 10, '24.0000', '0.0000', '13.0000', '51.0000', 1, 1),
(2295, 91, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2296, 92, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2297, 93, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2298, 94, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2299, 95, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2300, 96, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2301, 85, 62, '25.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(2302, 86, 62, '22.0000', '0.0000', '9.0000', '46.0000', 1, 1),
(2303, 87, 62, '25.0000', '0.0000', '8.0000', '44.0000', 1, 1),
(2304, 88, 62, '23.0000', '0.0000', '13.0000', '43.0000', 1, 1),
(2305, 89, 62, '15.0000', '0.0000', '5.0000', '22.0000', 1, 1),
(2306, 90, 62, '25.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2307, 85, 60, '25.0000', '0.0000', '14.0000', '51.0000', 1, 1),
(2308, 86, 60, '22.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2309, 87, 60, '23.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(2310, 88, 60, '22.0000', '0.0000', '12.0000', '50.0000', 1, 1),
(2311, 89, 60, '24.0000', '0.0000', '14.0000', '27.0000', 1, 1),
(2312, 90, 60, '25.0000', '0.0000', '10.0000', '52.0000', 1, 1),
(2313, 85, 64, '25.0000', '0.0000', '8.0000', '59.0000', 1, 1),
(2314, 86, 64, '22.0000', '0.0000', '8.0000', '38.0000', 1, 1),
(2315, 87, 64, '23.0000', '0.0000', '12.0000', '52.0000', 1, 1),
(2316, 88, 64, '22.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2317, 89, 64, '12.0000', '0.0000', '14.0000', '22.0000', 1, 1),
(2318, 90, 64, '25.0000', '0.0000', '8.0000', '47.0000', 1, 1),
(2319, 91, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2320, 92, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2321, 93, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2322, 94, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2323, 95, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2324, 96, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2325, 91, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2326, 92, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2327, 93, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2328, 94, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2329, 95, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2330, 96, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2331, 85, 58, '25.0000', '0.0000', '12.0000', '54.0000', 1, 1),
(2332, 86, 58, '25.0000', '0.0000', '12.0000', '42.0000', 1, 1),
(2333, 87, 58, '24.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(2334, 88, 58, '24.0000', '0.0000', '15.0000', '50.0000', 1, 1),
(2335, 89, 58, '12.0000', '0.0000', '14.0000', '35.0000', 1, 1),
(2336, 90, 58, '25.0000', '0.0000', '12.0000', '51.0000', 1, 1),
(2337, 78, 137, '25.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2338, 79, 137, '19.0000', '0.0000', '9.0000', '29.0000', 1, 1),
(2339, 80, 137, '20.0000', '0.0000', '10.0000', '40.0000', 1, 1),
(2340, 81, 137, '20.0000', '0.0000', '14.0000', '46.0000', 1, 1),
(2341, 82, 137, '23.0000', '0.0000', '10.0000', '49.0000', 1, 1),
(2342, 83, 137, '25.0000', '0.0000', '8.0000', '38.0000', 1, 1),
(2343, 78, 98, '25.0000', '0.0000', '7.0000', '51.0000', 1, 1),
(2344, 79, 98, '21.0000', '0.0000', '15.0000', '40.0000', 1, 1),
(2345, 80, 98, '22.0000', '0.0000', '6.0000', '36.0000', 1, 1),
(2346, 81, 98, '20.0000', '0.0000', '12.0000', '39.0000', 1, 1),
(2347, 82, 98, '24.0000', '0.0000', '9.0000', '40.0000', 1, 1),
(2348, 83, 98, '24.0000', '0.0000', '11.0000', '47.0000', 1, 1),
(2349, NULL, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2350, 78, 107, '25.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2351, 79, 107, '24.0000', '0.0000', '11.0000', '39.0000', 1, 1),
(2352, 80, 107, '23.0000', '0.0000', '10.0000', '42.0000', 1, 1),
(2353, 81, 107, '23.0000', '0.0000', '13.0000', '52.0000', 1, 1),
(2354, 82, 107, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2355, 83, 107, '23.0000', '0.0000', '12.0000', '51.0000', 1, 1),
(2356, 78, 124, '25.0000', '0.0000', '11.0000', '58.0000', 1, 1),
(2362, 79, 124, '23.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(2363, 80, 124, '18.0000', '0.0000', '7.0000', '42.0000', 1, 1),
(2364, 81, 124, '18.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2365, 82, 124, '22.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(2366, 83, 124, '25.0000', '0.0000', '11.0000', '52.0000', 1, 1),
(2367, 91, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2368, 92, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2369, 93, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2370, 94, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2371, 95, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2372, 96, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2373, 78, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2374, 79, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2375, 80, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2376, 81, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2377, 82, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2378, 83, 118, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2379, 85, 76, '24.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2380, 86, 76, '21.0000', '0.0000', '9.0000', '46.0000', 1, 1),
(2381, 87, 76, '23.0000', '0.0000', '14.0000', '44.0000', 1, 1),
(2382, 88, 76, '24.0000', '0.0000', '15.0000', '51.0000', 1, 1),
(2383, 89, 76, '16.0000', '0.0000', '14.0000', '36.0000', 1, 1),
(2384, 90, 76, '25.0000', '0.0000', '15.0000', '41.0000', 1, 1),
(2385, 86, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(2386, 89, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(2387, 92, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(2388, 96, 47, '23.0000', '0.0000', '6.0000', '27.0000', 1, 1),
(2389, 84, 68, '25.0000', '0.0000', '9.0000', '41.0000', 1, 1),
(2390, 91, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2391, 92, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2392, 93, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2393, 96, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2394, 84, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2395, 78, 146, '23.0000', '0.0000', '15.0000', '56.0000', 1, 1),
(2396, 79, 146, '15.0000', '0.0000', '10.0000', '33.0000', 1, 1),
(2397, 80, 146, '20.0000', '0.0000', '7.0000', '44.0000', 1, 1),
(2398, 81, 146, '20.0000', '0.0000', '12.0000', '48.0000', 1, 1),
(2399, 82, 146, '24.0000', '0.0000', '12.0000', '55.0000', 1, 1),
(2400, 83, 146, '22.0000', '0.0000', '11.0000', '49.0000', 1, 1),
(2401, 78, 147, '24.0000', '0.0000', '15.0000', '58.0000', 1, 1),
(2402, 79, 147, '23.0000', '0.0000', '12.0000', '47.0000', 1, 1),
(2403, 80, 147, '22.0000', '0.0000', '8.0000', '52.0000', 1, 1),
(2404, 81, 147, '22.0000', '0.0000', '13.0000', '54.0000', 1, 1),
(2405, 82, 147, '25.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2406, 83, 147, '25.0000', '0.0000', '14.0000', '55.0000', 1, 1),
(2407, 98, 73, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2408, 98, 85, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2409, 98, 92, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2410, 98, 89, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2411, 99, 89, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2412, 99, 92, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2414, 99, 85, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2415, 97, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2416, 100, 73, '0.0000', '0.0000', '0.0000', '-100.0000', 1, 1),
(2418, 113, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2419, 114, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2420, 115, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2421, 117, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2422, 120, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2423, 124, 15, '18.0000', '0.0000', '6.0000', '17.0000', 1, 1),
(2424, 113, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2425, 114, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2426, 115, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2427, 116, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2428, 117, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2429, 120, 23, '18.0000', '0.0000', '12.0000', '27.0000', 1, 1),
(2430, 113, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2431, 114, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2432, 115, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2433, 116, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2434, 117, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2435, 120, 24, '22.0000', '0.0000', '11.0000', '35.0000', 1, 1),
(2436, 113, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2437, 121, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2438, 122, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2439, 116, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2440, 123, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2441, 120, 25, '24.0000', '0.0000', '13.0000', '53.0000', 1, 1),
(2442, 113, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2443, 121, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2444, 122, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2445, 116, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2446, 123, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2447, 120, 26, '20.0000', '0.0000', '15.0000', '54.0000', 1, 1),
(2448, 113, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2449, 121, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2450, 122, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2451, 116, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2452, 123, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2453, 120, 27, '24.0000', '0.0000', '13.0000', '45.0000', 1, 1),
(2454, 113, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2455, 114, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2456, 115, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2457, 116, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2458, 117, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2459, 120, 28, '19.0000', '0.0000', '5.0000', '36.0000', 1, 1),
(2460, 107, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2461, 108, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2462, 110, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2463, 111, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2464, 112, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2465, 109, 69, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2466, 107, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2467, 108, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2468, 110, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2469, 111, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2470, 112, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2471, 109, 70, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2472, 107, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 2, 1),
(2473, 108, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2474, 107, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2475, 107, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2476, 108, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2477, 110, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2478, 111, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2479, 109, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2480, 124, 71, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2481, 107, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2482, 108, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2483, 110, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2484, 111, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2485, 112, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2486, 109, 72, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2487, 101, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2488, 102, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2489, 103, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2490, 104, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2491, 106, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2492, 105, 73, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2493, 101, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2494, 102, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2495, 103, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2496, 104, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2497, 105, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2498, 106, 113, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2499, 101, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2500, 102, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2501, 103, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2502, 104, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2503, 105, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2504, 106, 114, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2505, 101, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2506, 102, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2507, 103, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2508, 104, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2509, 105, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2510, 106, 115, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2511, 101, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2512, 102, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2513, 103, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2514, 104, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2515, 105, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2516, 106, 116, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2517, 101, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2518, 102, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2519, 103, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2520, 104, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2521, 105, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2522, 106, 117, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2523, 101, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2524, 102, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2525, 103, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2526, 104, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2527, 105, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2528, 106, 145, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2529, 101, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2530, 102, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2531, 103, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2532, 104, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2533, 105, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2534, 106, 111, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2535, 101, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2536, 102, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2537, 103, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2538, 104, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2539, 105, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2540, 106, 110, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2541, 101, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2542, 102, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2543, 103, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2544, 104, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2545, 105, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2546, 106, 109, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2547, 101, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2548, 102, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2549, 103, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2550, 104, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2551, 105, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2552, 106, 108, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2553, 101, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2554, 102, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2555, 103, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2556, 104, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2557, 105, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2558, 106, 138, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2559, 107, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2560, 108, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2561, 110, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2562, 124, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2563, 111, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2564, 109, 40, '22.0000', '0.0000', '11.0000', '37.0000', 1, 1),
(2565, 113, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2566, 121, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2567, 122, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2568, 116, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2569, 123, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2570, 120, 39, '23.0000', '0.0000', '13.0000', '41.0000', 1, 1),
(2571, 107, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2572, 108, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2573, 110, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2574, 111, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2575, 112, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2576, 109, 81, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2577, 113, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2578, 114, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1);
INSERT INTO `registration` (`ID`, `Course_semesterID`, `StudentID`, `YearWork`, `Practical`, `MidTermExam`, `FinalExam`, `statusID`, `AdvisorApprovalID`) VALUES
(2579, 115, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2580, 116, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2581, 117, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2582, 120, 36, '22.0000', '0.0000', '13.0000', '38.0000', 1, 1),
(2583, 107, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2584, 108, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2585, 110, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2586, 111, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2587, 112, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2588, 109, 83, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2589, 107, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2590, 108, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2591, 110, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2592, 111, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2593, 112, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2594, 109, 80, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2595, 113, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2596, 121, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2597, 122, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2598, 116, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2599, 123, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2600, 120, 37, '22.0000', '0.0000', '13.0000', '48.0000', 1, 1),
(2601, 113, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2602, 121, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2603, 122, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2604, 116, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2605, 123, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2606, 120, 38, '19.0000', '0.0000', '9.0000', '44.0000', 1, 1),
(2607, 113, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2608, 121, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2609, 122, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2610, 116, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2611, 123, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2612, 120, 13, '23.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2613, 113, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2614, 114, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2615, 115, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2616, 116, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2617, 117, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2618, 120, 42, '18.0000', '0.0000', '8.0000', '37.0000', 1, 1),
(2619, 104, 79, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2620, 106, 79, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2621, 105, 79, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2622, 126, 79, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2623, 113, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2624, 114, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2625, 115, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2626, 116, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2627, 117, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2628, 120, 20, '23.0000', '0.0000', '14.0000', '48.0000', 1, 1),
(2629, 113, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2630, 121, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2631, 122, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2632, 116, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2633, 123, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2634, 120, 17, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2635, 113, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2636, 114, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2637, 115, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2638, 116, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2639, 117, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2640, 120, 21, '19.0000', '0.0000', '7.0000', '32.0000', 1, 1),
(2641, 107, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2642, 108, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2643, 110, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2644, 111, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2645, 109, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2646, 124, 68, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2647, 101, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2648, 102, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2649, 103, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2650, 104, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2651, 106, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2652, 105, 125, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2653, 101, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2654, 102, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2655, 103, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2656, 105, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2657, 104, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2658, 106, 123, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2659, 101, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2660, 102, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2661, 103, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2662, 104, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2663, 105, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2664, 106, 126, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2665, 101, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2666, 102, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2667, 103, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2668, 104, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2669, 105, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2670, 106, 143, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2671, 101, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2672, 102, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2673, 103, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2674, 104, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2675, 105, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2676, 106, 124, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2677, 107, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2678, 108, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2679, 109, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2680, 110, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2681, 111, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2682, 112, 61, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2683, 107, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2684, 108, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2685, 110, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2686, 111, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2687, 112, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2688, 109, 67, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2689, 107, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2690, 108, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2691, 110, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2692, 111, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2693, 112, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2694, 109, 65, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2695, 113, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2696, 114, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2697, 115, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2698, 116, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2699, 117, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2700, 120, 19, '20.0000', '0.0000', '8.0000', '43.0000', 1, 1),
(2701, 113, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2702, 121, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2703, 122, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2704, 116, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2705, 123, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2706, 120, 18, '24.0000', '0.0000', '8.0000', '42.0000', 1, 1),
(2707, 107, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2708, 108, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2709, 110, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2710, 111, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2711, 109, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2712, 124, 64, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2713, 113, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2714, 114, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2715, 120, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2716, 107, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2717, 108, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2718, 112, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2719, 101, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2720, 102, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2721, 103, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2722, 104, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2723, 105, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2724, 106, 98, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2725, 113, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2726, 121, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2727, 122, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2728, 116, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2729, 123, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2730, 120, 6, '23.0000', '0.0000', '11.0000', '53.0000', 1, 1),
(2731, 107, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2732, 108, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2733, 110, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2734, 111, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2735, 109, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2736, 124, 62, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2737, 113, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2738, 114, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2739, 115, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2740, 116, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2741, 117, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2742, 120, 1, '20.0000', '0.0000', '11.0000', '46.0000', 1, 1),
(2743, 107, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2744, 108, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2745, 110, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2746, 111, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2747, 112, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2748, 109, 60, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2749, 101, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2750, 102, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2751, 103, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2752, 104, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2753, 105, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2754, 106, 137, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2755, 101, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2756, 102, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2757, 103, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2758, 104, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2759, 105, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2760, 106, 105, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2761, 113, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2762, 114, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2763, 115, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2764, 116, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2765, 117, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2766, 120, 9, '18.0000', '0.0000', '6.0000', '35.0000', 1, 1),
(2767, 113, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2768, 121, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2769, 122, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2770, 116, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2771, 123, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2772, 120, 7, '22.0000', '0.0000', '10.0000', '46.0000', 1, 1),
(2773, 113, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2774, 114, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2775, 115, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2776, 116, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2777, 117, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2778, 120, 8, '23.0000', '0.0000', '9.0000', '47.0000', 1, 1),
(2779, 113, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2780, 121, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2781, 122, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2782, 116, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2783, 123, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2784, 120, 5, '24.0000', '0.0000', '14.0000', '53.0000', 1, 1),
(2785, 101, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2786, 102, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2787, 103, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2788, 104, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2789, 105, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2790, 106, 107, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2791, 101, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2792, 102, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2793, 103, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2794, 104, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2795, 105, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2796, 106, 100, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2797, 101, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2798, 102, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2799, 103, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2800, 104, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2801, 105, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2802, 106, 102, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2803, 107, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2804, 108, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2805, 110, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2806, 111, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2807, 112, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2808, 109, 58, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2809, 101, 94, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2810, 111, 94, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2811, 109, 94, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2812, 124, 94, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2813, 113, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2814, 114, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2815, 115, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2816, 116, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2817, 117, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2818, 120, 11, '23.0000', '0.0000', '14.0000', '56.0000', 1, 1),
(2819, 113, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2820, 114, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2821, 115, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2822, 116, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2823, 117, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2824, 120, 50, '22.0000', '0.0000', '14.0000', '52.0000', 1, 1),
(2825, 113, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2826, 114, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2827, 115, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2828, 124, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2829, 120, 54, '20.0000', '0.0000', '12.0000', '22.0000', 1, 1),
(2830, 113, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2831, 114, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2832, 115, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2833, 116, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2834, 121, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2835, 120, 57, '19.0000', '0.0000', '7.0000', '24.0000', 1, 1),
(2836, 107, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2837, 108, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2838, 110, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2839, 111, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2840, 112, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2841, 109, 90, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2842, 107, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2843, 108, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2844, 110, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2845, 111, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2846, 112, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2847, 109, 91, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2848, 107, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2849, 108, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2850, 110, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2851, 111, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2852, 112, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2853, 109, 93, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2854, 102, 95, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2855, 104, 95, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2856, 106, 95, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2857, 108, 95, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2858, 101, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2859, 102, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2860, 103, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2861, 104, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2862, 105, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2863, 106, 134, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2864, 103, 135, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2865, 104, 135, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2866, 106, 135, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2867, 105, 135, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2868, 101, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2869, 102, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2870, 103, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2871, 104, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2872, 106, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2873, 105, 140, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2874, 101, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2875, 102, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2876, 103, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2877, 104, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2878, 105, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2879, 106, 141, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2880, 101, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2881, 102, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2882, 103, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2883, 104, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2884, 106, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2885, 105, 142, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2886, 101, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2887, 102, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2888, 103, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2889, 104, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2890, 105, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2891, 106, 146, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2892, 101, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2893, 102, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2894, 103, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2895, 104, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2896, 105, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2897, 106, 147, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2898, 113, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2899, 121, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2900, 122, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2901, 116, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2902, 123, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2903, 120, 35, '23.0000', '0.0000', '13.0000', '42.0000', 1, 1),
(2904, 107, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2905, 108, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2906, 110, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2907, 111, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2908, 109, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2909, 107, 78, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2910, 108, 78, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2911, 110, 78, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2912, 111, 78, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2913, 109, 78, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2914, 113, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2915, 121, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2916, 122, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2917, 116, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2918, 123, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2919, 120, 14, '20.0000', '0.0000', '9.0000', '39.0000', 1, 1),
(2920, 101, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2921, 102, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2922, 103, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2923, 104, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2924, 105, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2925, 106, 144, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2926, 101, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2927, 102, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2928, 103, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2929, 104, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2930, 105, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2931, 106, 121, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2932, 101, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2933, 102, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2934, 103, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2935, 104, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2936, 105, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2937, 106, 120, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2938, 101, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2939, 102, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2940, 103, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2941, 104, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2942, 105, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2943, 106, 122, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2944, 107, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2945, 108, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2946, 110, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2947, 111, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2948, 112, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2949, 109, 77, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2950, 113, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2951, 114, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2952, 115, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2953, 116, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2954, 117, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2955, 120, 29, '20.0000', '0.0000', '11.0000', '51.0000', 1, 1),
(2956, 107, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2957, 108, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2958, 110, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2959, 111, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2960, 112, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2961, 109, 74, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2962, 113, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2963, 114, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2964, 115, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2965, 116, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2966, 117, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2967, 120, 33, '20.0000', '0.0000', '8.0000', '45.0000', 1, 1),
(2968, 113, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2969, 114, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2970, 115, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2971, 116, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2972, 117, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2973, 120, 31, '23.0000', '0.0000', '11.0000', '44.0000', 1, 1),
(2974, 101, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2975, 102, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2976, 103, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2977, 104, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2978, 106, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2979, 105, 119, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2980, 113, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2981, 121, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2982, 122, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2983, 116, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2984, 123, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2985, 120, 34, '23.0000', '0.0000', '13.0000', '34.0000', 1, 1),
(2986, 107, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2987, 108, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2988, 110, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2989, 111, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2990, 112, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2991, 109, 76, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1),
(2992, 124, 75, '0.0000', '0.0000', '0.0000', '-300.0000', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `runsqlquery`
--

CREATE TABLE `runsqlquery` (
  `RunSQLid` int(11) DEFAULT NULL,
  `ID` int(11) DEFAULT NULL,
  `RunSQLQueryTxt` mediumtext,
  `CommentDisplayed` varchar(255) DEFAULT NULL,
  `Done` bit(1) DEFAULT NULL,
  `VersionDate` varchar(255) DEFAULT NULL,
  `VersionNo` float DEFAULT NULL,
  `ForceRunning` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `runsqlquery`
--

INSERT INTO `runsqlquery` (`RunSQLid`, `ID`, `RunSQLQueryTxt`, `CommentDisplayed`, `Done`, `VersionDate`, `VersionNo`, `ForceRunning`) VALUES
(1, 0, 'UPDATE Semester SET Semester.StatusID = 2;', 'حماية بيانات الترم', b'1', NULL, 1.2, b'0'),
(2, 0, 'UPDATE Semester SET Semester.StatusID = 1\r\nWHERE (((Semester.Semester)=\"Spring2018\"));', 'فتح اخر ترم', b'1', NULL, 1.2, b'0'),
(3, 0, 'UPDATE student SET student.MilitaryEducationID = 1\r\nWHERE (((student.GenderID)=1))', NULL, b'1', NULL, 1.2, b'0'),
(4, 0, 'UPDATE student SET student.MilitaryEducationID = 2\r\nWHERE (((student.GenderID)=2));', 'اضافة التربية العسكرية', b'1', NULL, 1.2, b'0'),
(5, 0, 'UPDATE Course SET Course.CurriculumID = 1\r\nWHERE (((Course.CurriculumID) Is Null));', 'اضافة الائحة', b'1', NULL, 1.4, b'0'),
(6, 0, 'UPDATE student SET student.CurriculumID = 1\r\nWHERE (((student.CurriculumID) Is Null));', NULL, b'1', NULL, 1.4, b'0'),
(7, 0, 'UPDATE Registration SET Registration.AdvisorApprovalID = 2\r\nWHERE (((Registration.AdvisorApprovalID) Is Null));', 'Add approval status', b'1', NULL, 1.4, b'0'),
(8, 0, 'UPDATE Course_Grade SET Course_Grade.CurriculumID = 1\r\nWHERE (((Course_Grade.semesterID)<8));', 'اضافة الائحة الى التقديرات', b'1', NULL, 1.5, b'0');

-- --------------------------------------------------------

--
-- Table structure for table `screen`
--

CREATE TABLE `screen` (
  `id` int(11) DEFAULT NULL,
  `ScreenCodeName` varchar(255) DEFAULT NULL,
  `ScreenArabicName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `screen`
--

INSERT INTO `screen` (`id`, `ScreenCodeName`, `ScreenArabicName`) VALUES
(1, 'StudentAffairs', 'قسم شئون الطلاب'),
(2, 'Semesters', 'قسم الارشاد الأكاديمى'),
(3, 'Settings', 'الخصائص'),
(4, 'CleanUpDB', 'ادارة المعلومات');

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `ID` int(11) NOT NULL,
  `Semester` varchar(255) DEFAULT NULL,
  `SemesterFullName` varchar(255) DEFAULT NULL,
  `SemesterArabicName` varchar(255) DEFAULT NULL,
  `SemesterEnumID` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`ID`, `Semester`, `SemesterFullName`, `SemesterArabicName`, `SemesterEnumID`, `StatusID`) VALUES
(1, 'Fall2016', 'الفصل الدراسى الأول', 'الدور الأول', 1, 2),
(2, 'Spring2017', 'الفصل الدراسى الثانى', 'الدور الأول', 2, 2),
(3, 'Summer2017', 'الفصل الدراسى الصيفى', 'الدور الثانى', 3, 2),
(4, 'Fall2017', 'الفصل الدراسى الأول', 'الدور الأول', 1, 2),
(5, 'Spring2018', 'الفصل الدراسى الثانى', 'الدور الأول', 2, 2),
(6, 'summer2018', 'الفصل الدراسى الصيفى', 'الدور الثانى', 3, 2),
(7, 'Fall2018', 'الفصل الدراسى الأول', 'الدور الأول', 1, 2),
(8, 'Spring2019', NULL, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `semesterenum_tbl`
--

CREATE TABLE `semesterenum_tbl` (
  `ID` int(11) DEFAULT NULL,
  `SemesterEnum` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `semesterenum_tbl`
--

INSERT INTO `semesterenum_tbl` (`ID`, `SemesterEnum`) VALUES
(1, 'Fall'),
(2, 'Spring'),
(3, 'Summer');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `UniversityName` varchar(255) DEFAULT NULL,
  `UniversityLogo` mediumblob,
  `FacultyLogo` mediumblob,
  `BachupIntervalMinutes` double DEFAULT NULL,
  `BackupsFolder` varchar(255) DEFAULT NULL,
  `BachupIntervalHours` double DEFAULT NULL,
  `PreserveSavedData` bit(1) DEFAULT NULL,
  `VersionNo` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`UniversityName`, `UniversityLogo`, `FacultyLogo`, `BachupIntervalMinutes`, `BackupsFolder`, `BachupIntervalHours`, `PreserveSavedData`, `VersionNo`) VALUES
('جامعة السويس', 0x151c2f00020000000d000e0014002100ffffffff4269746d617020496d616765005061696e742e506963747572650001050000020000000700000050427275736800000000000000000040520100424d36520100000000003600000028000000aa000000a900000001001800000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5fbfff6fefffbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5fdfff6fdfffdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4fbfff6fdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafffff7ffffeaf1f7fafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffff6fefff5fcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5fbfff7fefff4fbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fcfff7fefff5fcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4fbfff7fefff5fcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8a959e4e3b377b3e14804108804009ab7859eae8ebffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff76808a50352a83410f7e3f0882410db4866bf2f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff727b855a3f33763d147e4008874611b58b72f5fafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f9fb6067705b352185440c854c1f6a360dbe9984feffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffecf0f25c636d5b362484420f7b3d068f4e1cc09e8dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdde2e54d515967371c84420a7b3d06955525cab0a4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd0d6d94f515866381d84420d7a3e0498592dcbb6acffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbcc3c8484347733a178142097b3d049f6135d7c9c5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f9fa353a428c420eb65300a64e00a44e00a44d00a34800a34000cb9d80fffffffffffffffffffffffffffffffffffffffffffffffffffffff0f3f52e30399b480cb45300a44d00a54e00a34d00a24800a54300d6b4a0ffffffffffffffffffffffffffffffffffffffffffffffffffffffd2d8da2e2a2ea34a06b15100a64e00a44e00a34b00a34700a74500d8bbacffffffffffffffffffffffffffffffffffffffffffffffffffffffc8ced1302627ac4f06af5000a44d00a64d00a84f00a44500ab4e04e5d6d2ffffffffffffffffffffffffffffffffffffffffffffffffffffffa6aeb3392622b15106ae5100a44d00a54e00a24b00a54500ac5008e9dddaffffffffffffffffffffffffffffffffffffffffffffffffffffff98a1a842271db75401aa5000a44d00a54e00a24a00a54300af5b1cf3f1f6ffffffffffffffffffffffffffffffffffffffffffffffffffffff77838d522b19b75300ab5000a44d00a54e00a14b00a54400ae5e21f5f6fdffffffffffffffffffffffffffffffffffffffffffffffffffffff6a757e5d3017ba5400a74e00a44d00a54e00a14a00a34000b87241ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeff2f427272fb7550ca44e009f4d03a04d04a04d03a04d03a04d049f4c029f4000bf7645ffffffffffffffffffffffffffffffffffffffffffeaedef28252dba5708a24d009f4d03a14d04a04d03a04d03a04d039d4b019f3d00c8906dffffffffffffffffffffffffffffffffffffffffffc0c6ca342522c15a04a04c00a04d03a04d04a04d03a04e03a04c039d4b019f3c00cf9d81ffffffffffffffffffffffffffffffffffffffffffb9c0c43c2620c15a049f4c00a04c04a04e04a04d04a04d04a04d039c4a00a03d00d9b49fffffffffffffffffffffffffffffffffffffffffff8d979e562f1bbd58009f4c01a04c03a04d04a14d04a04d04a04d039c4900a23d00e0c4b8ffffffffffffffffffffffffffffffffffffffffff848e965d331cbc57009e4b02a04d04a04d03a04d03a04d049f4d039c4700a84300e7d7d2ffffffffffffffffffffffffffffffffffffffffff5b6771783a17b554009e4c02a04d03a04d04a04d04a04d049f4d039c4700a74600f1e9eaffffffffffffffffffffffffffffffffffffffffff535e6982411ab352009e4d02a04d04a04d03a04d04a04d049f4d039c4500ae4f06f8f8feffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fafb27282fba57089e4c00a04d04a14d04a04d049f4c019f4c02a04d04a04d04a04d039b4100bd7643ffffffffffffffffffffffffffffffeef2f329282fbb59089f4c00a04d04a14d04a04d049f4b009f4d02a14e04a04d049f4d039c3f00c88c63ffffffffffffffffffffffffffffffcad0d3362624c159049d4b00a14e04a14e04a04d039f4b00a04d03a14d04a14e049f4d039c3c00cf9f82ffffffffffffffffffffffffffffffbec5c93d2923c059039d4b01a14d04a14e04a04d039f4b00a04d03a14e04a14d049f4c029b3b00d9b29dffffffffffffffffffffffffffffff96a0a558311fba55009e4c02a14d04a04d04a04d039f4b00a04d03a14d04a14e049d4c029e3c00e2c8bbffffffffffffffffffffffffffffff8a959c5f341cb855009e4c03a14e04a04d04a04d039e4b00a14d03a14e04a14d049c4a00a33e00e8d7d2ffffffffffffffffffffffffffffff626e787c4019b152009f4d03a14e04a04d04a04d039f4b00a04d03a04e04a14d049d4900a74400f3edefffffffffffffffffffffffffffffff57636e854317af52009f4c03a14e04a14d04a04d029f4b00a04d04a14e04a04d049c4800ab4b00f7f8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfeff2b2f39b7570a9f4b00a14e04a14e04a04d039d4500a34c07a549009f4a00a04d04a14e04a04d039c4100c38355ffffffffffffffffffebeff12c2a32ba580aa04c00a04d04a14d04a04e039c4300a75311a446009d4a00a14e04a04e049f4d039d3e00cb9576ffffffffffffffffffd3d9dc322829bf58059d4b00a14e04a04e04a04c039c4100a85411a345009d4a00a14e04a04e049f4d039d3c00d6ab91ffffffffffffffffffbdc4c83c2a24c05a029d4b01a14e04a04e049f4d029b4000ac5817a042009e4b01a14e04a04d049f4c039c3c00dbbdacffffffffffffffffffa3acb24d2d22bb56009e4c02a14d04a04d04a04d01993d00ab5715a243009e4c03a14e04a04d049e4c02a13e00e4d1cbffffffffffffffffff8b969e5d331db955009e4c03a14e04a04d049f4c009a3e00ae5815a144009e4d03a14e04a14e049d4a00a44000ece2e0ffffffffffffffffff6f7c86733c1cb153009f4d03a14e04a04d049f4b009b4000ab530fa247009e4c03a14e04a04d049c4900ab4900f3f4fbffffffffffffffffff5a677181421baf52009f4d03a04e04a14d049f4a009e4400aa520ba046009f4d03a14e04a04d049c4700ae5003fdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffb8b6b5f9fcffd8e1e7313239b3550aa14c00a04d04a14e04a04d039a3c00c28966ffffffededf2a64c0c9f4900a04d04a14e04a04d039d4000c38255ffffffb9c3ca362c30b95808a04c00a04d04a04d04a04e03993900c9997cffffffe6dedfa74a009f4900a04d04a14e049f4d039e3f00c9916cffffffb1bcc33b2c29bc59079d4b01a14e04a04d04a04e039a3800d0a994ffffffd8cdcca844009d4a00a14e04a04e049f4d039e3c00d5a78bffffff939fa84a2e24bd58049d4b01a14d04a04e04a04c009b3b00d9b8a7ffffffcfbbb2a642009e4b00a14e04a14d049e4c029f3d00d7b29effffff8995a0543121bb56009e4c02a14d04a04d049f4c009d3e00e5cec6ffffffc4a798a640009d4c01a14e04a14e049d4a01a54100dfc7bcffffff6c788467381cb855009e4d03a14d04a04d049f4a009f4100edddd8ffffffc39b85a540009e4c02a14e04a14e049d4a00a74400e4d2ccfeffff5f6b77753d1ab353009f4d03a14e04a04d049e4800a34c0bf5ebeaffffffba8768a442009e4d03a14e04a04d039c4800ad4e00eee7ebf4feff4a55608a4419ae52009f4d03a14e04a04d049f4700a44f12fbf7fbffffffb47854a444009e4d03a14e04a04d049c4700b05308efeef4f8fffffdffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff787d83a244006d3d1db45405a04d00a04d04a14e04a04d049a3b00c9967bfffffffffffffffffff2faffa04909a04900a04d04a14e04a04c03a04700a04c0a753b17b655019f4c01a04d04a14e04a14d03983700d4ae9dffffffffffffffffffebeff79e43009e4a00a04d03a14e049f4d03a246009a4b0e7b3e13b554049e4c00a14e04a04d04a04e03983600debfb5ffffffffffffffffffd9d6dba745009c4a00a14e04a14e049e4d03a34600964c17824013b554009e4c02a14d04a04e04a04c009a3a00eadad7ffffffffffffffffffd0c9cca33e009d4c00a14e04a04d049f4c02a445008f4916864311b153009e4c02a14e04a04d049f4c009d3c00f2e8e9ffffffffffffffffffc1aca7a640009d4c02a14e04a14e049e4b01a5450087481b93470eaf51009e4d04a14d03a04d049e4a009f4300faf8fdffffffffffffffffffb89d92a33f009e4c02a14e04a14d049d4b00a5460083451a964910ad51009f4c03a14e04a04d049f4a00a14a0dffffffffffffffffffffffffb38772a543009e4d03a14e04a04d039d4900a84a007a411fa34d0ca950009f4d03a14e04a04d049f4700a95720ffffffffffffffffffffffffaf7c60a645009e4d03a14e04a04d049d4900a648008142188f4918f4e5ddffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff818a929e4300a74f00a04c02a04d04a14e04a04d049a3c00c79374fffffffffffffffffffffffffffffff0f6ffa349049f4800a04d04a14e04a04d03a14c00a54e00a04d03a14d04a14e04a04d03983700d0a996ffffffffffffffffffffffffffffffdbdbe1a845009c4900a04d04a14e04a04c03a14c00a54e00a04d03a14e04a04d04a04e03983600dabbabffffffffffffffffffffffffffffffd4d1d6a742009c4a00a14d04a14e04a04d03a14c00a44e00a04d03a14e04a04d049f4c019b3900e6d2ceffffffffffffffffffffffffffffffc2b3b1a641009d4b00a14e04a04d04a04d03a24d00a44e00a04d03a14e04a04d049f4c009d3c00efe3e4ffffffffffffffffffffffffffffffbea79ea73f009d4c01a14d04a04e04a04d03a34d00a34e00a04d03a14d03a04d049e4b009f3f00f9f5f9ffffffffffffffffffffffffffffffb5907da540009d4c03a14e04a04d04a04d03a34d00a34e00a04d03a14e04a04d039f49009f4505ffffffffffffffffffffffffffffffffffffb2846ba542009e4d03a14e04a04d049f4d02a44d00a14d01a14d04a04d04a04d049e4800a55114ffffffffffffffffffffffffffffffffffffaa7555a544009e4d04a14e04a04d04a04d02a24d009f3e00e4cdbdffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff818a919f4500a14d03a04d04a04e049f4c029a3900c58e6ffffffffffffffffffffffffffffffffffffffffffff1f7ffa64e0d9f46009f4d04a14e04a04e04a04d04a04e04a04d049f4c02993700cfa490ffffffffffffffffffffffffffffffffffffffffffe2e2e7a949009d4800a04c04a14e04a04e04a04d04a04e04a04d04a04d01983400d8b7a7ffffffffffffffffffffffffffffffffffffffffffd9d5d9ab47009c4800a04d04a14e04a04d04a04d04a04e04a04d049f4b009b3900e4cdc6ffffffffffffffffffffffffffffffffffffffffffccbebaa842009c4900a04d04a14e04a04d04a04e04a14e04a04d049e4b009c3c00eddfddffffffffffffffffffffffffffffffffffffffffffc3aca4a63f009c4a00a04d04a04d04a04d04a04d04a04d04a04d049e4900a04000f5f0f2ffffffffffffffffffffffffffffffffffffffffffbe9b88a53e009d4a00a14d04a04d04a04d04a04d04a04d04a04d039f48009f4403fdfdffffffffffffffffffffffffffffffffffffffffffffbb8e75a33e009d4c01a04e04a04e04a04d04a04d04a04e04a04d049d4500a55012ffffffffffffffffffffffffffffffffffffffffffffffffb27956a441009e4c03a14d04a04d04a04d049d4100e6d0c2ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff7b828a9e4400a14d029f4c019d47009a3900d0a791fffffffffffffffffffffffffffffffffffffffffffffffffffffff8ffffb96e3b9f3e009d4800a04d02a04d03a04c019d46009d3b00d9b9abfffffffffffffffffffffffffffffffffffffffffffffffffffffff4f7feaf5d20a040009d4b00a04d03a04e03a04c029e46009d3d00e2c8bfffffffffffffffffffffffffffffffffffffffffffffffffffffffecebf0ab55119f42009e4a00a04d02a04d039f4b009d43009f4200ecdedcffffffffffffffffffffffffffffffffffffffffffffffffffffffe2dcdcac4d049d44009f4c01a04e03a04d04a04c029d4500a04400f2e9eaffffffffffffffffffffffffffffffffffffffffffffffffffffffddd0cfaa49009d43009e4c00a04d03a14d039f4b009d4000a45113fbf9fdffffffffffffffffffffffffffffffffffffffffffffffffffffffd2bbb2a845009c45009f4c01a04d03a04d039f4b009c3f00ad5d26ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffccae9fa741009c45009f4b01a04d03a04d029e49009b3b00b66e3dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc6997fa33f009c4700a04c02a04d039d4100e6d0c2ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffacb5bd9b3b00973b009e4100b77446f3e9e9ffffffffffffe2e7ea79808968524878513995735ecec2bfffffffffffffffffffffffffdcbfaeb162259a3d00983b009f4300bc7b50f6f0f2ffffffffffffd0d7da6b6e76674a3c7c50369b7863d7cfceffffffffffffffffffffffffd1a88fa84e079839009c3f00983900b97549f8f4f7ffffffffffffcbd2d6707279684e427d553d9d7d6bdbd5d6ffffffffffffffffffffffffd3a98eaa5514993c00983b00a24902c58e6affffffffffffffffffb6bec46763676a493581543aa58573e4e2e5ffffffffffffffffffffffffc78f689e41009c3d009e4000973900c0835bffffffffffffffffffb4bdc36c686c6b4d3c825941a88b7ce6e6ebfffffffffffffffffffdffffca9571a44b06973b009a3d00a6520fcea389ffffffffffffffffff9fa9b163595a6e4a34865a3fb09586eff2fafffffffffffffffffff4f4f9c283559d4100983b00983a00a54f0bd2ab96ffffffffffffffffff9da7b0685f606e4d39885f48b59d91eff5fcfffffffffffffffffff1edf0c383549f4500983b009a3d00ac5d20dbbdadffffffffffffffffff89929c63534d734a338a6047bea89df8ffffffffffffffffffffffeae0ddb9713b9d4100973b009c3400e1cab8ffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffcfafbf3e8e9ffffffffffffffffffffffff79848e512f20a54a00ae4f00a94d00a84a00a54400ac5e21e9dfdffffffffffffffffffffffffffaf7f9f4ebecffffffffffffffffffffffff6a757f5b3119ac4d00ae4f00a84d00a74a00a34200b46e37f4f4faffffffffffffffffffffffffeeded8e6d0c5f9f5f8ffffffffffffffffff59626c633316ac4d00ae4e00a84d00a74a00a24100b77340f7f8fefffffffffffffffffffffffff7f1f3f6eeefffffffffffffffffffffffff4d555e733814af4e00ac4f00a74c00a74a00a14000bd835bfffffffffffffffffffffffffdfcffe5cdc1e2c7b8fbf8fbfffffffffffff5f8f944495279390ead4c00ad4f00a84c00a84900a14100bf8861fffffffffffffffffffffffffffffff6efeff7eff0ffffffffffffffffffebeff0393c4389410eaf4f00ab4e00a74c00a74800a54600cca086fffffffffffffffffffffffffeffffedded7f2e6e3ffffffffffffffffffd1d7da39363d8d4009ae4d00ab4d00a74c00a84800a44700cea58dfffffffffffffffffffffffffffffff5ececfaf5f6ffffffffffffffffffc3c9cd383032984507af4f00aa4e00a64c00a74700a64c02dbbdadfffffffffffffffffffffffffffdfff2e6e5e1c6b5f4eae5ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f5a64834016b453009f4c01a04d03a04d03a04d039f4d039d4700a54200d9b8a8ffffffffffffffffffffffffffffffffffffffffffffffff48525c8c4416b152009f4d02a04c03a04d04a04d039f4d029d4600ab4800e5d1c8ffffffffffffffffffffffffffffffffffffffffffffffff3439439f4c0fad52009f4d02a04d03a04d03a04d039f4d029d4600ac4c00eadcd9fffffffffffffffffffffffffffffffffffffffffffdffff30343da64f0fab50009f4d03a04d03a14d04a04d039e4c029e4400ac510af7f4f8ffffffffffffffffffffffffffffffffffffffffffe0e4e62d2a2eb15208a850009f4c03a04d03a04d03a04d039e4c029e4400b05710f8faffffffffffffffffffffffffffffffffffffffffffffd9dde02f292cb65508a54e00a04d03a04d03a14d049f4d039e4c01a04200b4682fffffffffffffffffffffffffffffffffffffffffffffffffb2b9be3f2b22bb5603a34e00a04d03a04d03a04d039f4d039e4b00a04200bc703affffffffffffffffffffffffffffffffffffffffffffffffaab3b7452b21bc5803a14d00a04d03a04d03a04d049f4d039d4b00a04000c5875fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c5661924813ac50009f4d03a14e04a04d04a04d03a04d03a14d04a04d049d4c019e3c00dbb6a2ffffffffffffffffffffffffffffffffffff47525c964914ab4f009f4d03a14d04a04d04a14f04a14e04a04d04a04d049c4a00a44000e1c8bdffffffffffffffffffffffffffffffffffff313741ac530da44e00a04d03a14d04a14d04a14f04a14e04a04e04a04d049c4800a84400ecdcd7ffffffffffffffffffffffffffffffffffff30343daf530ba34d00a04d03a14d04a14e04a14f04a14e04a04d04a14d039c4800aa4a00f3eeefffffffffffffffffffffffffffffffe6eaec2e292dbb5808a04c00a04d04a04e04a14e04a14f04a14e04a14d04a04d039b4700b15004f8f9ffffffffffffffffffffffffffffffffdce0e330292bbc58089f4c00a04d04a04d04a14e04a14f04a04e04a14d04a04d039c4500af5916ffffffffffffffffffffffffffffffffffffb5bcc0452c22be58009e4c01a04d04a04d04a14e04a14f04a14e04a04e049f4d039b4300b7662affffffffffffffffffffffffffffffffffffadb5ba4a2d21bc57019d4b01a14d04a14e03a04d04a04d03a14e04a04d049f4d039c4100c17a47ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff57636e894419ac51009f4c03a14d04a04d049f4b009d4000a246009e4c02a14e04a14d049f4c029f3c00e5c7b8ffffffffffffffffffffffff4c5660924714aa50009f4d03a14e04a14e04a14e009334009a4000a25003a04d04a14d049d4b00a44100e8d3cbffffffffffffffffffffffff39414ba75111a44e00a04d04a14e04a14e04a04d009232009c4300a24f04a04d04a04e049d4a00a74600f6ecebffffffffffffffffffffffff323842ac5210a34d00a04d04a04e04a14e049f4b009231009e4700a24f04a04d04a04d049c4800aa4c00fcf8fdfffffffffffffffffff0f3f52d2c33ba58099f4c00a04d04a04d04a24e039d47009132009e4800a14e04a04d04a04d049b4700b1560effffffffffffffffffffffffdee3e5302a2fbb580a9e4c00a14d04a04d04a24f049c4500923100a04b00a14e04a04d04a04d049c4500b46020ffffffffffffffffffffffffc2c9cd3e2a25bd58049d4c02a14e04a04d04a250039b4100933300a04d00a14e04a14e04a04d039c4300bd7037ffffffffffffffffffffffffb1b9be462c24bb56029e4c02a14e04a04e049f4b009e4600a142009e4b00a14d04a04e04a04d039c4100c38254ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffeae9e9ffffffffffff5a656f81421aae52009f4d03a14d04a04d049f4800a44f0fe9d9d3caa893a744009d4a00a14e04a14d049e4c01a03f00e2c7bbffffffffffff48505a914918ab4f009f4d03a04e04a14e049d470097390ce8d6d5c390808e2d00a25102a04d04a14d049d4b00a44200e8d2cbfffffffbffff3d444ea04f14a64e00a04d04a14e04a14e049a42009d4925ead8d7bb826f913000a25103a04d04a14d049d4900a64900f1e8eaffffffe6ecef343741ab510ea34e00a04d04a04e04a24f04973c00a35435efe1e0af6c56933400a25104a14d04a04d049c4800ac5004f3f1f5ffffffdfe5e9313036b5560ca04c00a04d04a04d04a25004943700ad644becdddda85d42973b00a25004a04d04a04d049c4600ae5814feffffffffffc3cbd0372d2fb957069f4c00a14e04a04d04a25003933200b4745feededea04c2b993f00a24f04a04d04a04d049c4500b26225ffffffffffffb5bec33f2d29bc59059e4b00a14e04a04d04a25102912e00bf8975ead8d79a41179c4500a14e04a04e04a04d039c4200be7642ffffffffffff9aa5ac4d3026ba57019e4c02a14e04a04d049f4c009d3e00d7b29ce0d3d0a74e06a04900a04d04a04e04a04d039d4100c2855bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff737678b5754b564c4e924814ac51009f4d03a14e04a04d049f4700a75721ffffffffffffffffffcabbb8a742009d4b00a14e04a14d049e4b01a24300b683644e3e3ba24e0ca84f00a04d03a04e04a24e049c44009e4b2effffffffffffffffffdcbfbf8d2900a25102a04d03a14d049d4b00a74600a87d64503e37a7500da54e00a04d04a04e04a14e04993f00a75b48ffffffffffffffffffcda29c8f2c00a25003a04d04a04d049e4a00ab4c00a27f6e4f362cb0540ba34d00a04d04a14d04a14f04963900b37061ffffffffffffffffffc5928a923100a25004a04d04a04e049c4800b0510497796c51362ab5550aa14d00a04d04a04d04a25004923200bf887fffffffffffffffffffb37463953800a25004a04d04a04d049d4700b358118d756d5c3522b756049e4c00a14d04a04d04a251038f2c00c99c97ffffffffffffffffffad6453983e00a14e04a14e04a04d049d4600b45d198570675e3722b756029e4c01a14e04a04d04a251028d2700d8b6b4ffffffffffffffffffa04e309b4300a14e04a14e04a04d039e4500b96729726361723b1ab554009e4c01a14e04a04d049f4b009e3f00ecdddbfffffffffffff4f9ffa35012a04900a04d04a04e049f4d03a04500b468317a6761967d6ffffcfaffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff828a929d4000af5000a44e00a04c03a14e04a04d049f4800a8541bffffffffffffffffffffffffffffffc5b5b0a741009d4b00a14d04a14e049f4d02a24800af5100a14d00a04d03a04e04a14d049d46009b4626ffffffffffffffffffffffffffffffdabab98c2600a35103a04d03a14d049e4c02a44900ae5000a14d00a04d04a14d04a14e049a4100a55541ffffffffffffffffffffffffffffffcba0998f2b00a25103a04d04a14d049e4c01a54a00ad52009f4d01a04d04a04d04a14f04973a00b06e5cffffffffffffffffffffffffffffffbf887c923300a25004a04d04a04d049e4b00a64b00ad5200a04d02a04d04a04e04a24f04933400bd837affffffffffffffffffffffffffffffb2705e963800a24f04a04e04a04d049e4b00a84b00ab51009f4d02a14d04a04d04a25003902d00ca9c95ffffffffffffffffffffffffffffffa65843994000a14e04a04d04a04d039e4a00aa4d00ab51009f4c02a14d04a04d04a350038d2900d6b3b1ffffffffffffffffffffffffffffff9d492c9c4500a14e04a04e04a14d039e4a00ac4d00a850009f4d03a14e04a04d049f4b009e3e00eee1dffffffffffffffffffffffffff0f7ff9f4a0ca04800a04d04a14e04a04d039f4900a94c00a73f00e1c8b8ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff818a919f4500a04c02a04e04a14d04a04d049e4600a55015ffffffffffffffffffffffffffffffffffffffffffc6b4afa540009d4b00a04d04a14e04a04d03a04d03a14d04a04d04a14f049c450099401dffffffffffffffffffffffffffffffffffffffffffd2aba68c2700a25101a04d04a14d04a04d03a04d03a04e04a04d04a15004994000a25139ffffffffffffffffffffffffffffffffffffffffffc99b958e2b00a25102a04d04a14d04a04d03a04d03a14d03a04d04a25004963900ac6452ffffffffffffffffffffffffffffffffffffffffffbb7e71933200a25003a04d04a14d03a04d03a04d03a04d03a04d04a25004943300b87b6effffffffffffffffffffffffffffffffffffffffffb16b5c953600a24f04a04d04a04d04a04d03a04d03a14d04a04d04a251038f2c00c5928cffffffffffffffffffffffffffffffffffffffffffa3543d983e00a25004a04d04a04e03a04d03a04d03a14d04a04d04a251028d2700d2aba8ffffffffffffffffffffffffffffffffffffffffff9d48299a4000a24f04a04d04a14e04a04d03a04d03a04d04a04d049f4b009d3c00eadad5ffffffffffffffffffffffffffffffffffffeff3faa24b09a04700a04d04a14e04a04d049f4d049c4000e6d0c2ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff8189919f4500a14d03a04d049f4c019c3f00af612affffffffffffffffffffffffffffffffffffffffffffffffffffffccc0beab4800a74e00a14d03a04d03a14e04a14e04a25002963800a14f34ffffffffffffffffffffffffffffffffffffffffffffffffffffffdbbcba8b2500a14d00a14f04a14e04a14e04a14e04a25002933500a95e4affffffffffffffffffffffffffffffffffffffffffffffffffffffd1aaa38b2500a14d00a14f04a14d04a14e04a14e04a35100902d00b47466fffffffffffffffffffffffffffffffffffffffffffefefeffffffbb8d86902b00a15000a14e04a14e04a14e04a14e04a350008f2900b4847affffffffffffffffffffffffffffffffffffffffffffffffffffffba7f718f2b00a14e00a14f04a14e04a14e04a14f04a14e008c2500ca9e97ffffffffffffffffffffffffffffffffffffffffffffffffffffffae6654923200a25001a14e04a14e04a14e04a14f04a04d008b2500d6b4b1fffffffffffffeffffffffffffffffffffffffffffffffffffffffae6953933100a85203a14d04a04d03a04d03a04d039e4800a04000ecdedcfffffffffffffffffffffffffffffffffffffffffffffffff2f7feae5e249f42009e4b01a04d04a04d049d4000e6d0c2ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff8189909533009e43009b3e009e4300cda185fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0f57f4318aa4f03ad4f00963c00933500902e00c39084fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1e6e99b431f9130009b43009c4600983b008e2b00c7968cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffebdadd9a431d912e00973c009a3f00993800852700d5b2adffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5bebf9333039436009d47009d48009639008d2a00dabfbdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd3b4b296380b933100983d00973d00913000993f17e9d5d7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcda39a902e009536009b4200994000912f009b4420efe3e5fffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffffc69b91671d00aa5201b55804b252009a3b00b26b38f5f3f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffce9d7ca444009b3f009e44009d3a00e4cebfffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffdebdabd0a78cdfc3b3fefcfefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefe3d3d3e00060d000000654435d7a995d7b3a9fcfbfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdec3bebd8365b47450cc9e8ff9f4f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe6cfcccda08fc49682bea8a4f1f7feffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdeb9acbf7c59bb7553d7ab9afffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f7fafdffffdac2bdca9c89cc9f8de3cbc8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcffd4aea3be8666c59177e2c9c5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb7c2cb0000000000005a4a3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8f7fadfc1b1cda084b97848e7d4c9ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff414141080507000000201e20fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f8f8e4e3e3d0cfcfc5c3c3b9b9bababdc1bcc3c7c1c7cac9cdd0d0d1d2e0dedef6f5f5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdad9da000000000000666568ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5252520d0b0b0000001a1819ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfcecf9190905453532a28290d0c0c0000000000000000000000000000000000000000000000000000000000000000000000000a090a232223515050898687c7c6c6d1ced0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdedcdd0000000000007b7a7affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6e6e6e100d0e0000000a0909ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1e0e08c8b8b3534340000000000000000000000000000000000000000000404041a19192525252d2b2c3432333331312f2e2e2828281d1a1b0907080000000000000000000000000000000000000000000303033b3a3b949393e8e8e8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d4d40000000000009e9b9cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c9c9c181516000000000000fcfbfbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1f1f1b6b5b63534340000000000000000000000001110114645458e8e8eb5b3b3dad9d9f4f2f2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f4f5dfdddebcbbbc8f8d8d4948483332320e0e0e000000000000000000000000323132bfbebffffffffffffffffffffffffffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefefdfdfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc4c2c2000000000000c8c5c6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd0d1d1201c1e000000000000dad9d8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbebcbd3a393a0000000000000000000000004342439f9e9ee6e5e5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0e0e19898983b3939000000000000000000212020575656c7c5c6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefefafafaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c999a000000000000f5f4f4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff343232000000000000a6a4a4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa8a7a71817180000000000000000003f3f3fafaeaefffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfbfba7a5a6353434000000000000000000232223b3b2b2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff636161000000151314ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6161610a080a000000595858ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadacad1311120000000000000505057e7e7ff1f1f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeae9e97271710000000000000000001d1b1bbbbabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff201e20000000585656ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafafaf1713140000000e0c0effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d5d52926270000000000000e0c0d9f9e9effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff908f8f040303000000000000343333e5e3e4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefefefefdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefe000000000000bbb9b9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfbfb2c2a2a000000000000e6e4e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff605e5e000000000000000000989797ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff898788000000000000000000747272fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefefefefefefefefdfdfefffffff6f0f0d5b3acffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb9b7b7000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6867660a07080000007d7b7cffffffffffffffffffffffffffffffffffffffffffb57662993f039c461be3cdcbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc5c4c40808080000000000006c6b6bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdedfb5b4b48a8889737272696768696768717071817f80a1a0a0c4c3c3e3e2e3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfafa5b5a5a000000000000111010d8d6d6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffebdbd9861b00994002a14f23a55931b06c48c79988f7f2f4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff575555000000292829ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcccccc1a17180000000f0e0effffffffffffffffffffffffffffffffffffffffff9c46229a3f00a04c00a04c00892400f9f6f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff706f6f000000000000232222e0dedefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f3f35c5a5b0c0b0b0000000000000000000000000000000000000000000000000000000000000000000402032f2e2e807c7ededbdcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd2d1d1121111000000000000878686ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdabbae963900a14e019f4b009f4a009d4600983e008b2600f1e7e8fffffffffffffffffffffffffffffffdfefeffffffffffffffffffffffff0605050000009d9c9dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff414141010000000000d6d4d5ffffffffffffffffffffffffffffffffffffbb8374973b009b440a9e4a10a24f01953800d4b0a1fffffff3eae9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2827270000000000007f7e7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0504040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b3939ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6b68690000000000003d3c3cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe897a8d2900a24e00a25005963a009d4700a25002993e00c18f7affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcdcbcc000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaaa110f100000004e4c4cfffffffffffffffffffffffffffffffffffff6eff48d2800953600f8f4faddc2b9973a00953800d7b9abffffff8e2f07bf8775ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcdbdb040304000000010000d4d2d3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006c6a6bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bec00000000000000f0f0fecebecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0c8c3953800983c00d5b3aab16d4e923400983d00cda48fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4e4d4e000000525252ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3d3d3d000000000000fdfbfcffffffffffffffffffffffffffffffffffffc08c769a4000a14e21ffffffb170559e48008f2d00f9f7fab06f579c42008e2b00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbaba000000000000312f31fdfcfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a1919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000979696fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f2f31f1d1e000000000000d1d0d0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6b4ab8f2b00c89887fffffff0e5e9851900e7d3ceffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000deddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbababa131212000000767373ffffffffffffffffffffffffffffffffffffffffffa85d369f4b008c2500f5f0f9923300a25000984010ffffff9e4a22a04c00923200e6d0ceffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa5a3a30000000000005d5b5bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff353435000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7b6b6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4a4949000000000000b7b5b6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff913000943600ffffffffffff973f21fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf7f6ffffff8d8c8c000000242323ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b3a3a000000000000e8e7e8ffffffffffffffffffffffffffffffffffffffffffbf8c78943200b16f58e5d0ca9435009a3f00c79884ffffffe3cdc49535008f2d00f6eff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9b9a9a0000000000007f7e7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff555455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e7e7e7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff646464000000000000b1b0b0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9b4417973b00c99d93ffffffd4b1a8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa65e49faf6f4ffffffffffff090707000000bebcbdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaaa0e0d0d0000004d4c4cffffffffffffffffffffffffffffffffffffffffffffffffffffff8d2d0bffffffba81669d4600913200e7d5ceffffffb9806b9b42009f4e29ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa19f9f000000000000939192ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefeeefe8e6e65d5a5c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b2a2a807f7fd5d3d3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7c7b7b000000000000b6b4b5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb77b619d47008f2c00f8f4fbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbb827193350cffffffffffffffffffb1b0b1000000131313ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff363636000000000000f3f2f2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae68489e49009f4a00a6592ac18d78993d008e2a00e7d5d4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb4b3b40000000000009a9899ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9a9999e4e3e3ffffffffffffffffffffffffffffffffffffffffffffffffcfcdcf7c7b7c3d3b3c100f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0e0e636162c7c6c7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff817f7f000000000000cdcbcbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe6d1cf912f00a04b009c4925ffffffffffffffffffffffffffffffffffffffffffffffffffffffc390888e2a00bf886cffffffffffffffffffffffff181717000000b4b3b3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaeaeae0d0c0d000000585757ffffffffffffffffffffffffffffffffffffb47569eddfddffffffffffffffffffffffffd5b1a88f2e00a25103a04b009c4500943600b87d6bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd3d0d10000000000008f8d8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3a3939000000464545ffffffffffffffffffffffffffffffffffff959393191819000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000191819908e8fffffffffffffffffffffffffffffffffffffffffff969595acababffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff706e6e000000000000eae8e9ffffffffffffffffffffffffffffffffffffe6d4d2c69482f3ebe7ffffff994019a14e00963800c89a8effffffffffffffffffffffffffffffffffffffffffc79b969435008b2300e4cfcdffffffffffffffffffffffffbcbbbb000000141313ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3c3b3b000000000000f4f4f4fffffffffffffffffffffffffffffff1e7e68b2400943600b16e54f1e7e9ffffffffffffffffffb06f598f2c009436008f2e00b67864fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f6f6000000000000737172ffffffffffffffffffffffffffffffffffffffffffffffffffffffe2e1e2080808000000000000000000d3d2d3ffffffffffffffffffafadae0e0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505058f8d8dffffffffffffffffffffffffe8e8e90000000000003a3939fefefeffffffffffffffffffffffffffffffffffffffffffffffffffffff585757000000050405ffffffffffffffffffffffffffffffffffffb87b60821400f0e3e3ffffffe9d8d88e2b00a352018d2900fbf9fcffffffffffffffffffffffffffffffd0a8a49232008f2d00d1aba6ffffffffffffffffffffffffffffffffffff181617000000bbb9baffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0c0c00f0e0e0000004f4e4effffffffffffffffffffffffffffffffffffa85d409e4900a14f029c4500933400b5765cf6f0f3ffffffffffffe8d6d2d4b1a3eddfdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1413140000004a4949ffffffffffffffffffffffffffffffffffffffffffffffffffffffc5c4c4000000000000000000000000000000161515ffffffffffff474546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161616d4d2d3ffffffffffff1e1d1d000000000000000000030303d6d5d5ffffffffffffffffffffffffffffffffffffffffffffffffffffff3331310000002d2c2bffffffffffffffffffffffffffffffa96042841800feffffffffffffffffba82709a3e009d4600ad674dffffffffffffffffffffffffd7b7b29130008f2c00d9b9b5ffffffffffffffffffffffffffffffffffffffffffb2b1b2000000222122ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff515050000000000000e5e4e4ffffffffffffffffffffffffffffffffffffbf89769233009a4000a25002a14f019b4300923100c7988effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff524f50000000181819ffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bfbf0000000000000000000000000000000000000000008d8c8c1a1919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bcbbbb878586000000000000000000000000000000000000b8b6b6ffffffffffffffffffffffffffffffffffffffffffffffffffffff0504040000006f6d6efffffffffffffffffffffffff3eae7f0e6e5ffffffffffffffffffffffff923403a351008e2b00f0e4e5ffffffffffffe0c9ca912e008e2b00dec4c1ffffffffffffffffffffffffffffffffffffffffffffffffffffff070506000000dad9d9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1e1e1161616000000313030fffffffffffffffffffffffffffffffffffffffffffffffff9f4f6bb80689232009a4100a25002a24f00913000c4948bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadabab000000000000f4f4f4ffffffffffffffffffffffffffffffffffffffffffffffffdcdbdb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000807070c0b0c0d0b0c080707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000afaeafffffffffffffffffffffffffffffffffffffffffffffffffe6e5e5000000000000c4c2c3ffffffffffffffffffffffffffffffffffffffffffffffffffffffd9bbb49333009f4900a96044ffffffe9d9db902e008d2a00e2cbcaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff908f8f0000004b4a4bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7b7b7b020202000000bebdbdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5eeefb87c63923000a04b00a24f018e2b00fefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfafa000000000000b7b6b6ffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000121111414041807f7fafaeaed0cecfe7e6e7f6f5f5fbfbfbfdfcfcfdfcfcfcfcfcf0efefcccbcb848384282727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfccceffffffffffffffffffffffffffffffffffffffffffffffff9b9a9a000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c471da14f00933400e3cdce9436008d2900e5cfcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000fffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff282727000000060506ffffffffffffffffffffffffffffffffffffe1cac4fcfcfffffffffffffffffffffffffffffffff2e8eb9a4210a24f00912f00e4cec5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff313031000000595859ffffffffffffffffffffffffffffffffffffffffffffffffffffff363334000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212121858484d3d2d3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d4d5706e70050404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7f7f7ffffffffffffffffffffffffffffffffffffffffffffffff403e3f0000004c4c4cffffffffffffffffffffffffffffffffffffffffffffffffffffffe0c5c0913100a25002993e008e2b00e6d4d7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff575757000000888787ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffb7b7b7090808000000807e7effffffffffffffffffffffffffffffffffff8e2d0098400cd0a99dffffffffffffffffffffffffffffffd7b6a7983b00902e00eadad4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa7a6a6000000010000ffffffffffffffffffffffffffffffffffffffffffffffffffffff959394000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000585757d3d1d2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdfd9594950d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f1e1effffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000c6c5c6ffffffffffffffffffffffffffffffffffffffffffffffffffffff993f12a14c008d2b00e9d9dcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdbdada000000121012ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff595858000000000000f3f1f1ffffffffffffffffffffffffffffffd5b1a3953700a14d00973a009b4518d4b1a8ffffffffffffffffffb97f679c4600933400ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000c3c3c3fffffffffffffffffffffffffffffffffffffffffffffffff9f8f80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005d5b5becebebffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff908f900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006a6869ffffffffffffffffffffffffffffffffffffffffffffffffa5a4a40000000a0909ffffffffffffffffffffffffffffffffffffffffffffffffffffffd8b8b08f2d05ecdedfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff151415000000d8d7d8ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffff5f5f51a19190000002b2b2bffffffffffffffffffffffffffffffffffffaa63529230009f4a00a25003a04b009538009e4b1ed9bab0cea5979539009d4500b57762ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6a6869000000434243ffffffffffffffffffffffffffffffffffffffffffffffffffffff4b4a4b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b2a2adddbdcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8f7f7595858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7c6c7ffffffffffffffffffffffffffffffffffffffffffffffff2827270000008b898afffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcfffffffffffffffffffffffffff0e4e3d8b9b0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8987870000008d8a8affffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffababab060506000000a0a0a0ffffffffffffffffffffffffffffffffffffffffffe1c8c3a2522c923300a04b00a250039f4b00983c00983e00a352018b2600f6eff2fffffffffffffffffffffffffffffffffffffffffffffffffffffff5f4f5000000000000f7f6f6ffffffffffffffffffffffffffffffffffffffffffffffffebeaea000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000807e7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030202ffffffffffffffffffffffffffffffffffffffffffffffffe2dfe0000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf7fab9806b9536008c2700c6988afffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f1f1000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff555455000000000000fffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffdbbeb49f4d249334009f4900a14e00a04c008e2a00c5958bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5250500000006e6d6dfffffffffffffffffffffffffffffffffffffffffffffffffffffff4f4f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c8c7c7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8f8f83231310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c5c5cffffffffffffffffffffffffffffffffffffffffffffffff5351510000006f6d6dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc99c96963900903000963a009d4600bb7f61ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff222222000000d2d1d1ffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffafafa1d1d1d0000002f2f2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6b6aca85e349a410ea35325d1aba5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0eeef000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd4d4d4000000000000000000000000000000000000000000000000000000000000000000000000000000070707eae8e8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5b595a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6d5d5fffffffffffffffffffffffffffffffffffffffffff7f5f5000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8e2c00a04f0ccb9f8fe0cac78c2500d5b1a3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8a8a8a000000696868ffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffbfbfbf050305000000969595fffffffffffffffffffffffffffffff7f1efd5b3acfaf7fafffffffffffffffffffffffffffffffffffffbf8faffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5a59590000007b7879ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9593940000000000000000000000000000000000000000000000000000000000000000000a0909f6f6f6ffffffffffffffffffffffffffffffffffffffffffc89889cc9f8acd9f8ccca08ccb9d86d8b6affffffff0e2e4bd8467bb8060e2cac9fffffffffffffffffff6f0eec28c76d6b2abffffffdfc5bec89884cca08ccc9e8bcda18bc89784ffffffffffffffffffffffffffffffffffffffffffffffff7170700000000000000000000000000000000000000000000000000000000000000000000000000000000000001b1a1affffffffffffffffffffffffffffffffffffffffffffffff5a5859000000797677ffffffffffffffffffffffffffffffffffffffffffffffffcfa69a953800a05129ffffffffffff7f1000fbf9f8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffebe9ea0000000e0d0dffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffff747372000000000000efeeefffffffffffffffffffffffffffffffdabcb0871e009b4407ae6846d2ae9ff2e9e6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfd000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff515050000000000000000000000000000000000000000000000000000000010001f6f6f6ffffffffffffffffffffffffffffffffffffffffffffffffa6583d963800993f00902e00882000ac6142ffffff8d2800963b00993e03882100ebd9daffffffffffffefe0d9841700ae6546ffffffdcbdb9871d009940009536008e2700841600ffffffffffffffffffffffffffffffffffffffffffffffffffffff6d6a6b000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1a0a0fffffffffffffffffffffffffffffffffffffffffff1eff0000000000000ffffffffffffffffffffffffffffffffffffffffffffffff9a4325a04b009d4500a0502cd7b9ab9d482cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff100e0f000000eae9e9ffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffff3330320000000f0f0fffffffffffffffffffffffffffffffffffffb474599d4700a14e009d4600973b00963900a65a2cc49380e9d8d3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8482820000005e5d5dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff212020000000000000000000000000000000000000000000000000e6e5e6fffffffffffffffffffffffffffffffffffffffffffffffffffffff3e9eb8c26009b4200e3cbcbedddd3f2e8e7d2ad9d8b2400dcbeb5ecdcdb8e2b00b97d62fffffffffffff1e4dd8d2800b47253ffffffffffff9f4d2e973b00c59384f3e9e4e5cfc5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c4b4b000000000000000000000000000000000000000000000000000000000000000000000000000000575555ffffffffffffffffffffffffffffffffffffffffffffffff413f3f000000a1a0a0fffffffffffffffffffffffffffffffffffffffffff2e9eb8e2b00a24f00a04b00871c00eddfddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff626162000000979796ffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffe9e9e91211120000005e5c5effffffffffffffffffffffffffffffffffff963c0da24f00983d009f4b00a14f04a14e019e4900993e00963a009b440dcba195ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff040404000000e7e7e7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff030203000000000000000000000000000000000000000000bbbabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0c5c68e2900963901e7d4d6ffffffb97d618b2600f3e6e5ffffff913100a85a33fffffffffffff1e5de8d2800b47153fffffffffffffefdff9a421f913000c38d85ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1b1b1a0000000000000000000000000000000000000000000000000000000000001c1b1bb9b7b8ffffffffffffffffffffffffffffffffffffffffffffffffffffffcdcccd0000001d1c1cffffffffffffffffffffffffffffffffffffffffffffffffe9d7d79030009e4800b06b51ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bfc00000003e3d3effffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffb2b2b2010102000000b8b7b8fffffffffffffffffffffffffffffff3eaed9231009a4200cba08fa5592a9f4a009f49009c4500a14e01a14f02933300d3afa5ffffffffffffffffffffffffffffffffffffffffffffffffffffffc7c7c7000000272526ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff615f600000000000000000000000000000000000000000006d6b6cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffead7d89334008c2800fdfdffb97b5e8c2700f3e8e7ffffff923200a5562fffffffcfa69df9f3f28d2700b47153ffffffffffffffffffffffffa353318e2a00ca9c93ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefef0000000000000000000000000000000000000000000000001b1a1b9a9999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0e0e000000e3e2e2ffffffffffffffffffffffffffffffffffffffffffffffffe5d2cf841700f8f3f5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffff757474000000000000f7f7f7ffffffffffffffffffffffffffffffd3b0a3963800983e13ffffffcda494973a00ab6338b678589f4a0aa14e018f2e00f9f6f9ffffffffffffffffffffffffffffffffffffffffffffffffffffff4e4d4e000000a4a2a3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe3e2e2000000000000000000000000000000000000000000110f10ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1c7c2cfa594ffffffe0c6c38d2a00cb9e89c897818c2500f0e3e1fcfbff8f2b00b16d48fefbff780100ae673f9b4200b37052fffffff2e8e5d2ac9dede0deffffff953700973b08ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c9b9b000000000000000000000000000000000000000000878686ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8483840000006c6a6bffffffffffffffffffffffffffffffffffffffffffffffffa85e408f2d00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1b1a1a000000e3e3e3ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffff3d3c3d0000000e0e0effffffffffffffffffffffffffffffffffffae69479a4000b77a61ffffffa3532d953700d6b4abffffffc08a749c43009a4417ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff343333000000000000000000000000000000000000000000d3d2d2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb06b58871d00c99984c59379902c00c99a8ae6d1ce881f00bf8769ca9d878c2400cda397ffffffd5b1a79231009e4a00b37051ffffffe6d1cf7f0d00a55521e1c8c1983b00963b0effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff242323000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5f4f4000000080707fffffffffffffffffffffffffffffffffffffffffff8f5f78d2a00923100eadad7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d5b5b000000a6a4a4ffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffdfdfd1a1919000000474645ffffffffffffffffffffffffffffffffffff943801943500dec2baffffff9231008f2f00f5eef2ffffff9d481d9d4400bb8166ffffffffffffffffffffffffffffffffffffffffffffffffffffffc1bfc00000003d3b3cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d6d6000000000000000000000000000000000000000000525152fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f5f79c441e8e2b008f2d00a04c29fefeffffffffb26e578f2c008d2900a6583bffffffffffffffffffe8d5d6861d00ab614bffffffffffffb676609131008d2700943602e1c7c5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd9d7d8000000000000000000000000000000000000000000767576ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff242222000000dad9dafffffffffffffffffffffffffffffffffffffcfafe903000963800d7b6adffffffffffffd2afa5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaeacad0000005a5858ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffd8d9d9080708000000939292ffffffffffffffffffffffffffffffe8d6d6861d008d2a00ffffffe4cfc9943400993f10fffffffbf9fc902e00933400e0c8c3ffffffffffffffffffffffffffffffffffffffffffffffffffffff5e5c5e000000a7a6a6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3a3939000000000000000000000000000000000000000000fefefefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2e7e5f3eae8fffffffffffffffffffffffff4eceaf1e7e5fffffffffffffffffffffffffffffff0e3e1f3eaeafffffffffffffffffff5edecf1e6e2fbf8f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b3a3b000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff878686000000797779ffffffffffffffffffffffffffffffffffffffffff983e0b9a4100c6967dffffffa354368e2800b87d6dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5e5e5000000222122ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffaeadad000000000000cfcecffffffffffffffffffffffffffffffff9f5f3cfa795b06b55ffffffbe8a7b8a2100b16f50ffffffdabcb5963800902f00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0b0a0a000000faf9faffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefeeee000000000000000000000000000000000000000000727171ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd7d6d6000000000000000000000000000000000000000000a8a7a7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4e4e4000000242323ffffffffffffffffffffffffffffffffffffffffffa659329e4700b27051c59388973b00a351028c2700f5eff3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff7f7f7f000000000000faf9f8fffffffffffffffffffffffffffffffffffffffffffffffffffffffefefee6d2cce9d9d3ffffffaf6c4f9c4300a15125ffffffffffffffffffffffffffffffffffffffffffffffffffffffedecec0000001b1a1bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff706e6f000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f1f2ffffffffffffcdcbcbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1f1c1e000000000000000000000000000000000000353434ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff020201000000ffffffffffffffffffffffffffffffffffffffffffb575529d4700a04b069d4703a14e02a14e04973b00cba192ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1e1c1d000000e8e7e7ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff575756000000030303ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb77a64933500c08b73ffffffffffffffffffffffffffffffffffffffffffffffffffffffa8a7a7000000676566ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff010000000000000000000000000000000000000000646363ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000e0dedf9f9d9f000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9d9b9c000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4a4949000000c2c1c1ffffffffffffffffffffffffffffffffffffc79986993f00a14e02a04d02a04d04a14e049c4300bb8367ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c4b4b000000bdbcbcffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff3635360000002b2a2bffffffffffffffffffffffffffffffffffffecdedcf6efeffffffffffffffffffffffffffffffffffffffcfbfff8f3f3faf7f8ffffffffffffffffffffffffffffffffffffffffffffffffffffff5b5a5a000000b6b5b6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc4c3c4000000000000000000000000000000000000000000efeeeeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff585657332f31cdcccd4645465f5c5d8e8c8dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffff000000000000000000000000000000000000000000c3c2c2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9a99990000007c7a7bffffffffffffffffffffffffffffffffffffefe2e38a2300a25003a04c00a14e02a14e049b4300bf8973ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff807f7f0000008e8b8dffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff1d1d1c0000004f4f4ffffffffffffffffffffffffffffffff6f0ef871e008d2a00faf7f9ffffffffffffffffffffffffae6b51993f0294380cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff222223000000f2f1f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5553540000000000000000000000000000000000002e2d2dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdedddf3230287f7d7de6e6e6211e1effffff000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2e2b2c000000000000000000000000000000000000777676ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd7d6d7000000383637ffffffffffffffffffffffffffffffffffffffffffd1aba3963a00a352169a4000a352038f2b00d4afa8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb4b3b3000000595858ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffefefef0c0a0b0000007b7a7bffffffffffffffffffffffffffffffeee2e1923100933500ffffffffffffffffffffffffa45534993d00a24f00923400ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000aaa9a9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff181508afb2f94b4844fefdfe1c1a0bacb0ffacacae252420ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8784850000000000000000000000000000000000003b393affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000080708ffffffffffffffffffffffffffffffffffffffffffc4927c923000d4b1a3d9b9b28a2200b57662ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5d4d40000003f3c3dffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffdcdcdc000000000000abaaa9ffffffffffffffffffffffffffffffe5cfcb933400983e08fffffffffffff4ecf09941199c4400a24f03a04d009a410cffffffffffffffffffffffffffffffffffffffffffffffffffffffe6e5e50000002b2a2bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd9d8d8000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6665648f8f7f2c2fff4e4d2effffff221d0c9a9aff484aff82815f474545ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5d4d4000000000000000000000000000000000000131212ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff161515000000fffefeffffffffffffffffffffffffffffffffffffa05029933300e1c8c0ebdad9ad6758fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f2f20000001a1818ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffc7c7c7000000000000c5c5c5ffffffffffffffffffffffffffffffdec2b79436009c471bffffffe7d6d59335039f4a009e48009c4503a04c00a25222ffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c0c10000005d5c5cffffffffffffffffffffffffffffffffffffffffffe5e5e5212020686767939192c2c1c1f7f6f6898788000000000000000000000000000000000000363636ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfbebf4645226768ff2a26ff4e4d2cffffff1d1a08a6a7ff0000ea797eff7e7d5d2d2a28eae9eaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000020101bbb9ba8a88896867674a4849131212adacacffffffffffffffffffffffffffffffffffffffffff3e3d3d000000d7d8d7ffffffffffffffffffffffffffffffffffff963b02933200e6d4cbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffb3b3b3000000000000dfdedeffffffffffffffffffffffffffffffd1ac9a963800ae6945e3cfd38f2f00a24f009a4100a45635cda396983c00aa603bffffffffffffffffffffffffffffffffffffffffffffffffffffff9897970000008b8a8affffffffffffffffffffffffffffffffffffffffffa19fa0000000000000000000000000060505040404000000000000000000000000000000000000979697fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfafb131100a1a5ff0901ed302dff515032ffffff211f10aeafff0f06ed0d05ed6769ffb4b6a628261343413e959494dad8d9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a191a0000000000000000000000000000000000000000000000000000000000000000002e2d2dffffffffffffffffffffffffffffffffffffffffff6b6a6a000000b4b3b4fffffffffffffffffffffffffffffffcfcff913100923200efe2deffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff020202000000fffeffffffffffffffffffffffffff0000ffffffffffffffffffffffff9f9e9e000000000000f4f3f4ffffffffffffffffffffffffffffffc18d77994000a7591e983f00a35000963a00a85d41ffffffc28f73983c00b16e50ffffffffffffffffffffffffffffffffffffffffffffffffffffff706f6f000000b2b1b1ffffffffffffffffffffffffffffffffffffffffff615f60000000000000000000000000000000000000000000000000000000000000000000000000e6e5e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1d1c0daaadd20a05f6251fed221eff626141f1f1f2333127b5b5f20801ee2720ee150deb2727fb9d9ffca7a6ae74745d3c3a2729261e888686ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff424141000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffff959494000000908e8efffffffffffffffffffffffffffffffaf8f8913000923100f2e6e3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0f0f000000e4e2e3ffffffffffffffffffffffff0000ffffffffffffffffffffffff8e8d8d000000000000fffeffffffffffffffffffffffffffffffffb77c5f9c44009f4c00a25100933300b77a65ffffffffffffb16e4c973d00be866affffffffffffffffffffffffffffffffffffffffffffffffffffff4f4e4e000000cdcccdffffffffffffffffffffffffffffffffffffffffff3c3b3b000000000000000000000000000000000000000000000000000000000000000000040202ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff29261aa8aab61613fe241ded251eec1411ff707160d2d1d152504aafb1cd0701f12520ec251eec221bee1109ed1c18f84c48ff7e80ffb2b4de73715d1a170eb4b3b4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6b6969000000000000000000000000000000000000000000000000000000000000000000000000f2f1f1ffffffffffffffffffffffffffffffffffffb7b6b60000006f6d6dfffffffffffffffffffffffffffffffbf7f8913000923100f1e6e4fffffffffffffffffffffffffffffffffffffffffffffffffeffffffffffffffffffffffffffffffffffffffffffffff252525000000c4c1c2ffffffffffffffffffffffff0000ffffffffffffffffffffffff807f7f000000000000ffffffffffffffffffffffffffffffffffffaf6b479e4800a25000902f00c7988dffffffffffffffffffa75d3a973b00c89a83ffffffffffffffffffffffffffffffffffffffffffffffffffffff353435000000e2e2e2ffffffffffffffffffffffffffffffffffffffffff212020000000000000000000000000000000000000000000000000000000000000000000373536ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2b291fb0b2ab1f1cff2119ed241dec251fed0a03f88a8a96a4a29e8f8e8ea5a5910c07f9261fed251fed241eee241eed241eee1e18ec130ced0e09f14e4fffbfc1e13c3922615f5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d8b8c000000000000000000000000000000000000000000000000000000000000000000000000d3d2d2ffffffffffffffffffffffffffffffffffffcbcbcb000000575556fffffffffffffffffffffffffffffffbf8f7913000913000f6f0f0fffffffffffffffffffffffffffffffffffff7f2effffffffaf8f8ffffffffffffffffffffffffffffffffffffffffff383838000000aba8aaffffffffffffffffffffffff0000ffffffffffffffffffffffff6c6c6c000000000000ffffffffffffffffffffffffffffffffffff9b441e963800912e00d8b9b5ffffffffffffffffffffffffa04e23963800d6b5a5ffffffffffffffffffffffffffffffffffffffffffffffffffffff282727000000f1f0f1ffffffffffffffffffffffffffffffffffffffffff0a0909000000000000000000000000000000000000000000000000000000000000000000716f71ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2c2b21aeb0a92828ff1f17ec241fed251dec251fec1009f08b8bdc565448e9e8ea5a583a4140ff221aed241eed251eed241eec241eed241eed251fee261fed1d14eb0a06f3999dff6e6d523c3a3affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafadae000000000000000000000000000000000000000000000000000000000000000000000000c1c1c1ffffffffffffffffffffffffffffffffffffdadada000000444444fffffffffffffffffffffffffffffff5eeee913000963800dcc1bafbf9f9e9d9d6dbbcb1ca9e8ab77a5b963a11e3cdcaffffffffffffffffffffffffffffffffffffffffffffffffffffff414141000000929192ffffffffffffffffffffffff0000ffffffffffffffffffffffff686868000000030303ffffffffffffffffffffffffffffffffffffe3cdc4cfa997e4cecbffffffffffffffffffffffffffffff902e00881e00ddc0b7ffffffffffffffffffffffffffffffffffffffffffffffffffffff1f1e1e000000fbf9faffffffffffffffffffffffffffffffffffffffffff010000000000000000000000000000000000000000000000000000000000000000000000aeacaeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c59578687772a29ff1f16e52822ff241eee251eed241fec1d16ec6567ff343212ffffff110e00a6aaff0d05ec251eed241eed241eec241eed251eed251eed231fed241dec251eed0902ed7276ff7b7b5d4f4d4dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bfbf000000000000000000000000000000000000000000000000000000000000000000000000b1afb0ffffffffffffffffffffffffffffffffffffe5e5e5000000333132fffffffffffffffffffffffffffffff4edee8c2700a351009a44029c450a943500923100993f008b2400b17057ffffff994325ffffffffffffffffffffffffffffffffffffffffffffffff4a494a000000838282ffffffffffffffffffffffff0000ffffffffffffffffffffffff676767000000060405ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe8d7ced8b7abf3eaeaffffffffffffffffffffffffffffffffffffffffffffffffffffff191818000000ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000d3d2d3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d4d73f3d1a5959ff1a12fd1711760e0a572721ff241ef2241dec241eed211dff5f5e40e9e8e9605d5db5b7a70906f7261fee241eed251ded231fee251eec251eed231eed251eed241dec2721ee0a01ec848bff5251339a999affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc6c4c5000000000000000000000000000000000000000000000000000000000000000000000000a6a6a6ffffffffffffffffffffffffffffffffffffeeeded0000002a2a2affffffffffffffffffffffffffffffffffffa85e45953700a14d069c4400a65729b77d5d953800d4b1acffffffcda498861b00ddc2b8ffffffffffffffffffffffffffffffffffffffffff4e4d4d000000818181ffffffffffffffffffffffff0000ffffffffffffffffffffffff676767000000060606ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff111011000000ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000eeededffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff312f27b5b7e50300ef2923ff110d5b1d1c00151139231cee251ff9251eed0c05f19396d1545246ffffff1a1901979bff0f07eb251eed241eed241fee251eed241eed251eed251eed241ded251eed2620ed0300edbabeff0a0800f9f7f8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc7c6c6000000000000000000000000000000000000000000000000000000000000000000000000a5a4a4ffffffffffffffffffffffffffffffffffffefeeee000000272626fffffffffffffffffffffffffffffffffffffffffffbfaffa55734cca290ffffffa1502eac6440ffffffffffff9e4a27993f00b67866ffffffffffffffffffffffffffffffffffffffffff504e4f000000818181ffffffffffffffffffffffff0000ffffffffffffffffffffffff676767000000060505ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff191819000000ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f6f73c3a195354ff2018ec2720ff15113e7d7a74afaea3000000221bd2241ff5221aec4444ff3d3b14ffffff575556a9a9912322ff231ced241eed251eed241fed241eed251fec241eed241eed251eed241eed261eed0b08f7c2c2b73a3836ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc4c2c3000000000000000000000000000000000000000000000000000000000000000000000000aaa8a7ffffffffffffffffffffffffffffffffffffededed0000002b2a2affffffffffffffffffffffffffffffffffffffffffc290838d2700d3b2a5f2eaeb831400d8b9adffffffffffffd0aa978f2d00fdfcffffffffffffffffffffffffffffffffffffffffffff4d4d4d000000818181ffffffffffffffffffffffff0000ffffffffffffffffffffffff686767000000030303ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1f1e1e000000fbf9faffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9a98989192860a06fb251feb2821ff000006ffffff1a1819d0cec40000112a23ff251fec0901f39ea0d038362affffff000000d1d3f10100f12720ed241ded251eec251eed241eed241eed251eed241eed241fed251eed160fec7b7eff2d2b0fe7e5e7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbcbabb000000000000000000000000000000000000000000000000000000000000000000000000b9b8b8ffffffffffffffffffffffffffffffffffffe5e4e5000000333132ffffffffffffffffffffffffffffffffffffffffff8c2600983e00dabaaec08c748b2400fefeffffffffffffffd4afa18f2f00ffffffffffffffffffffffffffffffffffffffffffffffff4a4a4a000000848182ffffffffffffffffffffffff0000ffffffffffffffffffffffff7e7e7e000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff282728000000f1f0f1ffffffffffffffffffffffffffffffffffffffffff0a090a000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d5c519798d10a03f1251fed2720ff060600ffffff080708f9f7f82222072018e8241df0241dec2c2bff696746a9a8a8dddcdd27260da6a9ff0700ec2520ed251eec251eec241ded241eed231fed251eed241eed251eed251fed0602f5bcbcb64e4d4bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa7a4a5000000000000000000000000000000000000000000000000000000000000000000000000c6c6c6ffffffffffffffffffffffffffffffffffffdad9d9000000454444ffffffffffffffffffffffffffffffffffffffffff953a00993f00d2afa19b440ca75c38fffffffffffffbf9ff8d2a00923000ebdcdcffffffffffffffffffffffffffffffffffffffffff414041000000929192ffffffffffffffffffffffff0000ffffffffffffffffffffffff8a8a8a000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff363536000000e3e2e2ffffffffffffffffffffffffffffffffffffffffff252324000000000000000000000000000000000000000000000000000000000000010000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff393725898cf9120ced251eec2721ff00004fc3c3b2ffffffffffff9f9e8d00005d2821ff251fec120aec8486ff242203fcfcfd8785876765456b6fff130aeb261fed231dec251eec251eee241ded251fed241eed241eed251fed1108ed9e9fff131100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff868585000000000000000000000000000000000000000000000000000000000000000000000000d7d5d6ffffffffffffffffffffffffffffffffffffcacaca000000575656ffffffffffffffffffffffffffffffffffffffffff9b430c9f4900ab653c881e00eadadcffffffffffffffffff983e08902f00f6eff1ffffffffffffffffffffffffffffffffffffffffff393838000000aaa8a9ffffffffffffffffffffffff0000ffffffffffffffffffffffff9c9a9b000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f4e4e000000cccccdffffffffffffffffffffffffffffffffffffffffff404040000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff38361a6f6fff1911ec251eed241eed271fff000000ffffffffffffffffff0000002a23ff2721ff2922fd0600f1b2b5e7181705ffffff3b3938a9a8913435ff1f17ed241fec241eed251dec241eee251eed251ded251fed241eed231cec3939ff636243c7c5c7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff656464000000000000000000000000000000000000000000000000000000000000000000000000f0efefffffffffffffffffffffffffffffffffffffb5b5b50000006f6e6effffffffffffffffffffffffffffffffffffffffff9e49229b4200902d00dfc6c3fffffffefefeffffffffffffa05138e0c8c3ffffffffffffffffffffffffffffffffffffffffffffffff262425000000c4c1c1ffffffffffffffffffffffff0000ffffffffffffffffffffffffb0b1b0000000000000f4f4f4fffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcfef1e7e5dcc1b5dcbeb1eee1dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff706f70000000b1b0b0ffffffffffffffffffffffffffffffffffffffffff666365000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff38361e7071ff1811ed251eed251eec251ff8150fbe3a3a22ffffffffffff61604a120ba60a0566161084271fff1512fcaaacac3c3933ffffff0f0d05ced0d40a06f5251fed231eed241dec241eed241eed251eed251dec251fec251fed0803f6a8a9a1716f6effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff413f3f000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffff939293000000908f8fffffffffffffffffffffffffffffffffffffffffffcda49aa9603ef3ebedfffffffffffffefefefffffffffffff3e9e7ffffffffffffffffffffffffffffffffffffffffffffffffffffff101010000000e2e1e1ffffffffffffffffffffffff0000ffffffffffffffffffffffffc4c4c4000000000000e0dedefffffffffffffffffffffffffffffff1e7e3d9baafc49177ac6744a04d16973a00943800963900923200bb8272ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9998980000008a8888ffffffffffffffffffffffffffffffffffffffffffa09e9f0000000000000000000000000000000000000000000000000000000807071c1b1bf8f7f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c4a387e80e5130cee251fed231eed251eec2923ff000046a4a193d7d6d6151413000000615f501716052820ff1d16eb3c3eff77765a7e7c7dffffff0d0a00bdc1ff0500ed2620ee241eed241eed241eed241eed241dec241fed251fed0600efbcbde334322dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff181616000000080208000000000000000000000000000000000000000000000000000000020202ffffffffffffffffffffffffffffffffffffffffff6b696a000000b5b3b4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff030202000000fefdfdffffffffffffffffffffffff0000ffffffffffffffffffffffffdadada000000000000c6c6c6ffffffffffffffffffffffffffffffa75c40943400983e009d4600a04c00a14f01a14f01a14e00a25001902d00cda59cffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c1c10000005c5a5bffffffffffffffffffffffffffffffffffffffffffd7d6d6000000000000000000000000000000101010474546878686c4c3c4f2f1f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7673687a7db40e06f4251fed241eee241eec241df02e26ff000000000000524f50e1dfdfffffff1a1a00241bf1251eef130cec6f72ff353410e1e0e1a4a4a55f5d3e5f61ff1b12ed251eec241eec251eed251eed241eed231eee2620ee0c04edadb0ff211f12ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000001e1c1cffffffffffffffffffffffffffffffffffffffffff3e3d3d000000d8d7d7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffefefef000000000000acaaaaffffffffffffffffffffffffffffffc799839a3f00a04c009c4400983e00953a00973d029c46109a4000a35000973e11ffffffffffffffffffffffffffffffffffffffffffffffffffffffe7e5e50000002a2929ffffffffffffffffffffffffffffffffffffffffffffffff0000001c1b1c5e5d5d9b9a9bdad9d9fbfbfbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafafae70716f110bff251fec241eed241eee2720f2050233383632d8d7d7ffffffffffffffffff343522150ea8251ff92620ec0801ef9ea2f4121100ffffff292825c7c8be0b06f5261fed231fed251eec251eed241fed251eed241eed0e08ea9fa0ff262412ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd1d0d00000000000000000000000000000000000000000000000000000000000000000000000003e3d3dffffffffffffffffffffffffffffffffffffffffff141415000000fffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f3f3000000191618ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff100e0e0000007c7a7bffffffffffffffffffffffffffffffe0c5bd8a2200a25219b16f4ec79a81dec3bcf4ece8ffffffba816c9c43008e2c00f7f3f3ffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffffffffffe7e6e6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf9fb3b39183633ff231ded251fed241ef0271fe70000104d4d3bffffffffffffffffffffffffb8b7af0000112d25ff241eed261fec0e09fd9697995e5c57ffffff1513009ca0ff1108ec251fed241eed241eed241ded251fed251fed0e07eba3a4ff262313ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb7b6b71413121a1a1a1313130f0f0f0b0a0a0505050100010000000000000000000000000000005a5858ffffffffffffffffffffffffffffffffffffffffff000000080808ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5d4d40000003d3c3cffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff292727000000515050fffffffffffffffffffffffffffffffaf8f8efe2defefffffffffffffffffffffffffffffffffffdfdff8f2e00953700dec4beffffffffffffffffffffffffffffffffffffffffffffffffffffff232223000000f1f0f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2e2d148080ff150fed241eec251eed251ef22b23ff000058545240ffffffffffffffffffffffff35342300005c2a22ff241fef1e16ec4e4dff3c3a16fffeff646363b0b0981211fa251eed231eed251eec241eed2019ed251fed1009eb9a9cff24220ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfdf8f8f8f3f2f2ebebebe6e5e6dfdfdfd6d4d4c6c5c5bebdbda9a7a8d5d5d5ffffffffffffffffffffffffffffffffffffd7d6d6000000383738ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb4b4b4000000595758ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff4a494a0000002c2c2cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1e8e9923200973a00d5b2a0ffffffffffffffffffffffffffffffffffffffffffffffffffffff5c5b5b000000b5b4b4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f7e7b8f90990703f8261fec241eed251eed231ded2c25ff00002cb6b5aaffffffffffffffffffffffff8a89730000102821fd2620ed0a03f29496d9413f31ffffff131100979aff120bec251fed241eee1f18ed4444ee0d09eb1d14ec6c6cff333111fbfcfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9998980000007d7c7cffffffffffffffffffffffffbd8672ba7f63c99b84eee0deffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff817f7f0000008d8c8cffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffff767476000000050405fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf5f6e9d8d2d5b3a49f4b1ca04c00953600d9baafffffffffffffffffffffffffffffffffffffffffffffffffffffffa9a8a8000000666464fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f9fa3d39165253ff2019ec251dee251eed231eec241ef11911dc53523bffffffffffffffffffb4b3b34845460905442720f5241eed231dec302eff4a4929fcfbfd555352bcbeb80601f4251fec251eed2019ed4747f0d2d6fc120ff40f0bfba0a085787778ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff484747000000c2c2c2ffffffffffffffffffffffffd5b2a99f4c27892200913100aa6036d8b8adfefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c4b4c000000bdbbbbffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffa8a7a7000000000000fbfafaffffffffffffffffffffffffffffffecdedad1ab99ba8065a75b2c9a420c963a00953800a04b00a351018c2800fbf7fcffffffffffffffffffffffffffffffffffffffffffffffffffffffedeced0000001a1919ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3e3b33b3b4da0300f02520ed241ded241fec251fef1c15ec504f38ffffffbfbcbe323131110e0c0000002f28ff241eee251dec261fee0b03f38e90c2656159ecebec4e4e2b4f4eff2019ec251eec261fec0a04f6cdcca7b6b8c41b1cffa4a6ff090700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff020001000000ffffffffffffffffffffffffffffffffffffffffffe3cbc7a95f38913000902f009c460ec28f7cf2e8e7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1e1d1e000000e7e6e6ffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffd5d5d5000000000000d0cfd0ffffffffffffffffffffffffffffffc18e7a8d28009b43009f4900a14e00a14f01a14e009e4900902c00c89d94ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0d0c0c000000f9f9f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdad9db4c4a294b4dff1f18ed251fee231dec251ff61b14b5282908514e4e555353dddcddfaf8f90000001f18b0261ff9251eed251fee1f17ec5759ff33310effffff131000a8abff0f08ed251fed251fed0600eebbbef6000000adada2787cffa8a8a3424141ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2e1e2000000242424ffffffffffffffffffffffffffffffffffffffffffffffffffffffe4cecca9603b933500943600963900af6a46e1cac3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffafafa070606000000979595ffffffffffffffffffffffffffffffe3cdc49333009e4a009b4200983c00963b009a4108a5572adabbb6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5e5d5d000000a5a4a5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff33312bbdc0d40400f3251fed251eec2620fd181285130d7a000000f8f6f6ffffffffffff43413c00001c2a24ff241eeb241ded261fed1916ff65654fe5e3e453524fbfc1c90300f22520ed251eed1c14ec787aff37351a454342464535dcdbde191718b4b3b4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8484840000007b7a7bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4cfcaa9603b943700993e0094360093360be9d8d2ffffffffffffffffffffffffffffffffffffffffffe5e5e5000000202020ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffff2a2929000000484748fffffffffffffffffffffffffffffff5efef8a2300a85c2fba8061cea795e9d8d3f7f2f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c1c10000003c3b3cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe9e9ea2d2c0e7275ff1810ec241eee241dec2520f92b24ff0a055a3d3c2fffffffffffffd7d5d50000002820e5241ef0241eed261eed0a04f48f90af888782afaead8b8b7c1714fd251eed241eed231eec2624ff7c7a5acdcbcdb8b6b73332313937379d9b9cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff212021000000dcdbdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe3cdc8a85d358e2c00cea69affffffffffffffffffffffffffffffffffffffffffffffffafadae000000595759ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffff626262000000111010fffffffffffffffffffffffffffffffffffff4ecebfffffffffffffffffffffffffffffffffffffffffff8f4f5c3927fd3b0a4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff605d5ba0a1931412fe261eec241eee251dec231dee2b23ff000000e6e4e3ffffffffffff2321160c085d2821ff241eec251eed1109ef8e8fea575444e6e5e75f5f393c38ff211ceb251eed251fed0702f5abacae686664fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2f2000000080808ffffffffffffffffffffffffffffffffffffa85c45a95f2ba45829d7b5abffffffffffffffffffffffffffffffffffffeee2e3ffffffffffffffffffffffffffffffffffffffffffffffffffffff5e5c5d000000a4a2a3ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffababab000000000000faf8f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeadad6b77b60973c049538009f4d23ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff514f51000000a2a1a1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff141100afb2f90700ee2620ec251eed251eec2721ff0b066b444335ffffffffffffb6b4b30000002b24ff241eed241eec1810ec8184ff333019ffffff423f205556ff1f18eb251eed2620ee0400efbfc1eb312e28ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8281810000006e6c6dffffffffffffffffffffffffffffffffffff9a410f9d4600a04c128921009f4d1ddcbfb6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1c1b1c000000e2e1e1ffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffe5e5e5000000000000bbb9bbfffffffffffffffffffffffffffffffffffffffffffffffffefdffd5b2a8a65b309333009c4200a14f00a14e00871e00efe3e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffc9c9c9000000252324ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcecdcf4a49255b5dff1a12ec241fee251eed241ded2a23ff000000ecebe9ffffffffffff06060019129a2520fc251eec1a12eb7b7eff252207ffffff302d136d70ff1c14ec241eed2620ec0d06eca4a8ff232011ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0e0e000000e4e3e3ffffffffffffffffffffffffffffffffffff973b00963900dcbfb6d8b9b39539008c2600a4552ae0c7c2ffffffffffffc6978dffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffff191818000000626161fffffffffffffffffffffffffffffffffffff0e5e2bf8b7699410e9538009f4900a14f019e4900963a009a430fbd8770f7f0efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff070606000000e4e4e4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff605e5c9fa0931411fe251eed241eee241dec2821ff0905634c4b3dffffffffffff93928d0000062b24ff241eec1a13ec7c7eff1f1d02ffffff2b29117779ff1a12ed251eed241fec140cec8c8dff27230dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcac9c90000001f1f1ffffffffffffffffffffffffffffffffffffffdfcff923100943700dec3bdfffffffdfcffb97e68902f00902d00b2714eab6540851900f8f4f9ffffffffffffffffffffffffffffffffffffffffffc2c0c10000003f3d3effffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffff5c5b5b000000131212ffffffffffffffffffffffffffffffffffff8720009a4000a14d00a14e04a14e029e4907ac643ed7b7acfeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8483830000005b5a5bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a1708adb1ed0600f1261fed241eed241fed2a22ff000000eeeeebffffffffffff000000231bd5241ff31810eb888aff181500ffffff2f2c147174ff1b13ec241fec251eed150dec898aff28250effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f3e3f000000a5a3a3fffffffffffffffffffffffffffffffffffff3e9e7902e00923200eadad7ffffffffffffffffffe9d8d7a4532a9131009e48009b4100bf8a79ffffffffffffffffffffffffffffffffffffffffff646363000000969495ffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffb5b5b5000000000000f2f0f1ffffffffffffffffffffffffffffffb16f539e4800a14e04a14d049f4900ab6336dbbfbaf6f0efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1e0e1312f0d787aff140cec241eed251fed2721ff0c0771464636ffffffffffff72706700003c2a24ff1109eca1a4ff100e00ffffff3c3a1b5959ff1e18eb241fee261fed0c05eba6aaff221f10ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeeeeee000000000000fffffffffffffffffffffffffffffffdfdffffffffe2cbc39434008f2e00f8f4f6ffffffffffffffffffffffffffffffcea59a953800a24e00923100ede0ddffffffffffffffffffffffffffffffffffff111010000000e9e8e8ffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffff6f6f6000000000000999898ffffffffffffffffffffffffffffffe5d0ca892000983e009d4600a04c009e4800963a00943600a04d1bb47556d1ab9cf2e8e6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c5a5b000000787677ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7573749291742524ff231bec241eec241eed2c23ff000000edebe9fffffffdfcfb0000002a23fd0c05eea8a8f6252215f7f6f75756324540ff211bec241eed261fee0300eebfc1e2373630ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5554550000007a7979fffffffffffffffffffffffffffffffefeffffffffcb9e8e993f00923400fffffffffffffffffffffffffffffffffffffffffff7f1f58e2c00923300d2aea7ffffffffffffffffffffffffffffffecebeb0000000c0c0cffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff3a3838000000333233ffffffffffffffffffffffffffffffffffffe8d5d0cda38eb06d4d9c460d963b00993f00a14e00a04c009b4300973a008c2800fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0efef000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1e1b12bdbfd30701f5261fed241ded2720ff0d077b504e3cffffffffffff5653430e087c0903ffaeb1e2433f37d4d3d46a6b4d2e29ff231ded241eee251eed120ffc989984868585fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f2f3000000000000ffffffffffffffffffffffffffffffffffffffffffffffffc38f78993e00a14f1fffffffffffffffffffffffffffffffffffffffffffffffffe6d1d0f1e5e5ffffffffffffffffffffffffffffffffffff8f8e8e000000656363ffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffff9a9999000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4ebead1ada29d490ca14e02a14e04a14f04943400e0c7bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5352530000006d6c6cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5f4f51c1a009899ff0c04ed251fed241eed2b23ff000000edebe9ffffffebe9e60000000e05ffb6b7bb686564bebdbd82816f1b19ff241eed251fed1a13eb7576ff272409f6f6f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4e4d4f000000727071ffffffffffffffffffffffffffffffffffffffffffffffffe5d3d4913000af6a4bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff242324000000d1cfd0ffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffff1f0f0000000000000a6a5a5fffffffffffffffffffffffffffffffffffffffffff4eeeff5eeefc5957ea15024a04b00a14e03a14e029e4a00943500a9614ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6f5f5000000000000f3f2f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa09e9f6665424445ff1e16eb251eed2720ff0e08824a4836ffffffffffff3837230501a9a1a19ca19fa0bdbcbb8282731a17ff241eed261fed0100f0c7cada2d2b27ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdede000000000000ffffffffffffffffffffffffffffffffffffffffffffffffa95f44a455249d44009b4307dec3bcf9f5f1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f3f3000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff383636000000313131ffffffffffffffffffffffffffffffffffffe1cac6ab653f943600983d00a14e00a04d009c4400963800a25328d3afa1faf7f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6d6b6b000000403d3effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff413f3aacafac0d0af9261fed241eec2c24ff000000ebe9e6ffffffd4d2d105060b777678d1d0d0c2c1c36f70512b26ff231dec221aed4543ff5d5d3dc3c1c2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2221220000008e8c8dffffffffffffffffffffffffffffffffffffffffffffffff9e4b249c4300b47449b371529438007f1200faf5f3fffffffefefefefffffffffffffffffdfdfdfefdfeffffffffffffffffffffffffffffff8c8b8c000000605f5fffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffa8a7a7000000000000f7f6f7ffffffffffffffffffffffffffffffbd8776963700a25001a04c00993f00963a00b47457e6d2ceffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000bfbebeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1614009ea1ff0b04ed251fed271ffe110b91464531ffffffffffff23211f020000ffffffe6e5e7504f2b4846ff221bec0c04ecb4b7ff0e0c00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa2a0a10000000c0b0bffffffffffffffffffffffffffffffffffffffffffffffffffffffe4d0cd902d00a75d3bffffffffffffefe3dffdfdfdfffffff9f8f8fdfcfcfffffffffffffefefefefefeffffffffffffffffffffffffffffff171616000000d8d6d6ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000888686fffffffffffffffffffffffffffffff9f7fa8b24009639009f4c18c08c7af8f2f4ffffffffffffffffffffffffeadad7963c1eeddfdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffacabab000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbcbcbd5c5b363e3fff2019eb241eec2b23ff000000ebeae6ffffffc2c0c1000000ffffffffffff1715009395ff150deb0803f6b1b1ab696867fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcfc000000000000cac9caffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa4542c953800bf8a72eddfdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcdbdc0000000f0e0effffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c5b5b0000000b0a0affffffffffffffffffffffffffffffffffffb06e60dfc3b8fffffffffffffffffffffffffffffff7f2f3b4745a9130009c4300aa6143ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff353434000000575557ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3c3a32a9aac00702f5261fec261ffc120d9b42422dffffffffffff020000d1d0cfffffff353430c3c7d50000f03330ff6e6d4ac3c2c4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff393838000000535151ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcea69f9638009f4a008f2e00892200a95e53ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5b5a5b000000878686ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5d5d5000000000000c7c5c7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf8fbc597869233009b4200a25003a25000851a00eddfe0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcfd000000000000b3b2b2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeff2624016365ff1c14ec241eec2b23ff000000e7e5e2ffffffa4a1a3232121ffffffd2d1d13d3b207474ff4345ff3f3c21f0eff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff989697000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdff8d2900a14d00a05027f8f2f4f4ebeaf0e4dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000fcfbfbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff292829000000383637ffffffffffffffffffffffffffffffffffffffffffffffffffffffc59789943700973b00a24f01a14e029a4200953701c89a8bfdfcfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb0afaf000000000000f2f1f2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff63625f9394a00c06f8251fec251ffb130da03f3f29ffffffffffff000000e4e1e1ffffff3c393aa4a493757aff38351ef2f1f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2e1e2000000000000c6c4c5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe87759b4200902e00f0e4e6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9493930000004a4949ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadacac000000000000ecebecffffffffffffffffffffffffffffffffffffe8d6d0994117953900a24e01a14f039e4700933400b5765ffaf8fcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff575656000000171616fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafafb3a38113735ff231ced231deb2b24ff000000e4e3deffffff8f8d8e383737ffffffffffff080501dbdbdd4a4847d6d5d6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff050303000000747374ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff902f00a14c00a65a37ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff090809000000d5d3d4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff110f10000000585657ffffffffffffffffffffffffffffffffffff9335139f4b00a14f049f4b00943600a45836ebdddcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff181717000000464444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3331197272f81912ed251fed251efb1a15a73d3b2affffffffffff000000f3f2f3fffffffaf9fa0c0b0a4a4849b7b6b6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3130300000002f2e2effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9e4d209f4a00aa5f27bd846dd2ac9ffefefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb5b4b4000000201f20ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff939393000000000000fdfbfcffffffffffffffffffffffffffffffe3cdc9912f00983d009b4415dabcb5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbf9f9000000000000727070ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff84817a7a7ba40d07f6251fec1710ec8589ff020100e0dee0ffffff7e7c7d4b4a4afffffffffffff5f5f5000000a3a0a1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5351510000000a0909ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb67a699a41009f4a00983e05a5562d882000f0e4deffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff191718000000bab8b9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff070506000000646363ffffffffffffffffffffffffffffffffffff994225c59684fffffffffffffffffffffffffffffffffffffffffffffffffdfcfdd8b5a9e0c7c1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd3d2d20000000000008b8a8affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c0c165645d120fff2620ec120aef9294ef2a2716323133ffffffffffff000000fefefeffffffffffffe6e6e67d7b7cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff727070000000000000ecebebffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd8b8b28f2c00a14e00984116fdfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0bebe000000111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d8c8d000000000000fcfcfcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf6f7d8b8adb3714e963b079535008e2c00fefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb8b7b7000000000000959494ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4e2e34b4c37211aff251fec0d07f97b7b95aeaca80f0e0fd9d7d7ffffff6d6a6b615f5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f7d7e000000000000cccaccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff902f00a352008f2b00f6f0f5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1b1a1a000000b0aeafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff090709000000585758fffffffffffffffffffffffffffffffffffffffffffffffffffffff8f1f1d3aea2ae673f9539019436009e47009f4b00a14f039d4700a55836ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa6a5a50000000000008f8d8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeae8e944462f241dff251eec2320ff47462df2f2f2bababa201e1fffffffffffff000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7a7979000000000000bcbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc28d7e993e00983c00c59588ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb4b3b3000000141313ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9e9c9c000000000000e9e8e8ffffffffffffffffffffffffffffffffffffc8998ca95f349537009437009e4900a14e009d4700953800a6592ba14c03a25003892100f2e7eaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa09f9f0000000000007c797affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcdbdc50523f1e18ff1c15eb6564ff2d2b09ffffffffffff010001d7d5d5ffffff5754557b7a7bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff636162000000000000b7b5b7fffffffffffffffffffffffffffffffffffffffffffcfafbfaf6f7fffffffffffffffffffdfdff8e2c00a25100923501ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0c0a0c000000bbb9baffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff191818000000383737ffffffffffffffffffffffffffffffffffffb7786a943400a25001a04b00993e00943700ae6645e9d6d1d5b2ae983d009a4200b97c6affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa9a8a9000000000000595859ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaeadac757471110dfd0e07f77b7ea574716affffffffffffbbbaba1a1819fffffff9f8f8000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff434243000000000000bebdbdfffffffffffffffffffffffffffffffffffff3e9eaa75b39994007983e03a04d18b7795cf3eaeab577629d4400943600d2ada3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9190900000001f1e1effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c1c1000000000000c3c2c3ffffffffffffffffffffffffffffffffffff9d4a26923300a14d1ec89a8bf6efeffffffffaf8fc8d2900a35100903000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfbebe0000000000002e2c2cfaf9faffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6866609a9cbc0900f23432ff3c3a17f6f5f6ffffffffffffffffff050304d3d0d1ffffff413f408e8d8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeeedee1a1819000000000000d2d0d1ffffffffffffffffffffffffffffffffffffffffff9031059e47009f4a00993e009638009130009437009c4600a14e00994016ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000d9d8d9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff414040000000060605fffffffffffffffffffffffffffffffffffff5efeedbbdb5ffffffffffffffffffffffff9c4824a04c00943500d4b0aaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1e0e0090809000000000000d1d0d0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff201e098d90ff0100f18386d83e3b2affffffffffffffffffffffffc5c2c3090708ffffffeeedec000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbaba000000000000141313f1f0f1fffffffffffffffffffdfbfcddc3baf7f1eeffffffd5b3aa943500963900a04e21cc9f8decddd8fdfdffa14f1ea14f00953600dfc5beffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff525050000000504f4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2f2f1000000000000767575ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc99b92953700a14d009d4722fffffffffffffffffffffffffcf9fa9e4a2effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2c2a2b0000000000007a7878ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0dee05654323d3cff3230ff383614e4e3e5ffffffffffffffffffffffffffffff181717aeadaeffffff3533349a9899ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff666565000000000000434141ffffffffffffffffffffffffffffffefe3e08214008b2700ffffffa14f22933500d8b7b0ffffffffffffffffffd3aea5943600a14e019a4100993e12ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd0ced0000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8b8a8a000000000000e8e7e8fffffffffffffffffffffffffffffffffffffffffffffffff5eff28d2900a353028e2b00efe1e2ffffffffffffffffffffffff9c4522983e009d4927fffffffffffffefefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7675750000000000001e1e1edddcdcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4c4b47bababf0000ff7c7d91595853ffffffffffffffffffffffffffffffffffffe0dfdf000000ffffffe9e7e8000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfcdcd1210110000000000008a8889ffffffffffffffffffffffffffffffc3917aa75a28983d00a04e29ffffff7f0e00f5eff1ffffffffffffffffffffffff943807a25100973c02cda698922f00b67b67ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff080707000000979595ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2120200000001c1b1bffffffffffffffffffffffffffffffffffffffffffffffff9d4822a04c009c4300b3735dffffffffffffffffffffffffb26f58983e00a14f049d4600984015fcfbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcdcbcc0e0e0e000000000000676567fffefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff24230a6a6dff7879b825220bffffffffffffffffffffffffffffffffffffffffffffffff2726269a999affffff2c292aa3a2a2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f6f6575657000000000000171717dbd9d9ffffffffffffffffffffffffffffffffffff963c118e2700d3ae9efdfcfecb9d8ac39182fffffffffffffffffffffffff0e5e48f2d009a3e00c89d90ffffff9231008f2d00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6b6a6a000000232222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4e4e40000000000007f7d7effffffffffffffffffffffffffffffffffffebdbda8a2200a452008f2d00ffffffffffffffffffffffffc49284933300a24f049e4a00983e009f4a0095380cfbf8fafeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff686667000000000000000000939293ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5655559c9aa253546a2a2915ffffffffffffffffffffffffffffffffffffffffffffffffffffffe8e7e7000000ffffffe3e2e1000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff838383000000000000000000787778ffffffffffffffffffffffffffffffffffffffffffffffffdec6beb47560eee0ddffffffe5d0c9fdfdfefffffffffffffffffffffffffefeff8c2700903000ffffffecdfdf943500923200e3cecbffffffffffffffffffffffffffffffffffffffffffffffffffffffd6d4d6000000000000f0efefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8c8a8b000000000000d8d8d8ffffffffffffffffffffffffffffffffffffc18b7d8b2300cfa89dffffffffffffffffffdec2c08d2a00a251039e4a00a65937dec2bc8f2d00a14d00923201f5ecedffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd7d7d72b292a0000000000000b0b0b989698fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f7f8050203302c2c928f8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b3a3a7f7d7effffff1f1d1eacaaacffffffffffffffffffffffffffffffffffff898888020102000000000000383637e7e6e7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1c7c68f2e009d4a279132009a41008a2500f8f4f7ffffffffffffffffffffffffffffffffffffffffffffffffffffff0201010000008f8f8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff323031000000040303ffffffffffffffffffffffffffffffffffffffffff9e4d37fffffffffffffffffff1e4e68d2800a35102a24f02933600ffffffffffffdbbcb98e2b00a24e008f2f00edddd9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb3b1b1161516000000000000040304797878eeededfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5f4f4000000ffffffdad8d8000000ffffffffffffffffffe6e4e56c6c6c000000000000000000201f1fc0bebfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5b2a9fefefffffffffffffffffffffbf9fbcea492bd8563c18d78f4ebecffffffffffffffffffffffffffffffffffffffffffffffffffffff4948490000002e2c2cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefe000000000000454343ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff903100a14f00a24e049a42009d4600ae6751ffffffffffffe1c8c58f2e00902d00d2aca4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaa8a91c1b1b0000000000000000003c3b3badacacfefefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff504e4f676666ffffff121011b7b5b6ffffffbfbdbd000000000000000000272627b6b5b5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc6978d8b2300943701d5b4abffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c9a9b000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc5c4c40000000000008c8a8bffffffffffffffffffffffffffffffffffffffffffffffff9b431c9f4900a24f03953800cba192913200993e00a65a3fffffffffffffe0c5bcbb8376fffffffefefeb67968ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1c0c1414040000000000000000000000000403e3f9b9a9ae0dfdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000ffffffcfcdcd010000ffffffffffff4e4d4d3c3c3ccdcccdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc29285912f00a352019b4300892100c39080ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdcde000000000000c2c2c2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff838283000000000000c6c4c6fffffffffffffffffffffffffffffffffffffbf9fa963a109d47009c4500ba7f69ffffffe4ccca8f2d009a4000a1502ffcfafcffffffffffffffffffbf8b778f2b00994010e1c7c0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeeeded878585252324000000000000000000000000111110444343878687b9b7b7dcdbdcfbfbfbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f8f9d8d8d7b5b4b56d6b6dc7c4c5ffffff696768444141ffffff020102bfbebfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb87d6a923100a452018f2c00dcbfbec99d8b851900dec3bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000787577ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff484646000000000000f3f2f2ffffffffffffffffffffffffffffffffffffffffff9c47239d4500943500d9b7b3ffffffead8d9902f00892300eddfe1fffffffffffffdfbff8d2a00a35003993e00b57666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe3e3e3918f913c3c3c0000000000000000000000000000000000000000001312132525263535344140414b4a4a4c4b4b4b494a3f3f3e343434242424111011000000000000000000000000000000ffffffffffff000000ecebebaba9aa1d1c1cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa85f47963900a350008f2c00d3b1acffffffffffff913100903100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1f1d1e0000003b3a3affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1c1b1a000000040204ffffffffffffffffffffffffffffffffffffffffffffffffa14f2d9c43008e2b00d0a99effffffe5d0cdd9b7aeffffffffffffffffffaf6a519e4600a14f00913100ffffffffffffffffffeee1dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd2d1d29897985b595a2a292a0909090000000000000000000000000000000000000000000000000000000000000000000000000000000c0c0c2d2d2e605e5f90908ff2f2f2ffffff807e7f121011ffffff000000fbf9f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdec4bafaf8f9d5b2a7913000a150008e2c00dcc1bcffffffffffffffffffb06e4d933300cca193ffffffffffffffffffffffffffffffffffffffffffffffffffffff4b49490000000a0809ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefe0402040000001e1c1dffffffffffffffffffffffffffffffffffffffffffffffffa6593c9a41008f2e00c99a88fffffffffffffffffffffffff0e4e48d2900a25004953700d4afa7ffffffffffffc18d78892200a65a36f7f1f2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f3f3d9d8d9c8c7c8b9b7b8a4a2a2979696929192979696a5a4a5bbb9bac9c9c9dbdadbf6f5f5ffffffffffffffffffffffffffffffffffffffffff000000acaaaa4d4b4baba9aaffffffffffffffffffffffffffffffffffffffffffeee2e0e1c8bfd8b5a6d7b5a7ddc1b5fffffffffffffffffffffffffffffffdfdff831500933400ad683e9e4900953804ede1e3ffffffffffffffffffffffffd4b1a28a2300913309ffffffffffffffffffffffffffffffffffffffffffffffff676566000000000000fbf9faffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeaeaea000000000000373537ffffffffffffffffffffffffffffffffffffffffffffffffac634a993f00831700f6eff2ffffffffffffffffffa354329f4b00a24e009a420effffffe8d5d2983d0e983c00a251039f4900801200d9b9b3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f7f80000000a0808959394fffffffffffffffffffffffff6f0f2b27152973c059232009334009334009132008d2700973e14f9f5f8ffffffffffffffffffffffff913100a24e00a251238c2800dfc5bfffffffffffffffffffffffffffffffffffffefe4e1c89b89fbf9f8ffffffffffffffffffffffffffffffffffff838182000000000000dbdadaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd5d4d3000000000000474546ffffffffffffffffffffffffffffffffffffffffffffffffa75b45dbbdb4ffffffffffffffffffe1c9c5912f00a14f049f4b009e48009c4510923300a14e00a14d019d4600903000d2ab9cfffffffffffff6eff0f4ece9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f3f33b393af2f2f2fffffffffffffffffffefeff8b25009c4500a14f00993d00953a009d4714a85e37b67652b37450871e00f7f1f3dfc5bcc6967ec593779f4a08913000ffffffc59383821600dec3bcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999798000000000000c1c0c0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3c2c30000000000004c4a4bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff973d10a14e009f4b00a75b2ba04e219c4300a14f02a2500b963a00ab6344faf6f9ffffffffffffad6952912e009231009c4612be8872faf6f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0c8bc902e00a25000963902d1ad9df5ededffffffffffffffffffffffffac6542923200933400983e00963800983c008f2d00d7b4aaffffffeddfd87a0700e7d7d1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9e9c9d000000000000afaeadffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbb000000000000484647ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfa89d943600a14f03923100efe5e9ffffffa862459d4700983d05f9f4fbffffffffffffffffffa4543d973b00a352029a4200963900983d008b2800dabab6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbf8fc8e2a00933400f4edf2ffffffffffffffffffffffffffffffffffffd8baac963800a04b00973d04b87a5edabbabc28f78811300bc826affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999697000000000000a4a4a4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbdbcbc0000000000003c3b3cffffffffffffffffffffffffffffffffffffffffffffffffffffff9a4323973a00a24f009a4308f0e6e8fffffff5eff89130009a4200bb816bffffffffffffffffffc79883983d068d2800c89987e4cec9a04e23a14e00881f00efe4e6ffffffffffffedddd7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc08b7d861c00ffffffffffffffffffffffffffffffffffffffffffe8d5d3923000a3542bfffffffffffffffffffffffffcfcfb994026f6efebffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff828080000000000000a4a3a3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc9c9c9000000000000262526ffffffffffffffffffffffffffffffffffffffffffffffffffffffcca093902f009f4800902d00b87f64a85e329f4a009e4800ab633bffffffffffffffffffffffffffffffdfc4c4ffffffffffffffffff8f2c009e4700b57659ffffffffffff923107963b01a95f3ff0e4dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff99411cb16e55ffffffffffffffffffffffffffffffffffffe9d7d6871d00953800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6a696a000000000000aeacadffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddcdd000000000000080808f7f7f7fffffffffffffffffffffffffffffffffffffffffffffffffbf8fba65a3d9436009d44009f4a00a25003943500cfa599ffffffffffffffffffdcbeb6c39076c8987dd5b2a2e4cecbbf88709a42009f4c00a85b36fffffffcf9fe8f2e00a350008d2700f1e8e8ffffffffffffffffffffffffa85c44bf896ac89981fefdfefffffffffffffffffffffffffffffffffffffaf6f5e6d2cde1c6bcddc1bbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9a432dc59486ffffffffffffffffffffffffffffffffffffe8d5d292360df5efefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4a4848000000000000bfbdbdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f3f30a090a000000000000d6d3d4ffffffffffffffffffffffffffffffffffffffffffffffffffffffdabbb4963b0b9437009334009f4c2effffffffffffffffffad69558f2c009940009940009639009335009b4200a25004983c00c3917bffffffdfc3b8943400a24f00983f11fffffffffffffffffffffffffefeff8d29009b4400851c00fbfafbffffffffffffffffffffffffffffffffffffdabbaf8418009433009f4921ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc28f81fefefdfffffffffffffffffffffffffffffffffffffffffffcfaf9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefe201e1e000000000000dad8d9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2927270000000000009b999affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdec4b9ddbfb6fffffffffffffffffff1e6e68c2600a352059c4500953600993d009b42009c4400983e008e2e02ffffffffffffba7e649b44009d4700b37358fffffffffffffffffffffffff7efef902e00a14f01963900ffffffffffffffffffffffffffffffffffffffffffe7d2c7933200a24f009e4b1bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcdcdc0000000000000d0c0cf9f9f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c5c5c000000000000565354ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2cabd9131009d4500bd846aeedfd7d2aea0cca288ba8260c9998bffffffffffffffffff9c471aa24e00943600d9b9aeffffffffffffffffffffffffede0da912f00a14e009a410effffffffffffffffffffffffffffffffffffffffffebdad4923000a24f009a4111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff989798000000000000363535ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9e9c9d0000000000000e0c0deeecedffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8c26009f4700b5775bfffffff5edf0af6b55fcf9fcfffffffffffffffffffbfafe8f2c00a25003902f00f6eef2ffffffffffffffffffffffffdfc6bc933500a14e00a24f26fffffffffffffffffffffffffffffffffffffffffff3eaea902f00a25000973c0cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfbfcffffffffffffffffffffffffffffffffffffffffffffffff464345000000000000767575ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0dfdf070707000000000000959393ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd7b6b08b25009a3e00953a019437009e48008b2600b5766affffffffffffdfc4bc933500a25000983e10ffffffffffffffffffffffffffffffd4b0a49739009f4b00aa623dffffffffffffffffffffffffffffffffffffffffffecdcd8923300a25003923300ebdbdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcecdce000000000000000000bebcbdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff535252000000000000313030f6f5f6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0e4e5a65b399232009538009537008f2e00f8f3f4ffffffffffffb97d619c44009d4700b37355ffffffffffffffffffffffffffffffca9e88983d009e4700b57453ffffffffffffffffffffffffffffffffffffffffff9d4825a14d00a04e02a24f00903001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff666464000000000000282828ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb2b1b10000000000000000008e8c8dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6eff2dec3b7ddbfb2ffffffffffffffffffffffff9b471aa24e00953700d8b8acffffffffffffffffffffffffffffffbf866d9b44009a4000c9997effffffffffffffffffffffffffffffffffffdabcb8923200a14f02993d00a14d009b4200af6c58ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc6c3c40302030000000000008e8d8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff474647000000000000151314d4d2d2fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f1f38214009e47008f2c00f7f2f4ffffffffffff963b1da25124b16d4ba5581da04c00994100c6967deedfdbf4edebfcfbfcffffffffffffffffff933505a350008f2e00f2e9f0913200a35101902e00d9bab6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaf9f9484748000000000000212021efeeeeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbcbbbb0504040000000000004b494af6f5f6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfbfce0c4bab87c5d94391dffffffffffffffffff923100a04b009d4700a04d00a14e03a25004993f009130008b2500b6785dffffffffffffca9e92973a00a04c00a55637ffffffd7b6b0923200a352018d2800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7b7a7a000000000000000000969494ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7b797b0000000000000000006a6868ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f4924a04d1b973e08943500933300943600963800983e00923100cda28dffffffffffff8b25009f49008a2400eddddcffffffffffffa15030933100923000903317ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999898000000000000000000525151ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f8f84b4a4a0000000000000000006f6f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdfff4ecece7d4d1e0c6bed2ad96b97b62e1c9c3ffffffc18c78a4532cb3724dbd8272fffffffffffffffffffaf6f8ddc0bbeddedbebdbd5fdfdfcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f9c9e0504040000000000002a292ae1dedeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5e4e43a3939000000000000000000605e5feaeae9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8a88890000000000000000001d1b1dc0bebfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddcdc3e3e3e000000000000000000393838c2c0c0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfdede5d5b5c000000000000000000232121bcbabaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeae8e9585656000000000000000000080708777677e9e8e9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefe9c9b9b1f1e1e0000000000000000003b3939cccbcbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8c8b8c1110100000000000000000001d1c1d898989e9e8e8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfbfba8a7a7373636000000000000000000000000696868edededffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd0cfd05351520000000000000000000000001515146a6969c7c6c6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdadada878585282627000000000000000000000000383738b6b5b5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbdbcbc4f4d4d0000000000000000000000000000002726276c6b6bb9b9b9eeeeeefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9f8f9c9c8c8858384383737000000000000000000000000000000373536a5a3a3fefdfdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd0cfcf767475201f200000000000000000000000000000000101012d2c2d5c5a5b8d8a8cb9b8b9d8d8d8f8f7f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfde2e1e1c2c1c29b999a6867693938380b0b0b000000000000000000000000000000100f0f605f60b8b8b8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc5c4c67876773e3d3c0100010000000000000000000000000000000000000000000000000808081312122120212b2a2a3937393b3a3a3b3a3a393839302f2f2322221615150c0b0b0000000000000000000000000000000000000000000000000000002d2b2c656364b3b2b2f3f1f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0efefc9c9c89a98996462623e3e3e1f1e1f0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001816173635355756578a8889c1bebfe6e5e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffecececd5d4d4b8b6b7a5a2a3918c8e8c8b8b8b8b8b8f8c8c9c9a9bb0aeafd0cecee6e4e4fffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000001050000000000000bad05fe, 0x151c2f00020000000d000e0014002100ffffffff4269746d617020496d616765005061696e742e5069637475726500010500000200000007000000504272757368000000000000000000c0440100424dbe440100000000003600000028000000b20000009b00000001001800000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe6e1f4b8abef9084ec7d73e85f4de4462de13010df1e00dc1100db0800db0200da0100db0300db0900dd1300e02200e13415e54b32e86455ed8179f09686f5c1b5fcf1edffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c2b7ee8a7fe65743df1f00da0300dc0b00dd1400de1b00de1e00df2100e02400e02600e02802e12904e12a05e12b05e12b05e12b05e12a05e02904e02702e02600e02300df2000de1d00de1a00dd1200dc0800da0400df2905e86352ef9285f8d2c9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5baadeb7567df2906da0400dd1200de1c00e02200e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02701df2000de1b00dd0f00db0400e23718ed8479f7ccc2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfbf0988be44329da0500dd1400de1f00e02601e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02500de1d00dd1000db0900e65641f3aba1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a093e23a1dda0600de1900e02400e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02200de1c00e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e02200de1600db0600e54f38f3b6adffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d4cbe75d47db0800de1800e02500e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701dc0b00e75e4bef9789e33e28df1d00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02300dd1300dc0e00eb7668fbeae5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a89ee02a0edc0d00df2100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e02200e02701e13416fcf0f4ffffffffffffffffffe23215e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903de1e00db0900e34024f6c5beffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9383dd1500de1500e02600e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05e12a05e02903df2000de1b00de1900dd1600e23317e96357de1800e1300cde1d00dc0e00ec7b77fffffff1a29ad80000dd1500de1a00df1e00df2000e02500e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02400dd1000df260af4b0a8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee9182dd1200de1800e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500de1e00dd1200db0900e02700de1b00ea7267ee8c79f19c8ceb7971ffffffffffffe23419e02400de1600ec7e69f7d0c8f2aea2fffffff8d8d4f3b2a6ef917fec7e75e96d61e1391cdb0d00de1b00de1700de1e00e02500e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02600dd1300df2104f3b1a8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2aba1de1700de1700e02803e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df1f00dd1000da0400e2381beb796ef5c0b5fdf7f5dc1000f5c0bafffffffffffffffffffffffffffffffffffff7d0cedb0700e65541fffffffffffffefffffffffffffffffffffffffffffffffffffffffffffffef8f6ec7a69f1a696ec7e74e23a20db0200de1700dd1600e12802e12a05e12a05e02803df2100de1a00de1b00e02701e12a05e12a05e12a05e12a05e12a05e12a05e02700dd1100e02b10f7cec9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9d9d4e12e14dd1200e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1400e96e5ef6c3baffffffffffffffffffffffffffffffde1c08f8d4d1ffffffffffffffffffffffffffffffffffffffffffe75f50e86249fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9faf19e8ef2ac9fdf2100e12801dd1900e12e09ec7d73f09a8aef9484df2606e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600dc0c00e54931fdf5f2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe8624edb0b00e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1500f09a8bffffffffffffffffffffffffffffffffffffffffffe6533ef3aba4fffffffffffffffffffffffffdf6f2e65548ffffffef928be1321dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75e4cdd1800ef9385dd1400ea7767fcf0eefffffffcf3f4dd1400e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2100dc0c00ed8674ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b5aedd1400de1d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1c00fdf2effffffffffffffffffffffffffffffffffffffffffff0a3a0eb8075ffffffeb7d74e65240fefbfdf3b4aeee8f84fcece9dc0d00df2000fefdfae76059e54f40f8cfcbdc1000e1361df8d4d2fbebeded8378f4b4a7fffffffffffffffffffffffffffffffffffffffffffffffffae5e3df1d07ffffffe02604db0100d70000f6c7c6ffffffe34630e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903de1700df2508fadedaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe65641dc0e00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904df2000dd1200e12803e02802df2402fdf3f1fffffffffffffffffffaded8ef9b90e3422ff0a196f8d0cae8624afefaf9dd1800de1900e12d0efffffffffffff2a9a0dd1400de1400f1a89ef6c5bcffffffe86551de1b00dd1500fbe6e2f1a79ee03218fcece8f4b8acfceae6ee958bef9489fbe8e3fffffffffffff0988eda0600f1a399ffffffdf260ff8d4cdffffffec8876ffffffe44a36e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600db0b00ec7d6bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d3d1dd1800de1d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1d00dd1100e12802e12a05e12904e12a05e12a05e12a05e12a05df1b00dc0c00ea776af8d9d3e02705e12903dc0d00f9dedcfdf5f2e54f36dc1300dd1200dd1400dd1300fffffffaded6e44229ffffffe13118e02700de1c00e44931f4b4abe02a0fe02700e02700df260bfffffffeffffde1c00e02500e1311cffffffeb7461e96955fffffff5c2b8fcefedffffffda0000ed8c82ffffffe33a27dd1200de1d00fdf9f6fae0e0ea7363fffffffffffffffffffdf8f8e13519e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1700e02e15fdf6f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed8572db0c00e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000ea7363f9ded9df2403dd1000dd1800e02500e12a05e12a05df1c00ed8978fffffff4b5ace23c21df2400e12a04e02100e6553df9d8d8db0c00df2100dd1600e3442ce33516df2608ed8673e33c29ffffffe23a29e02500e12a05e02200de1900e02701e12a05e12a05e02200e13313e02a09e02500e02100e55237ffffffeb7b65dc0b00ea7263f8d5cef5beb7e23c21de1700fdf7f5f8d3cddc0d00e02000e6593effffffea705cf4b3affffffffffffffffffffbe7e5dc0c00e12a05e12a05e02600df2000e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300dc0e00f4b1aaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44938dd1400e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1d00ec816ef6c4badd1300f5bcb3fffffedf2104df2200e12a05e02500e44427df1f03de1800e02500e12a04e12a05e12a04dd1700eb796be12c0be34229fffffffcefecf4b7aede1400de1b00e23a22ffffffe54d2fe02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e02701e12a05df1b00ed8877ffffffe96553df2000de1e00dd1600de1800df1a00e6553bffffffe6543fe02000dd1300f6cac7ffffffdf250bf7c6bbffffffffffffffffffea7666de1d00e12a05de1800e13318eb7971e02f11dd1400e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802dc0e00eb7562ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf5f3df2001de1d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02000da0000eb766efffffffffffffffffffdf4f2df1f01e02500e12a05e02600e02802e12a05e12a05e12a05e12a05e12a05e12a04df2000e02802de1e00e7604ede1900df1d00e12a04e02903df2101f8d1cbed8775df1c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903dd1600f2aca1e23b20e02600e12a05e12a04e12a04de1600f8d4d3ffffffe5513ddf2000e02a0efffffff9d9d5d90000f8d2c9e02918e34a3fffffffdd1600e12903de1a00ea6d58ffffffffffffffffffed8d80db0800e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1600e3412effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9d2cfdd1100e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd0e00e5543efdf7f6fffffffffffffffffffffffffffffffdf3f0de2000e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02100e02903e02904e12a05e12a05e02802dd1700e12f0de02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903df1c00e02701e12904e12a05e12a05e12a05de1900f19f90fcefeedd1200de1800ef9083ffffffe96b59db0700f6c5c1ffffffffffffe4492ddf2000e02700df2709fffffffffffffffffffffffffffffffbebe8e2371cdd1000e12a03e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1e00df2102fefbf9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3afa6dc0c00e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1600f1a597ffffffffffffffffffffffffffffffffffffffffffe5503fdf2000e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e12904e12a05e12a05e12a05e12a05e02802e02608e6563adf2100dd1700f6c9c3ffffffdf2606de1c00e96b55ffffffe75c48de1700e12a05df1c00ec7967fffffffffffffffffffffffffffffffffffffffffff09b8cdc0f00e12a03e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300dd1400fbe6e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9687dd0e00e02902e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904df2100e02801e12904de1c00fffffffffffffffffffffffffffffff7cdcbf09e93fef9f7de1e00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802df2300e12a05e02500e2381bf6c9c5dc0f00e12a05df2000dd1500df2000e12a04e12a05dd1500f6c7c7e54f40df2003f8d7d5fffffffffffffffffffffffffffffffae1dfdc0d00e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600dc0e00f8d0cdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee8978dd1000e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02904df1d00ea6f62de2003dd1500dd1000f3b3a8ffffffffffffffffffe54f42da0100fffffff8cfc6dd1700e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05e12a05e12904e02803e02802e02802e02803e02904e12a05e12b05e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2500df2200e12803e12a05e12a04e12903e12a05e12a05e12a05e02600e33e21e02300df1d00dc0e00ea7262ffffffffffffffffffffffffe4462fde1d00e23a20dd1600e12b05e12904df1f00df2400e12a05e12a05e12a05e12a05e12a05e02801db0d00f6c1bbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed8773dd1100e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1f00e5503bfffffffffffff09b91de1b00de1a00fffffffce8e3da0100ee9487fffffffffffff1a199de1700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02600df2100de1c00dd1400dc0d00da0600db0900dc1200de1c00df2200e02300df2000dd1900dc0e00db0700dc0800dc0f00dd1700df1e00e02300e02702e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e02a04e86658de1800de1700df1c00f3b0aafffffff5bcb2db0700ffffffffffffea756adc0900df2602ec816ee54b2de02400e12a05e12a05e12a05e12a05e12a05e02801dc0c00f6bfb9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef907fdd1000e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1a00df2207f6c6bfffffffffffffffffffffffffde1f01ed867affffffdf270cde1900f4b5a9f6cbc6df2104e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e02400de1b00dc0c00dc0c00e2391be86355ed836ff3afa2f9d7d1fdf9f8fffffffffffffffffffffffffffffffffffffffffffffffffffffffbedeaf6c9bff19d8bea7665e65441df2501db0700dd1200df1f00e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700e2331cffffffee8a7ce2371be23c22f2aea2ffffffdc0e00faddd5ffffffffffffffffffef9487db0500fffffff09c8bdf1b00e12a05e12a05e12a05e12a05e12a05e12a05e02801db0d00f8ccc7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a396dd0f00e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05dd0f00e76051fffffffffffffffffffffffff5c0b5ffffffdf1f07dc1000fefefff7c9c5dd1000de1a00dd1900e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903df2100dd1000dc0e00e54d39ed8674f8d6cefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefbfbf4b4a7ea7061e13113db0600de1900e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e02500dd1300fae5dee54f3aea6a54ffffffe75749ed887effffffffffffffffffffffffffffffe75e4cda0000df1e00e02904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02801dc0d00fae0deffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c1bbdc0e00e12902e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd0f00ec7d77ffffffffffffffffffffffffffffffda0600ffffffe55135de1500e85f4affffffe54e36df1f00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400dd1200dd1400e8604ef4baaefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2f1ef9181e44229db0700df1c00e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02700de1c00df2200e02d11ec8277e3402efffffff09f9dfbe7e5fffffffffffffffffffffffff6c8c1de1d03e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700dd1200fdf7f4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe8e6dc0e00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1900e65c4bfffffffffffffffffffffffffffffffffffffefefefffffff09b92df1900db0b00fadfdafefcfbde1d00e02903e12a05e12a05e12a05e12a05e12a05e12904df1f00db0800e4462ff3b0a5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf1efec806ddf2304dd0f00e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02904e12a04e02200dd1800fffffff7cfc8da0200dd1300f9dadafffffffffffffffffffffffffcefefdc1100e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400df1e00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffdd1900e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05dd1000e44639fbe6e5fffffffffffffffffffefefde23418e34227f3b0a9f8d0c8e13515e02500e02600e1351af1a19ae44a30e02500e12a05e12a05e12a05e12904de1c00dc0d00e96a5afbe8e4ffffffffffffffffffffffffffffffffffffee8e89ed877aed897ded897ded897ded897dec8176f5bbb2fffffffffffff1a29be96651e75c45ed8276fbe7e2fffffffffffffffffff9d8d5eb7d72ec7d73f8d6d5fffffffdf7f4ee8c82e85f49e8614cee8d83fcebe7fffffffffffffffffffffffffffffffffffff5b9b0e23d24dc0a00e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1d00fae2dcffffffdd1b00e02700df2100e12c0bfffffffffffffffffffffffffffffff9dbd8dd1400e02902e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2000e23723ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe13620df2000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05dc0900ef9288fffffffffffffffffffffffffae5e1dd1700df1d00e02200de1800dd1800e02500e12a05e12a05e02500de1b00e02500e12a05e12a05e12a05e12904df2000eb7464fefbfaffffffffffffeb7a67e8635ce96a65f7c7c1fffffffefbf9dd1400de1900de1b00de1b00df1b00df1c00dd1000ea654cffffffe33b1fdd1200df1e00df1d00de1900dc0e00f7cec7fffffffffffff3a69cdb0500db0700f2aaa0fdf3f3dd1600de1700de1700de1800de1800dd0f00f8ccc6fffffffffffffffffffffffffffffffffffffffffff7cdc6e34027dc0a00e02600e12a05e12a05e12a05e12a05e12a05e12a05e02701e02b12ffffffe44b32df1e00e12a05df1a00ef9c91f8d1d1f1a398ffffffffffffffffffffffffec827cdd0d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1800e96754ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96c59de1800e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1700ef9486ffffffffffffffffffffffffffffffffffffffffffe02911e02701e12a04e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400df1e00dd0e00e54e3cfffffffffffffffffffffffff09c8bf5b9b0f3aea2f19f90ffffffffffffec7c68dd0f00e12a04e12a05e02902dc1000d90000e96851f5beb8dc0e00e12903df2200e12f10df2300e02200e33c26fffffffffffff3ada2dd1400dd1600f5bfb8e86451df1c00e02300e86553e75846df1e00df2100e33f25fffffffffffffffffffffffffffffffffffffffffffffffffffffff6c7c0e23017dd1000e02902e12a05e12a05e12a05e12a05e12904df2603e96b57de1700e12a05e12a05e02400e55036e02505dc0b00ec7d6dfffffffffffffffffffffffff4b9aedb0900e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1100f1a093ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3aea4dd1000e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc0f00fffffffffffffffffffffffffae8e4f5bdb1e96f67ffffffdf240ae02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02902dd0f00e4422aeb765fef9583fefbfafffffffffffffffffffffffffae4dfffffffffffffffffffffffffffffffffffffee8c7adc0e00e12902df2303f8d1ccffffffffffffe75539e02100dd1300f6c4beffffffe12f13e02500df2301fbeae7fffffff3ada2dd1400dd1700f4b3aae33e26e02200e23a25ffffffffffffe02806e02500e12f1afffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff09d8fdd1300df1f00e12a05e12a05e12a05e12a05e02904df2100e12a05e12a05e12a05e12a05e02400e02802e12a04db0c00f6c5baffffffffffffffffffffffffe76151dd1000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12902dc0e00fbe9e6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf7f3dd1100e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700dd1700ee9484fffffffffffff8d6d4e76760fffffffffffff19e90de1900e12a04e12a05e12a05e12a05e12a05e12a05e12a05e02100de1b00f2ab9effffffffffffffffffffffffffffffffffffffffffffffffea7159de1d00de1b00f09a89fffffffffffffffffffffffff09c90dc0e00e02600de1d03fceceaffffffe33b29e02600dd0e00f9d6d5ffffffe23922e02500dd1600f9d9d2fffffff3ada2dd1400de1800f2a79de13212e02600e02603f19e95ed887cde1b00e02300e23b20fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefafae65441dc0c00e02902e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904de2100ed877bf2afa6fffffffffffffffffffffffff2a99cde1a00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400df2507ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2361ee02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04db0b00fef9f9fefdfcfffffffeffffdc0b00e34026f9dcd6ee8f82de1600e12903e12a05e12a05e12a05e12a05e12a05e12a04dd1200e4442bf3aca4f4b7adfffffffffffffffffffffffffffffffffffffffffffffffff7c6bcfef9f8fdf1eef6c5bbfffffffffffffffffffffffffffffff1a49ade1600df2100e13118ffffffe33f2ee02600dd0f00f9d4d3ffffffe33a25e02500de1400faddd6fffffff4b4aadd1400de1800f2a69ce13010e02702e02802dd1700de1500df1e00da0300f6c5c0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3afa4dd1200e02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1a00dd1000fffffffffffffffffffffffff8d4cfdb0800e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1b00e96a58ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee8b79dd1600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e34128ffffffffffffe3483cffffffe6533bdd1300de1b00de1b00e12903e12a05e12a05e12a05e12a05e12a05e02802dc0a00ed8776fffffff4b5b1da0100dc0c00dc0b00dc0800e55049fffffffffffffffffffffffff3afa0f6c6baf8d0c5fdf4f2ffffffffffffe55033f2aa9cffffffffffffe65638e02300dc0e00f7c2bce54d34e02400dd0f00f9dadaffffffe2371ee02500df2200f3b0a8e23b23ec8271df1c00dd1700f3afa5e23a20e02600e2300ce13619e86153ea7163fcefecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe54b31de1b00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02803e23410e2402bf1a89afffffff6c9bfda0400ee8c79e2381bdf1e00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0f00f7c7c1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcebe6dc0e00e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700e23117fbe7e3fffffff2a89effffffffffffe54c3cdf2300e12a05e12a05e12a05e12a05e12a05e12a05e02400dc1200f6beb7fffffffffffff1a19fe23e22f09581ef907cea7559e33f34ffffffffffffffffffffffffe96f5be5483ee43f36ed8372ffffffffffffe85a3fdc0a00e75d48f1a39ce02d0fe02802de1900ef907eee8b7ade1900df2000e8614bef978cdf2200e02600e1331df8d4d2db0500df2000e12a05dd1500f5c0b9e65340e02200e02802e23a21fef9f5f8d3cce6553ff7c9c0fffffffffffffffffffffffffffffffffffffffffffdf4f2e9715eea7060fbeae4fffffffffffffffffff5bfb5e86450ea725fe5553ddd1100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1700ee9794fffffff7c7bddd1907fefaf9ffffffffffffe13015e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701de1b00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1371fe02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802df2100df2300e12a04e12a05e02500dc1100ee8f86f09a90e1341be86451e6553bdc1200e12903e12a05e12a05e12a05e12a05df1f00df2402fdf0eefffffffffffffffffff9d9d4f8d5cefffffffffffffefbfaf4b7acffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75a43dc0d00df1d00de1900e02802e02700da0400f7ccc7fcece9dc0c00e02500df2100df1c00e02700dd0b00ee8d7dfceff3e0260ddd1100e12a03dd1200f3b1a8f9d3cedb0500e02400e02601df1e00de1700da0200f7c3bbfffffffffffffffffffffffffffffffffffffffffffcedeadd0e00dd1000fadcd6fffffffffffffffffff09888dc0b00dd1000fadbd5f1a495dc0b00e12902e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1900f1a9a1ef9892e33e23fffffffffffffffffffffffffbe5e3db0900e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1b00ea6d5cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a497de1300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802e23414ea746ae55340dc0f00e02700e12a05e12903de1b00de1a00e02400de1900e2351bf2afa1df2605e02903e12a05e12a05de1a00e2361bfefefdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b6aadf280fe0250df5bdb0fffffffffffffffffff1a095e33e25dd1400dc1100e13015f1a49afffffffffffff7c7c4e1341adc0d00db0700e13212ef9584fffffffffffffffffff4b6adde1700de1c00f3b3abfffffff6c3bce23a22df1e00db0800df1f00e6513afdf3f0fffffffffffffffffffffffffffffffffffffffffffcefecdf1b00df1e00fbe1dcfffffffffffffffffff09889dd1700dc1100f6c4b9fffffff4b9b0dc0e00e02800e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02901db0800ea6f64fffffff8d2cbffffffffffffffffffffffffef9185dd1100e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0d00faddd8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1600e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903dd1500f4bdbafffffff9dbd6de1c02df2200e12a05e12a05e12a05e02701e23a1df1a399f5c3bcdf2404e02903e12a05de1700e44631fffffffffffffffffffffffffffffffffffffdf8f5eb7665e23715e1310ee6533bf8d3cbffffffffffffffffffffffffe96c58eb7874ea706aeb7865ffffffffffffffffffe75a40f7cbc1f9d5cef8d0c8fbe5defffffffffffffffffffffffffffffffdf6f5ffffffed8574de1c00ea7060fffffffffffff6c9c4e86751ffffffffffffffffffffffffffffffe4443afffffff7cac4e12e0ee4492ffefbf9fffffffffffffffffffffffffffffffffffffceeecde1900dd1400fadfd9ffffffffffffffffffef9584db0400e6553afefffffffffffffffff8cfccdc1000e02700e12a05e12a05e12a05e12a05e12a05e02904dd1100f3b3aeffffffef958dd90000e65346ffffffffffffffffffffffffe2381ce02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400e1341cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea7463de1b00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df1f00e34227d90000ef9489fffffffdf3f2df2916df1e00e12a05e12a05e02400e65b4afaded7dd1200e02801e12a05de1800e54c38fffffffffffffffffffffffffffffffffffffffffff09b94e02c14eb7261eb725fe6543fe23d2efffffffffffffffffffffffffffffff8cfcaf8d3cfffffffffffffffffffffffffe44424db0b00dc0f00db0a00e43d2dffffffffffffffffffffffffffffffffffffffffffe96f58db0200e13111fffffffffffff5bcb4e9654efffffffffffffffffffffffffdf9f6e33c30fffffff09c8dd90000da0000fae2dcfffffffffffffffffffffffffffffffffffffcedeadc1400ea705bfefcfbffffffffffffffffffed8673e6553ffffffffffffffffffffffffffffffffadbd8dc1100e02800e12a05e12a05e12a05e12a05df1800f2a8a4ffffffe96955db0700e86048e65349f1a79afffffffffffffffffffcf0eedc0b00e12a03e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc1300f3aca2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffceeeadc0d00e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1200ee8c80ffffffea7867d80000ec7d6bffffffffffffe23926de1b00e12a05e02904e02400de1c00e02802e12a05df1c00e3412affffffffffffffffffffffffffffffffffffffffffffffffee8e85e5452bf3b4aef3b3aeed8673e23422fffffffffffffffffffffffff2a492e34032e23c2cf2ab9cffffffffffffffffffe85f46fae2dcfefdfcfcede8e96b62fffffffffffffffffffffffffffffffffffffffffffffffffef9f8f8d1cce9644cfffffff6c1baea6955fffffffffffffffffffffffffef9f6e2382bfffffffffffff9d7d1f9d8d3e75b3ffcefeefffffffffffff5bcb6f5beb5fffffffbe6e2e54b2bffffffffffffffffffffffffffffffeb7d6aeb7869fffffffffffffffffffffffffffffffffffff8d3cfdc0f00e02901e12a05e12a05e12a05df1a00f1a8a4e65a44dd1600de1c00fcf2f1fadedcdd1504fbe7e1fffffffffffffffffff09f90dd0e00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701de1a00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe6543cdf2000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400e13216fffffffffffffffffff3b1acd90000e86853ffffffffffffe54c31de1600e12a04e02904e12904e12a05df2100e12f11fffffffffffffffffffffffffffffffffffffffffffffffffffffffbebe7e44b3bdf1e01de1c00e1301bf5beb7ffffffffffffffffffffffffeb775fe75e51e7574aed846ffffffffffffffffffffffffffffffffffffffffffffce9e6ec7d6eed897af1a399f7c9bffffffffffffffffffffffffffffffffffffff8c9bef1a595efa298e3432be59697e68a89ea9d9cefbcbaf7dad5e44033fffffffffffffffffffffffffefbf9e55345fffffffffefdde1b00df2711fffffffbe5e1e54d2dffffffffffffffffffffffffffffffec7864eb796afffffffffffffffffffffffffffffffffffffffffff5c0b8dc0d00e12a04e12a05e12a05e02903e02302df1f00e12a04de1a00fbe9e6fffffffffffffbeae8ffffffffffffffffffffffffe34129e02100e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1800ef8f81ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae0dadc0e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a03dc0d00fae6e3fffffffffffffffffffffffff9d7cfdb0400e65236ffffffffffffea735edf2100e12904e12a05e02600de1e00fefbfafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbebebfceaebfffffffffffffffffff7c7c3fefbfeee9186ec8270ef9085f8d2cbdb0800de1c00dd1900dd1900e02a0cf5c1b7ffffffffffffffffffffffffea9b91d11503cc1310ca4f2bc44929c54828c34b27c81f13cd1611de2103e1847ffbf3f3ffffffffffffffffffeb765efffffffffffff9dad2f6c3b9fffffffbe4e0e54e30ffffffffffffffffffffffffffffffea745feb7e71fffffffffffffffffffffffffffffffffffffffffffffffff1a394dc0c00e12a05e12a05e12a05e02903e12a05e12a05e02500e02904f0a29cf4b4b0f5baaffefcfbffffffffffffffffffffffffdf2206e02902e12a05e12a05e12a05e12a05e12a05e12a05e02802dd1300ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe55139df2000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1a00ee887afffffffffffffffffffefdfbe44737fffffffdf7f6e3453ae64e3af5c3bdec7c6ddf2400e12904e12903dc0f00fae1dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefcf1a19ae9624be85d44ed8074fbe9e5fffffffffffffffffffffffff2a696e33d2fe23928f6c2b6fcf1eee86650dc1000e34423df1f00de1c00de1d00e44827df2600e12c05e12c05e12b04e02700dc0f00f6c3b8ffffffffffffe79590c90601cb3b2ac57547d03727cf2a22ce2f24d02a21cb5a38c66840cd3124cb100ccb1b13e38a85fdfbfbffffffeb745dfffffffffffff9dad4f7c6bcfffffffbe3dde55031ffffffffffffffffffffffffffffffea6f5aec8376ffffffffffffffffffffffffffffffffffffffffffffffffffffffec7f72dd1200e12a05e12a05e12a05e12a05e12a05e12a05e02601dd1700dd1500dd1500dd1500fbe6e3fffffffffffffae3ddde1f00df1c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1900ee8e7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe5e0dc0e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05da0100ffffffffffffffffffffffffe6594adb0500e44836ffffffffffffe96b5adc0900df1e00e12904e12a05dc0c00f2aa9dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3a7a1dd1300e65647e6584ae13419e44435ffffffffffffffffffffffffef907bec806fed8977e02b04df2000de1f00e12a02de1f00df2300e02600e02500df2200e12c05e12c05e12c05e12c05e12c05e02400e23d23fffffffcf3f3cc1d17ca462fc7663fd41d19a85c51c83028d31b19bb483baa534bd31b18c85e3cc76941cd2e23cb100dcb1e16dd7774e65f48fffffffffffffbe2dcf8ccc2fffffffbe1dce55132ffffffffffffffffffffffffffffffea6b55ed877bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4432cdf1f00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700dc0c00e33f29fae4dfffffffee9387d90000e54f3beb7966df2000e12a05e12a05e12a05e12a05e12a05e12a05e02802dd1400ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe8624fdf1f00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1600eb7867fffffffffffffffffffefdfcfdf4f3e0311ade1500e44936fdfcfcf7cbc6e12d0ae02803e12a05de1700ea6e60ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee877fe75d48f7cbc7f7c9c4f09c8ee34132fffffffadbd4f2aca1ed8879e65030de1b00df1f00e02901e02a03e12d05dd1300f9d4d0e86358e6513de65442e54c34df2600e12c05e12c05e12c05e12c05e02b03de1d00fceae5efd7d4c80e07c85b3acb422ed51817a4755ebdaf64cb5e3ac2342daf9f67c68e50ce2620cf211ec8603cc76841cc3024cb1413d81e04cd2a23da635fe33d23eb9c92fbf6f7fef4efe65335ffffffffffffffffffffffffffffffe96851ee8c81fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefaf9de1a00e02801e12a05e12a05e12a05e12a05e12a05df2400e0280cf4bab1fffffffdf3f0e12e1adc1200f4b9afffffffe54d37e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1700f09c8effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefddc0d00e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701df280affffffffffffffffffffffffe1392cfcf0ebed8374df2000df1f00df2305dd1600e02702e12a05e02500e02a0cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadfd9e02b14db0600db0800e02d0fe96953e4482cde1b00dd1800de1c00e02500e12c04e12c05e12c05e12c05e12c05dc0f00fadeddfffffffffffffffffff9ded8dd1600e12c05e12c05e12c05e12c05e12b04dd1b00fce6e0efd5d3c91109d61c16c76840c85c3ad41716d01d1acb412dc86e42ce3e2acf1f1dc85e3cc7653fcf231fcf231fc85f3cc66841d53117ce1e1bcb2019dc2301cd1a0ecb1f18d7473cea6346ffffffffffffffffffffffffffffffe9654dee9084fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c1badc0b00e12a05e12a05e12a05e12a05e02802de1e02fffffffffffff09c95da0200ee897dfffffffffffff09f96dd1100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701df2103ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee8b80de1a00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1100ee8d7fffffffffffffffffffffffffe65741dd1600de1c00e12a04e12a05e02802e12a04e12a05e12a04dd0b00f9d8d4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf7f5fefcfae75b41df2100e02500e02b03e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05de1700f4b8ace13520df2203e03016f1a594de1d00e12c05e12c05e12c05e12c05e02b04de1c00fce7e2f2d4d3c81c0f809f88d52c1ecd2e24c57145c94f34d01a1acf1f1dca4830c67045cc3b2acf221ec76740c85c3acf1f1dce2c23cd5534cb603bcd3226ce1a1bcf2620ce2922cf2417d91b00e08483ffffffffffffffffffffffffe8614aef948affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea6e5fde1900e12a05e12a05e12a05e02701e0310dffffffed887fe45043fefdfcfffffffefaf8e8624edd1400e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc1200f6c3bcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1b00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200e54c36ffffffffffffffffffffffffdc1502e02804e02802e12a05e12a05e12a05e12a05e12a05e12a05de1600ec7b6bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe7e3fbe7e1ffffffe96953dd1900e12c04e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c04de1b00dc1100dc0e00dc1000dd1b00e12b04e12c05e12c05e12c05e12c05e02b04df1d00fde7e2f2d6d3c91209bd5a42c59955c8603ccf1a1bcc3f2bc67345cb422dd0191acf221fca5135c66d42cf2520ca4f33cb5034d51c179b7264b1594aca5c39c59053ce492ed0261fd12b1ddd2709c60f08e7a9a4ffffffffffffffffffe85e46ef978dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2003e02801e12a05e12a05e02803e1300bdf230df6cac3ffffffffffffee9083de1800df1c00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200e44b31ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c0b8dc1400e12a04e12a05e12a05e12a05e12a05e12a05e02600e02400db0700fbeae7ffffffffffffffffffffffffe02c0ce02600e12a05e12a05e12a05e12a05e12a05e12a05e02701df2306fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a19ce5523cf5bdb9df2705e02a02e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05df2500e4482df6c3b8fbe4e2f8cec6e75c42df2100e12c05e12c05e12c05e12c05e02b04df1d00fde7e2f2d6d3c8150bd1231fd01c1bce2e24c76d43c94f34cf191aca4d33c66f43cd3628d0181acc392ac95d39cc402dcb5034d11818bc9b5dc56440d41113da311c77b199c03e34d2251ad52a15cc221bd44b43ffffffffffffffffffe86148f0998ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5bab1dc0c00e12a05e12a05e12a05e02700de1a01fffffff6c3bfe02b10de1500e02802e12a05e12a04de1c00de1500e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0c00fdf5f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe6533cdf2100e12a05e12a05e12a05e12a05e12a05dd1400e2381de4422eeb766afffffffffffffffffffbede8de1d09e02a05e02904e12a05e12a05e12a05e12a05e12a05e12a05dc0c00f4b7affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3afaadb0800de1c00df2800e12b04e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05dd1300fae1ddf1a4a1eb796fef9590fbe8e2df2300e02b03e12c05e12c05e12c05e02b04df1d00fde7e2f2d7d4c8150bcf2922cd3527c8643dce2620cc3e2cc67245cb422dcf1b1bc85c3ac7663fcc3a29c95737cc412dcb5034d01f1dc95837cf3c29b35949997567de120dd1261fc5392fcf2621cd2219d95d56fffffffffffff6c4badb0400f6c4beffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4462ee02300e12a05e12a05e02802e23614e86954dc1100e02500e12a05e12a05e12a04dc0e00ec7c6ef4b6abdc1100e12902e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1a00ee8e82ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0c00e12903e12a05e12a05e12a05e12a05df1900ed8776ffffffffffffffffffffffffffffffffffffe54f39df1d00e02904e12a05e12a05e12a05e12a05e12a05e12a05e02400e33e23fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2aba8ee8e7fffffffe12d0fe02a02e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05dd1200f9dad5fae4e5f6c5c0f8d7d5fbe7e3de1e00e02b03e12c05e12c05e12c05e02b04df1d00fde8e2f2d9d6c8140bd1201dc95d3ac0ce70ca4c32d0211ecf231eca4b32c67043cd3426cf241fc67447c95c39cc402dcb5034d0211dc94f35cd3b2bc56640bc9359d21918c73f2f77d4a6d71e17cd241cd64b45ffffffed8375dc0800f8d1c9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae2dcdc0b00e12a04e12a05e12a05df2601df2000e12a04e12a05e12a05e12a04de1b00ef988bfffffffffffffaebecdb0700e12902e12a05e12a05e12a05e12a05e12a05e12a05e02701df2406ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a599de1800e12a05e12a05e12a05e12a05e12a04db0e00ffffffffffffed8c84f7cfc8ffffffffffffffffffdc1100e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc0a00f8d0c9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2ab9bdd1700e02a02e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e02801e13110ee8c7af1a398ef9384e2391be02500e12c05e12c05e12c05e12c05e02b04df1d00fde8e2f2d8d5c7180ec54232ce3125cd2721ce2720ce2c23ce2c23ce2720cf221ec85e3bca4e34ce2d24c95a38cc402dcb5034d01819c66a41cd3929cc3d2aca5c39cf221fcf2f23cc964fcf1a1bcd2a23cd2d28e7583ee43721fdf2efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe8604fdf1f00e12a05e12a05e12a05e12a05e12a05df2400e02802e02903de1900fefcfbee9082fffffff4b8ade44337df2506e02902e12a05e12a05e12a05e12a05e12a05e12a04dc1000faddd5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe4482ddf2300e12a05e12a05e12a05e12a05e12904dd1800ffffffe65043ed8678fffffffffffffffffff6c5bbfcedebde1e04e02600e12a05e12a05e12a05e12a05e12a05e02300e4472efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefbfbed866fdf2408e2381bdf2300de1b00e12c05e12c05e12c05e12c05e12c05e02b03e02b03e12c05e12c05e12c05e12c04de1d00dd1500dd1500de1700df2300e12c05e12c05e12c05e12c05e12c05e02b04df1d00fde8e2f4d4d3b6332689a987ce8046c85e3bc85939c85a39c85a3ac85738c57b48cd3929c95a3acd3226c95a38cc412dcc4830c8613ccb4830cf221ecb3d2bca5635cf2320ce2b22c76a41cf1e1dd0291ee12400d91400f3cac9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffceceadc0b00e12a04e12a05e12a05e12a04df2300e54c32e02e0ee02800dd0c00ffffffe6583efffffffef8f7fffffff3aca2dd1200e02600df2000e12a05e12a05e12a05e12a05de1c00ed8478ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0c00e12a03e12a05e12a05e12a05e12a05e02801da0000fcefecd90000ee8c7cffffffffffffffffffd70000fffffff6c4bbde1a00e12904e12a05e12a05e12a05e12a05dc0900f7cec6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a595faddd6ffffffffffffffffffec8371de1d00e12c05e12c05e12c05de1c00df2400df2400df1e00e12c05e12c05dd1400f8cec8e6584be44730e44a34e4442ae02600e12c05e12c05e12c05e12c05e02b04df1d00fde8e3f1dad8cb1008d71915cd2821cd2d24cd2e24cd2f25ce2620d0191ac8623dcc412cc95939cd3226c95a38cc412ecc432ec67947cf2820d0201dcc392ac77243cf1e1ccf2720c67a48cc2c24db3511d63d1cc44635b93228f8d2d1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75d4ae02100e12a05e12a05e02903df1b00ffffffe55244dd1300ec7f72fffffffcf0edffffffffffffffffffffffffdc0e00e33d1dea7263df1f00e12a05e12a05e12a05e02701df2505ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b2a7de1600e12a05e12a05e12a05e12a05e02600e23a1eec7f6be02d11e86146df240af4b3aefffffffffffffae2e1fffffffbede9dd1a00e12903e12a05e12a05e12a05e02500e23c23fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d0caed846ff5c0b7e03118e13116ec7768fbe5dfde1f00e12b04e12c05df1f00ec816df7ccc3f8d0c8eb7965df2000e12d05dc0f00fadfdefffffffffffffffffff9dcd5dd1700e12c05e12c05e12c05e12c05e02b04df1d00fde8e3f2dad8c91009c95135c76840ca442fc94b32ca4530c4834ecf1d1bc7643ecc412cc95939cd3327c95836cc3c2bc8653fcf1d1cc8663fc85c3acf221ecc3326c67144ca4a32cb402dca4630c94631ca633db68659976b5ed4221cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaded9db0900e12a05e12a05e12a04e02200e44534ffffffdc1100f3aea4e65338dc0b00f2a59affffffffffffffffffe96c5feb7562f9ddd9db0400e12b05e12a05e12a05e12a04dc0e00fcece8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96857df1f00e12a05e12a05e12a05e12a05df2000e86656fae3e1da0000fffffffffffef0a195e44642e02407e65336e44426df2507e02700e12a05e12a05e12a05e12a05dc1000f3afa4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe65337e96955fffffffbe3e4fbe4e5fdf4f6f8d0c8de1a00e12b04e12c05de1900f3ac9ff5c5baf7ccc2f19d90de1c00e12d05dd1600f5c0b7e23c29e0290ce13720f2ad9ddd1c00e12c05e12c05e12c05e12c05e02b04df1d00fde8e3f1dad8c91008c95136cd3327c58f52c2c069cf201dc57446cf1e1cc8643ecc422dc95638cf2620c67646cc3226cc3b2bc66e43cc392ace2b23c76b41ca5135cf1919cb422ec76840c85e3bca5c39c95939ca5d39d23d28c9110be9a19dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe3422ae02400e12a05e12a05e02702e1320fef9d92de1600de1d00df2100e02300e13217fffffffffffffffffff1a596d80000ffffffe96e5de02200e12a05e12a05e12a05dd1900f09a8dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd1900e02802e12a05e12a05e12a05e12a04dd1200ffffffe4472ee76150fffffffffffffffffffffffff5beb5dd1800df2000e02802e12a05e12a05e12a05e12a05e02802de1c00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02d0ddf2100eb7d67f5bcb7f5bfbbf09c8fe03114e02700e12c05e12c05e12b03dd1800e34020e34121df2100e02b03e12c05e02b04df2000de1900dd1500de1700de2100e02b04e12c05e12c05e12c05e12c05e02b03df1e00fde9e4f2dbd9ca0d08cb653ccd472ecc3c2cc8613cd01618c57747cf1e1cc66d42ce2f23c66d43cc412dcf1c1bc95838c8653ece3025ca462fc76a41ce3226ce3326c67244cb422dcf1f1dd1231ec03531cc2521ce3526c8633ecd1914db635dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b1a6dd1000e12a05e12a05e12a05e02701de1a00e12a05e12a04e12a05e12a03db0400fefefcfffffffffffffdf9f7e02b12e86551e13313e02702e12a05e12a05e12a05df2200e65039ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe9e5dc0f00e12a04e12a05e12a05e12a05e12a05df1e00e75c42db0700f9d9d3ffffffffffffffffffea6f5ffffffffbe5e3df1d00e02904e12a05e12a05e12a05e12a05df1e00ea6f5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe13816de1d00dd1200dd1700dd1600de1b00e02800e12c05e12c05e12c05de1f00ed8773e96458e75b4be23c1de02800e12c05e02800e13312ee8f7bf3afa2f09884e34026df2400e12c05e12c05e12c05e12c05e02b03df1e00fde9e4f3dbdace0402a4a672b66b4cc69051c0ca6dcf2520c57546cf231fcd3729c66e43ca4a31cb442fc76a40cc3b2acf211dc85a39c9613dcd2e24ca5035c8673fd01619c66f43cd3327d51e1889bd8fc0513bcf3426c95d3bcd1713de706bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1a00e02803e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1f00ec7c6ffffffffffffffffffffffffff4bab2db0700e02701e12a05e12a05e12a05e12a05e02903dc1000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a296dd1900e12a05e12a05e12a05e12a05e12a05e12a05df1d00e23d25fffffffffffffffffff9dcd5da0000e96850e02608e02600e12a05e12a05e12a05e12a05e12a05db0900f9dbd6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff09e8ddd1600e96c52eb7562db0700dd1300dd1300dd1a00e02c05e12c05e12c05dd1a00f2ab9cf5c4bef7cecaf09a8adf1d00e12c05dc1300f9d6d0f7cbcbf4b6b8f6c4c4fae0d9df1f00e02800e02800e02700e02600e02500de1800fce8e3f2dad8ca0a02ba4134c43429ce261dcc3324cf1818c47c49ce2620d0211ecf221ecb422dc76a41ca4d33ca4931cd5f37cc3929ce2721c76840cd3c2ac67546cf201cc7613dcd3527cf1c1ccc8749ce3928ce2d23c67747cd3124cd1915f2c7c6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96857df2000e12a05e12a05e12a05e12a05e12a05e12a05e02904e02000f3b0a5e6553fffffffffffffffffffffffffdd1200e02903e12a05e12a05e12a05e12a05e12a04dd1100f9dad3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96a5adf1f00e12a05e12a05e12a05e12a05e12a05e12a05de1600f1a699fffffffffffffffffff09d9adb0900df1e00e02802e12a05e12a05e12a05e12a05e12a05e02700e12d0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c4bae1381ade1a00df1f00ea7258fffffffcedeafcf0edfdf5f2f3b0a2dd1b00e12c05e12c05e02a03de2300dc0f00dc1100e02a07e02a03e12c05dd1200fbe5e2f3b0a6ed8578f0988bf9dad2dc1a00df3112e23a1ee2422be34731e44a36e3432efceae4f4dfddd23c33d64c43d4483fd44039d13730cf3029cb2c1fc15a2fc33d1ccd1f19d01a1bd01d1bcb4a31c2a85f8e8e76cf5a34cc402dcf3325ca5737c67043cf201cc7623dcd3527d01f1dc76840cd2e24cf2721ce2921c8613dc7603acb1610d74845f9e7e7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ccc4dc0c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904de1b00dc0e00f09e94ffffffffffffffffffe86454df2100e12a05e12a05e12a05e12a05e12a05dd1900f09a8dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02703e02701e12a05e12a05e12a05e12a05e12a05e12a05dc0a00f7d0cafffffffffffffbe8e4fffffffae6e4df2200e02903e12a05e12a05e12a05e12a05e12a05df1e00ea7160fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2ab9cdd1100e02500e12c05df2100eb7860fbe7e7f09b90f1a195f4bab6f9d5ccdd1800e12c05e12c05de1d00ee917eeb7561e96a4fe34220e02700e12c05e02400e54b2af5bcb7f9ddd8fefffffdf8f7fbebe7fdfbfafefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcfbfbefeffae1e5f3e2d8cf9a6cc57c45c83d2ed1201cce2721b3433ece482ccb4a32cf3426ca5536c67043cf201cc7633ecd3226d0211ec76a41cb4530d01e1ccf2721cf221ecd3426c76d42c74429cb1610f7dad9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf1c00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701df1d00df250cfffffffffffffffffff6ccc4dc0b00e12a05e12a05e12a05e12a05e12a05df2000e86553ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0c00e12a04e12a05e12a05e12a05e12a05e12a05e02300de1d00fdf5f4fffffffffffff1a194ea7264e55139df2500e12904e12a05e12a05e12a05e12a05e12a05dc0c00f7cec7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcebe7de1900e02901e12c05e12c05e02600e55031e55339dd1200de1700df2808ea745ddf2200e12c05e12c05de1b00f1a291f1a498f3aea3ef9584df1e00e12c05e12d05dd1300da0400e3563bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcffffe07371c5503077aa95d71f17ce2721cc5736c7653fcf1f1dca5939cb4b31c67043cf211dc85c3bc95437d01d1ccf2420c95738c76a41cc3c2bd11a19d2221cd01c1bc66941ca3422d1322cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75b49e02200e12a05e12a05e12a05e12a05e12a05e02803dc0e00e02d10e54f3aed897bffffffffffffffffffffffffdf2000e02802e12a05e12a05e12a05e12a05e02701e02602ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d2cadd1200e12a04e12a05e12a05e12a05e12a04dd1200e23921ed8783ffffffffffffffffffffffffdf2507df1f00e12a04e12a05e12a05e12a05e12a05e12a05e02903dd1500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9587de1900e12c05e12c05e12c05e12c05df2000df1e00e12d05e12d05e02a01df2200e12c05e12c05e12c05e02b03de1c00de1b00de1c00dd1700de1b00de1d00db0c00ed8674fffffefffffffdfffff3b6a9e03c1ee6614ae9725fe97f70fbefebfffffffffffffffffffffffffffffffffffffcf2f3e08e84d8aa8bda6660d35247c6a76192886bce1208cd100cd40e06c54a29c35c32ca2216c82f1dc36035c92f1ccb3523c57949cf241fcf2520ca4831c77044cc422ed01719ce2620c97443afb671b05a4ad31d1ac85939cb3d2bca140df3cac8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a192dd1500e12a05e12a05e12a05e12a05e02903dd1700fae5e3fefaf8fffffffffffff9dad4ffffffffffffffffffe96a5cdf2000e12a05e12a05e12a05e12a05e12a04db0b00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a193dd1900e12a05e12a05e12a05e12a04dd1100f2a699ffffffffffffffffffffffffffffffdf230fde1c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400e54e3bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96750df2000e12c05e12c05e12c05e02700e54e2ee55033dc0d00dd1500dd1500de1c00e12c05e12c05e12c05dd1400eb816cfefdfcfdfaf8f0a091ec816ced846eeb765ffdf2f1f2b0a2ee917cf1a696fcede9eb7964ea7864eb7561e76b56fbe8e4fffffffffffffffffffffffffffffffffffffbf3f1d9a483de7a72df7873dbb18fdf8d80e97572e3827de28882ddb898e09689e57677dfa38ddfa88fe47979df9c89d0785bcb0f0cd0201ed0211ed01d1cd01c1bca4e33c76f43cc3b2bd21316c14133bd4b3bd11c1aca6e40cd452eca130cecaca9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcf2f1db0700e12a05e12a05e12a05e12a05e02000e86651fffffffffffff4bbb3dd1400df2100fffffffffffffffffff5beb3dd1000e12a05e12a05e12a05e12a05e12a04dd1100f9dad3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec7e74df1d00e12a05e12a05e12a05df2000e96d5dfffffffffffffffffffadfddf8d5d2fffffffdf8f9e34326e02500e12a05e12a05e12a05e12a05e12a05e12a05df1c00ec7d69ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea715cdf1f00e12c05e12c05e12c05df2100eb775ffdf4f5f4b5adf4bcb3f5bfb7ee9080de1e00e12c05df1e00e97a64ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1a395c4502bc85d3bc95939c75f3ccd3829cf1b1bc95537c76c42ce3225d11c1ad41a17a2ad77bb6849cc0f0aedb4b1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02704e02701e12a05e12a05e12a05e02500e23a1df09c9dffffffffffffea7058d90000fcf2efffffffffffffffffffdb0b00e12904e12a05e12a05e12a05e12a05de1800f3a99affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe6523be02200e12a05e12a05e12a05dd0f00f8d0c8fffffffffffffbebe7dc1000dc0900fdf5f4f3afa5e02c11e02701e12a05e12a05e12a05e12a05e12a05e12a05dd1000f6c2b8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec8270df1e00e12c05e12c05e12c05df2100ea745afffffff9d6cef9d9d1fce9e6f8d3cadd1700e12d05dc0e00fae6e7fffffffaefede86d55e76a4fe7664be86448e86448e86448e86448e86448e86448e86448e86448e86448e8674be66a4fe86447e86346e86449fdf2eef6dfddd95750da6e62d69a77db6660db6660da6b64d69174d8826eda6661d8826dd59e7dda6760da6f64d59c7cd96d63d88672d8987df8e2e4fffffffbf7f2c3421fca4b30c8663fca4a31ca4c32c76840cd2e24cf201dc85c3bc7653ecf3a28b2614dc24336cb130cf0c1beffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75848e02300e12a05e12a05e12a05e12a05dd1400f4b2a7ef8f7df6c8c6ffffffe02d15ed867affffffffffffffffffe65845e02300e12a05e12a05e12a05e12a05de1c00ee8c82ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02905e02701e12a05e12a05e12a05dc0c00f9ddd9ffffffffffffeb7567df1a00e02600e0290add1700e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05db0700fefafaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44a2ce02500e12c05e12c05e12c05e02400e86549eb7464dc0c00dd1500e23316f09e92de1e00e12d05dc0e00fadfe0fffffffaded7e65546f9d6cdf8d7d0f9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf9d5cdf7d7d0f8d5cdf9d5cdf8d4cdfefdfdfcf9f9f4cfcff4ded8f4dcd7f5d3d2f4d5d4f4d9d6f2eadef5d2d2f5d6d4f2f1e1f4ddd8f5d1d2f3e1daf3e2daf5d3d4f3e4d9ca2815f0d0c8fffffffadce1c35128c49857ce231eca4831c76a41cb3e2cca5336c8633ece2921d0201dcd422cce3928c68049cc100ce48e89ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec7f6bdf1c00e12a05e12a05e12a05e12a05dd1900f4b7aaf3afa2da0300f5bcb2fffffff9dbdbffffffffffffffffffe96b54df2100e12a05e12a05e12a05e12a05df1f00e96654ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0e00e12904e12a05e12a05e12a05df1e00ea7663ffffffffffffed877fdc0a00df2200e02802e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802de2100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae0dadd1b00e02b03e12c05e12c05e12c05e12c05df2200dd1400dd1800dd1600dd1700dd1800e12c05e12c05dc0e00fadfe0fffffffceeeaf2a69afffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4ffffa1a06df3dccefffffffadee1c34320c6844dcf211ecf221ecf251fc95536c8613dcd2e24c77a47b7a363b64b3fd31718c67847cf1c19ce2c24fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5b6aadd1300e12a05e12a05e12a05e12a05dd1800f3aca3fdf8f7dc0800dd1500e4452cee9081ee8d7de44d34e0280cdf1d00e12a05e12a05e12a05e12a05e12a05e02400e44125ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0c00e12a04e12a05e12a05e12a05e12a04dd1200f19f93ffffffffffffef9386e86a51df2300e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400e3452dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec7f6edf1c00e12c05e12c05e12c05e12c05e02b03df2504e96f57f3b2a8f4b8afef917ee13215e02700e12d05dc0e00fadfe0fffffff8d3c9de1901fffefcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefbfbcb1d17f3c3c4fffffff8eee9c34b23ca5737c7663ecc3c2bcf221fcf221ecd3d2bc8603cd21718bd543eb0654fd31817c67746cf1f1cca170eefbcb9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffceae7dc0800e12b05e12a05e12a05e12a05df1b00f09b95f4b4abdd1500e12a04e02400de1a00de1a00df2200e02701e12a05e12a05e12a05e12a05e12a05e12a05e02802df2100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbebe7dd1000e12a04e12a05e12a05e12a05e12a05e12a04de1500e2341ce96850ee8f7fe65942e02400e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2100e86255ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44220e02500e12c05e12c05e12c05e12c05df2100ea7057fffffff9d7cff9d6cdfdf6f3f7cdc4dd1a00e12c05dc0e00fadfe0fffffffae0dae75c51fefffdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef7f9c83424f0d6cdfffffffae3e4c90704cf211ece2721c85f3ccb4f34cf2420ce3628c8603ccf2420d1241fd31c19ce2821c4894fd01e1cca1b12e38782ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0b00e12a05e12a05e12a05e12a05e02702e13715df1e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904dc0e00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d3cadd1300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e02600df1f00de1b00e02300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1e00eb7460ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44021df2200e12c05e12c05e12c05e12c05de1c00f09885f5bdb0e13118e1301bea725dfbe5dede2000e12c04dc0e00fadfe0fffffffcefebf3a99efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffec27743f1d7cefffffff8eee9c4381bcf201ecf2620cd3427c95c3ad01c1ccd3d2bc8633dd01d1dce2721c85b3ac75f3cc57e49d01e1cca160de38884ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2200e02802e12a05e12a05e12a05e12a05e02701e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0a00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5bfb4dd1500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1900ef927ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8cfc7de1900e02a03e12c05e12c05e12c05e02700e4452dfdf9f8ffffffffffffffffffec8475de1d00e12d05dc0e00fadfe0fffffff9d5cbdf200bfffcfafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfafaca2c20f2c8c7fffffffae2e2c72f16c67144cd3125cd3628ca5637ca4930c76840ce231eca5236c66d42cd3527d11016c4854dce1917cf2d24fdf7f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2381ce02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0d00fdfcfbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3afa0de1600e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e12a04dd1400f2ab9dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9281de1d00e12c05e12c05e12c05e12c05df2100de2000e2381fe23921e02d0cde1c00e12c04e12c05dc0e00fadfe0fffffffdf4f2f5beb0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef8f9c45d38eee4d4ffffffeffaf4bb2b1dcf2820c67445cd2d24c95737c77847d01819c67748cc3e2cd01718cb402cc67245d5301fcc1610f2c8c7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44932e02300e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e02904e12903dc0e00fcebe7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff09c8bdc0900de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00da0100f4baaefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5beb3de1b00e12c05e12c05e12c05e02a02e13513e13214de1b00df1e00df1f00e02500e12c05e12c05dc0e00fadfe0fffffffcefecf4b7a8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef5f8c5492fefe9d7fffffff6fbefc63118cf2821c76d41cd2d24c95737c87044cf2d23c95d3bd01b1bc85e3bc85738d51e1983897dcc2b1dfdf3f4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe54d38dd1300de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00de1a00db0200f9dcd5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf1eef9dcd6fae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0daf9dbd4fef7f6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefaf9e02b0fe02700e12c05e12c05e12c05df2100ec7e66f7c7bee75b3ee8664ae9684de65334df2400e12d05dc0e00fadfe0fffffff9ddd5e54c3ffefdfbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef6f8c5482defe8d6fffffff8eae7c8160cce2a22c76a41cd2d24c95737c87044cf2b23c8603cd01c1bc76e42cd2922d0231db2bc71ca301fd74b45fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbe7e2faded8fae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0dafae0daf9dbd4fefaf9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b4a9dd1600e12c05e12c05e12c05e12c05df2100ea6f56fffffffffffffffffffffffff8d5ccdd1700e12d05dc0e00fadfe0fffffffaddd6e54f43fefefcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef0f6c9743cf3efd6fffffff8e9e7c7150bcf3025cea254cd2822c95737c87044cf2b23c8603cd01c1cc76c41cd2e24cf1e1dc78048cf1e1cca1a12f9e4e3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeb8070df1b00e12c05e12c05e12c05e12c05df2300ea745aef9a8edf2306e02c0de5503ef6beb1dd1b00e12d05dc0e00fadfe0fffffffcf1edf3b2a9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0f1899679d0f1eefffffff8eae7c9140ac63d3069c4a9d92719c95a39c87043cf2b22c85f3bd01c1cc76c41cd2e25d01f1dc67746cf1f1cca160defbbb8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d5cef19c90f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f0988cfbe7e4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b0a6de1a00e12c04e12c05e12c05e12c05e02b04e02904df2600e02800e02900e02700e02b08e02a03e12c05dc0e00fadfe0fffffff7d6cedc2d16fefaf9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefbfcd21810f6c4c2fffffff9e7e5c91008d11d1bd33b25c66941cd3527c77c49cf2921c9653dd01a1ac76c41cd2e25d01f1dc67a47cf1c1acc1f16f8e1e0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b9b3f1a093f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a398f1a397f0988efcf0ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff09c8bdb0400dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500de1600da0000f4b8aeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2705e02a02e12c05e12c05e12c05e02a03e1300ce02e0be02500e02700e02700e02700e12c05e12c05dc0e00fadfe0fffffffcf3f1f2beb5fefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9fbc93b25efe6d5fffffffae5e4c62914c76940ca4a32ca4931c76c42cd3326c94b34baa964d21015c76c42cd2e24d0201ec77545cc2d21d43a37ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe54838dc0e00dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500dd1500de1600d90000f9ddd7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b1a4de1700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05dd1500f2ac9dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe54c30df2200e12c05e12c05e12c05e12c05df2200eb7b61f2aca5e13422e3402de3412fe23a21e02800e12c05dc0e00fadfe0fffffffbece9f0b4aafefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef6f9c6492cefead8fffffff8eeeac3391dcb4831c7653ecc3f2cd01d1cd11c1abd4f3d89997fd71212c76a41cd2d24d01c1bd01619c66f43c8301ce3817fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe54933e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc1000fcefeaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c3b8dd1500e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802e02700e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1900ef927ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ccc3dd1600e02b04e12c05e12c05e12c05e12c05df2100ea6e54fffffffffffffffffffffffff8d5cddd1700e12d05dc0e00fadfe0fffffff9dfd9e25447fefdfafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbffc7492defead7fffffffadce0c34b23cb4630cc3c2acc3e2bcd3126c95335d1231dd71b15cf201ec97946ce2921c58b50c49a57cd2720c6633ecc1712fefefeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe2381ce02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0c00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d8d0dd1200e12a04e12a05e12a05e12a05e12a05e12a05e02700df1f00de1600dc1000df2302e1341ae02601e12a04e12a05e12a05e12a05e12a05e12a05e12a05df1e00eb7560fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a8a0dd1600e12c05e12c05e12c05e12c05e12c05df2200eb7a61f3aca4e1341fe33d25e76156f8cbc0dd1900e12d05dc0e00fae0e1fffffffcf5f3f2bbb0f8e0def3b5b4f4bbb7f2b4b1fcf3f3f6d1c9f6c6bbf6ccc2fdf2eff4b9b6f4b8b7f4b9b8f4b9b8f4b9b8f4b8b7f4bbb8fffcfafcf4f3edb2b3edc7bdeec1bcebd3c4eeb6b7eeb9b8eeb9b8eeb8b9ebd5c4edbcb8edc0bcecd2c4ecc9bfebddc7efb8b9edcbc0c03214ede7d3fffffffadde1c25527ce231fc2b564c49f59c66e43c0d371cb3d2ccf2822d2201aa6bb79c64833c9693fc87244cc3125c76540cb140ef5d2d1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2200e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000de1600df2100e02600e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0b00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcf0ecdc0f00e12a04e12a05e12a05e12a05e12a05e02600e1351ae86147f09f95f8cdc9fcedeaffffffdd1600e12903e12a05e12a05e12a05e12a05e12a05e12a05df2100e86255fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b7addc1300e12c05e12c05e12c05e12c05e12c05e02a02e1310fe02e0bdf2000df2200df2500e2381ae02901e12c05dd0f00f9e1dffffffffdf5f3f2b8aff7d9d6ef9a97f0a49eee9793fbedecf7dcd5f7cac1f8d5cdfcefeaf09e98f19f9cf19f9cf19f9cf19f9cf09e9bf1a29cfef7f5faedece79796e6b0a3e8a9a3e5c0ace99b9ce99e9ee99e9ee99d9de6b9a7e6b5a6e99f9de7aca1e6c2ace4deb8e8a19ee6bfacebbbb3fbfcf9fffffffbe0e5c24f25c95135ca4a32ca4b32cb3e2cce221fcf221fce2b23d3251da16959c7342bd11819cb4630c66f44cd2e23ca170efaeaeaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0b00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02100e86252f3aba2e55034e1311bde1b00dd1100e12903e12a05e12a05e12a05e12a05e12904dc1000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0b00e12a04e12a05e12a05e12a05e12a05de1600f3aea0fffffffffffffffffffffffffefefede1f00e02903e12a05e12a05e12a05e12a05e12a05e12a05e02400e3452dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe23a18de1c00e12c04e12c05e12c05e12c05e12c05df2100e02a09e33e2ae33d2be2361cde1b00e12b04e12c05e02300e4553cfbf0eefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffd88673c92d1dca4730ca472fcc3d2bcb432ec76e42cc3d2bd0201dcf2922d4201bcd3929c67246cb432ed01e1cc91008dd6b65fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffceae8dc0800e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1800f4b4aafffffffffffffffffffae1dcf5c2bfde1f00e12904e12a05e12a05e12a05e02701e02802ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd1100e02903e12a05e12a05e12a05e12a05df2000e97164ffffffef9988ffffffe86454dc1100de1d00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802de2100ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe55036de1c00e12c04e12c05e12c05e02600e44d34fffffffffffffffffffffffff09c8fde1b00e12c05e12c05dc1200ed8976ed8f7eed856ee7624de44b35e54e39e54e37e44735e86964ec7f64ea6f66e44a3de54c36e54e39e54e39e54f39e44e39e54d37e5503efdf5f1f7e1e0d23d37d27058d55c4ecf8562d47d5cd56450d26d56cf8d66d64845d36a55cf8964d65148d65048cf9168d5554bd08461d64844d08c65ca5238c73721cb452fca4830ca452fc95035c95536ce2621ca4f34c66b41ce2f25d01f1dc57948ce211ecf2620c9180ee17d79fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5b6aadd1200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1d00ed877afffffffffffff8d4d0ffffffffffffdb0800e12a05e12a05e12a05e12a05e02400e4482effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1310fe02600e12a05e12a05e12a05e12a05e02400e3432bffffffe23c1fffffffee928bdf2200e96958df2100e12a05e12a05e12a05e12a05e12a05e12a05e12a05db0700fefafaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe65940df2200e12c05e12c05de1c00f09a85f3b1ace13323e23524e96a62fbe2dcde2000e12b04e12c05de1b00f1a191f3ab9ef3b4a8ef917ede1600df2600dc1000f3b0a3fffffefceeeafefefcf6c2b7dd1500df2500df2500df2500df2500df2300df2401fff8f5f6deddc80c06c74e30cb3424c86338a79764b95d41c77843c1b25ecc251dce1916cc271dc65e38c75333cd1f19c8482ec2904fcc281dcf1113ca452dc76d42cc3f2cd01d1ccf211ec77847c67245c85f3bca5035ce241fc5814ad01318c67246ce2720cb1c13e5918dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec7f6bdf1c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2300d90000f1a092fffffff1a499dd1200e44832e02200e12a05e12a05e12a05e12a05df1f00e96d5effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75b46e02100e12a05e12a05e12a05e12a05e12904dc1200ffffffee908eea6f5ae33e29fdf9f7f7cdc6de1800e12a04e12a05e12a05e12a05e12a05e12a05e12a05dd1000f7c2b9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d1c9de1a00e12b04e12c05df2200e96850fffffffcece6fceae4fffffff6c2b9dd1a00e12c04e12c05e12a02df2500dd1200dd1500e02c06e02a03e12c05dc1200fbe9e7ea7156e33f1ce85f41fbe9e4df2702e02a03e12c05e12c05e12c05e02901e02a09fff9f5f6dfdfc9130dc95336cc3a2ac87745ae5e4cbc5540ce3426cb3628cb402dcb432ecb422ece2e24cd2e24c66b41ca4d32cf221fc85f3cc85f3bce251fd01518cb4e33c66e43cc3929c49555c6814bd10f15c8633ecd3828c77645d01318c67246ce261fcd241cfefcfcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75748e02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300e54f34f7cecbe76049f9ddd8ffffffee9181dc1100e12a04e12a05e12a05e12a05e12a05de1b00ef9287ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed867cde1c00e12a05e12a05e12a05e12a05e12a05dd1500f0a093e54728dd1500fdf5f3ffffffec8274de1d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05df1c00ec7e6affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9182de1c00e12c05e12c05e02b03df2400e75940ef917eef9785ea715ae02907e02901e12c05e12c05de1e00ed8773e86547e75b3ce23a17e02801e12c05de1d00ec806dfefefeffffffffffffed897ade1d00e12c04e12c05e12c05e12c05e02901e02b09fff9f5f6dfdfca130dc95336cc432ecd3125d03e29cd402ccb442ecb432ecc422dd43622cc3e2cc85d3ac8643ece231fcd3729c66e43cc422dce2d23c76e44c7804acd2c23d0211dc85838c85c3ace2720d01b1bc85738cd3a29c77645d01218c67144ce2620ca1a12f2c9c7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02804e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1c00ef938bffffffffffffffffffffffffffffffe33f23e02600e12a05e12a05e12a05e12a05de1700f3b1a3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3a89ade1800e12a05e12a05e12a05e12a05e12a05e12b05dd0f00df270dfefefdffffffffffffe65944e02000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400e54e3cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe34727e02300e12c05e12c05e12b04df2500dd1a00de1a00de1900df1e00e02900e12c05e12c05e12c05de1a00f1a496f4b6adf5c1b7ef9889df1d00e12c05e12d05dd1400da0100dc1000da0300dd1000e12d05e12c05e12c05e12c05e12c05e02901e02b09fff9f5f6dfdfcb130dc95336cb442fd1231ec5352ecf201ecf241fcf2721d02a21869681d33423d0181acd2e25c76740c85a39cf1e1dcb402dc66f44cd3627c759396fb19ed82317d01c1bce2520c85c3ac95838ca5034cd3a29c77645d01217cb9d53ce3a2aca140ce58f8bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2f2db0600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700de1a00e65452ed836cf3b5affbe8e4ffffffdd1400e12904e12a05e12a05e12a05e12a04dc1000fbe5deffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9ded7dd1100e12a04e12a05e12a05e12a05e12a05e02701e13115ffffffffffffe7685ef7cac3f3aba0dc0a00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e02903dd1500fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a599dc0c00df2200e12b04e02400e96a4fed8879de1e00e02908e02909e02a08e02a02e12c05e12c05e12a02df2701dd1200dd1500e02d07e02a03e12c05df2300e65639f8d3d2fae0d9f9dad7e96852df2000e12c05e12c05e12c05e12c05e02901e02b09fff9f5f6dfdecb130cc95437ca5035d81512849d86bba964ce3727d0201ed02620b75e47c5a25aca5636cf221ed01c1bcc3828c76d42ca4c33cf1d1bca4d33c77e49d74727d01f1cc95436c1d071ca4a31c86e43cb4a32cd3a2ac77544d8151473b999bf3c28ca0f08f5d6d4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a392dd1500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02904de1400f2a99dfffffffefbfaf3b5b1dd1600e33c23df2200e12a05e12a05e12a05e12a05e12a04dc0c00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0c00e12a04e12a05e12a05e12a05e12a05e02702e02607fffffffffffffffffffefefefefefceb7969df1e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05dc0c00f7cfc7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c0b7e6573ade2100df2100ea7157fffffffffffffffffffffffff5bcafdd1900e12c05e12c05de1e00ed856fe75f41e65535e13814e02901e12c05dd1200fbe7e6f09884e9674bee8973fcece7de2400e02b03e12c05e12c05e12c05e02901e02b09fef9f5f7dfdfca180fce2922c85c3ac85d3bd71f17cf3124c76c41c85e3bce2b22d21c1ad0191acb422ec67144cb462fcf1f1cd01a1ac7613dcb422fd0211ed1271ea5a3708e8373d4241bc95c3acd3326c77545cb4b32cd3a29c77645cf1a1ad6190fe06b67f6dcdbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75c4ae02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1e00e9705ffffffffef8f7fdf7f5fffffffae7e4db0700e12b05e12a05e12a05e12a05e12a05e02600e1310fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe13211e02600e12a05e12a05e12a05e12a05e12a05df1e00e54d38ed8a79f8d6d4fcf2eeffffffffffffde1800e02903e12a05e12a05e12a05e12a05e12a05e12a05df1e00ea7161ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75d46dd1600ec7d64f9d2cbe96e54ea755cef9484f9d6cedd1800e12c05e12c05de1a00f1a697f4bbb1f6c4bbf09989df1d00e12d05dc1300f8d0cafae0daf7cac1f9d8d1f9d6cfde1f00e02b04e12c05e12c05e12c05e02901e02b09fef9f5f7dfe0ca1810d0211ecd2f25c67546c76840c85938cf1d1ccd2e25c66b42c95638ce2620cf211ecf201dc94f34c67044ce2b22c94f35cb4330cf2821cf2922d41a17d81813cd2d24c95437c7653fce2a22ca5235cd3b2ac77645cb0d0be89d99ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf1c00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12904de1700fadfd8ffffffde1a00de1a00fcefebffffffdd1400e12904e12a05e12a05e12a05e12a05df1f00ea7163ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea7668df1e00e12a05e12a05e12a05e12a05e12a05e12a05e02300de1900d90000e02e1aea7762f1a191df2000e02803e12a05e12a05e12a05e12a05e12a05e12a05e02700e12e10fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b9afdd1400e23e1ae34222de1900df1d00e02806e65333df2500e12c05e12c05e12a02df2602dd1600dd1900df2601e02a02e12c05e02801e12f0eeb765fee8b77ec7a62e13516e02600e12c05e12c05e12c05e12c05e02901e02b09fef9f5f7dfdfca140ec85e3bc85f3ccf241fcf1f1dcd3427c76c43ca5135cf1b1bcc3929c67044cb4a32cf231ed0201dcd3427c8603bc94933cb422fcf2821cf221ecd3026c8613cc7653ecd3226d01618cc3326c67447ce2c22c77644cc100ff8e5e4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ccc5dc0c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12902dd1500fffffff8d3ceda0000db0400f9e0dcffffffdb0800e12a05e12a05e12a05e12a05e12a05de1800f2a598ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3ada1de1700e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1300f09d91ffffffffffffffffffe55343df1f00e12a04e12a05e12a05e12a05e12a05e12a05e12a05db0900f9dbd6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf0edde1e00df2400dc1200de1e00de2000dd1500de1d00e12c05e12c05e12c05de2000ea725bf7ccc1f7d0c5ea6e5adf2100e12c05e02a02e02906de1a00dd1700de1a00df2400e12c05e12c05e12c05e12c05e12c05e02901e02b0afef8f6f8dedec82e1ac95c39d01518c2b263c1b966cf1c1ccf191acc3d2cc67044ca4931d01919d03e28c67144cc3829cd3327c95736ca5737cc462fd0201dc95938c8623dd1261fd01618cc3929c76d42c95838cf1f1dce2c23c57843d22827ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96858df2000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1400ffffffffffffec7f6fed8475fffffff3b3a9dd1400e12a05e12a05e12a05e12a05e12a04dc0f00fbe9e4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf8f6dc0d00e12a04e12a05e12a05e12a05e12a05e12a05e02200e75e4cfffffffffffff6c7c4fffefdffffffdd1800e02802e12a05e12a05e12a05e12a05e12a05e12a05df1e00ea705fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75f48de1c00f5beb7fbe7e1fbeae5f9d9d4e6573edf2200e12c05e12c05de1900f3aea1f4b6a6f5bdadf1a195de1c00e12d05dd1300f8d1cde6553ce44320e44624e33d1ae02700e12c05e12c05e12c05e12c05e02901e02b0afef8f6f8dedec82b19c7673fcf1c1ccd3627cd3126c59454c1bc67cf221ed00e15ca5335bdb265a17561d51213c67f4acd3025cc5031b59e63c06a46d21015c67b49ce201daf7155c69e56c95537cf1c1bce2b23c8623dc8633ec7130aeaa3a0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1a00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02501dd1500ec8078ffffffffffffffffffffffffe02e14e02600e12a05e12a05e12a05e12a05e02802de1700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2503e02701e12a05e12a05e12a05e12a05e12a05df1c00ed8a76ffffffe3462bda0000e23a20ffffffea705fdf1e00e12a05e12a05e12a05e12a05e12a05e12a05e02802de1c00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfcf09c90fbebeaee8b7eee8979f5c1bbfae1dbde1c00e02b04e12c05e12b02dd1b00e8625ee8615ddd1900e12b03e12c05dd0f00fadddcfffffffffffffffffffae3dedd1600e12c05e12c05e12c05e12c05e02901e02b0afef8f6f8dedec82918c67143c66b42cb4530cf1b1bce3c29ca5034c95838c2ab5fce3125ca2d26a95d51d51515c96f43cd3326cd5734a65b52b8483ecb5435c76940cb2d25918674d51c17ce2a22c7673fc8603cce2d23c90a06de6d69fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b2a7dc1000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701e12d0dffffffed867ce75c46f09f94f3afa7e23b1edf1d00e12a05e12a05e12a05e12a05e12a05df2000e8614fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeb7769de1d00e12a05e12a05e12a05e12a05e12a05df2000ea7062ffffffdd1700e12902da0200fdfefff5b8afdd1700e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc1000f3afa5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c7c3ec857ced877cf3b0adfaddd7de1d00e12b04e12c05de1f00ec806bf8d1cdf8d5d1ec7c68de1f00e12c05dd1600f6c4bfe13419de2000e02e0ef3ada1de1c00e12c05e12c05e12c05e12c05e02901e02b0afef8f6f8dedec82d1ac95a38d11116ca4932c69d57b17855ce1f1ecb4f33c49454cd3326d0201dd2211cc94a31c77244ce2921c8633cd41315cb623acb422ed01d1ccf2720c54a36c69051c7613dce2b23ce1c18c91209e17f7affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe3422ae02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200e75d48fffffffffffffffffff5bab6e65341df2000e12903e12a05e12a05e12a05e12a05e12a05de1800f2a99effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5c0b5dd1400e12a04e12a05e12a05e12a05e12a05e02802de1d00fffffff09990de1a00dd0d00f6ccc4f09a90de1700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23c24fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfbf9dadae65537df2100e12c05e12c05de1a00f19f8ff4b6b4f5bbb9ef9485de1d00e12c05e12d05dd1700e02700e02a02e02700dd1900e12c05e12c05e12c05e12c05e12c05e02a01df2806fef6f4f7dddcc9130cc8603cc8613dce241fd5171594826ec93a2cd21f1cd30e13cf2721c95336c76941cc3c2bcd2d24c67045cc3d2bcf1b1cc77142cd2e25d02720c73d2e81ad8ed43420ce1916ca140cd0322bf0c4c1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadedadb0900e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de2000dd0f00dd1500e65842f7cdc8fefefdffffffe1351ae02600e12a05e12a05e12a05e12a05e12a04dc0c00fefcfbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdc0f00e12903e12a05e12a05e12a05e12a05e12a05de1400f09989ffffffdd1300de1c00ee8f7bf3aeafe12e0be02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc0900f7cfc7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae2dbea7063df2607de1d00dd1a00e02901e12c04dd1600e55043e54e41dd1500e12c04e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e02600dc1200e33d25fffffffbf2f1cc1f17ca0b08cc2e23c76f43c7814bd12e21d3211cc23e32ac9e68c78e4fcc3226ce3026c86840cb4c32ce1d1ccb452fc76941c77a47cd2e24cf2a22cf211ad30701cb1c16d23d35ecaeabffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75e4bdf2000e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000e7604eee8e80de1d00dd0d00da0000ed8b78eb7865de1500e12a05e12a05e12a05e12a05e12a05e02500e23516ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe85c47df2100e12a05e12a05e12a05e12a05e12a05e12a04de1d00df230ef09d92fffffffffffffffffffdf6f5dd1300e02903e12a05e12a05e12a05e12a05e12a05e12a05e02300e4472ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadcd5ef9484df2504dd1700eb7d68f8d4cff9d7d3eb7966de2000e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05df2300e23a1bf5b8aefceeebfffffffffffff8e2e1ebadaacd251dcf1918d053316fc0a3d32b1fbf4436a95a4ed12e21c76941cb5235c62b27c37248c5894fcb442fd01518c9613bcd3227cb1c14d03730edb2b0faeae9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffceeeadc0b00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12904dd1600fae4e0fffffffeffffef9488e33e23ffffffe96754df2100e12a05e12a05e12a05e12a05e12a05de1a00ef9287ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4b7aedd1500e12a04e12a05e12a05e12a05e12a05e12a05dc0a00fefcfbfffffffffffff2aea5f2a89bffffffea7363df1d00e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc0900f8d2cbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefaf8df2301f09e8df4b6b5f4bbbaef9789de1c00e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e02a02e02a09fdf6f5fffffffffffffffffffffffffffffffffffff4d1d0ca1b12cf231fde0d0bcf1e1ccd3c2aca683fc95135cc3628d41b17a17961a98160d21e1acf2420d01b1bc86d41cb261bd95853ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe86250df1f00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701e02808ea7765f9d6d2fffffffffffffffffffefeffdb0900e12a04e12a05e12a05e12a05e12a05e12a04dc0d00fcf0ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd1000e12903e12a05e12a05e12a05e12a05e12a05df2000ea7061f1a496e12e11db0500da0000fffffff8d3cbdd1800e12904e12a05e12a05e12a05e12a05e12a05e12a05e02400e33e24fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff2a69cda0000e44931e4482fdd1c00e12c04e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05e12c05df2400e2381efffffffffffffffffffffffffffffffffffffffffffbf1f1cc1d15cc271fb67552c79c57d1462cd10f15ca4d33bfe279c8603cd51314d31b19cf211ecd3326c76b41c85233c80a02f8dfdefffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae2dedc0b00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1900f3b2a7fce9e5d70000e44631f5c0b7ffffffec8072df1b00e12a05e12a05e12a05e12a05e12a05e02400e2361affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe96957de1e00e12a05e12a05e12a05e12a05e12a05e12a05de1d00dd1100dd1300e33c23f5c3c0fffffffdf3f0dc0b00e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc0c00f5b8affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfcf4baade55032e65536e23b18e02700e12c05e12c05e12c05e12c05e12c05e12c05e02b03e02700dd1900dd1800f4b7a9ffffffffffffffffffffffffffffffffffffffffffffffffe58885c32416897b67d52719908975cc7742ca4f33ca5435cc452dcc4a30cc482fc7663fc75e39cb170fcd1812ebaca8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5462fe02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904de1800f9dbd8ffffffee8a7bda0000ef9389ffffffdd1600e02803e12a05e12a05e12a05e12a05e12a05dd1800f09e92ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9d4ccdd1000e12a04e12a05e12a05e12a05e12a05e12a05e02600e3422af8d5cffffffffffffffdf2f2e8644ced8375de1a00e12904e12a05e12a05e12a05e12a05e12a05e12a05e02701df2306fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf8f6ee8b7cdb0a00de1a00df1f00df1f00df1f00de1c00dd1700de1d00e13415ef9687fdf6f3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae6e6e97976cf2c23ac483bc9371bc82f1cc9281bc92c1dc92b1cc82817ca180fcf201be2837efdf8f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5bbb3dc0c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1100f5bfbdffffffffffffdf2612ee907ef1a295de1400e12a05e12a05e12a05e12a05e12a05e12903dc0e00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe02b0fe02600e12a05e12a05e12a05e12a05e12a05e02701df2709fffffffbe7e4e96d63ec7e6ffef8f7ffffffe44935df2100e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1600ec7c6dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf5f3f5beb4ee8f82ea735dea6f58ea715bec8474f3b1a8fadfd8fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9d2d2eba7a6e2807cdf716dde706ce07975e99c99f3cccbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2103e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02a04dd1100e3442effffffec8476fffffffbeae6da0000de1600e12b05e12a05e12a05e12a05e12a05e12a05de1f00e8634effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1a094dd1700e12a05e12a05e12a05e12a05e12a05e12a05df1d00e4493de76252fcece9fffffffffffffffffffae2dedd1100e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd0b00f9d9d5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea7062de1900e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904de1a00ef9488fdf2f3feffffef9696ffffffffffffeb7c6cdf1f00e12a05e12a05e12a05e12a05e12a05e12a04dc0f00fad7d0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd1200e02803e12a05e12a05e12a05e12a05e12a05e02903de1d00fffffffffffff9dbd6e1351fef9383ffffffe86553df1f00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e0290cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c2bbdc0b00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200e23b25fffffffffffffefefdfffffffefaf9fefdfde13114e02600e12a05e12a05e12a05e12a05e12a05e02400e2341affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec8073de1b00e12a05e12a05e12a05e12a05e12a05e12a05df1900ec806ee96955db0900df2100de1800fffffff7cdc4dd1200e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1700ea6f61fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefdde1a00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802de1c00f4bcb4e02a15e0270ae02c0bdf2705df2100de1c00df2300e12a05e12a05e12a05e12a05e12a05e12a04dc1300f4b7aeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfcdc0f00e12903e12a05e12a05e12a05e12a05e12a05e12a05de1c00de1800e0250adf2100de1500e23b2fed8c7bef9787de1a00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1700e7594ce85e53e85d51e85d51e85d51e85d51e85d51e85d51e85d51e85e51e85e51e85e52e85e51e85e51e85d51e85d51e85e51e85e51e85d51e85d51e85d51e85e51e85e51e85e51e85e51e85e51e85d51e85d51e85d51e85d51e85e52e85e52e85d51e85d51e85d51e85e51e85e51e85e51e85e51e85e51e85e51e85e51e85e51e85e51e85e51e85d51e85d51e85d51e85e51e85e51e85e51e85d51e85e51e85e52e85e52e85e51e85d51e85d51e85e51e85e51e85d51e85d51e85d51e85e51e85e51e85e51e85d51e85d51e85d51e85d51e85d51e85e51e85e51e85e51e85d51e85d51e85d51e85d51e85d51e85d51e85d51e85d51e85d51e86257e2361bdf2200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1b00ef9281fffffffdf5f4e44a32dd0f00e02600e02802e02903e12a05e12a05e12a05e12a05e12a05e12a05e02700df2206ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea6f5ede1d00e12a05e12a05e12a05e12a05e12a05e12a05e02600e33e27ffffffe44635e34028fae7e2ffffffffffffe02e12e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300df2200df2200df2200df2200df2200df2200df2200df2100de1900dd1100dc0e00dd1000de1600df2000df2000dd1400dd1300df1e00df2200df2000dd1400dd1300de1800de1500dd1300df1f00df2200df2200df2100dc1000dc1100df2100df2200e02200de1a00dd1300dd1300dd1300dd1300dd1300de1800de1700dd1300de1600e02200df2200df1d00dd1300dd1300de1a00df1d00de1400dc0f00dc0e00de1600df2000df2100dd1400dd1400df1f00df2200df2000dd1300dd1300df1c00df2200df2200df2200df2200df2100de1500dd1300de1700e02200df2200df2200df2200df2200df2200df2200df2200df2200df2200e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02801dd1900dd1700f2a59afffffffffffff1a59dde1900e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1500f2a99dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf9f7dc0e00e12903e12a05e12a05e12a05e12a05e12a05e12a04dd1000fbe3e1fefefdfffffffffffffbebe8e54b37df1e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903de1700e6533bef978ef2ada9f0a29be9705dde1e01e02300ec8474ee8e82e23919e02400df2200ec8374ed877ae75d46eb7968ee8e80e02f0fe02802e02903de1d00f1a29af19e95df1e00e02903df2100e65941ed897bec8273ec8273ec8273ed8678e7614de96b58ed887aea7462df1e00e02400e23a1bee8b7fed897be75e47e23518ec8071f1a49ff2aaa5ea725fdd1b00e02402ec8575ed887ae13212e02600e02b0ced8a7ced8b7de54b2ee02400e12a05e12a05e02903df2502eb7c6bed887aea6c5adf1e00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903df2001fae6e2f7cdc3f09c96fae3dffffffffffffff9dbd8dd1000e12a05e12a05e12a05e12a05e12a05e12a05e02700de2002ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea7566de1c00e12a05e12a05e12a05e12a05e12a05e12a05e02500e1351cffffffffffffec867cdc0e00df2100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1100f6c0b8ffffffffffffffffffffffffffffffffffffe33a28ffffffffffffe86449db0400f3aca3fffffffffffff6cac3fcf1eeffffffe24025e02500df2000e65843ffffffffffffe5533ee02000dd1300f4b5acfffffffffffffffffffffffffffffff8d7d0f7cec5fffffffbe7e3dc1600dd1200f7cac5ffffffffffffe75c4dfae1dbfffffffffffffffffffffffffae4e1e02c20ffffffffffffe44937df2000e23b21ffffffffffffee8c79de1a00e12a05e12a05e02802df2609fffffffffffffbeceddc0c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2100dc0f00fcf3f1fffffffefbfcfefaf9fefcfbffffffe1381de02500e12a05e12a05e12a05e12a05e12a05e12a04dd1300f3aea5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd1200e02802e12a05e12a05e12a05e12a05e12a05e12a05dd0f00f1a092ffffffdf2509e02500e12a05e12a05e12903de1b00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e23315fffffffffffffffffff7d2cefdf5f5ffffffffffffef9785fcf0edffffffe55034e64f38fffffffffffffffffff4bab1fbe4dfffffffe23d21e02500dc1000f8d6d0fffffffffffff7cfcadd1400dd1400f2a99efffffffefcfbf1a59bf0a096f2a99feb806cf8cec5fffffff8d6d0d90000e34329fffffffffffff7cfcadb0b00fdf6f3fbe6e5ea7461e76049fdf0eeffffffeb7666fefbf9ffffffe34431df2000e2381effffffffffffed836fde1a00e12a05e12a05e02802de2305fdf4f2fffffffadcdbdc0c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02000e6563feb7b69e34134ffffffe65742db0700df1f00df2807df1f00e12a05e12a05e12a05e12a05e12a05e12a05e02400e02d13ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9382dd1600e12a05e12a05e12a05e12a05e12a05e12a05e12903dc1100ffffffe86756dd1000df1d00df1e00dd1000ee8f85de1e02e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23d23ffffffffffffec8375da0000df240cfffffffffffff1a594fceeeaffffffe6563dfdf6f8fffffffffffffffffff4bbb1fbe4dfffffffe23d21df1e00e44732ffffffffffffffffffffffffe34228dc0d00f2a99efffffffdfaf9ee8c87ed8580ed817adb0700f9ded7fffffffdf4f2f2ab9ffceeecfffffffdf7f7e12d12e02400e33d28dd1500ec837cf4bcb3fefefeffffffec826ffefaf8ffffffe34431df2000e2381effffffffffffed846fde1a00e12a05e12a05e02700de1a00fdf6f5fffffff9dddedb0300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700dd1200fefffdfffffff4bab8fae2ddfdf7f7db0800e12902e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a04dc0f00f8cfcaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf2407e02500e12a05e12a05e12a05e12a05e12a05e12a05e02500df2507f09b96ed897dea7564e75c48f7d3cbfffffff2afa3df1b00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23b21ffffffffffffea6c57df1d00e02300fdf5f4fffffff1a292fceeeafffffffbebe8fffffffef7f7fcf5f4fffffff4bbb1fbe4dfffffffe23e21db0900f6c8c2fffffffbeae8fcf0eefffffff5bfb8da0000f2a99effffffffffffffffffffffffffffffdf2005f9dbd4fffffffffffffffffffffffffffffffbe6e7e44126dc1000ed867afffffffffffffffffffffffffdf3eee13124ffffffffffffe34531df2000e2381effffffffffffed846fde1a00e12a05e12a04dd1100f09e8fffffffffffffffffffe96752de1800e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1600f3b6ade23e2ffbe5e0ffffffffffffffffffe86657df2100e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000e55039ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7c8c2dc1000e12a04e12a05e12a05e12a05e12a05e12a05e12a05dd1200f6c7beffffffffffffffffffffffffffffffe75f48e02200e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23b21ffffffffffffeb6f5bdf1c00e02503fdf7f6fffffff1a292fceeeaffffffffffffffffffe86555f8d2cefffffff4bbb1fbe4dfffffffe1381ae2351effffffffffffef958ce96756ffffffffffffde200af2a598fffffffdfafaed8a78ed8672eb806bdc0f00f9ddd7fffffff7d2d0dd1200e02b13fadedafffffffae7e5dc1100fdf8f5fffffffdf3f2f5c5bfea6e5cdf2108e0280fffffffffffffe23e2cdd0d00e0280effffffffffffec7963db0700df1e00de1900e8675bffffffffffffffffffffffffffffffe13721e02100e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1c00ee9183ffffffe96450d90000ef978fffffffffffffed8777df1c00e12a05e12a05e12a05e12a05e12a05e12a05e12903dc1000fef8f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe65741df1e00e12a05e12a05e12a05e12a05e12a05e12a05e02902df1f03e9715dea6d56f8d3cdffffffdf2414de1b00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23b21ffffffffffffeb6f5bdf1c00e02503fdf7f6fffffff1a292fceeeafffffffffffff9d5cfd80000fbe4dffffffff4bab1fbe4dfffffffde230af2aba0ffffffffffffe13015df2408fefefefffffff09d98ef9389fffffffefcfbf1a69df1a192f3aea1e6553bf8d4cdfffffffae0dee65b47ea6f5ffceeedfffffffceae6de1900fdf7f5ffffffef9a8de86561f4b1a9ffffffe23a2dffffffffffffe96758f2aba8f3adaefffffffffffff7ccc6f2a7a6ea7a6ddf270cfffffffffffffefdfbdf2105fcf0eefffffffbefeddd1600e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200de1800e96d5bfffffff3b5a8e86856db0700e44630f6c7c0dd0c00e12a04e12a05e12a05e12a05e12a05e12a05e12a05dd1600ef907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1400e02802e12a05e12a05e12a05e12a05e12a05e12a05e02802df2000d90000fef8f7fbeae5de1800e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500e23f25ffffffffffffeb7763df1b00e02706fffffffffffff3afa0fefdfcffffffffffffdf280dda0900fdf2f1fffffff6c9c1fdf3f0ffffffe54f42fffffffffffff6cac6dd1300dc1000f3b2aafffffffefffff6c3b7ffffffffffffffffffffffffffffffed8976fadbd4ffffffffffffffffffffffffffffffffffffec8270db0700ef9688fffffffffffffffffffffffffcf2eee02510ffffffffffffef9b8cfffffffffffffffffffffffffffffffffffff9dcd7fceef1ffffffffffffe55342dd1000e44a36fffffffffffff9d8d2de1600e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1e00e65643e44835da0000fffffffffffffffffffbe6e3db0700dd1300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e02400e12f17ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3b1a8dd1000e12a04e12a05e12a05e12a05e12a05e12a05e12a05e02500e34329fffffff3ada7de1700e12a05e12a05e02903df2100e02300e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802e12d0dea6a5dea7064e23d20e02500df2601e96758ea6e61e54b33e86454ea6d61e54e3cdf1e00df2000e86152ea6d61e55540e86150ea6f63e33d26eb7165ea6f63e2361ae02500e02701e12c0bea7064ea6d60e8604fea6a5de9695be9695be9695bea6e62e33b1fe75946ea6b5ee9695be9695be9695cea6c60e34028de1500e12b05dd1400e55440ee917ff09d8eeb7764e44a35df2200ea6c5fe96a5de44429ea6d61e9695be9695be9695be9695be9695ce96c5fea6e61ea6b5ee75f4fdd1500e12b05de1c00e65440ea6c60ea7164e02e0de02803e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e13515fffffffffffff2ada3ffffffe55147fdf3efffffffdb0800e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12903db0e00fce9e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75845de1c00e12a05e12a05e12a05e12a05e12a05e12a05e12a05dc1000f7ccc5eb7a6bdf1e00e12a05e02400de1700e76049e44b30dd1500e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802df2100df2000e02600e12a05e12904df2100df2000df2300df2100df2000df2300e12a05e12a05df2200df2000df2200df2100df2000e02500df2000df1f00df2400e02500e02500e02500df2000df2000df2200df1f00de1d00de1b00de1c00df1f00e02500df2200df1f00df1f00df1f00df1f00df1f00e02400e12903e02802e02901df2100de1800dd1600de1d00e02300e12903df2100df2000df2400df2000df2000df2000df2000df2000df2000df2000df2000df2000df2200e12a05e12a05e12a04df2300df2000df2100e02803e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02400de1600dd1400f5bab6ffffffffffffec8978e33c32ffffffe86859df1e00e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1400ee8e7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffde1d00e02500e12a05e12a05e12a05e12a05e12a05e12a05e02802e0290ee02c07e02803e02700de230bfbedebfffffffffffff8d8d6de1c00e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903df1d00df1d02e23613e23917de1d01de1b00e12a04de1d00de1900e02a08e33f1fe0300dde1b00de1a00e02501de1c04de1a03de1a03de1a03de1a03de1c03de1f00de1b04de1a02de1a03de1a03de1b03de1a03de1d04e02601e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1c00e1351bf5c2bdf8d7cee55247eb7f77fffffffffffffffffff19e91dc0a00e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000e3412dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadcdadc0d00e12903e12a05e12a05e12a05e12a05e12a05e12a05e02802e02803e12a05dc0d00fae0dbfffffffbe3dff5c0b8fffffffae7e7dd1500e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1400f7d1cbfffffffffffffffffffffffff09385db0700e97062fffffffffffffffffffffffffffffff09988e1311ffffffffffffffffffffffffffffffffffffff09785ffffffffffffffffffffffffffffffffffffffffffe02807e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1d00e44e3fffffffffffffffffffffffffea7167e5503bfffffff5beb5db0800e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701dd1700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9383dd1200e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802df2502ffffffffffffdb0c00da0000f0998bffffffeb7b6adf1800e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1e00fefaf8fffffffdf3f3f9dbd9ffffffffffffe75a48fefefdffffffffffffffffffffffffffffffffffffe97064fffffffffffffefefdfefcfcfefefefeffffef9382fffffffffffffffffffefdfcfffffffffffffefbfbe0290ae02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02700df2503ffffffffffffe34631e75f4affffffffffffdd1100e44830df2103e02902e12a05e12a05e12a05e12a05e12a05e12a05e12903dc0d00f8d1cdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe75d4ade1a00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05db0c00fcf1f0ffffffe13019db0400ea7368fffffff4b1aedf2810df2705e02400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02803e02a07ef968ae02815db0400e54f42fdf3effffffff09f8dfffffffffffff2a59bde1b00e96f65ffffffffffffee9581fefdfdffffffec7f69dc0d00de1d00dc1300dd1500f9dddcfffffffffffff5c2bbdf240ce34027e34026e02400e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1a00ee9085ffffffea745ddd0b00db0400faded7ffffffe13417df2100e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1200ee8f7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03119e02100e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300e4452bfffffffffffff4b2a5ffffffffffffe34732fcf3f4ffffffe1300ee02601e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df2000e13217fae2deffffffffffffffffffffffffe76258ffffffffffffe65233df1a00e02c10fefdfcffffffef9381fefdfeffffffffffffffffffffffffee8876dd1700dd1500fbe9e7fffffffffffff1a69bdc0700e02500e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903e02803e12a05df1c00ec7d6efffffffae3e0de1e00ee8976fffffff7cbc4dc0d00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1900e75f4effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffedd1b00e02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1700e44f3affffffffffffffffffe8654ef6c3b9fffffff9d9d2df2000e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903dd1a00fdf6f6fffffffffffffffffffbe7e6e54e3ae1301cffffffffffffe7593ddf1e00e13218fefefcffffffef9380fefdfefffffffefbfbfdf7f8ffffffea715cdf1c00df1c00dc1000fbe5e2fffffffffffff0a299dd0d00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600dd1b00e02300e02600de1900db0b00fbe9e4fffffffffffffffffffbebeadd1700e02901e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1e00e23b28ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdf3f2dd1100e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1e00dd1900e86253dd1600f2a8a2ffffffffffffe7604cdd1100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701e12f11fefbfaffffffec8071dd1500e34232f4b9afe54c44ffffffffffffe7593ddf1e00e13218fefefcffffffee9380fefdfdffffffee8f81e02c1ae23a27e3462fdf2604e7604be6533de5553cfefbfbffffffffffffef978fde1800e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df1f00df2200fcf1f3f8d2c9da0100f8d2cef1a199d90000f3afa3fdf6f8f09787dc1300e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200df270affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffadbdadc0e00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903dd1400ed8d82fffffffceeebf4b7aeffffffed8878de1c00e12a05e12a04e12903e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1300fadfdefffffffffffffffffffffffffef7f4e34036ffffffffffffe75b3fdf1e00e13319ffffffffffffef9886fefffffffffffffffffffffffffffffef9f7e65134fffffffffffffffffffffffffffffffffffffdf5f2de1b00e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1b00e65343ed8772fdf0edffffffffffffffffffe86a64f0978be3432ddb0100de1800e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400dd1a00fefefcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c8c4db0d00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e02e10fbececffffffe65145ee907de3422ce02500e12a04df1d00dd1600dd1700de1a00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02600e02504f4bbb3fffffffffffffbedecee8a78e1341efbe9e5fdf0eee55134e02000e13013f9ddd7fcebe8eb7f69fadcd7fadfdafaded9faded9fae2ddf6c6bee33d20fcefecfaded9faded9faded9faded9fae2ddf6cbc3dd1a00e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02300df1e00e75a40ffffffffffffe45048ffffffffffffea7562f5c0bdfffffff09c8ede1a00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400dd1600fefaf8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6bdb7db0c00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500dc0d00f6c4bbffffffee8b7cde1800e12a04dd1400ea776afefbf9fefdfbf09d91de1800e02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701dd1300db0600db0800dc0900de1a00e02400dc0c00dc0a00df2100e12a05e02601dc0e00dc0b00de1900dc0d00dc0b00dc0b00dc0b00dc0b00dc1000df2200dc0b00dc0b00dc0b00dc0b00dc0b00dc0b00dc1000e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02701de1700e54d38df2307ea705bfffffffffffff7cec6e54e36ffffffffffffffffffe85f51dc0d00e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02400dc1400fdf5f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c2bedc0c00e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12902db0700f2b0a4ea735cdf1f00e02200e6553efffffffffffffcf3f4ffffffffffffe13418e02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05e12a05e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2400de2202ec7e6dfffffff3b2a9e86256fffffffdf6f5ffffffeb7872ef9189ffffffe13010dd1800e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300dd1700fdf7f5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d4d1dc0e00e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1600df1f00e12b05dd0f00f8d4cfffffffeb7864d80000df2308fefafdffffffdd1500de1700de1b00e02701e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903e02300e02701e12e12fffffff7d0c8f8d2cafffffff6cac1ffffffe55247ffffffffffffe23925df1f00e02200e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02100de1d00fefbfaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbebeadd1500e02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd0f00f9d2ceffffffde1e00e02300e02300e13216e76149eb776af5bdb1f0968ddf2203de1900e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e12a03e02600dd1100e65a42e02400dd1600f3b1a9ffffffeb7b67ffffffffffffffffffe33c28e96d5af09e95de1c00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05de1c00e12d14ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefdfbdf2508de1d00e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02300e44b33fffffff9dee0de1a00de1800dc0d00f09e93ffffffffffffffffffffffffea7969de1700e02701e02702e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802de1900dd0f00df1d02fefefdf9dddadc0b00e02700df2001fffffffbe8e6eb7e69ffffffffffffe54a35de1700de1900e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04dd1500e54737ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44837dd1500e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05dd1600e5523ffffffffffffff3b6aadf270bffffffffffffe65042e44932fefbfaffffffe54f3ae02a08df2302df2000e12903e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802dd1900f09d90fffffffffffffffffff5c0b8df260ae02600de1800ec8070ffffffee8984f9dcd5ef998ede1c00e12904e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02902dc0f00eb7461ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec7e69dd0c00e02801e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1f00dd1100ec877be23c20e5503ffffffff6c7bddb0400db0700eb7661ffffffed8983f3afa9ffffffe55437de1400dd1a00e02801e02600e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e12a04e12a04e12a05e12a05e12a05dd1700f4bab1ffffffeb7c75fbe4defffffffffffffdfaf9dd1600e12903dd1400fcf5f3f6c8c0db0300de1800e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500dc0d00f2a89effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c1bcdd1000e02100e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903df1e00df2400df1d00fefeffffffffef9386e33e29fdf2f3ffffffe6583dfdf2eefeffffdc1104f9d6cffef8f6de1600e2391bdc1300de1a00de1a00e02702e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e12a04e02802de1c00dd1400dd1100de1a00e02904e12a05e12a04dd1700f9d5d0fffffff2a9a3fffffffbe7e5dd1804dc0c00e12904e12a05e02600de2100dd1000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04de1b00df2103fbece9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffde33924dd1400e12903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02200e02c0cfdf3f2fffffffffffffffffff8d6d1e54f42fffffff3afa6f8d5cdfffffffefefddf220ffffffffcebe9ef9685f1a09ae23410e02701e12a05e12a04e02701e02300e02600e12903e12a05e12a05e12a05e12a05e12a04e12a05e12a05e12a05e12a05e12a04e12a04e12a04e12a04e02802e02802e12a05df2100dd1400dd1600de1b00ec8379f9e1dafffffff19f90dd1800e12904e12a05e02400e13317f9dbd6fffffffefefdfffffffceae7dc0f00e12a05e12a05e12a05e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02802dd0e00e8604dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffee8e7cdb0b00e02300e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500db0900e8614ef1a495ee8d7fda0000f8d0cbfffffffffffffffffff2aca2ffffffe96e64fffffff2aea0f9dad3ffffffe2361ee02500e12a05df1e00df2301e44c34e13313db0f00de1a00e12904e12a05df1c00dd1600df2200e12a05df2000de1600dd1500dd1300dc1100de1500de1e00e02c07df1e00e75b43f9dcd5f5c1c1f5c1c5fffffff5beb3f5bcb2ffffffe75642e02200e12a05e12a05e02600d90000f6c4bdfffffffcf2f0f5beb6dd1400e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df1f00dd1100f4b7b0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcede8e13119dd1300e02903e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2100de1800de1800e2371afffffffffffffefbf9e02c15e23523fffffffdf6f5ffffffe86454fefdfcfcf5f3e34128dc0d00df1c00e6553fffffffffffffffffffffffffee8f7cde1b00de1900ed8c7ef8d2cae7593ede1500ea7764f4baaff7cbc2fae2ddfdf9f9f4bbb0fffffff1a89ed80000f8d5d3ffffffe65844eb7865e55046ea6f64ffffffffffffe23f26e02500e12a05e12a05e12a05e02400e34029f4b8abeb796ddc1100e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701dc0d00e6523cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff09c8edc0e00de1e00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05df1f00e33a21ef9283df1c00df2000df2704fdf5f3fffffffbebe6e55546ffffffffffffffffffffffffde1b00f3b5acfffffff3b0aaec8279ffffffffffffe3402edc0e00f4beb7ffffffea6e57dc0c00f09e91fffffffbeae8f4b8adf3ab9eea7158fffffff9d9d7e96d68fffffff9dedcdc0800dc0d00f7cfcafffffffbe7e2e45042e75b47df2000e12a05e12a05e12a05e12a05df2400dd1500df1f00e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903de1800de1c00f6c2bcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe86350db0a00e02300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02500de1d00e02802e12a05dc0c00fbe8e8fffffff19b98ef9388ffffffe55347e34633ffffffee918ef6c4c4ffffffe02f1bda0000fadad4ffffffe2361fdc0d00f6c0bbffffffe75d40dd1000ec8675fffffff6cac2f2ac9ff19e8fde220ffffffffffffffffffffcf1effffffff4baafdd1400fffffffdf2eeeb736afffffff9dfdedd1000e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df1f00db0a00ee8675ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae3dce33e25dc0e00e02500e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12903dc1000e86b5adf2305f7cdc7ffffffffffffffffffffffffe55137f9dcd6ffffffe12e14df2301fdf4f3fdf4f2df2101da0000f6c7c5ffffffe54b2cdb0900ea715bfffffffdf9f9f9dad4f1a395de1800fefdfbfcf0ecd70000e13828fffffffdf7f4dc0a00ed8471fffffffffffff3b4abe1371de02500e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2100db0900e85d4afefffdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8cfc9e2371cdc0d00e02300e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e02100e02700dd0e00dc0b00e54a32eb7972e44c35de2104fffffffdfaf8df2000e23821fffffff9d9d2e34226f09b90fbeaedfffffff1a59fea766be7593efffffff8d8d2ee8f7df6cac0e23620fae0daffffffffffffffffffffffffe76152df1d00de1a00da0700db0400dd1400e02600e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04df2100db0a00e55139fbe8e3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7cfc8e34024db0a00df2000e12a04e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02400df2000e02300e02500e1381be5533edf2000e33a20f8d8d0f2aca6e86551ffffffffffffffffffffffffffffffe44d37fffffffffffffdfdfdfcf5f4e33e21eb7763ec8178e5523edf2200db0400df1f00e12a05e12a05e12a05e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02903de1d00db0800e75a46fbe7e2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffae1dae8614fdb0800de1900e02700e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12904e02600e02400e12a04e02600dd1000dd1300df1d00db0600db0400db0200da0100db0600df2000da0100db0300dc0800dc0b00df2300df1e00df1e00e02300e02702e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02500de1500dc0e00ec7d70fefaf8ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffef9384df2507dc0b00de1e00e02802e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05e12b05e12b05e12b05e12b05e12a05e12b05e12b05e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02701de1c00db0800e2391df2aca3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9dbd4ea7567dd1400dd0d00de1d00e02701e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a04e02500de1c00dc0800de2304ed877bfdf1eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8d4ccec7e73df2504da0600de1700df2000e02802e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e02601de1f00dd1400da0400e23617ed8a7ffbeae4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefcfaf2a699e96556df1d00da0400dd1200de1c00df2100e02701e12a05e12b05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12a05e12b05e12a04e02600df2000de1b00dd1000da0300e02a07ea7366f3b4a7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5bfb3ee897fe75b49e02804db0400db0600dd0f00de1600de1c00de1d00df1f00e02200e02300e02400e02500e02500e02500e02400e02300e02100de1f00de1d00de1b00dd1500dd0e00db0500db0600e13212e86757ee9185f7cdc3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefbf9f8cfc6f3aa9aee8c80ec8078ea6b5de65945e54c33e44228e23d21e33b1fe23d22e4442ae54d36e75d4aea6f62ed847def9081f3b1a3f9d7cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000001050000000000002fad05fe, 20, '\\\\NOHA-PC\\Backups', 0, b'1', 1.5);

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

CREATE TABLE `status` (
  `ID` int(11) DEFAULT NULL,
  `Status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`ID`, `Status`) VALUES
(1, 'نشيط'),
(2, 'غير نشيط'),
(3, 'Simulator');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `ID` int(11) NOT NULL,
  `StudentName` varchar(255) DEFAULT NULL,
  `StudentEductionalNumber` int(11) DEFAULT NULL,
  `DOB` varchar(40) DEFAULT NULL,
  `NationalityID` int(11) DEFAULT NULL,
  `Phone` varchar(255) DEFAULT NULL,
  `GenderID` int(11) DEFAULT NULL,
  `جهة اصدار البطاقة` varchar(255) DEFAULT NULL,
  `جهة الميلاد` varchar(255) DEFAULT NULL,
  `الديانة` varchar(255) DEFAULT NULL,
  `المؤهل الدراسي وتاريخة` varchar(255) DEFAULT NULL,
  `العنوان` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  `حالة القيد` varchar(255) DEFAULT NULL,
  `ActivityID` int(11) DEFAULT NULL,
  `MilitaryStatusID` int(11) DEFAULT NULL,
  `AdvisorID` int(11) DEFAULT NULL,
  `SocialNumber` varchar(255) DEFAULT NULL,
  `MajorDepartmentID` int(11) DEFAULT NULL,
  `MinorDepartmentID` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `MilitaryEducationID` int(11) DEFAULT NULL,
  `CurriculumID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`ID`, `StudentName`, `StudentEductionalNumber`, `DOB`, `NationalityID`, `Phone`, `GenderID`, `جهة اصدار البطاقة`, `جهة الميلاد`, `الديانة`, `المؤهل الدراسي وتاريخة`, `العنوان`, `Email`, `حالة القيد`, `ActivityID`, `MilitaryStatusID`, `AdvisorID`, `SocialNumber`, `MajorDepartmentID`, `MinorDepartmentID`, `StatusID`, `MilitaryEducationID`, `CurriculumID`) VALUES
(1, 'مريم عبدالتواب عبدالعزيز قطب', 161001, '1998-06-20 00:00:00', 1, '01120474969', 1, 'السويس', 'بنى سويف', 'مسلم', 'الثانوية العامة -2016', 'السويس - السلام 1 شارع عباس العقاد متفرع من شارع حمزة - قطعة ارض رقم 18/29', 'm.abdeltawab_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29806202202482', 1, NULL, 1, 1, 1),
(5, 'اسلام احمد عبدالفتاح احمد', 161002, '1997-12-18 00:00:00', 1, '01212772140', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - حوض الدرس عمارة رقم 329 - شقة 12', 'i.ahmed_fci16@suezuni.edu.eg', 'مستجد', NULL, 2, 1, '29712180400078', 3, NULL, 1, 4, 1),
(6, 'اسماء ناصر غريب محمد', 161003, '1998-03-23 00:00:00', 1, '01113665561', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - تعاونيات القاهرة عمارة رقم 44 - شقة 7', 'a.naser_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29803230400061', 3, NULL, 1, 1, 1),
(7, 'مارينا سعيد امين عطاالله', 161004, '1998-08-09 00:00:00', 1, '01120310664', 1, 'السويس', 'السويس', 'مسيحي', 'الثانوية العامة -2016', 'السويس - السلام 1 قطعة رقم 559 شارع الخدمات - الدور الرابع - شقة 4', 'm.said_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29808090400084', 3, NULL, 1, 1, 1),
(8, 'احمد عبده على احمد', 161005, '1998-03-19 00:00:00', 1, '01205155483', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - الاربعين - كفر ابو العز - شارع صبرى - منزل رقم 8 - شقة 3', 'a.abdo_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 1, '29803190400136', 1, NULL, 1, 3, 1),
(9, 'محمد عبدالحى متولى عبدالحى', 161006, '1998-05-01 00:00:00', 1, '01064255815', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'مدينة الإيمان 1 - عمارة رقم 39 ب - شقة 10', 'm.abdelhai_fci16@suezuni.edu.eg', 'باق', NULL, 3, 1, '29805010400292', 5, NULL, 1, 4, 1),
(10, 'اميره محمد جلال احمد', 161007, '1998-06-18 00:00:00', 1, '01121163226', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - شارع السكة الحديد بجوار مسجد زيد بن حارث - الجناين - ابوسيال', 'a.mohamed_fci164@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29806180400404', 1, NULL, 1, 1, 1),
(11, 'سحر محمد مصطفى عبدالمجيد', 161008, '1998-12-22 00:00:00', 1, '01287744245', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - مدينة الإيمان 1 - عمارة 28 أ - شقة 9', 's.mohamed_fci161@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29812220400402', 1, NULL, 1, 1, 1),
(12, 'سلمى محمد سعيد يوسف يعقوب', 161009, '1998-04-25 00:00:00', 1, '01026226939', 1, 'السويس', 'القاهرة', 'مسلم', 'الثانوية العامة -2016', 'السويس - 23 شارع زغلول - عمارة إيكونو ماكس - الدور الرابع - شقة 7', 's.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29804250100427', 1, NULL, 1, 1, 1),
(13, 'زينب محى الدين محمد محمد', 161010, '1997-11-01 00:00:00', 1, '01095320655', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - حى الكويت - آخر شارع مصطفى الوكيل - منزل 12 - شقة 4', 'z.mohyeldeen_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29711010400549', 3, NULL, 1, 1, 1),
(14, 'شذى حسام الدين فوزى عبدالرحمن', 161011, '1998-07-21 00:00:00', 1, '01092146116', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - تعاونيات الدلتا - عمارة 30 - شقة 9', 's.hossameldeen_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29807210400362', 3, NULL, 1, 1, 1),
(15, 'عبدالرحمن محمد فوزى احمد', 161012, '1998-07-05 00:00:00', 1, '01020283410', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - تعاونيات الشركة العربية - عمارة 40 - شقة 18', 'a.mohamed_fci163@suezuni.edu.eg', 'باق', NULL, 3, 4, '29807050400239', 1, NULL, 1, 4, 1),
(16, 'احمد محمد سعدالدين محمدين', 161013, '1998-07-14 00:00:00', 1, '01015977548', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - برج 2 - طريق ناصر - ابراج الروضة - الدور 11 - شقة 1105', 'a.mohamed_fci162@suezuni.edu.eg', 'باق', NULL, 3, 3, '29807140400271', 5, NULL, 2, 2, 1),
(17, 'على حسام على جاد المولى', 161014, '1998-06-01 00:00:00', 1, '01125706162', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 15 ب مدينة الامل البنى - شقة 2', 'a.hossam_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29806010400833', 3, NULL, 1, 4, 1),
(18, 'سندس وائل السيد برعى', 161015, '1998-01-01 00:00:00', 1, '01114482671', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - الجناين - كوبرى العمدة أمام قسم شرطة الجناين', 's.wael_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 3, '29801010402761', 3, NULL, 1, 1, 1),
(19, 'دينا ممدوح محمد احمد', 161016, '1998-04-20 00:00:00', 1, '01282289541', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - شارع محمد رضوان - ارض البلبوشى - الاربعين', 'd.mamdouh_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 3, '29804200400144', 1, NULL, 1, 1, 1),
(20, 'ابراهيم مطاوع ابراهيم نصرالدين', 161017, '1998-05-27 00:00:00', 1, '01019942646', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - مستقبل 1 - عمارة 64 أ - شقة 19', 'i.metawea_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29805270400113', 1, NULL, 1, 4, 1),
(21, 'عبدالرحمن مصطفى سعيد شهاب', 161018, '1998-03-08 00:00:00', 1, '01207564644', 2, 'السويس', 'السعودية', 'مسلم', 'الثانوية العامة -2016', 'السويس - برج 1 - طريق ناصر - ابراج الروضة - الدور التاسع - شقة 903', 'a.mostafa_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29803088800456', 1, NULL, 1, 4, 1),
(22, 'احمد محسن رجب منيع اسماعيل', 161019, '1998-08-15 00:00:00', 1, '01118399876', 2, 'الدقهلية', 'الدقهلية', 'مسلم', 'الثانوية العامة -2016', 'الدقهلية - السكة الحديد - ميت طاهر - مدينة النصر', 'a.mohsen_fci16@suezuni.edu.eg', 'باق', NULL, 3, 3, '29808151203015', 5, NULL, 2, 2, 1),
(23, 'محمد الزناتى محمد واصل الزناتى ', 161020, '1996-10-23 00:00:00', 1, '01129158828', 2, 'الاسكندرية', 'الاسكندرية', 'مسلم', 'الثانوية العامة -2016', 'الاسكندرية - 5 تل العمارنة - اللاجيتية - الابراهيمية', 'm.elzanati_fci16@suezuni.edu.eg', 'مستجد', NULL, 2, 4, '29610230201511', 1, NULL, 1, 2, 1),
(24, 'وليد أحمد السعيد ابراهيم سالم', 161021, '1998-05-10 00:00:00', 1, '01017145303', 2, 'دمياط', 'دمياط', 'مسلم', 'الثانوية العامة -2016', 'دمياط - كفر سعد - الوسطانى - بجوار مدرسة الاعدادية بنين', 'w.ahmed_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 4, '29805101100399', 1, NULL, 1, 2, 1),
(25, 'حسام على عبدالوهاب عبدالله', 161022, '1997-11-10 00:00:00', 1, '01280564284', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - الجناين - السيد هاشم امام جمعية ابنود', 'h.ali_fci161@suezuni.edu.eg', 'مستجد', NULL, 2, 4, '29711100400416', 3, NULL, 1, 3, 1),
(26, 'اسماء ناصر يوسف احمد', 161023, '1998-06-03 00:00:00', 1, '01211167343', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 11 شارع التهامى - حى الكويت - الاربعين', 'a.naser_fci161@suezuni.edu.eg', 'مستجد', NULL, 1, 4, '29806030400163', 3, NULL, 1, 1, 1),
(27, 'شروق يوسف سعد على', 161024, '1998-05-23 00:00:00', 1, '01120399755', 1, NULL, 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - مستقبل 1 - عمارة 50 ب - شقة 15', 'a.youssif_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 4, '29805230400285', 3, NULL, 1, 1, 1),
(28, 'عبدالرحمن غريب حجازى غريب', 161025, '1997-11-04 00:00:00', 1, '01068024525', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - حى المدينة - فيصل - عمارة 7-  شقة 6', 'a.ghareb_fci16@suezuni.edu.eg', 'مستجد', NULL, 2, 4, '29711040400195', 1, NULL, 1, 3, 1),
(29, 'دينا رجب السيد ابراهيم', 161026, '1998-05-20 00:00:00', 1, '01152747101', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - تعاونيات البحر الاحمر - عمارة 29 - شقة 14،15', 'd.ragab_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29805200400345', 1, NULL, 1, 1, 1),
(30, 'محمد عبدالمنعم عبدالعزيز عبدالله حسين', 161027, '1998-03-14 00:00:00', 1, '01067476217', 2, 'الاسكندرية', 'الاسكندرية', 'مسلم', 'الثانوية العامة -2016', 'الاسكندرية - العصافرة قبلى - أرض عبدالعال خلف صالون خميس فودة', 'm.abdelmoneam_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 5, '29803140201655', 5, NULL, 2, 2, 1),
(31, 'اسلام جاد هندى محمد', 161028, '1998-03-14 00:00:00', 1, '01025688640', 2, 'السويس', 'الشرقية', 'مسلم', 'الثانوية العامة -2016', 'السويس - مستقبل حودة - عمارة 1 أ - شقة 6', 'i.gad_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 5, '29803141301394', 1, NULL, 1, 2, 1),
(32, 'عمرو ياسر إسماعيل السيد ', 161029, '1998-11-26 00:00:00', 1, '01145397632', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 24 اكتوبر - المميز - عمارة 2 ب - شقة 6', 'a.yaser_fci16@suezuni.edu.eg', 'باق', NULL, 3, 5, '29811260400034', 5, NULL, 2, 2, 1),
(33, 'اسلام محمد بدر محمود', 161030, '1998-06-18 00:00:00', 1, '01116528587', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - كفر أحمد عبده القديم - شارع المنوفية من صلاح الدين شلاضم', 'i.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 5, '29806180400218', 1, NULL, 1, 2, 1),
(34, 'احمد حمدى محمود محمد', 161031, '1998-02-08 00:00:00', 1, '01117558633', 2, 'السويس', 'قنا', 'مسلم', 'الثانوية العامة -2016', 'السويس - شارع السنترال - عرب المعمل - منزل رقم 39', 'a.hamdy.fci_16@suezuni.edu.eg', 'مستجد', NULL, 3, 5, '29802082706397', 3, NULL, 1, 2, 1),
(35, 'عمر حمدى صديق احمد', 161032, '1998-03-25 00:00:00', 1, '01028080927', 2, 'البحر الاحمر', 'الجيزة', 'مسلم', 'الثانوية العامة -2016', 'الغردقة - حى التقوى - مجمع الرضا - شقة 4', 'o.hamdy_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 5, '29803252101815', 3, NULL, 1, 2, 1),
(36, 'ليلى فتوح طه على محمود رشيد', 161033, '1998-11-13 00:00:00', 1, '01212772154', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - شارع النهضة - عمارة 10 - شقة 12', 'l.fatouh_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29711130400224', 1, NULL, 1, 1, 1),
(37, 'حسين احمد عبدالحميد السيد', 161034, '1998-04-17 00:00:00', 1, '01200463178', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - السلام 2 - أرض الجمارك - حوض 60 - قطعة 23 أ', 'h.ahmed_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 12, '29804170400217', 3, NULL, 1, 2, 1),
(38, 'نعم محمد عبدالله احمد', 161035, '1999-01-01 00:00:00', 1, '01024999336', 1, NULL, 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 15 فيلات المحروسة - تقسيم المغربى - الملاحة', 'n.mohamed_fci161@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29901010402049', 3, NULL, 1, 1, 1),
(39, 'محمد فتحى ابراهيم مصطفى صالح', 161036, '1998-03-21 00:00:00', 1, '01069084993', 2, 'البحر الاحمر', 'البحر الاحمر', 'مسلم', 'الثانوية العامة -2016', 'البحر الاحمر - القصير - بجوار مدرسة السلام', 'm.fathy_fci161@suezuni.edu.eg', 'مستجد', NULL, 3, 12, '29803213100071', 3, NULL, 1, 2, 1),
(40, 'عبدالرحمن الرفاعى توفيق المرسي', 161037, '1998-10-01 00:00:00', 1, '01021521695', 2, 'الدقهلية', 'الدقهلية', 'مسلم', 'الثانوية العامة -2016', 'الدقهلية - شارع الحوار - مدينة تمى الامديد - بجوار المجمع الاسلامى', 'a.elrahman_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 12, '29810011237755', 5, NULL, 1, 2, 1),
(41, 'باسل محمد بكر محمد', 161038, '1998-11-21 00:00:00', 1, '01063459134', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس-  شارع حافظ ابراهيم - عمارة 3 - شقة 6', 'b.mohamed_fci16@suezuni.edu.eg', 'باق', NULL, 3, 12, '29811210400297', 5, NULL, 2, 2, 1),
(42, 'محمود سيد محمد عوض', 161039, '1998-09-07 00:00:00', 1, '01112967011', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - كفر احمد عبده القديم - شارع الجوهرى - عمارة 12 - شقة 2', 'm.sayed_fci16@suezuni.edu.eg', 'مستجد', NULL, 3, 12, '29809070400157', 1, NULL, 1, 2, 1),
(43, 'احمد محمد عبدالراضى عيد', 161040, '1997-10-02 00:00:00', 1, '01140414776', 2, 'البحر الاحمر', 'البحر الاحمر', 'مسلم', 'الثانوية العامة -2016', 'الغردقة - الدهار - حى الامل - شارع المجر  - البحر الاحمر - الغردقة', 'a.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 2, 11, '29710023100131', 1, NULL, 1, 2, 1),
(44, 'شروق غريب فتحى محمد', 161041, '1998-12-11 00:00:00', 1, '01289845220', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس-  حارة ابو العباس - تل القلزم - الاربعين', 'a.ghareb_fci161@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29812110400245', 3, NULL, 1, 1, 1),
(45, 'ايلاف محمد عصام محمد نور السيد', 161042, '1998-03-26 00:00:00', 1, '01068115375', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - مدينة عمر بن الخطاب - شارع هريدى - منزل 43-  شقة 3', 'e.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29803260400104', 3, NULL, 1, 1, 1),
(46, 'منه الله محمد حسن محمد', 161043, '1997-11-01 00:00:00', 1, '01016924994', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - العبور-  عمارة 30أ - شقة 4', 'm.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29711010400425', 3, NULL, 1, 1, 1),
(47, 'محمود احمد محمود عوض', 161044, '1998-01-01 00:00:00', 1, '01068639493', 2, 'الدقهلية', 'الدقهلية', 'مسلم', 'الثانوية العامة -2016', 'الدقهلية - ابو داود-  تمى الامديد', 'm.ahmed_fci16@suezuni.edu.eg', 'باق', NULL, 3, 11, '29801011211617', 5, NULL, 1, 2, 1),
(48, 'سلمى عبدالناصر حسن قطب', 161045, '1998-02-25 00:00:00', 1, '01005390525', 1, 'السويس', 'الجيزة', 'مسلم', 'الثانوية العامة -2016', 'السويس - عمارة سما عرفات - شقة 402', 's.abdelnaser_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29802252103641', 1, NULL, 1, 1, 1),
(49, 'احمد عطيه رمضان هلال', 161046, '1998-03-19 00:00:00', 1, '01005511794', 2, 'الدقهلية', 'الدقهلية', 'مسلم', 'الثانوية العامة -2016', 'الدقهلية - قرية السنبلاوين - السرسى', 'a.atya_fci16@suezuni.edu.eg', 'باق', NULL, 3, 14, '29803191200432', 5, NULL, 2, 2, 1),
(50, 'نيره محمد مدنى هاشم', 161047, '1998-05-10 00:00:00', 1, '01271569269', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 75 شارع محمود عثمان - قرية عامر - الجناين', 'n.mohamed_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29805100400402', 1, NULL, 1, 1, 1),
(54, 'احمد محمد منصور محمد حموده', 161049, '1998-03-01 00:00:00', 1, '01026146601', 2, 'الدقهلية', 'الدقهلية', 'مسلم', 'الثانوية العامة -2016', 'الدقهلية - كفر الصلاحات - مركز بنى عبيد', 'a.mohamed_fci161@suezuni.edu.eg', 'باق', NULL, 3, 14, '29803011207671', 1, NULL, 1, 2, 1),
(55, 'مروان محمد عبدالعليم محمد', 161050, '1998-04-17 00:00:00', 1, '01017838264', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - العبور - عمارة 75 مدخل ب - شقة 5', 'M.mohamed_fci161@suezuni.edu.eg', 'باق', NULL, 3, 14, '29804170400179', 5, NULL, 2, 2, 1),
(56, 'عبدالرحمن مصطفى السيد أحمد النجار', 161051, '1998-02-17 00:00:00', 1, '01069471600', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2016', 'السويس - 24 شارع الفنارات - بورتوفيق', 'A.moustafa_fci16@suezuni.edu.eg', 'باق', NULL, 3, 14, '29802170400231', 5, NULL, 2, 2, 1),
(57, 'آيه محمد فؤاد السيد', 161052, '1994-08-01 00:00:00', 1, '01018323204', 1, 'السويس', 'السويس', 'مسلم', 'بكالوريوس فى تكنولوجيا التعليم (تكميلى)- كلية التربية - جامعة السويس', 'السويس - مستقبل 1 - عمارة 51 - شقة 2 ب', 'A.fouad_fci16@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29408010400307', 1, NULL, 1, 1, 1),
(58, 'احمد خميس حسان محمد حسان', 171002, '1999-01-25 00:00:00', 1, '01224014305', 2, 'السويس', 'الاسكندرية', 'مسلم', 'الثانوية العامة -2017', 'خورشيد شارع السوق بجوار مدرسة محمد سعد مصطفى', 'Ahmed.Khamisfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 1, '29901250200516', 5, 0, 1, 3, 1),
(60, 'امل ايهاب محمود رشوان', 171004, '1999-10-07 00:00:00', 1, '01205995817', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '22 شارع الخور السويس', 'Amal.Ehabfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '299707100400469', 5, 0, 1, 1, 1),
(61, 'ايه حميد محمد حفنى', 171006, '1998-03-12 00:00:00', 1, '01062983404', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '49 ش سوهاج - أحمد عرابى -كفر كامل الاربعين - السويس', 'Aya.Hamidfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 3, '29812030400244', 5, 0, 1, 1, 1),
(62, 'احسان محمد صالح غريب', 171001, '1999-05-01 00:00:00', 1, '01144699760', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة-2017', 'الجناين - قرية عامر محطة شل -السويس', 'ehsan.Mohammedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29901050400146', 5, 0, 1, 1, 1),
(63, 'خالد رضا عبدالحميد محمد سلامة', 171036, '1999-06-03 00:00:00', 1, '01014284468', 2, 'دمياط', 'دمياط', 'مسلم', 'ثانوية عامة -2017', 'دمياط فارسكور الروضة', 'Khaled.Redafci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 14, '29903061100112', 5, 0, 1, 2, 1),
(64, 'ايمن نصر عبدالرحمن محمد', 171005, '1998-12-13 00:00:00', 1, '01287384678', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '9 أ مدينة المستقبل1 السويس', 'Ayman.Nasrfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 1, '29812130400373', 5, 0, 1, 3, 1),
(65, 'عبدالرحمن روبى يسن محمد', 171007, '1998-11-13 00:00:00', 1, NULL, 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'الجناين - الحسينى - منزل (روبى) بجوار الجامع', 'AbdulRahman.rubyfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29811130400458', 5, 0, 1, 2, 1),
(66, 'عمر حسام محمد خليفة', 171008, '1999-05-01 00:00:00', 1, '01155527800', 2, 'الاسكندرية', 'الاسكندرية', 'مسلم', 'الثانوية العامة -2017', 'جمال عبدالناصر ش 56 اخر منزل على الشمال - الاسكندرية', 'AbdulRahman.rubyfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29901050200872', 5, 0, 2, 2, 1),
(67, 'محمد حاتم عثمان محمود عثمان', 171009, '1999-06-20 00:00:00', 1, '01020640260', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'مساكن مستقبل حوده عماره رقم 1 ب شقة رقم 8', 'Mohamed.Hatemfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '2990620040021', 5, 0, 1, 3, 1),
(68, 'محمد عادل فهمى حسن', 171010, '1999-01-10 00:00:00', 1, '01092942466', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '20ش حمدالله من شارع الجيش الاربعين السويس', 'Mohamed.Adelfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 3, '29910010401157', 5, 0, 1, 3, 1),
(69, 'يوسف سامى جوده على', 171011, '2000-08-02 00:00:00', 1, '01022003126', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '6حى فراغات جدة فيصل - السويس', 'Yousuf.Samifci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 4, '30002080400079', 5, 0, 1, 4, 1),
(70, 'ياسمين عادل عبدالحميد توفيق', 171012, '2000-01-01 00:00:00', 1, '01065157733', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'سلام1 شارع عمر بن الخطاب 120ق 14ب', 'Yasmin.Adelfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 4, '30001010403961', 5, 0, 1, 1, 1),
(71, 'محمد احمد عبدالنبي رجب', 171013, '1999-12-11 00:00:00', 1, '01010634589', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '5 ش الخضر - برج الغريب', 'Mohamed.Ahmedfci2017@suezuni.edu.eg', 'مستجد', NULL, 3, 4, '29911120400136', 5, 0, 1, 3, 1),
(72, 'اسراء محمود محمدين السيد', 171014, '1999-06-07 00:00:00', 1, '01224330401', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '9 ش الانفوشي - كفر كامل - الاربعين - السويس', 'Israa.Mahmoudfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 4, '29907060400169', 5, 0, 1, 1, 1),
(73, 'عبدالرحمن محمد موسي محمد محمد', 171015, '1999-02-15 00:00:00', 1, '01067900157', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'قطعه 391- حوض 166 شارع نافع سلام2', 'Abdulrahman.Mohammedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 4, '29902150400212', 5, 0, 1, 2, 1),
(74, 'منال محمود عبدالمقصود عبدالودود', 171016, '1999-05-21 00:00:00', 1, '01017835957', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'ش محطة السكة الحديد منشية الفرز - السويس', 'Manal.Mahmoudfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29905210400267', 5, 0, 1, 1, 1),
(75, 'محمد ابو الحسن محمد ابراهيم', 171017, '1998-03-11 00:00:00', 1, '01017208633', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'ابراج السحاب نماء 4 الدور الخامس شقة3', 'Mohamed.Abolhassanfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29811030400256', 5, 0, 1, 4, 1),
(76, 'على شيمى سيد عبدالعاطى', 171018, '1998-12-29 00:00:00', 1, '01112164583', 2, 'المنيا', 'المنيا', 'مسلم', 'الثانوية العامة -2017', 'حى الامل - طور سيناء - جنوب سيناء', 'Ali.shemifci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29812292401152', 5, 0, 1, 2, 1),
(77, 'كريم الامير احمد محمد', 171019, '1999-08-23 00:00:00', 1, '01015239341', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'السويس - مركز فيصل - الصباح الجمهورية ع39 ش5', 'Karim.elamirfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29908230400173', 5, 0, 1, 2, 1),
(78, 'امنية اشرف احمد فتحى', 171020, '1999-11-04 00:00:00', 1, '01020943183', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', '8ش الصعايدة امام بريد السويس', 'Omnia.Ashraffci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 5, '29904100400109', 5, 0, 1, 1, 1),
(79, 'محمد ناصر محمد على فياض', 171021, '1999-06-25 00:00:00', 1, '01092976498', 2, 'دكرنس', 'الدقهلية', 'مسلم', 'الثانوية العامة -2017', 'ميت ضافر - دكرنس - الدقهلية', 'Mohammed.Nasserfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29906251201453', 5, 0, 1, 2, 1),
(80, 'محمد خالد على حامد النصر', 171022, '1999-01-23 00:00:00', 1, '01018680917', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'تعاونيات اسبيكوا مستطيل عماره 71 شقة1', 'Mohammed.Khaledfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29901230400098', 5, 0, 1, 3, 1),
(81, 'محمود مصطفى محمود', 171023, '1999-05-01 00:00:00', 1, '01206767341', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'الصباح فراغات السحاب ع21 ش5', 'Mahmoud.Mustafafci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29901050400251', 5, 0, 1, 3, 1),
(83, 'عمر محمد عربي اسماعيل', 171025, '1999-07-26 00:00:00', 1, '01128285281', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة -2017', 'الجناين كوبرى ام ملكة', 'Omar.Mohamedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 12, '29907260400376', 5, 0, 1, 2, 1),
(84, 'ندى نصر محمد الصغير', 171026, '1999-11-11 00:00:00', 1, '01022103076', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2017', 'السويس- ميدان الشونة ش محرم برج الزهراء ش10', 'Nada.Nasrfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29911110400065', 5, 5, 1, 1, 1),
(85, 'عبدالرحمن احمد فؤاد عبدالرحمن', 171027, '1999-01-08 00:00:00', 1, '01128084811', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2017', '302 مساكن الهيئة بورتوفيق', 'Abdulrahman.Ahmedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29908010401357', 5, 0, 1, 2, 1),
(86, 'ايمان عماد الدين عبدالفتاح احمد', 171028, '2000-07-03 00:00:00', 1, '01120463844', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2017', 'شباب اكتوبر ع 6 م (ا) ش2', 'Eman.emadeldinfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '30003070400069', 5, 0, 1, 1, 1),
(87, 'تسنيم بربرى رمضان بربرى', 171029, '1999-09-18 00:00:00', 1, '01228408936', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2017', '    15  شارع طلعت حرب حارة الشوام  منزل 15- الدور الثانى', 'Tasneem.barbarifci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '2990918040052', 5, 0, 1, 1, 1),
(88, 'محمد محسن همام احمد', 171030, '1998-11-22 00:00:00', 1, NULL, 2, 'البحر الاحمر', 'البحر الاحمر', 'مسلم', 'الثانوية العامة 2017', 'حفر الباطن - الغردقة - البحر الاحمر', 'Mohamed.Mohsenfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 11, '29811222702299', 5, 0, 1, 2, 1),
(89, 'محمد السيد محمد على الخطيب', 171031, '1999-02-28 00:00:00', 1, '01063577210', 2, 'طنطا', 'طنطا', 'مسلم', 'الثانوية العامة 2017', 'فيلا 208 هضبة ام         شرم الشيخ', 'Mohamed.ElSayedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29902281600934', 5, 0, 1, 2, 1),
(90, 'مريم صبرى محمد عباس السيد', 171032, '1998-02-24 00:00:00', 1, '0109295596', 1, 'دمياط', 'دمياط', 'مسلم', 'الثانوية العامة 2017', 'تعاونيات الدلتا ع35ش19', 'Maryam.Sabrifci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29802241100144', 5, 0, 1, 1, 1),
(91, 'سامح المتولى المتولى المتولى مطاوع', 171033, '1999-01-20 00:00:00', 1, '01129674616', 2, 'دمياط', 'دمياط', 'مسلم', 'الثانوية العامة 2017', 'ميت ابوغالب - كفر سعد - دمياط', 'Sameh.Metwallyfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29901201100271', 5, 0, 1, 2, 1),
(92, 'ايمن يحى عيد احمد الشوطة', 171034, '1999-03-25 00:00:00', 1, '01093463338', 2, NULL, 'المنوفية', 'مسلم', 'الثانوية العامة 2017', '11ل وحده 88 منحل ا طور سيناء جنوب سيناء', 'Ayman.Yahiafci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29903251701295', 5, 0, 1, 2, 1),
(93, 'سليمان محمد سلمان اسماعيل', 171035, '1999-03-03 00:00:00', 1, '01090250380', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2017', 'السويس ذرب شارع الرخا', 'Soliman.Mohammedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29903030400053', 5, 0, 1, 3, 1),
(94, 'أحمد محمد السيد زاهر', 171037, '1998-01-14 00:00:00', 1, '01126068337', 2, 'الشرقية', 'الشرقية', 'مسلم', 'الثانوية العامة -2017', 'مركز مشتول السوق - الشرقية', 'Ahmed.Mohamedfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29801141301651', 5, 0, 1, 2, 1),
(95, 'نورهان رشاد محمد شحاته', 171038, '1999-09-25 00:00:00', 1, NULL, 1, 'طنطا', 'الغربية', 'مسلم', 'الثانوية العامة (شهادة معادلة)2017', 'محافظة الغربية مركز بسيون حى الشعلاء بجوار مدرسة النصر', 'Norhan.Rashadfci2017@suezuni.edu.eg', 'مستجد', NULL, 1, 14, '29909251601043', 5, 5, 1, 1, 1),
(97, 'First', 181000, NULL, 1, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 8, '7777777', 5, NULL, 2, 2, 1),
(98, 'أحلام رجب محمد السيد', 181001, '2000-05-16 00:00:00', 1, '01149291487', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'الإيمان 2 عمارة 104 شقة 3', NULL, 'مستجد', NULL, 1, 1, '30005160400184', 5, 5, 1, 1, 1),
(100, 'أحمد صابر دسوقى أحمد', 181002, '2000-06-27 00:00:00', 1, '01019595207', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مساكن شركة السويس لتصنيع البترول ى 44/2', NULL, 'مستجد', NULL, 1, 1, '30006270400232', 5, 5, 1, 2, 1),
(101, 'أحمد صابر محمد جلال', 181003, '2000-02-03 00:00:00', 1, '01010801856', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس - المستقبل عمارة 57 أ', NULL, 'مستجد', NULL, 1, 11, '30002030400116', 5, 5, 1, 2, 1),
(102, 'أحمد عبد الغنى محمد إبراهيم', 181004, '2000-08-01 00:00:00', 1, '01014173523', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'ق 68 ب حوض 15 السلام 2 فيصل - السويس', NULL, 'مستجد', NULL, 1, 1, '30008011301377', 5, 5, 1, 2, 1),
(105, 'أحمد محروس عباس يمنى', 181006, '2000-02-15 00:00:00', 1, '01063321062', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مساكن اليسر عمارة 9 شقة 11', NULL, 'مستجد', NULL, 1, 1, '30002150400276', 5, 5, 1, 2, 1),
(107, 'حسين خلف حسين حسن جاد', 181008, '2001-02-12 00:00:00', 1, '01022877939', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مدينة الأمل عمارة 50ب شقة 1', NULL, 'مستجد', NULL, 1, 1, '30102120400411', 5, 5, 1, 2, 1),
(108, 'رويدا العربى رضا داود', 181009, '2000-01-01 00:00:00', 1, '01279885465', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مبارك 2 عمارة 18ب شقة 13', NULL, 'مستجد', NULL, 1, 12, '30001010400385', 5, 5, 1, 1, 1),
(109, 'سارة ياسر محمد رفعت أحمد', 181010, '2000-06-04 00:00:00', 1, '01032639448', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السلام 2 ش القدس الشريف عمارة 147 شقة 2', NULL, 'مستجد', NULL, 1, 12, '30006040400144', 5, 5, 1, 1, 1),
(110, 'شيماء أبو الحمد عبداللطيف محمد', 181011, '2000-03-10 00:00:00', 1, '01129293605', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس - عرب المعمل شارع دسوقى آدم منزل رقم 9', NULL, 'مستجد', NULL, 1, 12, '30003100400107', 5, 5, 1, 1, 1),
(111, 'عبد الرحمن رأفت أمين حسنين', 181012, '2000-02-03 00:00:00', 1, '01282672438', 2, 'فيصل', 'السويس', 'مسلم', 'الثانوية العامة 2018', '17 تعاونيات اسبيكو المستطيل - فيصل - السويس', NULL, 'مستجد', NULL, 1, 12, '30004030400054', 5, 5, 1, 2, 1),
(113, 'عبد الله أحمد السيد حنورة', 181014, '2000-06-23 00:00:00', 1, '01129485477', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '11ب حوض 69 السلام 2 - عتاقة - السويس', NULL, 'مستجد', NULL, 1, 4, '30006231700938', 5, 5, 1, 2, 1),
(114, 'عبدالله وليد محمد عبد العزيز', 181015, '2000-06-13 00:00:00', 1, '01016647002', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مساكن هيئة قناة السويس - المثلث1 عمارة 286 شقة 13', NULL, 'مستجد', NULL, 1, 4, '30006130400275', 5, 5, 1, 2, 1),
(115, 'عمر محمود أحمد محمد', 181016, '2000-12-14 00:00:00', 1, '01064461595', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس- فيصل - الامل لبنى عمارة 14ب شقة 8', NULL, 'مستجد', NULL, 1, 4, '30012140400176', 5, 5, 1, 2, 1),
(116, 'عمرو سعد مصطفى فرحات', 181017, '2000-01-22 00:00:00', 1, '01276622243', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '13 شارع المدينة الرياضية برج اليسر - الملاحة', NULL, 'مستجد', NULL, 1, 4, '30001220400116', 5, 5, 1, 2, 1),
(117, 'عمرو محمد على عبد العال', 181018, '2000-05-10 00:00:00', 1, '01029951527', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس- الأربعين كفر شارل ش علام شقة 12 الدور السادس', NULL, 'مستجد', NULL, 1, 4, '30005100400177', 5, 5, 1, 2, 1),
(118, 'عمرو ياسر فتحى محمد', 181019, '2000-01-01 00:00:00', 1, '01068761987', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '1ش الفلكى متفرع من ش الخضر عمارة 335 شقة 3', NULL, 'مستجد', NULL, 1, 5, '30001010402558', 5, 5, 1, 2, 1),
(119, 'فادى نبيل ريس جيد', 181020, '2000-09-05 00:00:00', 1, '01282905006', 2, 'السويس', 'السويس', 'مسيحى', 'الثانوية العامة 2018', '28 ش ابن هانى حارة محمد صالح كفر عقدة الأربعين - السويس', NULL, 'مستجد', NULL, 1, 5, '30009050400036', 5, 5, 1, 2, 1),
(120, 'فاطمة الزهراء جابر هريدى محمد', 181021, '1999-10-19 00:00:00', 1, '01208126285', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'المثلث نموذج 7 الجديد عمارة 9 أ شقة 6', NULL, 'مستجد', NULL, 1, 5, '29910190400242', 5, 5, 1, 1, 1),
(121, 'فاطمة رجب محمد السيد', 181022, '2000-05-16 00:00:00', 1, '01121823774', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'الإيمان 2 عمارة 104 شقة 3', NULL, 'مستجد', NULL, 1, 5, '30005160400206', 5, 5, 1, 1, 1),
(122, 'فاطمة عيد محمد مرسى', 181023, '2000-04-13 00:00:00', 1, '01114046843', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'شباب المثلث عمارة 5ب شقة 9 - السويس', NULL, 'مستجد', NULL, 1, 5, '30004130400329', 5, 5, 1, 1, 1),
(123, 'كريم حمادة عبد الوهاب عبد الرحمن', 181024, '2000-09-21 00:00:00', 1, '01090802802', 2, 'البحر الأحمر', 'البحر الأحمر', 'مسلم', 'الثانوية العامة 2018', 'القصير- تقسيم الجمعية خلف مدرسة مصطفى حبيب - البحر الأحمر', NULL, 'مستجد', NULL, 1, 3, '30009213100078', 5, 5, 1, 2, 1),
(124, 'كوثر أحمد سعيد حامد', 181025, '1999-11-22 00:00:00', 1, '01287506616', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'الأربعين - كفر كامل ش المتنبى عمارة 23 شقة 3', NULL, 'مستجد', NULL, 1, 3, '29911220400109', 5, 5, 1, 1, 1),
(125, 'محمد عبد اللطيف امبارك عمر', 181026, '1999-03-06 00:00:00', 1, '01016225703', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'كفر أحمد عبده القديم - الأربعين عمارة 5 ش مبروك شقة 3', NULL, 'مستجد', NULL, 1, 3, '29903060400376', 5, 5, 1, 2, 1),
(126, 'محمد على سعيد أبو المعاطى', 181027, '2000-05-13 00:00:00', 1, '01060135248', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة', '35 ش أحمد شوقى ح 72 السلام 1', NULL, 'مستجد', NULL, 1, 3, '30005130400058', 5, 5, 1, 2, 1),
(128, 'محمد عوض أبو بكر حمادة', 181028, '2000-01-14 00:00:00', 1, '01001670219', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السلام 2 قطعة 113 4ب حوض 68', NULL, 'مستجد', NULL, 1, 3, '30001140400298', 5, 5, 1, 2, 1),
(129, 'محمود رمضان محمد حشاد', 181029, '2000-09-23 00:00:00', 1, '01012672166', 2, 'جنوب سيناء', 'المنوفية', 'مسلم', 'الثانوية العامة 2018', 'الطور- الجبيل-300 وحده عمارة 15 -جنوب سيناء', NULL, 'مستجد', NULL, 1, 11, '30009231700414', 5, 5, 1, 2, 1),
(130, 'مرام كرم أبو الوفا أبو الحسن', 181030, '2000-09-26 00:00:00', 1, '01000827316', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس 3ش القبطان خلف هانو شقة 6', NULL, 'مستجد', NULL, 1, 11, 'السويس', 5, 5, 1, 1, 1),
(131, 'مريم عصام عمر محمد', 181031, '1999-11-26 00:00:00', 1, '01090678496', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مبارك 1 عمارة 10أ شقة 6', NULL, 'مستجد', NULL, 1, 11, '29911260400322', 5, 5, 1, 1, 1),
(132, 'مريم نبيل محمد شلتوت', 181032, '2000-08-11 00:00:00', 1, '01115621115', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '21 مدينة النور مربع 2 برج الزهراء شقة 3', NULL, 'مستجد', NULL, 1, 11, '30008110400085', 5, 5, 1, 1, 1),
(133, 'مصطفى أمين جابر جاد الرب', 181033, '1999-12-12 00:00:00', 1, '01203059986', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'الصفا والمروة عمارة 19ب شقة 6', NULL, 'مستجد', NULL, 1, 11, '29912120400191', 5, 5, 1, 2, 1),
(134, 'مصطفى سعد نور الدين فرهود', 181034, '2000-06-27 00:00:00', 1, '01016177464', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '4ب حوض 68 السلام 2', NULL, 'مستجد', NULL, 1, 14, '30007260400257', 5, 5, 1, 2, 1),
(135, 'مصطفى عمر السيد حسنين محمد', 181035, '2000-05-06 00:00:00', 1, '01030093492', 2, 'كفر الشيخ', 'بيلا', 'مسلم', 'الثانوية العامة 2018', 'كفر الشيخ- مركز بيلا - قرية الشرقاوية شارع البحر', NULL, 'مستجد', NULL, 1, 14, '30005061500592', 5, 5, 1, 2, 1),
(137, 'بسمه أحمد عبد اللاه', 181007, '2000-04-08 00:00:00', 1, '01221584862', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'مساكن شل عمارة 23 أ شقة 9 الدور الخامس', NULL, 'مستجد', NULL, 1, 1, '30004080400268', 5, 5, 1, 1, 1),
(138, 'عبد الرحمن مساعد محمد حسن', 181013, '2000-04-30 00:00:00', 1, '01011204036', 2, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'السويس - الصباح - فراغات مختار عمارة 34 شقة 10', NULL, 'مستجد', NULL, 1, 12, '30004300400191', 5, 5, 1, 2, 1),
(140, 'منار شاهين إبراهيم شاهين', 181036, '2000-09-10 00:00:00', 1, '01118228738', 1, 'المنوفية', 'المنوفية', 'مسلم', 'الثانوية العامة 2018', 'السويس- فيصل - قرية الرائد', NULL, 'مستجد', NULL, 1, 14, '30009101702644', 5, 5, 1, 1, 1),
(141, 'منه الله محمد شاذلى إسماعيل', 181037, '2000-10-21 00:00:00', 1, '01153276633', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', 'الصفا - عتاقة - فيلا 320- المرحلة الأولى', NULL, 'مستجد', NULL, 1, 14, '30010210400087', 5, 5, 1, 1, 1),
(142, 'نورهان محمد أحمد السيد', 181038, '1999-10-24 00:00:00', 1, '01227032920', 1, 'الأربعين', 'الأربعين', 'مسلم', 'الثانوية العامة 2018', 'الأربعين - كفر النجار2 ش الغرازمن ش مصطفى الوكيل', NULL, 'مستجد', NULL, 1, 14, '29910240400141', 5, 5, 1, 1, 1),
(143, 'يمنى على محمد عبد الفتاح', 181039, '2000-05-02 00:00:00', 1, '01003547345', 1, 'السويس', 'السويس', 'مسلم', 'الثانوية العامة 2018', '70ش طلعت حرب عمارة البلاع شقة 3 - السويس', NULL, 'مستجد', NULL, 1, 3, '30005020400125', 5, 5, 1, 1, 1),
(144, 'يوسف عادل السيد أحمد', 181040, '2000-08-15 00:00:00', 1, '01115789527', 2, 'جنوب سيناء', 'القاهرة', 'مسلم', 'الثانوية العامة 2018', 'جنوب سيناء- رأس سدر أرض الجمعيه 5 ش مجلس المدينة', NULL, 'مستجد', NULL, 1, 5, '30008150104217', 5, 5, 1, 2, 1),
(145, 'أحمد محمد أحمد السباعى', 181005, '1999-09-01 00:00:00', 1, '01096297944', 2, 'البحر الاحمر', 'الغردقه', 'مسلم', 'الثانوية العامة 2017', 'الدهار ثان االبحر الاحمر حى الهلال ش حوهر', NULL, 'مستجد', NULL, 1, 4, '29909010109539', 5, 5, 1, 2, 1),
(146, 'يوسف أسامة محمد الدسوقى أبو العطا', 181041, '2000-08-12 00:00:00', 1, '01100595731', 2, 'المحلة الكبري', 'الغربية', 'مسلم', 'شهادة معادلة2018', '16ش ابو زيد منشية أبو راضى أول المحلة الغربية', NULL, 'مستجد', NULL, 1, 14, '30008121601899', 5, 5, 1, 2, 1),
(147, 'مارك عادل راتب ابراهيم', 181042, '2000-11-08 00:00:00', 1, '01281558101', 2, 'الغردقة', 'بنى سويف', 'مسيحى', 'الثانوية العامة 2018', '52ش العشرين بجوار كومباوند فلورنزا- الغردقة - البحر الأحمر', NULL, 'مستجد', NULL, 1, 14, '30011082201013', 5, 5, 1, 2, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `studentlevel`
-- (See below for the actual view)
--
CREATE TABLE `studentlevel` (
`StudentCode` int(11)
,`StudentID` int(11)
,`CountOfSemester` bigint(21)
,`SemesterStatusID` int(11)
,`StudentName` varchar(255)
,`Total_Credits_Completed` decimal(41,0)
,`StudLevel` varchar(255)
,`StudLevelID` bigint(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `studentsemestercount`
-- (See below for the actual view)
--
CREATE TABLE `studentsemestercount` (
`StudentID` int(11)
,`StudentEductionalNumber` int(11)
,`CountOfSemester` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `tablesmetadata`
--

CREATE TABLE `tablesmetadata` (
  `TableName` varchar(255) DEFAULT NULL,
  `TableIDInSystemObjects` int(11) DEFAULT NULL,
  `NoofRecords` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tablesmetadata`
--

INSERT INTO `tablesmetadata` (`TableName`, `TableIDInSystemObjects`, `NoofRecords`) VALUES
('uUsers', 200, 2),
('UsersPermissions', 201, 34),
('Faculty', 280, 3),
('Department', 290, 6),
('Semester', 293, 7),
('Curriculum', 295, 5),
('Student', 303, 131),
('Course', 330, 166),
('Doctor', 335, 25),
('Course_semester', 340, 78),
('Registration', 400, 2244),
('GPA_Grade', 420, 77),
('Course_Grade', 430, 110),
('Settings', 3242, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tblmailmerge`
--

CREATE TABLE `tblmailmerge` (
  `ID` int(11) DEFAULT NULL,
  `Path` mediumtext,
  `Query` varchar(255) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tblmailmerge`
--

INSERT INTO `tblmailmerge` (`ID`, `Path`, `Query`, `Description`) VALUES
(1, 'D:\\كلية حاسبات ومعلومات\\البرنامج\\MailMerge\\Template_انذارات أكاديمية - بالفصل.docx', 'First_warning_mailMergeLetters', 'انذارات الطلاب - انذار اول');

-- --------------------------------------------------------

--
-- Table structure for table `ملاحظات`
--

CREATE TABLE `ملاحظات` (
  `ID` int(11) DEFAULT NULL,
  `Course` varchar(255) DEFAULT NULL,
  `Code` varchar(255) DEFAULT NULL,
  `DepartmentID` int(11) DEFAULT NULL,
  `Credits` int(11) DEFAULT NULL,
  `Prerequisits` varchar(255) DEFAULT NULL,
  `CourseTypeID` int(11) DEFAULT NULL,
  `Teaching Hours Lecture` int(11) DEFAULT NULL,
  `Teching Hours Tutorial` varchar(255) DEFAULT NULL,
  `TeachingHours Practical` int(11) DEFAULT NULL,
  `MidtermID` int(11) DEFAULT NULL,
  `Year Work Grades O` int(11) DEFAULT NULL,
  `Year Work Grades PE` int(11) DEFAULT NULL,
  `YearWorkGrades G` int(11) DEFAULT NULL,
  `FinalExam` int(11) DEFAULT NULL,
  `TimeofExam` int(11) DEFAULT NULL,
  `LeveLID` int(11) DEFAULT NULL,
  `OrderCode` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ملاحظات`
--

INSERT INTO `ملاحظات` (`ID`, `Course`, `Code`, `DepartmentID`, `Credits`, `Prerequisits`, `CourseTypeID`, `Teaching Hours Lecture`, `Teching Hours Tutorial`, `TeachingHours Practical`, `MidtermID`, `Year Work Grades O`, `Year Work Grades PE`, `YearWorkGrades G`, `FinalExam`, `TimeofExam`, `LeveLID`, `OrderCode`, `StatusID`) VALUES
(1, 'Computer Graphics', 'CS351', 1, 3, 'IT101, CS201', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(2, 'Computer Graphics', 'CS354', 1, 3, 'IT101, CS201', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(3, 'Computer Graphics', 'CS355', 1, 3, 'CS121, CS201', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(4, 'Software Development and Professional Practice', 'CS381', 1, 3, 'CS211, SE301', 1, 2, NULL, 3, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(5, 'Software Development and Professional Practice', 'CS382', 1, 3, 'CS211, SE301', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(7, 'Software Development and Professional Practice', 'CS383', 1, 3, 'CS211, CS391', 1, 2, NULL, 3, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(9, 'Software Development and Professional Practice', 'CS384', 1, 3, 'CS211', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(10, 'Software Engineering', 'SE301', 4, 3, 'CS211', 1, 2, '2', NULL, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(11, 'Software Engineering', 'SE303', 4, 3, 'IS231', 1, 2, '2', NULL, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(13, 'Computer Networks', 'IT351', 3, 3, 'IT251', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(14, 'Computer Networks', 'IT352', 3, 3, 'IT251, CS321', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(16, 'Numerical Analysis', 'MATH301', 5, 3, 'MATH102', 1, 2, '2', NULL, 15, 10, 10, 5, 60, 2, 0, NULL, NULL),
(17, 'Numerical Analysis', 'MATH302', 5, 3, 'MATH102', 2, 2, '2', NULL, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(18, 'Numerical Analysis', 'MATH301', 5, 3, 'MATH102', 1, 2, '2', NULL, 15, 10, 10, 5, 60, 2, 0, NULL, NULL),
(19, 'Advanced Database', 'IS411', 2, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(20, 'Advanced Database', 'IS418', 2, 3, 'IS212', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(21, 'Distributed \r\nand Object Databases', 'IS412', 2, 3, 'IS212', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(22, 'Distributed \r\nand Object Databases', 'IS419', 2, 3, 'IS212', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(23, 'Data Mining and Business Intelligence', 'IS414', 2, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(24, 'Data Mining and Business Intelligence', 'IS41X', 2, 3, 'IS201', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(25, 'Wireless and\r\n Mobile Computing', 'IT431', 3, 3, 'IT251', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(26, 'Wireless and\r\n Mobile Computing', 'IT434', 3, 3, 'IT251', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(27, 'Computer Animation', 'CS451', 1, 3, 'CS352', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(28, 'Computer Animation', 'CS454', 1, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(29, 'Parallel Computation', 'CS431', 1, 3, 'CS311, CS321', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(30, 'Parallel Computation', 'CS434', 1, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(31, 'Advanced Computer Architecture', 'CS422', 1, 3, 'CS321', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(33, 'Decision Support Systems', 'IS341', 2, 3, 'IS201', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(34, 'Decision Support Systems', 'IS343', 2, 3, 'IS201', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(35, 'Software Quality Assurance and Testing', 'SE422', 4, 3, 'SE301', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(36, 'Software Quality Assurance and Testing', 'SE423', 4, 3, 'SE301', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(37, 'Network Analysis and Design', 'IT451', 3, 3, 'IT351, MATH202', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(38, 'Network Analysis and Design', 'IT453', 3, 3, 'IT351, MATH202', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, NULL, NULL),
(40, 'Introduction to Multimedia Technology', 'IT381', 3, 3, 'CS241', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0),
(41, 'Introduction to Multimedia Technology', 'IT382', 3, 3, 'CS241', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 2, 0, 0, 0),
(42, 'Human Computer Interaction', 'IT482', 3, 3, 'IT 271', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0),
(43, 'Human Computer Interaction', 'IT483', 3, 3, 'IT 271', 1, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0),
(47, 'Human Computer Interaction', 'IT482', 3, 3, 'CS341', 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0),
(48, 'Virtual Reality', 'IT482', 3, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0),
(49, 'Virtual Reality', 'IT481', 3, 3, NULL, 2, 2, NULL, 2, 15, 10, 10, 5, 60, 3, 0, 0, 0);

-- --------------------------------------------------------

--
-- Structure for view `cgpa_points`
--
DROP TABLE IF EXISTS `cgpa_points`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cgpa_points`  AS  select `course_points`.`StudentID` AS `StudentID`,`course_points`.`StudentName` AS `StudentName`,`course_points`.`StudentCode` AS `StudentCode`,round(sum(`course_points`.`Course_cr_points`),2) AS `CGPA_Total_points`,sum(`course`.`Credits`) AS `CGPA_SumOfCredits`,(select `gpa_grade`.`Grade_English` from `gpa_grade` where ((max(`course_points`.`CurriculumID`) = `gpa_grade`.`CurriculumID`) and (`gpa_grade`.`Points` <= ifnull(round((sum(`course_points`.`Course_cr_points`) / sum(`course`.`Credits`)),2),0))) limit 1) AS `CGPA_grade`,ifnull(round((sum(`course_points`.`Course_cr_points`) / sum(`course`.`Credits`)),2),0) AS `CGPA_Points`,sum(`course_points`.`CourseCredits_Completed`) AS `CGPA_Credits_Completed` from (`course` join (`course_semester` join (`course_points` join `registration` on((`course_points`.`RegID` = `registration`.`ID`))) on((`course_semester`.`ID` = `registration`.`Course_semesterID`))) on((`course`.`ID` = `course_semester`.`CourseID`))) where ((`course_points`.`CourseMarks` >= 0) and (`registration`.`statusID` < 2) and (`registration`.`FinalExam` not in (-(300),-(200)))) group by `course_points`.`StudentID`,`course_points`.`StudentName`,`course_points`.`StudentCode` order by `course_points`.`StudentID`,`course_points`.`StudentCode` ;

-- --------------------------------------------------------

--
-- Structure for view `coursesemestercount`
--
DROP TABLE IF EXISTS `coursesemestercount`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coursesemestercount`  AS  select `student`.`ID` AS `StudentID`,`student`.`StudentEductionalNumber` AS `StudentEductionalNumber`,`student`.`StudentName` AS `StudentName`,count(`course_semester`.`CourseID`) AS `CountOfCourseID`,`course_semester`.`SemesterID` AS `SemesterID`,`semester`.`SemesterFullName` AS `SemesterFullName`,`semester`.`Semester` AS `Semester` from (`student` join (`semester` join (`course_semester` join `registration` on((`course_semester`.`ID` = `registration`.`Course_semesterID`))) on((`semester`.`ID` = `course_semester`.`SemesterID`))) on((`student`.`ID` = `registration`.`StudentID`))) group by `student`.`ID`,`student`.`StudentEductionalNumber`,`student`.`StudentName`,`course_semester`.`SemesterID`,`semester`.`SemesterFullName`,`semester`.`Semester` ;

-- --------------------------------------------------------

--
-- Structure for view `course_points`
--
DROP TABLE IF EXISTS `course_points`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `course_points`  AS  select `registration`.`ID` AS `RegID`,`student`.`CurriculumID` AS `CurriculumID`,`student`.`StudentEductionalNumber` AS `StudentCode`,`registration`.`StudentID` AS `StudentID`,`course_semester`.`SemesterID` AS `SemesterID`,`student`.`StudentName` AS `StudentName`,`semester`.`SemesterEnumID` AS `SemesterEnumID`,`semester`.`StatusID` AS `SemesterStatusID`,`semester`.`Semester` AS `Semester`,`course`.`Credits` AS `CourseCredits`,`course`.`ArabicName` AS `CourseArabicName`,`course`.`Prerequisits` AS `Prerequisits`,`course`.`Code` AS `CourseCode`,if((ifnull(`registration`.`FinalExam`,0) < 0),ifnull(`registration`.`FinalExam`,0),((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0))) AS `CourseMarks`,if((`registration`.`FinalExam` = -(300)),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 54)) limit 1),if((`registration`.`FinalExam` = -(200)),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 53)) limit 1),if((`registration`.`FinalExam` = -(100)),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 52)) limit 1),if((((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)) < (((((`course`.`FinalExam` + `course`.`Year Work Grades O`) + `course`.`Year Work Grades PE`) + `course`.`YearWorkGrades G`) + `course`.`Midterm`) * (select `curriculum`.`Limit_Fail_Total` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 50)) limit 1),if((ifnull(`registration`.`FinalExam`,0) < (`course`.`FinalExam` * (select `curriculum`.`Limit_Fail_Final` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 51)) limit 1),(select `course_grade`.`Grade_English` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`Percentage` <= ((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)))) limit 1)))))) AS `Grade_English`,if((`registration`.`FinalExam` = -(300)),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 54)) limit 1),if((`registration`.`FinalExam` = -(200)),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 53)) limit 1),if((`registration`.`FinalExam` = -(100)),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 52)) limit 1),if((((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)) < (((((`course`.`FinalExam` + `course`.`Year Work Grades O`) + `course`.`Year Work Grades PE`) + `course`.`YearWorkGrades G`) + `course`.`Midterm`) * (select `curriculum`.`Limit_Fail_Total` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 50)) limit 1),if((ifnull(`registration`.`FinalExam`,0) < (`course`.`FinalExam` * (select `curriculum`.`Limit_Fail_Final` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`OrderCode` = 51)) limit 1),(select `course_grade`.`Grade_Arabic` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`Percentage` <= ((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)))) limit 1)))))) AS `Grade_Arabic`,if((ifnull(`registration`.`FinalExam`,0) < (`course`.`FinalExam` * (select `curriculum`.`Limit_Fail_Final` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))),0,if((((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)) <= 0),'',round((select `course_grade`.`Points` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`Percentage` <= ((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)))) limit 1),2))) AS `Course_Points`,round(((select `course_grade`.`Points` from `course_grade` where ((ifnull(`student`.`CurriculumID`,0) = `course_grade`.`CurriculumID`) and (`course_grade`.`Percentage` <= ((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)))) limit 1) * `course`.`Credits`),2) AS `Course_cr_points`,if(((ifnull(`registration`.`FinalExam`,0) < (`course`.`FinalExam` * (select `curriculum`.`Limit_Fail_Final` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1))) or (((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)) < (((((ifnull(`course`.`Midterm`,0) + ifnull(`course`.`Year Work Grades O`,0)) + ifnull(`course`.`Year Work Grades PE`,0)) + ifnull(`course`.`YearWorkGrades G`,0)) + ifnull(`course`.`FinalExam`,0)) * (select `curriculum`.`Limit_Fail_Total` from `curriculum` where (ifnull(`student`.`CurriculumID`,0) = `curriculum`.`ID`) limit 1)))),0,ifnull(`course`.`Credits`,0)) AS `CourseCredits_Completed`,`student`.`MajorDepartmentID` AS `DepartmentID` from (`student` join (`semester` join (`course` join (`course_semester` join `registration` on((`course_semester`.`ID` = `registration`.`Course_semesterID`))) on((`course`.`ID` = `course_semester`.`CourseID`))) on((`semester`.`ID` = `course_semester`.`SemesterID`))) on((`student`.`ID` = `registration`.`StudentID`))) where (`registration`.`statusID` <> 2) order by `student`.`StudentEductionalNumber` ;

-- --------------------------------------------------------

--
-- Structure for view `course_points_lvl`
--
DROP TABLE IF EXISTS `course_points_lvl`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `course_points_lvl`  AS  (select `registration`.`ID` AS `RegID`,`student`.`StudentEductionalNumber` AS `StudentCode`,`registration`.`StudentID` AS `StudentID`,`course_semester`.`SemesterID` AS `SemesterID`,`student`.`StudentName` AS `StudentName`,`semester`.`SemesterEnumID` AS `SemesterEnumID`,`studentsemestercount`.`CountOfSemester` AS `CountOfSemester`,`semester`.`StatusID` AS `SemesterStatusID`,`semester`.`Semester` AS `Semester`,if(((ifnull(`registration`.`FinalExam`,0) < (`course`.`FinalExam` * 0.4)) or (((ifnull(`registration`.`FinalExam`,0) + ifnull(`registration`.`YearWork`,0)) + ifnull(`registration`.`MidTermExam`,0)) < (((((ifnull(`course`.`Midterm`,0) + ifnull(`course`.`Year Work Grades O`,0)) + ifnull(`course`.`Year Work Grades PE`,0)) + ifnull(`course`.`YearWorkGrades G`,0)) + ifnull(`course`.`FinalExam`,0)) * 0.5))),0,ifnull(`course`.`Credits`,0)) AS `CourseCredits_Completed`,`student`.`MajorDepartmentID` AS `DepartmentID` from ((`student` join (`semester` join (`course` join (`course_semester` join `registration` on((`course_semester`.`ID` = `registration`.`Course_semesterID`))) on((`course`.`ID` = `course_semester`.`CourseID`))) on((`semester`.`ID` = `course_semester`.`SemesterID`))) on((`student`.`ID` = `registration`.`StudentID`))) left join `studentsemestercount` on((`studentsemestercount`.`StudentID` = `registration`.`StudentID`))) where (`registration`.`statusID` <> 2) order by `student`.`StudentEductionalNumber`) ;

-- --------------------------------------------------------

--
-- Structure for view `studentlevel`
--
DROP TABLE IF EXISTS `studentlevel`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentlevel`  AS  select `course_points_lvl`.`StudentCode` AS `StudentCode`,`course_points_lvl`.`StudentID` AS `StudentID`,`course_points_lvl`.`CountOfSemester` AS `CountOfSemester`,`course_points_lvl`.`SemesterStatusID` AS `SemesterStatusID`,`course_points_lvl`.`StudentName` AS `StudentName`,sum(`course_points_lvl`.`CourseCredits_Completed`) AS `Total_Credits_Completed`,(select `level`.`LevelTxt_Arabic` from `level` where (`level`.`LevelCreditHours` > ifnull(sum(`course_points_lvl`.`CourseCredits_Completed`),0)) limit 1) AS `StudLevel`,(select `level`.`ID` from `level` where (`level`.`LevelCreditHours` > ifnull(sum(`course_points_lvl`.`CourseCredits_Completed`),0)) limit 1) AS `StudLevelID` from `course_points_lvl` group by `course_points_lvl`.`StudentCode`,`course_points_lvl`.`StudentID`,`course_points_lvl`.`StudentName`,`course_points_lvl`.`CountOfSemester`,`course_points_lvl`.`SemesterStatusID` having (((`course_points_lvl`.`CountOfSemester` < 2) and (`course_points_lvl`.`SemesterStatusID` < 2)) or ((`course_points_lvl`.`CountOfSemester` >= 2) and (`course_points_lvl`.`SemesterStatusID` > 1))) order by `course_points_lvl`.`StudentCode` ;

-- --------------------------------------------------------

--
-- Structure for view `studentsemestercount`
--
DROP TABLE IF EXISTS `studentsemestercount`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentsemestercount`  AS  select `coursesemestercount`.`StudentID` AS `StudentID`,`coursesemestercount`.`StudentEductionalNumber` AS `StudentEductionalNumber`,count(`coursesemestercount`.`Semester`) AS `CountOfSemester` from `coursesemestercount` group by `coursesemestercount`.`StudentID`,`coursesemestercount`.`StudentEductionalNumber` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `course_ibfk_1` (`CourseTypeID`),
  ADD KEY `course_ibfk_2` (`CurriculumID`),
  ADD KEY `course_ibfk_3` (`LeveLID`);

--
-- Indexes for table `coursetype`
--
ALTER TABLE `coursetype`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `course_grade`
--
ALTER TABLE `course_grade`
  ADD KEY `course_grade_ibfk_1` (`semesterID`);

--
-- Indexes for table `course_semester`
--
ALTER TABLE `course_semester`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `course_semester_ibfk_1` (`CourseID`),
  ADD KEY `course_semester_ibfk_2` (`SemesterID`),
  ADD KEY `course_semester_ibfk_3` (`DoctorID`);

--
-- Indexes for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `curriculum_ibfk_1` (`DepartmentID`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `department_ibfk_1` (`FacultyID`);

--
-- Indexes for table `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `level`
--
ALTER TABLE `level`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `military`
--
ALTER TABLE `military`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `nationality`
--
ALTER TABLE `nationality`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `registration_ibfk_1` (`StudentID`),
  ADD KEY `registration_ibfk_2` (`Course_semesterID`);

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `student_ibfk_1` (`MajorDepartmentID`),
  ADD KEY `student_ibfk_2` (`CurriculumID`),
  ADD KEY `student_ibfk_3` (`NationalityID`),
  ADD KEY `student_ibfk_4` (`MilitaryStatusID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`CourseTypeID`) REFERENCES `coursetype` (`ID`),
  ADD CONSTRAINT `course_ibfk_2` FOREIGN KEY (`CurriculumID`) REFERENCES `curriculum` (`ID`),
  ADD CONSTRAINT `course_ibfk_3` FOREIGN KEY (`LeveLID`) REFERENCES `level` (`ID`);

--
-- Constraints for table `course_grade`
--
ALTER TABLE `course_grade`
  ADD CONSTRAINT `course_grade_ibfk_1` FOREIGN KEY (`semesterID`) REFERENCES `semester` (`ID`);

--
-- Constraints for table `course_semester`
--
ALTER TABLE `course_semester`
  ADD CONSTRAINT `course_semester_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `course` (`ID`),
  ADD CONSTRAINT `course_semester_ibfk_2` FOREIGN KEY (`SemesterID`) REFERENCES `semester` (`ID`),
  ADD CONSTRAINT `course_semester_ibfk_3` FOREIGN KEY (`DoctorID`) REFERENCES `doctor` (`ID`);

--
-- Constraints for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD CONSTRAINT `curriculum_ibfk_1` FOREIGN KEY (`DepartmentID`) REFERENCES `department` (`ID`);

--
-- Constraints for table `department`
--
ALTER TABLE `department`
  ADD CONSTRAINT `department_ibfk_1` FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`ID`);

--
-- Constraints for table `registration`
--
ALTER TABLE `registration`
  ADD CONSTRAINT `registration_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `student` (`ID`),
  ADD CONSTRAINT `registration_ibfk_2` FOREIGN KEY (`Course_semesterID`) REFERENCES `course_semester` (`ID`);

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `student_ibfk_1` FOREIGN KEY (`MajorDepartmentID`) REFERENCES `department` (`ID`),
  ADD CONSTRAINT `student_ibfk_2` FOREIGN KEY (`CurriculumID`) REFERENCES `curriculum` (`ID`),
  ADD CONSTRAINT `student_ibfk_3` FOREIGN KEY (`NationalityID`) REFERENCES `nationality` (`ID`),
  ADD CONSTRAINT `student_ibfk_4` FOREIGN KEY (`MilitaryStatusID`) REFERENCES `military` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
