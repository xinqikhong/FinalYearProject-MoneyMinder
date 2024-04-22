<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_GET['email'];
$otp = $_GET['otp'];

$sqlverify = "SELECT * FROM tbl_user WHERE user_email = '$email' AND user_otp = '$otp'";
$result = $conn->query($sqlverify);

if ($result->num_rows > 0)
{
   $newotp = '1';
   $sqlupdate = "UPDATE tbl_user SET otp = '$newotp' WHERE user_email = '$email'";
  if ($conn->query($sqlupdate) === TRUE){
        echo "success";
  }else{
      echo "failed";;
  }
}else{
    echo "failed";;
}
$conn->close();
?>