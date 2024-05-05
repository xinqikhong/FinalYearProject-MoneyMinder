<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    exit;
}

if (empty($_POST['user_id']) || empty($_POST['amount']) || empty($_POST['category']) || empty($_POST['year']) || empty($_POST['month'])) {
    $response = array('status' => 'failed', 'message' => 'Missing required parameter');
    sendJsonResponse($response);
    exit;
}

include_once ("dbconnect.php");

$userId = $_POST['user_id'];
$amount = $_POST['amount'];
$category = $_POST['category'];
$year = $_POST['year']; 
$month = $_POST['month'];
//$startDate = $_POST['startdate'];
$startDate = date("$year-$month-01");

$sqlinsert = "INSERT INTO `tbl_budget`(`user_id`, `budget_amount`, `budget_category`, `budget_startdate`) VALUES ('$userId','$amount','$category','$startDate')";

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