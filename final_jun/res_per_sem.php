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
<title> Exams Management System/Full Result</title>
<link href="assets/css/btable.css" rel="stylesheet">
<link href="assets/css/footer.css" rel="stylesheet">
<link href="assets/css/bootstrap.css" rel="stylesheet">
<link rel="stylesheet" href="assets/css/home.css" type="text/css">
<link href="assets/css/topback.css" rel="stylesheet" type="text/css"/>

<script src="assets/js/search.js"></script>
<script src="assets/js/jquery-3.3.1.min.js"></script>
<script src="assets/js/search.js"></script>
</head>
<script>


function exportTableToExcel(tableID, filename = ''){
    var downloadLink;
    var dataType = 'application/vnd.ms-excel';
    var tableSelect = document.getElementById(tableID);
    var tableHTML = tableSelect.outerHTML.replace(/ /g, '%20');
    
    // Specify file name
    filename = filename?filename+'.xls':'excel_data.xls';
    
    // Create download link element
    downloadLink = document.createElement("a");
    
    document.body.appendChild(downloadLink);
    
    if(navigator.msSaveOrOpenBlob){
        var blob = new Blob(['\ufeff', tableHTML], {
            type: dataType
        });
        navigator.msSaveOrOpenBlob( blob, filename);
    }else{
        // Create a link to the file
        downloadLink.href = 'data:' + dataType + ', ' + tableHTML;
    
        // Setting the file name
        downloadLink.download = filename;
        
        //triggering the function
        downloadLink.click();
    }
}

</script>
<body>
  
<div class="mynav navbar navbar-inverse navbar-fixed-top " id="menu">
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
                   <li>
                        <a href="list.php">List Of Courses</a>
                    </li>
                    
                    <li>
                        <a href="report.html">Reports</a>
                    </li>
                    
                    <li>
                        <a href="Bi.html">Detailed statistics</a>
                    </li>
                </ul>
            </div>

        </div>
    </div>
            
<div >
<br><br><br>
<form action="res_per_sem.php" method="post">
  <center id="selector">
    
<label>
   
<?php

$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");
	    echo" </select>";
			echo"<span>Curriculum</span> <select name='curriculum' id='curriculum'>";

