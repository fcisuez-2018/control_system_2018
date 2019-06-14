<html>
<head>
 <meta http-equiv="content-type"content=" text/html; charset=UTF-8"  >
 <link href="assets/css/footer.css" rel="stylesheet">
  <link href="assets/css/table.css" rel="stylesheet">
  <!--script for search js-->
  <script src="assets/js/search.js"></script>
</head>
<body>

	
	
	
	
<center>
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search ">
<table border=5px id="myTable" class="container"> 
     <th>StudentEductionalNumber</th>	 
     <th>Student</th>	    
<?php


$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");
$levelID=$_GET['lvl'];	
$semesterID=$_GET['sem'];
$id=$_GET['idd'];

$getinfo=mysqli_query($DB,"select DISTINCT Student.StudentEductionalNumber , student.StudentName , registration.MidTermExam , registration.YearWork, registration.FinalExam ,
(registration.MidTermExam + registration.YearWork + registration.FinalExam ) as total ,course_grade.Grade_English,course_grade.Points,course_grade.OrderCode ,round(course.credits * course_grade.Points,1) as percourse
FROM course INNER JOIN ( student INNER JOIN(registration INNER JOIN Course_semester INNER JOIN 
(course_grade INNER JOIN semester ON course_grade.semesterID=semester.ID)
 ON Course_semester.ID = registration.Course_semesterID )ON student.ID = registration.studentID) ON course.ID = Course_semester.CourseID
where course.code='$id' and((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID'
HAVING( 
(registration.MidTermExam + registration.YearWork + registration.FinalExam is NULL and course_grade.OrderCode='60'  and registration.FinalExam='-200')OR 
(registration.MidTermExam + registration.YearWork + registration.FinalExam is NULL and course_grade.OrderCode='100'  and registration.FinalExam='-300')
   )");

while($row=mysqli_fetch_row($getinfo))
{
   $idd=$row['0'];
    
    echo "<tr id='search'> <td>  ".$row['0']."</td><td>";
    echo $row['1']."</td><td>";
    
  
}

	?>
 </table>  
 </center>
 <div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
 
 </body>  
    
 </html>