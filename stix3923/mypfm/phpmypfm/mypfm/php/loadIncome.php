<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$userId = $_POST['user_id'];
$sqlloadincome = "SELECT * FROM tbl_income WHERE user_id = '$userId' ORDER BY income_date DESC";
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
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>