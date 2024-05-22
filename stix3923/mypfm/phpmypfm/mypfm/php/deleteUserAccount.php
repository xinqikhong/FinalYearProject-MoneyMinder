<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once ("dbconnect.php");

// Get user ID and password from the request body
$user_id = isset($_POST['user_id']) ? trim($_POST['user_id']) : null;

// Validate input
if (empty($user_id)) {
    $response = array('status' => 'error', 'message' => 'Missing required fields');
    echo json_encode($response);
    exit();
}

// Update query to set user_otp to 0
$sql = "UPDATE tbl_users SET user_otp = 0 WHERE user_id = '$user_id'";
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
    $response = array('status' => 'error', 'message' => 'Account update failed');
}

sendJsonResponse($response);
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>