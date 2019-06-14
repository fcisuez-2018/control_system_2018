<?php
session_start();
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
$pass=mysqli_query($DB,"SELECT * from users");
while($row1 = mysqli_fetch_row( $pass ))
{
 $adminpass=$row1['2'];   
}
if($adminpass=$_SESSION['pwd']){
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");
$levelID=$_GET['lvl'];	
$semesterID=$_GET['sem'];
$id=$_GET['idd'];
$getAA=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and( (registration.MidTermExam + registration.YearWork + registration.FinalExam >=90 and course_grade.OrderCode='10'))
and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)))) 
    ");

while($row=mysqli_fetch_row($getAA))
{
   $AA=$row['0'];
    
     $row['0'];
}
$getA=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and( (registration.MidTermExam + registration.YearWork + registration.FinalExam IN(85,86,87,88,89) and course_grade.OrderCode='15'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)))) 
");
while($row=mysqli_fetch_row($getA))
{
   $A=$row['0'];
    
     $row['0'];
}

$getBB=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(80,81,82,83,84) and course_grade.OrderCode='20'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)))) 
");
while($row=mysqli_fetch_row($getBB))
{
   $BB=$row['0'];
    
     $row['0'];
}
$getB=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(75,76,77,78,79) and course_grade.OrderCode='25'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)))) ");
while($row=mysqli_fetch_row($getB))
{
   $B=$row['0'];
   
     $row['0'];
}
$getCC=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(70,71,72,73,74) and course_grade.OrderCode='30'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)))) ");
while($row=mysqli_fetch_row($getCC))
{
   $CC=$row['0'];
   
     $row['0'];
}

$getC=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(65,66,67,68,69) and course_grade.OrderCode='35'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))");
while($row=mysqli_fetch_row($getC))
{
   $C=$row['0'];
   
     $row['0'];
}

$getDD=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(60,61,62,63,64) and course_grade.OrderCode='40'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))");
while($row=mysqli_fetch_row($getDD))
{
   $DD=$row['0'];
   
     $row['0'];
}

