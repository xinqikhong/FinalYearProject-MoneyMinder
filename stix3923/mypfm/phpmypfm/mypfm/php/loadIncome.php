<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$userId = $_POST['user_id'];
$year = $_POST['year']; 
$month = $_POST['month'];

$start_date = date("$year-$month-01");
$end_date = date("Y-m-t", strtotime("$year-$month-01"));

$sqlloadincome = "SELECT * FROM tbl_income WHERE user_id = '$userId' AND income_date BETWEEN '$start_date' AND '$end_date' ORDER BY income_date DESC";

$result = $conn->query($sqlloadincome);
if ($result->num_rows > 0) {
    $data["income"] = array();
    while ($row = $result->fetch_assoc()) {
        $incomelist = array();
        $incomelist['income_id'] = $row['income_id'];
        $incomelist['income_date'] = $row['income_date'];
        $incomelist['user_id'] = $row['user_id'];
        $incomelist['income_amount'] = $row['income_amount'];
        $incomelist['income_category'] = $row['income_category'];
        $incomelist['income_account'] = $row['income_account'];
        $incomelist['income_note'] = $row['income_note'];
        $incomelist['income_desc'] = $row['income_desc'];
        $incomelist['income_creationdate'] = $row['income_creationdate'];
        array_push($data["income"], $incomelist);
    }
    $response = array('status' => 'success', 'data' => $data["income"]);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'No records found for the requested month and year');
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>