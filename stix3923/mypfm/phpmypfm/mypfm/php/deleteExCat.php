<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['user_id'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'User ID is missing']);
    exit;
}

$userId = $_POST['user_id'];
$excatName = $_POST['category_name'];
$sqldelete = "DELETE FROM `tbl_excat` WHERE user_id = '$userId' AND excat_name = '$excatName'";
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