$getD=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(50,51,52,53,54,55,56,57,58,59) and course_grade.OrderCode='45'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))");
while($row=mysqli_fetch_row($getD))
{
   $D=$row['0'];
   
     $row['0'];
}
$getF=mysqli_query($DB,"select DISTINCT COUNT(course_grade.OrderCode)as countgrade
FROM `course_grade`,  
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` 
        ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) 
        ON ((`course`.`ID` = `course_semester`.`CourseID`)))
        ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) 
        ON ((`student`.`ID` = `registration`.`StudentID`)))
 
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
and((registration.MidTermExam + registration.YearWork + registration.FinalExam IN(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49) and course_grade.OrderCode='50'))and((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`) AND(`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))");
while($row=mysqli_fetch_row($getF))
{
   $F=$row['0'];
   
     $row['0'];
}

 $dataPoints = array( 
    	array("label"=>"A+", "y"=>$AA),
    	array("label"=>"A", "y"=>$A),
    	array("label"=>"B+", "y"=>$BB),
    	array("label"=>"B", "y"=>$B),
    	array("label"=>"C+", "y"=>$CC),
    	array("label"=>"C", "y"=>$C),
    	array("label"=>"D+", "y"=>$DD),
    	array("label"=>"D", "y"=>$D),
    	array("label"=>"F", "y"=>$F)
 
    )
	?>
<html>
<head>
 <meta http-equiv="content-type"content=" text/html; charset=UTF-8"  >
 <title>Exams Management System/Course</title>
 <link href="assets/css/bootstrap.css" rel="stylesheet">
 <link href="assets/css/home.css" rel="stylesheet">
 <link href="assets/css/footer.css" rel="stylesheet">
 <link href="assets/css/btable.css" rel="stylesheet">
 <link href="assets/css/topback.css" rel="stylesheet" type="text/css"/>
 <!-- file js-->
 
<script src="assets/js/angular.1.6.min.js"></script>
<script src="assets/js/angular-route.js"></script>
 <script src="assets/js/jquery-3.3.1.min.js"></script><!-- link for jquery file-->
 <script src="assets/js/bootstrap.js"></script>
 <script src="assets/js/search.js"></script><!-- link for search file js-->
 <script src="assets/js/table.js"></script>
 <script src="assets/js/topback.js"></script>
 
 <script>
    $(document).ready(function() {
    $('#example').DataTable();
} );
    </script>
		 <script>
    window.onload = function() {
     
     
    var chart = new CanvasJS.Chart("chartContainer", {
    	theme: "light2",
    	animationEnabled: true,
    	title: {
    		text: "Grade Count of Students"
    	},
    	data: [{
    		type: "pie",
    		indexLabel: "{y}",
    		yValueFormatString: "#,##0.00\"\"",
    		indexLabelPlacement: "outside",
    		indexLabelFontColor: "red",
    		indexLabelFontSize: 25,
    		indexLabelFontWeight: "bolder",
    		showInLegend: true,
    		legendText: "{label}",
    		dataPoints: <?php echo json_encode($dataPoints, JSON_NUMERIC_CHECK); ?>
    	}]
    });
    chart.render();
     
    }
    </script>

</head>
<body>
    <br>
    <script src="chart.js"></script>
		<div class="navbar navbar-inverse navbar-fixed-top " id="menu">
        <div class="container">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>

                <a class="navbar-brand" href="index.html">
                    <img class="logo-custom" src="assets/img/suez.png" alt=Suez University Drop Logo" />
                </a>
                <h1>Suez     University</h1>
            </div>
            <div class="navbar-collapse collapse move-me">
                <ul class="nav navbar-nav navbar-right">
                    <li class="mi">
                        <a href="index.html">HOME</a>
                    </li>
                                       
                    <li class="mi">
                        <a href="list.php">List Of Courses</a>
                    </li>
                    
                    <li class="mi">
                        <a href="res_per_sem.php">Full Result</a>
                    </li>
                   
                </ul>
            </div>

        </div>
    </div>
    <br><br>   <br>
<div id="chartContainer" style="height: 370px; width: 100%;"></div>
    <script src="assets/js/chart.js"></script>
	
	
	<?php


$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");
$levelID=$_GET['lvl'];	
$semesterID=$_GET['sem'];
$id=$_GET['idd'];



$getsemester=mysqli_query($DB,"SELECT semester.Semester 
FROM semester where ID = '$semesterID'  ");

while($row1 = mysqli_fetch_row( $getsemester ))
{
 $seme=$row1['0'];   
}

echo"<br>
<center>
<input type='text' id='myInput' onkeyup='myFunction()' placeholder='Search'>

<center><a href='MarksEdit.php?idd=$id&sem=$semesterID&lvl=$levelID'><button type='button' class='editbtn'> <b>Edit</b></button></a></center><br>

<div class='table-wrapper-scroll-y my-custom-scrollbar'>
<table border=5px id='myTable' id='example'class='display' cellspacing='0' class='table table-bordered table-striped mb-0 table-sm'>
   <div id='header' class='myHeader'>
   <th></th>
     <th>Student ID</th>	 
     <th>Student Name</th>	 
     <th>Course Credits</th>	 
     <th>Prerequisits</th>	 
     <th>Mid Term</th>	 
     <th>Year Work</th>	 
     <th>Final</th>
     <th>Total Marks</th>
     <th>Grade English</th>
     <th>Grade Arabic</th>
     <th>course Points</th>
     <th>Credits_cr_Points</th>
	 <th>Course Credits Completed</th>
     <th>Department ID</th></div>";
$getinfo=mysqli_query($DB,"SELECT 
        `student`.`StudentEductionalNumber1` AS `StudentCode`,
        `student`.`StudentName` AS `StudentName`,
        `course`.`Credits` AS `CourseCredits`,
        `course`.`Prerequisits` AS `Prerequisits`,
       Round( `registration`.`MidTermExam`,2),Round(`registration`.`YearWork`,2),Round(`registration`.`FinalExam`,2),
       Round( IF((IFNULL(`registration`.`FinalExam`, 0) < 0),
            IFNULL(`registration`.`FinalExam`, 0),
            ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))),2) AS `CourseMarks`,
        IF((`registration`.`FinalExam` = -(300)),
            (SELECT 
                    `course_grade`.`Grade_English`
                FROM
                    `course_grade`
                WHERE
                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                        AND (`course_grade`.`OrderCode` = 54))
                LIMIT 1),
            IF((`registration`.`FinalExam` = -(200)),
                (SELECT 
                        `course_grade`.`Grade_English`
                    FROM
                        `course_grade`
                    WHERE
                        ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                            AND (`course_grade`.`OrderCode` = 53))
                    LIMIT 1),
                IF((`registration`.`FinalExam` = -(100)),
                    (SELECT 
                            `course_grade`.`Grade_English`
                        FROM
                            `course_grade`
                        WHERE
                            ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                AND (`course_grade`.`OrderCode` = 52))
                        LIMIT 1),
                    IF((((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)) < (((((`course`.`FinalExam` + `course`.`Year Work Grades O`) + `course`.`Year Work Grades PE`) + `course`.`YearWorkGrades G`) + `course`.`Midterm`) * (SELECT 
                                `curriculum`.`Limit_Fail_Total`
                            FROM
                                `curriculum`
                            WHERE
                                (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                            LIMIT 1))),
                        (SELECT 
                                `course_grade`.`Grade_English`
                            FROM
                                `course_grade`
                            WHERE
                                ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                    AND (`course_grade`.`OrderCode` = 50))
                            LIMIT 1),
                        IF((IFNULL(`registration`.`FinalExam`, 0) < (`course`.`FinalExam` * (SELECT 
                                    `curriculum`.`Limit_Fail_Final`
                                FROM
                                    `curriculum`
                                WHERE
                                    (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                                LIMIT 1))),
                            (SELECT 
                                    `course_grade`.`Grade_English`
                                FROM
                                    `course_grade`
                                WHERE
                                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                        AND (`course_grade`.`OrderCode` = 51))
                                LIMIT 1),
                            (SELECT 
                                    `course_grade`.`Grade_English`
                                FROM
                                    `course_grade`
                                WHERE
                                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                        AND (`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))
                                LIMIT 1)))))) AS `Grade_English`,
        IF((`registration`.`FinalExam` = -(300)),
            (SELECT 
                    `course_grade`.`Grade_Arabic`
                FROM
                    `course_grade`
                WHERE
                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                        AND (`course_grade`.`OrderCode` = 54))
                LIMIT 1),
            IF((`registration`.`FinalExam` = -(200)),
                (SELECT 
                        `course_grade`.`Grade_Arabic`
                    FROM
                        `course_grade`
                    WHERE
                        ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                            AND (`course_grade`.`OrderCode` = 53))
                    LIMIT 1),
                IF((`registration`.`FinalExam` = -(100)),
                    (SELECT 
                            `course_grade`.`Grade_Arabic`
                        FROM
                            `course_grade`
                        WHERE
                            ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                AND (`course_grade`.`OrderCode` = 52))
                        LIMIT 1),
                    IF((((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)) < (((((`course`.`FinalExam` + `course`.`Year Work Grades O`) + `course`.`Year Work Grades PE`) + `course`.`YearWorkGrades G`) + `course`.`Midterm`) * (SELECT 
                                `curriculum`.`Limit_Fail_Total`
                            FROM
                                `curriculum`
                            WHERE
                                (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                            LIMIT 1))),
                        (SELECT 
                                `course_grade`.`Grade_Arabic`
                            FROM
                                `course_grade`
                            WHERE
                                ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                    AND (`course_grade`.`OrderCode` = 50))
                            LIMIT 1),
                        IF((IFNULL(`registration`.`FinalExam`, 0) < (`course`.`FinalExam` * (SELECT 
                                    `curriculum`.`Limit_Fail_Final`
                                FROM
                                    `curriculum`
                                WHERE
                                    (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                                LIMIT 1))),
                            (SELECT 
                                    `course_grade`.`Grade_Arabic`
                                FROM
                                    `course_grade`
                                WHERE
                                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                        AND (`course_grade`.`OrderCode` = 51))
                                LIMIT 1),
                            (SELECT 
                                    `course_grade`.`Grade_Arabic`
                                FROM
                                    `course_grade`
                                WHERE
                                    ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                        AND (`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))
                                LIMIT 1)))))) AS `Grade_Arabic`,
        IF((IFNULL(`registration`.`FinalExam`, 0) < (`course`.`FinalExam` * (SELECT 
                    `curriculum`.`Limit_Fail_Final`
                FROM
                    `curriculum`
                WHERE
                    (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                LIMIT 1))),
            0,
            IF((((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)) <= 0),
                '',
                ROUND((SELECT 
                                `course_grade`.`Points`
                            FROM
                                `course_grade`
                            WHERE
                                ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                                    AND (`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))
                            LIMIT 1),
                        2))) AS `Course_Points`,
        ROUND(((SELECT 
                        `course_grade`.`Points`
                    FROM
                        `course_grade`
                    WHERE
                        ((IFNULL(`student`.`CurriculumID`, 0) = `course_grade`.`CurriculumID`)
                            AND (`course_grade`.`Percentage` <= ((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0))))
                    LIMIT 1) * `course`.`Credits`),
                2) AS `Course_cr_points`,
        IF(((IFNULL(`registration`.`FinalExam`, 0) < (`course`.`FinalExam` * (SELECT 
                    `curriculum`.`Limit_Fail_Final`
                FROM
                    `curriculum`
                WHERE
                    (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                LIMIT 1)))
                OR (((IFNULL(`registration`.`FinalExam`, 0) + IFNULL(`registration`.`YearWork`, 0)) + IFNULL(`registration`.`MidTermExam`, 0)) < (((((IFNULL(`course`.`Midterm`, 0) + IFNULL(`course`.`Year Work Grades O`, 0)) + IFNULL(`course`.`Year Work Grades PE`, 0)) + IFNULL(`course`.`YearWorkGrades G`, 0)) + IFNULL(`course`.`FinalExam`, 0)) * (SELECT 
                    `curriculum`.`Limit_Fail_Total`
                FROM
                    `curriculum`
                WHERE
                    (IFNULL(`student`.`CurriculumID`, 0) = `curriculum`.`ID`)
                LIMIT 1)))),
            0,
            IFNULL(`course`.`Credits`, 0)) AS `CourseCredits_Completed`,
        `student`.`MajorDepartmentID` AS `DepartmentID`
    FROM
        (`student`
        JOIN (`semester`
        JOIN (`course`
        JOIN (`course_semester`
        JOIN `registration` ON ((`course_semester`.`ID` = `registration`.`Course_semesterID`))) ON ((`course`.`ID` = `course_semester`.`CourseID`))) ON ((`semester`.`ID` = `course_semester`.`SemesterID`))) ON ((`student`.`ID` = `registration`.`StudentID`)))
    WHERE
        (`registration`.`statusID` <> 2) and  course_semester.semesterID='$semesterID'  and course.Code='$id' and course.LeveLID='$levelID'
    ORDER BY `student`.`StudentEductionalNumber`");
    $n=1;
while($row=mysqli_fetch_row($getinfo))
{
   $idd=$row['0'];
    
    echo "<tr id='search'> <td>$n</td><td>  ".$row['0']."</td><td>";
    echo $row['1']."</td><td>";
    echo $row['2']."</td><td>";
    echo $row['3']."</td><td>";
    echo $row['4']."</td><td>";
    echo $row['5']."</td><td>";
    echo $row['6']."</td><td>";
    echo $row['7']."</td><td>";
    echo $row['8']."</td><td>";
    echo $row['9']."</td><td>";
    echo $row['10']."</td><td>";
    echo $row['11']."</td><td>";
    echo $row['12']."</td><td>";
    echo $row['13']."</td>";
    $n++;
  
}
}else{
    header("Location:error.html");
}

   ?>
   </div>
</div>
 </table>  
 </center>

   <div><a id='mina' href="javascript:history.go(-1)"onMouseOver="self.status.referrer;return true">Back</a></div>
   <button onclick="topFunction()" id='myBtn' title="Go to top">Top</button>

<div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
 </body>  
    
 </html>