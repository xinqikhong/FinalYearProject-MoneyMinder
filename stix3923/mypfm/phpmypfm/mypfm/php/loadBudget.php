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

$sqlloadbudget = "SELECT * FROM tbl_budget WHERE user_id = '$userId' AND budget_startdate BETWEEN '$start_date' AND '$end_date'";

$result = $conn->query($sqlloadbudget);
if ($result->num_rows > 0) {
    $data["budget"] = array();
    while ($row = $result->fetch_assoc()) {
        $budgetlist = array();
        $budgetlist['budget_id'] = $row['budget_id'];
        $budgetlist['budget_amount'] = $row['budget_amount'];
        $budgetlist['budget_category'] = $row['budget_category'];
        array_push($data["budget"], $budgetlist);
    }
    $response = array('status' => 'success', 'data' => $data["budget"]);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'No budget records found for the requested month and year');
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>