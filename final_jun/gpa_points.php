<?php
session_start();
?>
<html>
<head>

<meta http-equiv="content-type"content=" text/html; charset=UTF-8" >
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<link rel="stylesheet" href="css/bootstrap.css" type="text/css">
<link href="assets/css/font-awesome.min.css" rel="stylesheet" />
<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="assets/css/home.css" type="text/css">
<link href="assets/css/footer.css" rel="stylesheet">


<!-- file of java script-->
<script src="assets/js/angular.1.6.min.js"></script>
<script src="assets/js/angular-route.js"></script>
<script src="assets/js/mod.js"></script>
<script src="assets/js/controller1.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
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

<body >

<form action="gpa_points.php" method="post">
<?php
$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");

echo"<span>Semester</span> <select name='semester' id='semester'>";
$getsemester=mysqli_query($DB,"SELECT semester.ID,semester.Semester 
FROM semester ");



while($row = mysqli_fetch_row( $getsemester ))
{
  
$semesterID=$row['1'];
    
    echo " <option value=".$row['0']."> ".$row['1']." </option>";


}
echo" </select>
<input type='submit'value='Go' class='sh'>";

 $semesterID='';                                                       
if(isset($_POST['semester'])){
$semesterID=$_POST['semester'];
	
	}
	$getpoints=mysqli_query($DB, "CALL sp_gpa_points('$semesterID')");
$num_r=mysqli_num_rows($getpoints);
if($num_r>0)
{
	





echo"
<center>
<input type='text' id='myInput' onkeyup='myFunction()' placeholder='Search'>
</center>
<table border=5px id='myTable'>

<th>StudentID</th>
<th>StudentName</th>
<th>StudentCode</th>
<th>GPA_total_points</th>
<th>GPA_SumOfCredits</th>
<th>GPA_Grade</th>
<th>GPA_Points</th>
<th>GPA_CreditsCompleted</th>





";








//////////////////////////////////////////////////

while($row=mysqli_fetch_row($getpoints)){
	echo"<tr><td>".$row['0']."</td>
 	<td>".$row['1']."</td>
	<td>".$row['2']."</td>
	<td>".$row['3']."</td>
	<td>".$row['4']."</td>
	<td>".$row['5']."</td>
	<td>".$row['6']."</td>
	<td>".$row['7']."</td></tr>
	
	";
}
echo"</table>";
}else{echo"<center><h1></h1>";
		
		echo"</center>";
 }
 
$_SESSION["semester"]='';
if(isset($_POST['semester'])){
 
 $_SESSION["semester"] = $_POST['semester'];
}
?>
	
 </center>
 </div>
  <script>

var country = '<?php echo $_SESSION["semester"]; ?>';
if(country !== ''){
    
    document.getElementById("semester").value = country;
    
}
</script>
<div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
</body>
</html>