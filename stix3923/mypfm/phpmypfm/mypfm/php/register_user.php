<?php
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/Exception.php';
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/PHPMailer.php';
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/SMTP.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once ("dbconnect.php");

$name = $_POST['name'];
$email = $_POST['email'];
$pass = $_POST['password'];
$password = sha1($pass);
$otp = rand(10000, 99999);

$sqlregister = "INSERT INTO `tbl_user`(`user_name`, `user_email`, `user_password`, `user_otp`) VALUES ('$name','$email','$password','$otp')";

try {
    if ($conn->query($sqlregister) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        $mailResult = sendMail($email, $otp, $pass);
        if (!$mailResult) {
            $response['status'] = 'failed1';
        }
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed2', 'data' => null);
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed3', 'data' => null);
    sendJsonResponse($response);
}

$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    $jsonResponse = json_encode($sentArray);
    if ($jsonResponse === false) {
        // Error occurred while encoding to JSON
        error_log("Failed to encode response to JSON");
        echo '{"status": "failed4", "data": null}';
    } else {
        echo $jsonResponse;
    }
}

function sendMail($email, $otp, $pass)
{
    // Create a new PHPMailer instance
    $mail = new PHPMailer\PHPMailer\PHPMailer();

    $mail->SMTPDebug = 2;

    // SMTP settings
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->Port = 587;
    $mail->SMTPSecure = 'tls'; // Enable TLS encryption
    $mail->SMTPAuth = true;
    $mail->Username = ''; // Your Gmail email address
    $mail->Password = ''; // Your Gmail password

    // Sender and recipient settings
    $mail->setFrom('xinqikhong11@gmail.com', 'Your Name'); // Your name and email address
    $mail->addAddress($email);

    // Email content
    $mail->isHTML(true);
    $mail->Subject = 'Account Verification';
    $mail->Body = "
        <html>
        <head>
        <title>Account Verification</title>
        </head>
        <body>
        <h3>Thank you for your registration - DO NOT REPLY TO THIS EMAIL</h3>
        <p>
            <a href='http://192.168.144.1/mypfm/php/verify_email.php?email=$email&otp=$otp'>Click here to verify your account</a><br><br>
        </p>
        <table>
        <tr>
        <th>Your Email</th>
        <th>Password</th>
        </tr>
        <tr>
        <td>$email</td>
        <td>$pass</td>
        </tr>
        </table>
        <br>
        <p>TERMS AND CONDITIONS</p>
        </body>
        </html>
    ";

    // Attempt to send the email
    if ($mail->send()) {
        $mail->SMTPDebug = 0;
        // Email sent successfully
        return true;
    } else {
        // Email sending failed
        error_log("Failed to send email to $email: " . $mail->ErrorInfo);
        return false;
    }
}
?>
