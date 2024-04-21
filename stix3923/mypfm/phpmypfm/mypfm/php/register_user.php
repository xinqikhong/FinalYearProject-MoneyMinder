<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$name = $_POST['name'];
$email = $_POST['email'];
$pass = $_POST['password'];
$password = sha1($pass);
$otp = rand(10000, 99999);

$sqlregister = INSERT INTO `tbl_user`(`user_name`, `user_email`, `user_password`, `user_otp`) VALUES ('$name','$email','$password','$otp');
try{
    if ($conn->query($sqlregister) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendMail($email,$otp,$pass);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
}catch (Exception $e){
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

function sendMail($email,$otp,$pass){
    $to = $email;
    $subject = "";
    $message = "
    <html>
    <head>
    <title></title>
    </head>
    <body>
    <h3>Thank you for your registration - DO NOT REPLY TO THIS EMAIL</h3>
    <p></p><br><br>
        <a href='https://slumberjer.com/mypasar/php/verify.php?email=$email&otp=$otp'>Click here to verify your account</a><br><br>
    </p>
    <table>
    <tr>
    <th>Your Email</th>
    <th>Key/Password</th>
    </tr>
    <tr>
    <td>$email</td>
    <td>$pass</td>
    </tr>
    </table>
    <br>
    <p>TERMS AND CONDITION <br></p>
    </body>
    </html>
    ";
    
    // Always set content-type when sending HTML email
    $headers = "MIME-Version: 1.0" . "\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
    
    // More headers
    $headers .= 'From: <mypasar@slumberjer.com>' . "\r\n";
    
    mail($to,$subject,$message,$headers);
}


?>