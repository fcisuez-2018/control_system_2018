<?php
session_start();
?>
<html>
<head>
<link href="assets/css/table.css" rel="stylesheet">
<script src="assets/js/search.js"></script>
<script src="assets/js/jquery-3.3.1.min.js"></script>
</head>
<body>
<form action="res_per_sem.php" method="post">
<label>
 
  faculty <select> 
		<option> fci </option>	  
     </select>
        
<?php


$DB=mysqli_connect("localhost","root","","gpa1") or die("error:".mysqli_error());

	    echo" </select>";
			echo"Curriculum <select name='curriculum' id='curriculum'>";

	 
$getcurriculum=mysqli_query($DB,"SELECT curriculum.ID,curriculum.curriculumEngName 
FROM curriculum ");



while($row = mysqli_fetch_row( $getcurriculum ))
{
  
$curriculumID=$row['1'];
    
    echo " <option value=".$row['0']." > ".$row['1']." </option>";


}
echo" </select>";	
		echo"Semester <select name='semester' id='semester'>";
$getsemester=mysqli_query($DB,"SELECT semester.ID,semester.Semester 
FROM semester ");



while($row = mysqli_fetch_row( $getsemester ))
{
  
$semesterID=$row['1'];
    
echo " <option value=".$row['0']."> ".$row['1']." </option>";


}
echo" </select>";

echo"level <select name='level' id='level'>";

	 
$getlevel=mysqli_query($DB,"SELECT level.ID,level.levelTxt 
FROM level ");



while($row = mysqli_fetch_row( $getlevel ))
{
  
$levelID=$row['1'];
    
    echo " <option value=".$row['0']."> ".$row['1']." </option>";


}
echo" </select>";
echo"Department <select name='Department'>";

	 
$getDepartment=mysqli_query($DB,"SELECT Department.ID,DeptartmentCode 
FROM Department ");

echo"<option value='null'>null</option>";

while($row = mysqli_fetch_row( $getDepartment ))
{
  
$departmentID=$row['1'];
		
    echo " <option value=".$row['0']."> ".$row['1']." </option>";
	
}
echo" </select>";
////////////////////////////////////////////////////

?>

<input type="submit"value="Gooo" name="go"> 

 
 </label>
</form>

<button onclick="myFunction()"><b>Print this page</button>

<button onclick="exportTableToExcel('tblData', 'Results-data')"><b>Export Result To Excel File</button>

<table border="1"  id='tblData'>
    <thead>
        
    

<?php


 $curriculumID='';
 $semesterID='';
 $levelID='';
 $departmentID='';
if(isset($_POST['semester'])){
$curriculumID=$_POST['curriculum'];
$semesterID=$_POST['semester'];
$levelID=$_POST['level'];
$departmentID=$_POST['Department'];
}

$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");

$getcourse=mysqli_query($DB,"SELECT DISTINCT Course.Code
FROM student INNER JOIN (Course INNER JOIN (Course_semester INNER JOIN  
(Registration INNER JOIN StudentLevel ON Registration.StudentID = StudentLevel.StudentID)  ON 
Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID)
ON student.ID = Registration.StudentID 
WHERE student.curriculumID=$curriculumID and Course_semester.SemesterID=$semesterID and student.MajorDepartmentID=$departmentID and StudentLevel.studlevelID=$levelID 
GROUP BY Course.Code, Course.ArabicName,
(Course.Midterm+Course.`Year Work Grades O`+Course.`Year Work Grades PE`+ Course.`YearWorkGrades G`+Course.FinalExam),
Course_semester.CourseID, Course_semester.SemesterID, Course.Course") ;

 
echo"
<center>
<input type='text' id='myInput' onkeyup='myFunction()' placeholder='Search'>
</center>
<table border=5px id='myTable'>
<tr><th>StudentEductionalNumber</th>
<th>StudentName</th>
";
$count=0;
while($row=mysqli_fetch_row($getcourse)){

	
	echo"
	<th>".$row['0']."_CourseMarks</th>
	<th>".$row['0']."_CourseEnglish</th>
	<th>".$row['0']."_CoursePoints</th>
	<th>".$row['0']."_Cr_points</th>
	";
	$count++;
}
$countAll=$count*4;
echo"
<th>Total_CR_points</th>
<th>GPA_Semester</th>
<th>Total_points</th>
<th>SumOfCredits</th>
<th>CGPA_Total_points</th>
<th>CGPA_grade</th>
<th>CGPA_Points</th>
<th>CGPA_SumOfCredits</th>
</tr>";



echo $count;
echo "<br> All ".$countAll;

$getpoints=mysqli_query($DB,"CALL sp_cursor_semester('$curriculumID','$semesterID','$levelID','$departmentID')");

	
$count8=$countAll+3;
while($row=mysqli_fetch_row($getpoints)){

	echo"
	<tr><td>".$row['0']."</td>
 	<td>".$row['2']."</td>";
	$n=3;
	$countAll=$count*4;
		z:
	if($countAll!=0){
		echo"
	<td>".$row[$n]."</td>";
	$n++;
	$countAll--;
	goto z;
	
}	


echo"
	<td>".$row[$count8]."</td>
	<td>".$row[$count8+1]."</td>
	<td>".$row[$count8+2]."</td>
	<td>".$row[$count8+3]."</td>
	<td>".$row[$count8+4]."</td>
	<td>".$row[$count8+5]."</td>
	<td>".$row[$count8+6]."</td>
	<td>".$row[$count8+7]."</td></tr>

	";
}
$_SESSION['curriculum']='';
$_SESSION['semester']='';
$_SESSION['level']='';
$_SESSION['Department']='';
if(isset($_POST['go'])){
$_SESSION['curriculum']=$_POST['curriculum'];
$_SESSION['semester']=$_POST['semester'];
$_SESSION['level']=$_POST['level'];
$_SESSION['Department']=$_POST['Department'];}


echo"</table>";
?>
<script>
var country = '<?php echo $_SESSION["curriculum"]; ?>';
var country1 = '<?php echo $_SESSION["semester"]; ?>';
var country2='<?php echo $_SESSION["level"];?>'
var country3='<?php echo $_SESSION["Department"];?>'
if(country !== '' && country1!=='' && country2!=='' && country3!==''){
    document.getElementById("curriculum").value = country;
    document.getElementById("semester").value = country1;
		document.getElementById("level").value = country2;
    
}
</script>
</body>
</html>