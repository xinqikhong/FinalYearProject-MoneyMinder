<?php
// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Include the database connection
include_once ("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['user_id'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'User ID is missing']);
    exit;
}

$userId = $_POST['user_id'];
$excatName = $_POST['old_name'];
$newName = $_POST['new_name'];
$sqlUpdate = "UPDATE tbl_excat SET excat_name = '$newName' WHERE user_id = '$userId' AND excat_name = '$excatName'";

// Execute the update query
if ($conn->query($sqlUpdate) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

// Function to send JSON response
function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>