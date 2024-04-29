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
$expenseDate = $_POST['date'];
//$expenseAmount = $_POST['expense_amount'];
$expenseAmount = floatval($_POST['amount']);
$expenseCategory = $_POST['category'];
$expenseNote = $_POST['note'];
$expenseDesc = $_POST['desc'];
$expenseAccount = $_POST['account'];

//$expenseDesc = isset($_POST['expense_desc']) && $_POST['expense_desc'] !== null ? (string)$_POST['expense_desc'] : "";

$expenseDateObj = DateTime::createFromFormat('d/m/Y', $expenseDate);
// Format the date object into 'YYYY-MM-DD' format
$expenseDateFormatted = $expenseDateObj->format('Y-m-d');

/*
// Perform a database query to get the account_id based on the accountName

$stmt = $pdo->prepare("SELECT account_id FROM tbl_account WHERE account_name = ?");
$stmt->execute([$accountName]);

if ($stmt->rowCount() > 0) { // Check the number of rows returned by the prepared statement
    $accountRow = $stmt->fetch(PDO::FETCH_ASSOC);
    $accountId = $accountRow['account_id'];
} else {
    $response = array('status' => 'failed5', 'data' => null);
    sendJsonResponse($response);
    exit;
}
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
    exit;
}


function sendJsonResponse($sentArray)
{
    // Log the response before sending
    error_log('Response: ' . json_encode($sentArray));

    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>