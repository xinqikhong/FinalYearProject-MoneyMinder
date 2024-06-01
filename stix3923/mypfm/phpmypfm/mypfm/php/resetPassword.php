<?php
// Check if $_POST is set and not empty
if (!$_POST) {
    $response = array('status' => 'failed', 'message' => 'No data received');
    sendJsonResponse($response);
    die();
}

// Include database connection file
include_once("dbconnect.php");

// Get user email, password, and token from the request body
$email = isset($_POST['email']) ? trim($_POST['email']) : null;
$password = isset($_POST['password']) ? trim($_POST['password']) : null;
$token = isset($_POST['token']) ? trim($_POST['token']) : null;

// Validate input
if (empty($email) || empty($password) || empty($token)) {
    $response = array('status' => 'error', 'message' => 'Missing required fields');
    sendJsonResponse($response);
    die();
}

// Hash the new password
$hashed_password = sha1($password);
$reset_token = '0';

// Update user password query
$sql = "UPDATE tbl_users SET user_password = ?, user_passtoken = ? WHERE user_email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $hashed_password, $reset_token, $email);
$result = $stmt->execute();

if (!$result) {
    // Error executing query
    $response = array('status' => 'error', 'message' => 'Database error');
} elseif ($stmt->affected_rows == 1) {
    // Success: Password and token updated
    $response = array('status' => 'success');
} else {
    // No rows affected, likely due to email not found
    $response = array('status' => 'error', 'message' => 'User not found or no changes made');
}

$stmt->close();
$conn->close();

sendJsonResponse($response);

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
