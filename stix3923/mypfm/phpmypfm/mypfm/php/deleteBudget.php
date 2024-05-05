<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['budget_id'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'Budget ID is missing']);
    exit;
}

$budgetId = $_POST['budget_id'];
$sqldelete = "DELETE FROM `tbl_budget` WHERE budget_id = '$budgetId'";
if ($conn->query($sqldelete) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}


function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}