<?php
ini_set('display_errors', 1);

if (!isset($_POST)) {
    $response = array('status' => 'failed1', 'data' => null);
    sendJsonResponse($response);
    exit;
}

if (empty($_POST['user_id'])) {
    $response = array('status' => 'failed2', 'data' => null);
    sendJsonResponse($response);
    exit;
}

include_once("dbconnect.php");

$userId = $_POST['user_id'];
$incomeDate = $_POST['date'];
//$incomeAmount = $_POST['amount'];
$incomeAmount = floatval($_POST['amount']);
$incomeCategory = $_POST['category'];
$incomeNote = $_POST['note'];
$incomeDesc = $_POST['desc'];
$incomeAccount = $_POST['account'];

$incomeDateObj = DateTime::createFromFormat('d/m/Y', $incomeDate);
$incomeDateFormatted = $incomeDateObj->format('Y-m-d');

$sqlinsert = "INSERT INTO `tbl_income`(`user_id`, `income_date`, `income_amount`, `income_category`, `income_note`, `income_desc`, `income_account`) VALUES ('$userId','$incomeDateFormatted','$incomeAmount','$incomeCategory','$incomeNote','$incomeDesc','$incomeAccount')";
try{
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed3', 'data' => null);
        sendJsonResponse($response);
        exit;
    }
}catch(Exception $e){
    error_log('Exception caught: ' . $e->getMessage());

    $response = array('status' => 'failed4', 'data' => null);
    sendJsonResponse($sentArray);
    exit;
}


function sendJsonResponse($sentArray)
{
    error_log('Response: ' . json_encode($sentArray));

    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>