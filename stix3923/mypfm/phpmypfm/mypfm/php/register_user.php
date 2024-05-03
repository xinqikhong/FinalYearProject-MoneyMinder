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

            // Insert default income categories for the user
            $sqlinsertincat = "INSERT INTO tbl_incat (incat_name, user_id) VALUES 
            ('Salary', $userId),
            ('Wages', $userId),
            ('Interest', $userId),
            ('Rental', $userId),
            ('Gifts', $userId),
            ('Awards', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertincat);

            // Insert default expense categories for the user
            $sqlinsertexcat = "INSERT INTO tbl_excat (excat_name, user_id) VALUES 
            ('Food', $userId),
            ('Rent', $userId),
            ('Bills', $userId),
            ('Transportation', $userId),
            ('Entertainment', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertexcat);

            // Insert default account for the user
            $sqlinsertaccount = "INSERT INTO tbl_account (account_name, user_id) VALUES 
            ('Cash', $userId),
            ('Bank Account', $userId),
            ('E-wallet', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertaccount);

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
        $mail->Host = 'smtp.gmail.com';
        $mail->Port = 587;
        $mail->SMTPSecure = 'tls'; // Enable TLS encryption
        $mail->SMTPAuth = true;
        $mail->Username = 'xinqikhong11@gmail.com'; // Your Gmail email address
        $mail->Password = 'oagryttdsvikdhbg'; // Your Gmail password

        // Sender and recipient settings
        $mail->setFrom('xinqikhong11@gmail.com', 'MoneyMinder'); // Your name and email address
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
                <a href='http://10.19.33.28/mypfm/php/verify_email.php?email=$email&otp=$otp'>Click here to verify your account</a><br><br>
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