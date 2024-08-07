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
$category = $_POST['category'];

$start_date = date("$year-$month-01");
$end_date = date("Y-m-t", strtotime("$year-$month-01"));

$sqlloadexpense = "SELECT * FROM tbl_expense WHERE user_id = '$userId' AND expense_category = '$category' AND expense_date BETWEEN '$start_date' AND '$end_date'";

$result = $conn->query($sqlloadexpense);
if ($result->num_rows > 0) {
    $data["expense"] = array();
    while ($row = $result->fetch_assoc()) {
        $expenselist = array();
        $expenselist['expense_id'] = $row['expense_id'];
        $expenselist['expense_date'] = $row['expense_date'];
        $expenselist['expense_amount'] = $row['expense_amount'];
        array_push($data["expense"], $expenselist);
    }
    $response = array('status' => 'success', 'data' => $data["expense"]);
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