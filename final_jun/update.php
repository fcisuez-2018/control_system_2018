<?php


$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());



$mid1 = array();
                foreach($_POST['mid1'] as $val)
                {
                $mid1[] = (int) $val;
                }
					
				
$year1 = array();
                foreach($_POST['year1'] as $val)
                {
                $year1[] = (int) $val;
                }
$final1 = array();
                foreach($_POST['final1'] as $val)
                {
                $final1[] = (int) $val;
                }








$ids = array();
                foreach($_POST['idd'] as $val)
                {
                $ids[] = (int) $val;
                }
$mid = array();
                foreach($_POST['mid'] as $val)
                {
                $mid[] = (int) $val;
                }
$year = array();
                foreach($_POST['year'] as $val)
                {
                $year[] = (int) $val;
                }
$final = array();
                foreach($_POST['final'] as $val)
                {
                $final[] = (int) $val;
                }
		


$co=$_POST['code'];
$semID=$_POST['sem'];
$count=$_POST['lenth'];

$x=0;
while($x<$count)
{
	
	if (($mid[$x]>15 || $mid[$x]<0 || $year[$x]>25 || $year[$x]<0 || $final[$x]>60 || $final[$x]<0 )||($mid1[$x]==$mid[$x] && $year1[$x]==$year[$x] && $final1[$x]==$final[$x]))
		{
			
			$x=$x+1;
		}
	else
		{
	
mysqli_query($DB,"update registration set registration.MidTermExam='$mid[$x]',registration.YearWork ='$year[$x]',registration.FinalExam='$final[$x]'
WHERE registration.Course_semesterID = (select course_semester.ID from course_semester WHERE course_semester.SemesterID ='$semID' and course_semester.CourseID=( select course.ID from course WHERE course.Code='$co'))
and registration.StudentID=(select Student.ID from Student WHERE  Student.StudentEductionalNumber1='$ids[$x]')");
		
		$x=$x+1;	
	    }

	



}	
	header("location:marksedit.php?idd=$_POST[code] & sem=$_POST[sem] & lvl=$_POST[lvl]");

?>