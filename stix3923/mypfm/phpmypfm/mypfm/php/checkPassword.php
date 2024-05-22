<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once ("dbconnect.php");

// Get user ID and password from the request body
$user_id = isset($_POST['user_id']) ? trim($_POST['user_id']) : null;
$password = isset($_POST['password']) ? trim($_POST['password']) : null;

// Validate input
if (empty($user_id) || empty($password)) {
    $response = array('status' => 'error', 'message' => 'Missing required fields');
    echo json_encode($response);
    exit();
}

// Query to retrieve user record
$sql = "SELECT user_password FROM tbl_users WHERE user_id = '$user_id'";
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

// Verify password securely (SHA-based verification)
$hashed_password = $row['user_password'];

// **Important:** Replace the following line with actual SHA verification logic
if (hash_equals($hashed_password, sha1($password))) { // Placeholder, use a secure hashing algorithm

    // **WARNING:** sha1() is NOT recommended for secure password hashing. Consider using bcrypt, Argon2i, or Argon2id instead. See below for details.

    $response = array('status' => 'success');
} else {
    $response = array('status' => 'error', 'message' => 'Incorrect password');
}

sendJsonResponse($response);
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>