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

// Check if email parameter exists
if (isset($_POST['email'])) {
    $email = $_POST['email'];

    // Check if email exists in the database
    $stmt = $conn->prepare("SELECT * FROM tbl_users WHERE user_email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    // If email exists
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $otp = $row['user_otp'];

        // If account is verified (otp == 1), generate random token
        if ($otp == 1) {
            //Generate passtoken
            $passtoken = rand(10000, 99999);
            
            //Update passtoken in database
            $sqlUpdate = "UPDATE tbl_users SET user_passtoken = '$passtoken' WHERE user_email = '$email'";;
            // Execute the update query
            if ($conn->query($sqlUpdate) === TRUE) {
                // Attempt to send the email
                $sendPassResetEmailResult = sendPassResetEmail($email, $passtoken);
                if ($sendPassResetEmailResult) {
                    // Email sent successfully
                    $response = array('status' => 'success', 'data' => null);
                } else {
                    // Email sending failed
                    $response = array('status' => 'failed', 'message' => 'Failed to send password');
                }
            } else {
                $response = array('status' => 'failed', 'message' => 'Failed to update passtoken');
                sendJsonResponse($response);
            }
        }
        // If account is not verified (otp == 0), return 'IInactive account' message
        else if ($otp == 0) {
            $response = array("status" => "failed", "message" => "Inactive account");
        }
        // If account is not verified (otp != 0 or 1), send verification email and return 'Unverified' message
        else {
            // Attempt to send the email
            $sendVerifyEmailResult = sendVerifyEmail($email, $otp);
            if ($sendVerifyEmailResult) {
                // Email sent successfully
                $response = array("status" => "failed", "message" => "Unverified");
            } else {
                // Email sending failed
                $response = array('status' => 'failed', 'message' => 'Failed to send verification email');
            }
        }
    } else {
        // If email does not exist in the database, return 'Invalid email' message
        $response = array("status" => "failed", "message" => "Invalid email.");
    }
} else {
    // If email parameter is not provided, return 'Email parameter missing' message
    $response = array("status" => "failed", "message" => "Email parameter missing");
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

function sendPassResetEmail($email, $passtoken){
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
$mail->Subject = 'Money Minder - Password Reset';
$mail->Body = "
    <html>
    <body style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ccc; border-radius: 5px;'>
        <h2 style='text-align: left;'>MoneyMinder Password Reset</h2>
        <p style='text-align: left;'>One-Time-Password(OTP): $passtoken</p>
        <br>
        <p style='text-align: left;'>Please enter the provided OTP in the app to reset your password. If you did not request a password reset, please ignore this email.</p>
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


function sendVerifyEmail($email, $otp)
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