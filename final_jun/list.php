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
<meta http-equiv="content-type"content=" text/html; charset=UTF-8" >
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="assets/css/bootstrap.css" type="text/css">
<link href="assets/css/font-awesome.min.css" rel="stylesheet" />
<link href="assets/css/flexslider.css" rel="stylesheet" />
<link rel="stylesheet" href="assets/css/home.css" type="text/css">
<link href="assets/css/footer1.css" rel="stylesheet">
<link href="assets/css/table.css" rel="stylesheet">
<link href="assets/css/topback.css" rel="stylesheet">

<!-- file of java script-->
<script src="assets/js/angular.1.6.min.js"></script>
<script src="assets/js/angular-route.js"></script>
<script src="assets//js/bootstrap.js"></script>
<script src="assets/js/jquery-3.3.1.min.js"></script>
<script src="assets/js/search.js"></script>
<script src="assets/js/topback.js"></script>

</head>

<body >
  
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
                        <a href="res_per_sem.php">Full Result</a>
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
<form action="list.php" method="GET" style="margin-top:100px">
<center id="selector">
<label>
 <span>Faculty</span> <select> 
<option> Fci </option>	  
</select>
 <span> Level </span><select name="level" id="level" >    
</div>
<?php

$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());



$getlevel=mysqli_query($DB,"SELECT level.ID,level.levelTxt 
FROM level ");



while($row = mysqli_fetch_row( $getlevel ))
{
  $lvllimit=$row['0'];
 $level=$row['1'];
    if($lvllimit<5)
   
   echo " <option value=".$row['0']."> ".$row['1']." </option>";



}

	    echo" </select>";
		echo"<span>Semester</span> <select name='semester' id='semester'>";

	 
$getsemester=mysqli_query($DB,"SELECT semester.ID,semester.Semester 
FROM semester order by ID Desc");



while($row = mysqli_fetch_row( $getsemester ))
{
  
$semesterID=$row['1'];
    
    echo " <option value=".$row['0']."> ".$row['1']." </option>";


}


?>
 </select>
<input type="submit"value="Go" class="sh"> 
</center>
 
 </label>
</form>

	<div id="db">
	<?php
   


$DB=mysqli_connect("localhost","root","","gpa") or die("error:".mysqli_error());
mysqli_query($DB,"SET NAMES utf8");



$levelID='';
 $semesterID='';                                                       
if(isset($_GET['level'])){
$levelID=$_GET['level'];
$semesterID=$_GET['semester'];

$getsemester=mysqli_query($DB,"SELECT semester.Semester 
FROM semester where ID = '$semesterID'  ");

while($row1 = mysqli_fetch_row( $getsemester ))
{
 $seme=$row1['0'];   
}

	
	}
	
$getcourse=mysqli_query($DB,"CALL sp_course_semester('$semesterID','$levelID')");

$num_r=mysqli_num_rows($getcourse);
if($num_r>0)
{
	echo"
<center>
<div class='container'>
<input type='text' id='myInput' onkeyup='myFunction()' placeholder='Search'>
<table border=5px id='myTable'>
   
     <th>Course Code</th>	 
     <th>Course Name</th>	 
     <th>Instructor</th>";
  
while($row=mysqli_fetch_row($getcourse))
{
    $idd=$row['0'];
    
    echo "<tr id='search' class='table-hover'> <td> <a href='marks.php?idd=$idd & sem=$semesterID & lvl=$levelID' > ".$row['0']."</a></td><td><a href='marks.php?idd=$idd & sem=$semesterID & lvl=$levelID' >";
    echo $row['1']."</a></td><td><a href='marks.php?idd=$idd & sem=$semesterID & lvl=$levelID' >";
    echo $row['2']."</a></td></tr>";
  
	 
	
	
	
    }
    
	echo"<br><center><a href='db1.php?semester=$semesterID & level=$levelID' ><button type='button' class='editbtn'> <b>Edit</b></button></center><br>";

 echo"</table>"; 

 
 }else{echo"<center><h1></h1>";
		/*echo"<mark><span>There is no Courses in<br> ".$seme." and level ".$levelID."</span>";*/
		echo"</center>";
 }
 $_SESSION["level"]='';
$_SESSION["semester"]='';
if(isset($_GET['level'])){
 $_SESSION["level"] = $_GET['level'];
 $_SESSION["semester"] = $_GET['semester'];
}
}
else{
    header("Location:error.html");
}
	?>
 </center>
 </div>
  <script>
var country = '<?php echo $_SESSION["level"]; ?>';
var country1 = '<?php echo $_SESSION["semester"]; ?>';
if(country !== '' && country1!==''){
    document.getElementById("level").value = country;
    document.getElementById("semester").value = country1;
    
}
</script>
<div><a id='mina' href="javascript:history.go(-1)"onMouseOver="self.status.referrer;return true">Back</a></div>
<button onclick="topFunction()" id='myBtn' title="Go to top">Top</button>
<div id="footer">
  &copy 2019 controlsystem.com | All Rights Reserved | <a href="index1.php">Contact Us</a>
</div>
</body>
</html>