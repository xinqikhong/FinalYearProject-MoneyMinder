<?php
// Make sure there is no whitespace or HTML output before this PHP opening tag
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/Exception.php';
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/PHPMailer.php';
require_once __DIR__ . '/../vendor/phpmailer/PHPMailer-6.9.1/src/SMTP.php';

// Check if headers have already been sent
if (!headers_sent()) {
    // No headers sent yet, so set the error reporting and display errors
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

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

$sqlregister = "INSERT INTO `tbl_users`(`user_name`, `user_email`, `user_password`, `user_otp`) VALUES ('$name','$email','$password','$otp')";

try {
    if ($conn->query($sqlregister) === TRUE) {
        $userId = $conn->insert_id;

        // Attempt to send the email
        $mailResult = sendMail($email, $otp, $pass);

        if ($mailResult) {
            // Email sent successfully
            $response = array('status' => 'success', 'data' => null);
        } else {
            // Email sending failed
            $response = array('status' => 'failed', 'error' => 'Failed to send email');
        }
    } else {
        $response = array('status' => 'failed2', 'data' => null);
    }
} catch (Exception $e) {
    // Log the exception message for debugging
    error_log('Exception caught: ' . $e->getMessage());

    // Set a generic error message for the response
    $response = array('status' => 'failed3', 'data' => null);
}

// Send the JSON response after all other code has executed
sendJsonResponse($response);

$conn->close();

function sendJsonResponse($sentArray)
{
    // Check if headers have already been sent
    if (!headers_sent()) {
        // Set the HTTP Content-Type header to indicate JSON
        header('Content-Type: application/json');
    }

    // Encode the response array to JSON
    $jsonResponse = json_encode($sentArray);

    // Check if encoding was successful
    if ($jsonResponse === false) {
        // If encoding fails, create a simple JSON error response
        $jsonResponse = '{"status": "failed", "error": "Failed to encode response to JSON"}';
    }

    // Output the JSON response
    echo $jsonResponse;
}


function sendMail($email, $otp, $pass)
{
    // Create a new PHPMailer instance
    $mail = new PHPMailer\PHPMailer\PHPMailer();

    try {
        // SMTP settings
        $mail->isSMTP();
        $mail->Host = 'mail.xqksoft.com';
        $mail->Port = 465;
        $mail->SMTPSecure = 'ssl'; // Enable TLS encryption
        $mail->SMTPAuth = true;
        $mail->Username = 'moneyminder_admin@xqksoft.com'; // Your Gmail email address
        $mail->Password = 'Khongq11@'; // Your Gmail password

        // Sender and recipient settings
        $mail->setFrom('moneyminder_admin@xqksoft.com', 'MoneyMinder Team'); // Your name and email address
        $mail->addAddress($email);

        // Email content
        $mail->isHTML(true);
        $mail->Subject = 'Money Minder - Account Verification';
        $mail->Body = "
    <html>
    <body style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 5px;'>
        <h2 style='text-align: left;'>Welcome to MoneyMinder</h2>
        <p style='text-align: left;'>Thank you for registering with MoneyMinder. Please verify your email address to activate your account.</p>
        <br>
        <p style='text-align: left;'>
            <a style='display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px;' href='https://xqksoft.com/mypfm/php/verify_email.php?email=$email&otp=$otp'>Verify Email</a>
        </p>
        <br>
        <p style='text-align: left;'>If you did not register for an account, please ignore this email.</p>
        <br>
        <p style='text-align: left;'>Thank you,<br>MoneyMinder Team</p>
    </body>
    </html>
";

        // Attempt to send the email
        if ($mail->send()) {
            // Email sent successfully
            return true;
        } else {
            // Email sending failed
            return false;
        }
    } catch (Exception $e) {
        // Handle the exception
        error_log('Exception caught while sending email: ' . $e->getMessage());
        return false;
    }
}