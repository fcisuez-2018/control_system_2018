<html>
<head>
<link href="assets/css/footer.css" rel="stylesheet">
<meta http-equiv="content-type"content=" text/html; charset=UTF-8" >
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

</head>
<body>

<center>
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search ">
<table border=5px id="myTable">
   
     <th>Course Code</th>	 
     <th>Course Name</th>	 
     <th>Instructor</th>	 
     <th>Action</th>
  

        
<?php


$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");

$levelID=$_GET['level'];
$semesterID=$_GET['semester'];


 
 
$getcourse=mysqli_query($DB,"SELECT course.LeveLID,semester.Semester,semester.ID,course.code, Course.Course , doctor.NameTxt 
FROM Semester INNER JOIN ( doctor INNER JOIN(Course INNER JOIN Course_semester ON Course.ID = Course_semester.CourseID )ON   doctor.ID = Course_semester.DoctorID)
ON Semester.ID = Course_semester.SemesterID
WHERE (((course_Semester.semesterID)='$semesterID')and (Course.LeveLID)='$levelID')");

   while($row = mysqli_fetch_row( $getcourse ))
	{
		echo "<tr><form action=saveup.php method=post>";
				echo "<input type=hidden name=level value='".$row['0']."'>";
		echo "<input type=hidden name=semester value='".$row['1']."'>";
		echo "<input type=hidden name=semesterID value='".$row['2']."'>";

		echo "<td><input type=text name=code value='".$row['3']."'readonly>";
		echo  "<td>".$row['4']."</td>";
		echo "<td><input type=text name=nametxt value='".$row['5']."'></td>";
		
		echo "<td><input type=submit value=save style=background-color:orange;width:80px;height:30px;font-size:20>";
		echo "</form></tr>";
	}
	 

	
	

 
  
	?>
	
	
 </table>  
 </center>
 <div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
 
 </body>  
    
 </html>