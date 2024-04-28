<?php
ini_set('display_errors', 1);

if (!isset($_POST)) {
    $response = array('status' => 'failed1', 'data' => null);
    sendJsonResponse($response);
    exit; // Exit after sending error response
}

// Check if the required parameters are present in the POST data
if (empty($_POST['user_id'])) {
    $response = array('status' => 'failed2', 'data' => null);
    sendJsonResponse($response);
    exit;
}

include_once("dbconnect.php");

$userId = $_POST['user_id'];
$expenseDate = $_POST['expense_date'];
$expenseAmount = $_POST['expense_amount'];
$expenseAmount = floatval($_POST['expense_amount']);
$expenseCategory = $_POST['expense_category'];
$expenseNote = $_POST['expense_note'];
$expenseDesc = $_POST['expense_desc'];
$expenseAccount = $_POST['expense_account'];

//$expenseDesc = isset($_POST['expense_desc']) && $_POST['expense_desc'] !== null ? (string)$_POST['expense_desc'] : "";

$expenseDateObj = DateTime::createFromFormat('d/m/Y', $expenseDate);
// Format the date object into 'YYYY-MM-DD' format
$expenseDateFormatted = $expenseDateObj->format('Y-m-d');

/*
// Perform a database query to get the account_id based on the accountName
$stmt = $pdo->prepare("SELECT account_id FROM tbl_account WHERE account_name = ?");
$stmt->execute([$accountName]);
$accountRow = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$accountRow) {
    // Handle the case where the accountName is not found
    // You can return an error response to the frontend
    $response = array('status' => 'failed3', 'data' => null);
    sendJsonResponse($response);
    exit;
}

// Extract account_id from the retrieved row
$accountId = $accountRow['account_id'];
*/
$sqlinsert = "INSERT INTO `tbl_expense`(`user_id`, `expense_date`, `expense_amount`, `expense_category`, `expense_note`, `expense_desc`, `expense_account`) VALUES ('$userId','$expenseDateFormatted','$expenseAmount','$expenseCategory','$expenseNote','$expenseDesc','$expenseAccount')";
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
    // Log the exception message for debugging
    error_log('Exception caught: ' . $e->getMessage());

    // Set a generic error message for the response
    $response = array('status' => 'failed4', 'data' => null);
    sendJsonResponse($sentArray);
}


function sendJsonResponse($sentArray)
{
    // Log the response before sending
    error_log('Response: ' . json_encode($sentArray));

    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>