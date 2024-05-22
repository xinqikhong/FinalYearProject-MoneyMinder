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

// Hash the new password
$hashed_password = sha1($password);

// Update user password query
$sql = "UPDATE tbl_users SET user_password = '$hashed_password' WHERE user_id = '$user_id'";
$result = mysqli_query($conn, $sql);

if (!$result) {
    // Error executing query
    $response = array('status' => 'error', 'message' => 'Database error');
    echo json_encode($response);
    exit();
}

if (mysqli_affected_rows($conn) == 1) {
    $response = array('status' => 'success');
} else {
    $response = array('status' => 'error', 'message' => 'Password update failed');
}

sendJsonResponse($response);
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>