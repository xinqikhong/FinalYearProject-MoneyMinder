<?php
// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Include the database connection
include_once ("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['budget_id']) || empty($_POST['amount'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'Required parameter is missing']);
    exit;
}

$budgetId = $_POST['budget_id'];
$amount = $_POST['amount'];
$sqlUpdate = "UPDATE tbl_budget SET budget_amount = '$amount' WHERE budget_id = '$budgetId'";

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