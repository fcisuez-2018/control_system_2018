<?php

$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());

$sql="update course,doctor,semester,course_semester set
  doctor.NameTxt = '$_POST[nametxt]' 
WHERE Course.ID = Course_semester.CourseID and doctor.ID = Course_semester.DoctorID and course.code='$_POST[code]'";



if(mysqli_query($DB,$sql))
		
		header("location:db1.php?semester=$_POST[semesterID] & level=$_POST[level]");
else
		echo "NOT UPDATE";




?>