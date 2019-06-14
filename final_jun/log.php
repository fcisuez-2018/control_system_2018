<?php
session_start();
?>
<?php
$mysql_hostname="localhost";
$mysql_username="root";
$mysql_password="";
$mysql_dbname="gpa";
$connect=mysqli_connect($mysql_hostname, $mysql_username, $mysql_password, $mysql_dbname) or die(mysql_error());
$id=($_POST['id']);
$password=($_POST['pwd']);
$_SESSION['id']=$id;
$_SESSION['pwd']=$password;
$get_users=mysqli_query($connect,"select * from student where (StudentEductionalNumber1='$id' )and socialnumber='$password'")
 or die(mysqli_error());
$pass=mysqli_query($connect,"select * from users where (Username='$id' or Email='$id')and password='$password'") or die(mysqli_error());
echo mysqli_num_rows($get_users);
echo mysqli_num_rows($pass);
while($row=mysqli_fetch_assoc($get_users)){  
    $db_user=$row['id'];
    $db_pass=$row['pwd'];   
}
while($row=mysqli_fetch_assoc($pass)){  
    $db_user=$row['id'];
    $db_pass=$row['pwd'];   
}
if(mysqli_num_rows($get_users)==1){
     header("Location:marks1.php");
     $_session['id']=$id;
    exit();
}
else if(mysqli_num_rows($pass)==1){
    header("Location:list.php");
    $_s['admin']=$password;
    exit();
}
	else{
		echo "Username or Password wrong!!";
		exit();
    }
?>

