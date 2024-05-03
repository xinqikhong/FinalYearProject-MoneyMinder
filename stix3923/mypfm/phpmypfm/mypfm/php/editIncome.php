<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Include the database connection
include_once ("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['record_id']) || empty($_POST['selected_type'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'Missing required parameters']);
    exit;
}

// Check if the selected record type is Expense
if ($_POST['selected_type'] === "Expense") {
    $incomeId = $_POST['record_id'];

    // Delete the current income record from the income table based on the expense_id
    $sqlDeleteIncome = "DELETE FROM tbl_income WHERE income_id = ?";
    $stmtDeleteIncome = $conn->prepare($sqlDeleteIncome);
    $stmtDeleteIncome->bind_param("i", $incomeId);

    if ($stmtDeleteIncome->execute()) {
        // Create a new expense record in the expense table
        $userId = $_POST['user_id'];
        $expenseDate = $_POST['date'];
        $expenseAmount = floatval($_POST['amount']);
        $expenseCategory = $_POST['category'];
        $expenseNote = $_POST['note'];
        $expenseDesc = $_POST['desc'];
        $expenseAccount = $_POST['account'];

        $expenseDateObj = DateTime::createFromFormat('d/m/Y', $expenseDate);
        $expenseDateFormatted = $expenseDateObj->format('Y-m-d');

        $sqlinsert = "INSERT INTO `tbl_expense`(`user_id`, `expense_date`, `expense_amount`, `expense_category`, `expense_note`, `expense_desc`, `expense_account`) VALUES ('$userId','$expenseDateFormatted','$expenseAmount','$expenseCategory','$expenseNote','$expenseDesc','$expenseAccount')";


        if ($conn->query($sqlinsert) === TRUE) {
            $response = array('status' => 'success', 'data' => null);
            sendJsonResponse($response);
        } else {
            $response = array('status' => 'failed', 'data' => null);
            sendJsonResponse($response);
            exit;
        }

    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
} else { // Assuming the selected type is Income
    // Update fields if provided
    $incomeId = $_POST['record_id'];
    $incomeDate = $_POST['date'];
    $incomeAmount = floatval($_POST['amount']);
    $incomeCategory = $_POST['category'];
    $incomeNote = $_POST['note'];
    $incomeDesc = $_POST['desc'];
    $incomeAccount = $_POST['account'];

    $incomeDateObj = DateTime::createFromFormat('d/m/Y', $incomeDate);
    $incomeDateFormatted = $incomeDateObj->format('Y-m-d');

    // Prepare and execute SQL update statements
    $sqlUpdate = "UPDATE tbl_income SET ";
    $updates = array();

    // Check and add fields to update array
    if (!empty($incomeDate)) {
        $incomeDateObj = DateTime::createFromFormat('d/m/Y', $incomeDate);
        $incomeDateFormatted = $incomeDateObj->format('Y-m-d');
        $updates[] = "income_date = '$incomeDateFormatted'";
    }
    if (!empty($incomeAmount)) {
        $updates[] = "income_amount = '$incomeAmount'";
    }
    if (!empty($incomeCategory)) {
        $updates[] = "income_category = '$incomeCategory'";
    }
    if (!empty($incomeAccount)) {
        $updates[] = "income_account = '$incomeAccount'";
    }
    if (!empty($incomeNote)) {
        $updates[] = "income_note = '$incomeNote'";
    }
    if (!empty($incomeDesc)) {
        $updates[] = "income_desc = '$incomeDesc'";
    }

    // Construct the update query
    $sqlUpdate .= implode(", ", $updates);
    $sqlUpdate .= " WHERE income_id = '$incomeId'";

    // Execute the update query
    if ($conn->query($sqlUpdate) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
}

// Function to send JSON response
function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>