
<style>
      
			  
		   #myInput {
  background-image: url('/css/searchicon.png'); 
  background-position: 10px 12px; 
  background-repeat: no-repeat; 
  width: 50%; 
  font-size: 16px; 
  padding: 12px 20px 12px 40px; 
  border: 1px solid #ddd; 
  margin-bottom: 12px; 
}

#myTable {
  border-collapse: collapse; 
  width: 80%;
  border: 1px solid #ddd; 
  font-size: 18px; 
}

#myTable th, #myTable td {
  text-align: left; 
  padding: 12px; 
}

#myTable tr {
  border-bottom: 1px solid #ddd;
}

#myTable tr.header, #myTable tr:hover {
  background-color: #f1f1f1;
}
        </style>

<script src="jquery-3.3.1.min.js"></script>
<script>
$(document).ready(function(){
  $("#myInput").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#myTable tr").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});
</script>	

<?php


echo"
<center>
<input type='text' id='myInput' onkeyup='myFunction()' placeholder='Search'>
</center>
<table border=5px id='myTable'>

<th>RegID</th>
<th>StudentCode</th>
<th>Reg.StudentID</th>
<th>SemesterID</th>
<th>StudentName</th>
<th>SemesterEnumID</th>
<th>SemesterStatusID</th>
<th>Semester</th>
<th>CourseCredits</th>
<th>CourseArabicName</th>
<th>Prerequisits</th>
<th>CourseCode</th>
<th>CourseMarks</th>
<th>Grade_English</th>
<th>Grade_Arabic</th>
<th>Course_Points</th>
<th>Course_cr_points</th>
<th>CourseCredits_Completed</th>
<th>DepartmentID</th>




";
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");





$getpoints=mysqli_query($DB, "CALL sp_course_point");

//////////////////////////////////////////////////

while($row=mysqli_fetch_row($getpoints)){
	echo"<tr><td>".$row['0']."</td>
 	<td>".$row['1']."</td>
	<td>".$row['2']."</td>
	<td>".$row['3']."</td>
	<td>".$row['4']."</td>
	<td>".$row['5']."</td>
	<td>".$row['6']."</td>
	<td>".$row['7']."</td>
	<td>".$row['8']."</td>
	<td>".$row['9']."</td>
	<td>".$row['10']."</td>
	<td>".$row['11']."</td>
	<td>".$row['12']."</td>
	<td>".$row['13']."</td>
	<td>".$row['14']."</td>
	<td>".$row['15']."</td>
	<td>".$row['16']."</td>
	<td>".$row['17']."</td>
	<td>".$row['18']."</td></tr>
	
	";
}
echo"</table>";
