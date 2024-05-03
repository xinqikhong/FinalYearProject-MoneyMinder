<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    exit;
}

if (empty($_POST['user_id']) || empty($_POST['category_name'])) {
    $response = array('status' => 'failed', 'message' => 'Missing required information');
    sendJsonResponse($response);
    exit;
}

include_once ("dbconnect.php");

$userId = $_POST['user_id'];
$inCatName = $_POST['category_name'];

$sqlinsert = "INSERT INTO `tbl_incat`(`user_id`, `incat_name`) VALUES ('$userId','$inCatName')";


if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    exit;
}


function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>