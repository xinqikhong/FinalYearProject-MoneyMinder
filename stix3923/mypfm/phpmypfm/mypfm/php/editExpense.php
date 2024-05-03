<?php

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Include the database connection
include_once ("dbconnect.php");

// Check if the required parameters are present in the POST data
if (empty($_POST['record_id'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'Record ID is missing']);
    exit;
}


$responses = [];

//Check if the selected record type is Income
if ($_POST['selected_type'] === "Income") {
    $expenseId = $_POST['record_id'];

    // Delete the current expense record from the expense table based on the expense_id
    $sqlDeleteExpense = "DELETE FROM tbl_expense WHERE expense_id = ?";
    $stmtDeleteExpense = $conn->prepare($sqlDeleteExpense);
    $stmtDeleteExpense->bind_param("i", $expenseId);

    if ($stmtDeleteExpense->execute()) {
        // Create a new income record in the income table
        $userId = $_POST['user_id'];
        $incomeDate = $_POST['date'];
        $incomeAmount = floatval($_POST['amount']);
        $incomeCategory = $_POST['category'];
        $incomeNote = $_POST['note'];
        $incomeDesc = $_POST['desc'];
        $incomeAccount = $_POST['account'];

        $incomeDateObj = DateTime::createFromFormat('d/m/Y', $incomeDate);
        $incomeDateFormatted = $incomeDateObj->format('Y-m-d');

        $sqlinsert = "INSERT INTO `tbl_income`(`user_id`, `income_date`, `income_amount`, `income_category`, `income_note`, `income_desc`, `income_account`) VALUES ('$userId','$incomeDateFormatted','$incomeAmount','$incomeCategory','$incomeNote','$incomeDesc','$incomeAccount')";

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
} else {
    // Update fields if provided
    $expenseId = $_POST['record_id'];
    $expenseDate = $_POST['date'];
    $expenseAmount = floatval($_POST['amount']);
    $expenseCategory = $_POST['category'];
    $expenseNote = $_POST['note'];
    $expenseDesc = $_POST['desc'];
    $expenseAccount = $_POST['account'];

    $expenseDateObj = DateTime::createFromFormat('d/m/Y', $expenseDate);
    $expenseDateFormatted = $expenseDateObj->format('Y-m-d');

    // Prepare and execute SQL update statements
    $sqlUpdate = "UPDATE tbl_expense SET ";
    $updates = array();

    // Check and add fields to update array
    if (!empty($expenseDate)) {
        $expenseDateObj = DateTime::createFromFormat('d/m/Y', $expenseDate);
        $expenseDateFormatted = $expenseDateObj->format('Y-m-d');
        $updates[] = "expense_date = '$expenseDateFormatted'";
    }
    if (!empty($expenseAmount)) {
        $updates[] = "expense_amount = '$expenseAmount'";
    }
    if (!empty($expenseCategory)) {
        $updates[] = "expense_category = '$expenseCategory'";
    }
    if (!empty($expenseAccount)) {
        $updates[] = "expense_account = '$expenseAccount'";
    }
    if (!empty($expenseNote)) {
        $updates[] = "expense_note = '$expenseNote'";
    }
    if (!empty($expenseDesc)) {
        $updates[] = "expense_desc = '$expenseDesc'";
    }

    // Construct the update query
    $sqlUpdate .= implode(", ", $updates);
    $sqlUpdate .= " WHERE expense_id = '$expenseId'";

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