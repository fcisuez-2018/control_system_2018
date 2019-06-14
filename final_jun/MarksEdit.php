<?php
session_start();
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
$pass=mysqli_query($DB,"SELECT * from users");
while($row1 = mysqli_fetch_row( $pass ))
{
 $adminpass=$row1['2'];   
}
if($adminpass=$_SESSION['pwd']){
?>
<html>
<head>
<title>Exams Management System</title>
 <meta http-equiv="content-type"content=" text/html; charset=UTF-8"  >
    <!-- BOOTSTRAP CORE STYLE CSS -->
    <link href="assets/css/bootstrap.css" rel="stylesheet" />
    <!-- FONT AWESOME CSS -->
    <link href="assets/css/font-awesome.min.css" rel="stylesheet" />
    <!-- FLEXSLIDER CSS -->
    <link href="assets/css/flexslider.css" rel="stylesheet" />
    <!-- Google	Fonts -->
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,700,300' rel='stylesheet' type='text/css' />
    <!--Angular Framework-->
    <script src="assets/js/angular.1.6.min.js"></script>
    <!--App Module-->
    <script src="assets/js/app.js"></script>
    <!-- CUSTOM STYLE CSS -->
    <link href="assets/css/home.css" rel="stylesheet"/>
    <link href="assets/css/btable.css" rel="stylesheet"/>
    <link href="Articles/css/article1.css" rel="stylesheet" />
    <link href="assets/css/footer.css" rel="stylesheet" />
    <link href="assets/css/topback.css" rel="stylesheet"/>
    <!--JS Code -->
    <script src="assets/js/jquery-3.3.1.min.js"></script>
     <!--code for search js -->
     <script src="assets/js/search.js"></script> 
     <!--top and back js-->
     <script src="assets/js/topback.js"></script>
</head>
<body>
<br><br><br><br>
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
                        <a href="res_per_sem.php">Full result</a>
                    </li>
                   
                   
                </ul>
            </div>

        </div>
    </div>
	
<center>
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search ">
<form action="update.php" method="post">
<div class='table-wrapper-scroll-y my-custom-scrollbar'>
<table  id='myTable' id='example'class='display' cellspacing='0' class='table table-bordered table-striped mb-0 table-sm'>
<thead>
    <tr class="header">
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
     <th>Department ID</th>
	 </tr>
</thead>
   <tbody>
<?php
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");
$levelID=$_GET['lvl'];	
$semesterID=$_GET['sem'];
$id=$_GET['idd'];


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
   
$rowss = mysqli_num_rows($getinfo);
while($row=mysqli_fetch_row($getinfo))
{
	
   echo "<tr id='search'>";
		 echo "<td>".$row['0']."<input  type=hidden  name='idd[]' value='".$row['0']."'></td>";
		echo "<td>".$row['1']."</td>";
		echo" <td>  ".$row['2']."</td>";
		echo" <td>  ".$row['3']."</td>";
		echo "<td><input type=number min='0' max='15' name='mid[]' value='".$row['4']."'></td>";
		echo "<td><input type=number min='0' max='25' name='year[]' value='".$row['5']."'></td>";
		echo "<td><input type=number min='0' max='60' name='final[]' value='".$row['6']."'></td><td>";
		echo $row['7']."</td><td>";
		echo $row['8']."</td><td>";
		echo $row['9']."</td><td>";
		echo $row['10']."</td>";
		echo "<td>".$row['11']."</td>";
		echo "<td>".$row['12']."</td>";
		echo "<td>".$row['13']."</td>";
		
		
		echo "<input type=hidden name='mid1[]' value='".$row['4']."'>";
		echo "<input type=hidden name='year1[]' value='".$row['5']."'>";
		echo "<input type=hidden name='final1[]' value='".$row['6']."'>";		
		
		
}

	
echo "</tbody>";
echo "<input type=hidden name='lvl' value='".$levelID."'>";
echo "<input type=hidden name='code' value='".$id."'>";
echo "<input type=hidden name='sem' value='".$semesterID."'>";
echo "<input type=hidden name='lenth' value='".$rowss."'></tr>";
echo" </table> </div>";

echo $rowss ;
echo "<br><input type=submit value=save class='btn'><br>";
echo" </form>
	
	 
 </center>";
}
else{
    header("Location:error.html");
}
 
 ?>
 
 <div><a id='mina' href="javascript:history.go(-1)"onMouseOver="self.status.referrer;return true">Back</a></div>

<button onclick="topFunction()" id='myBtn' title="Go to top">Top</button>
 
<div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
 </body>    
 </html>