$getcurriculum=mysqli_query($DB,"SELECT curriculum.ID,curriculum.curriculumEngName 
FROM curriculum ");



while($row = mysqli_fetch_row( $getcurriculum ))
{
  
$curriculumID=$row['1'];
    
    echo " <option value=".$row['0']."> ".$row['1']." </option>";


}
echo" </select>";

/////////////////////////////////////////////		
		echo"<span>Semester </span><select name='semester' id='semester'>";
$getsemester=mysqli_query($DB,"SELECT semester.ID,semester.Semester 
FROM semester order by ID Desc");



while($row = mysqli_fetch_row( $getsemester ))
{
  
$semesterID=$row['1'];
    
    echo " <option value=".$row['0']." > ".$row['1']." </option>";


}
echo" </select>";

//////////////////////////////////////////////////
	echo"<span>Level</span> <select name='level' id='level'>";

	 
$getlevel=mysqli_query($DB,"SELECT level.ID,level.levelTxt 
FROM level ");


echo"<option value='null'>All</option>";

while($row = mysqli_fetch_row( $getlevel ))
{
  $lvllimit=$row['0'];
$levelID=$row['1'];
    if($lvllimit<5)
    echo " <option value=".$row['0']."> ".$row['1']." </option>";


}

echo" </select><br>";

echo"<span>Department </span><select name='Department' id='Department'>";

	 
$getDepartment=mysqli_query($DB,"SELECT Department.ID,DeptartmentCode 
FROM Department ");

echo"<option value='null'>All</option>";
while($row = mysqli_fetch_row( $getDepartment ))
{
  
$departmentID=$row['1'];
		
    echo " <option value=".$row['0']."> ".$row['1']." </option>";
	
}


echo" </select>";

?>

<input type="submit"value="Go" name="go"> 
</center>
 
 </label>
</form>
<br><br><br>
<center>


<button onclick="exportTableToExcel('myTable', 'Results-data')"><b>Export Result To Excel File</button>
</center>

<center>
<input type='text' id='myInput' placeholder='Search'>
</center>
<div class='table-wrapper-scroll-y my-custom-scrollbar'>
<table border=5px id='myTable' id='example'class='display' cellspacing='0' class='table table-bordered table-striped mb-0 table-sm'>
  
<?php
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");


$levelID='';
 $semesterID='';                                                       
$curriculumID='';                                                       
 $departmentID='';                                                       
if(isset($_POST['level'])){
$curriculumID=$_POST['curriculum'];
$semesterID=$_POST['semester'];
$levelID=$_POST['level'];
$departmentID=$_POST['Department'];


echo"  <th colspan='0'></th>";


$getcourseth=mysqli_query($DB,"SELECT DISTINCT Course.course,Course.Credits,Course.Code
FROM student INNER JOIN (Course INNER JOIN (Course_semester INNER JOIN  
(Registration INNER JOIN StudentLevel ON Registration.StudentID = StudentLevel.StudentID)  ON 
Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID)
ON student.ID = Registration.StudentID 
WHERE student.curriculumID=$curriculumID and Course_semester.SemesterID=$semesterID and if($departmentID is null,true,student.MajorDepartmentID=$departmentID)and if($levelID is null,true,StudentLevel.studlevelID=$levelID )
GROUP BY Course.Code, Course.ArabicName,
(Course.Midterm+Course.`Year Work Grades O`+Course.`Year Work Grades PE`+ Course.`YearWorkGrades G`+Course.FinalExam),
Course_semester.CourseID, Course_semester.SemesterID, Course.Course") ;

 echo"

<th colspan='2'>Subjects<br>ــــــــــــــــــــــــــــــــــــــــــــــــــ<br> Number of Credits per Subject</th>";

while($row1=mysqli_fetch_row($getcourseth))
{
	 $idd=$row1['0'];
echo"	
<th colspan='4'>".$row1['0']."<br>".$row1['2']."<br> ــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ<br>".$row1['1']." Credits</th>

         
       ";
	  
	    }



		
$getcourse=mysqli_query($DB,"SELECT DISTINCT Course.Code
FROM student INNER JOIN (Course INNER JOIN (Course_semester INNER JOIN  
(Registration INNER JOIN StudentLevel ON Registration.StudentID = StudentLevel.StudentID)  ON 
Course_semester.ID = Registration.Course_semesterID) ON Course.ID = Course_semester.CourseID)
ON student.ID = Registration.StudentID 
WHERE student.curriculumID=$curriculumID and Course_semester.SemesterID=$semesterID and if($departmentID is null,true,student.MajorDepartmentID=$departmentID)and if($levelID is null,true,StudentLevel.studlevelID=$levelID )
GROUP BY Course.Code, Course.ArabicName,
(Course.Midterm+Course.`Year Work Grades O`+Course.`Year Work Grades PE`+ Course.`YearWorkGrades G`+Course.FinalExam),
Course_semester.CourseID, Course_semester.SemesterID, Course.Course") ;

echo"
<th>Total_CR_points</th>
<th>GPA_Semester</th>
<th>Total_points</th>
<th>SumOfCredits</th>
<th>CGPA_Total_points</th>";
//<th>CGPA_grade</th>
echo"<th>CGPA_Points</th>
<th>CGPA_SumOfCredits</th>
";

$count=0;
echo"<tr><th>-</th><th>Student ID</th>
<th>Student Name</th>
";
   
while($row=mysqli_fetch_row($getcourse)){

	
	echo"
	<th>CourseMarks</th>
	<th>CourseEnglish</th>
	<th>CoursePoints</th>
	<th>Cr_points</th>
	";
	$count++;
}
$countAll=$count*4;



//echo $count;
//echo "<br> All ".$countAll;

$getpoints=mysqli_query($DB,"CALL sp_cursor_semester($curriculumID,$semesterID,$levelID,$departmentID)");

	
$count8=$countAll+3;
$s=1;
while($row=mysqli_fetch_row($getpoints)){

	echo"
	<tr id='search'><td>$s</td><td>".$row['0']."</td>
 	<td>".$row['2']."</td>";
	$n=3;
	$ncolor=3;
	$countAll=$count*4;
		z:
	if($countAll!=0)
	{	
		$fcolor=$row[$n];
		
		if($fcolor<50 & $fcolor>12 or $fcolor=='F' or $fcolor=='-' or $fcolor=='ر ل'){echo"<td style=background-color:gray>".$row[$n]."</td>";}
		  else{echo"<td>".$row[$n]."</td>";}
	$n++;
	$countAll--;
	
	goto z;
}		
echo"
	<td>".$row[$count8]."</td>
	<td>".$row[$count8+1]."</td>
	<td>".$row[$count8+2]."</td>
	<td>".$row[$count8+3]."</td>
	<td>".$row[$count8+4]."</td>";
	//<td>".$row[$count8+5]."</td>
echo"	<td>".$row[$count8+6]."</td>
	<td>".$row[$count8+7]."</td></tr>

  ";
  $s++;
}
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

echo"</table></div>";
}
else{
  header("Location:error.html");
}
?>
<script>
var country = '<?php echo $_SESSION["curriculum"]; ?>';
var country1 = '<?php echo $_SESSION["semester"]; ?>';
var country2='<?php echo $_SESSION["level"];?>'
var country3='<?php echo $_SESSION["Department"];?>'
if(country !== '' || country1!=='' || country2!=='' || country3!==''){
    document.getElementById("curriculum").value = country;
    document.getElementById("semester").value = country1;
		document.getElementById("level").value = country2;
    document.getElementById("Department").value = country3;
    
}
</script>
 <script>                                                     
        function scrollFunction() {
      if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
        document.getElementById("myBtn").style.display = "block";
      } else {
        document.getElementById("myBtn").style.display = "none";
      }
    }
    
    // When the user clicks on the button, scroll to the top of the document
    function topFunction() {
      document.body.scrollTop = 0; // For Safari
      document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    }   
        
    </script>  
    <div><a id='mina' href="javascript:history.go(-1)"onMouseOver="self.status.referrer;return true">Back</a></div>

    <button onclick="topFunction()" id='myBtn' title="Go to top">Top</button>

<div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
</body>
</html>
