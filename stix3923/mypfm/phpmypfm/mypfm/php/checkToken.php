<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once ("dbconnect.php");

// Get user ID and password from the request body
$email = isset($_POST['email']) ? trim($_POST['email']) : null;
$token = isset($_POST['token']) ? trim($_POST['token']) : null;

// Validate input
if (empty($email) || empty($token)) {
    $response = array('status' => 'error', 'message' => 'Missing required fields');
    echo json_encode($response);
    exit();
}

// Query to retrieve user record
$sql = "SELECT user_passtoken FROM tbl_users WHERE user_email = '$email'";
$result = mysqli_query($conn, $sql);

if (!$result) {
    // Error executing query
    $response = array('status' => 'error', 'message' => 'Database error');
    echo json_encode($response);
    exit();
}

$row = mysqli_fetch_assoc($result);

// Check if user exists
if (!$row) {
    $response = array('status' => 'error', 'message' => 'User not found');
    echo json_encode($response);
    exit();
}

// **Important:** Replace the following line with actual SHA verification logic
if ($row['user_passtoken'] == $token) { // Placeholder, use a secure hashing algorithm

    $response = array('status' => 'success');
} else {
    $response = array('status' => 'error', 'message' => 'Invalid OTP');
}

sendJsonResponse($response);
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>