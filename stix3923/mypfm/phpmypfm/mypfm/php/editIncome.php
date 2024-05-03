<?php

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Check if the required parameters are present in the POST data
if (empty($_POST['record_id']) || empty($_POST['selected_type'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'Missing required parameters']);
    exit;
}

// Include the database connection
include_once ("dbconnect.php");

$responses = [];

// Check if the selected record type is Expense
if ($_POST['selected_type'] === "Expense") {
    //$expenseId = $_POST['record_id'];

    // Delete the current income record from the income table based on the expense_id
    $sqlDeleteIncome = "DELETE FROM tbl_income WHERE income_id = ?";
    $stmtDeleteIncome = $conn->prepare($sqlDeleteIncome);
    $stmtDeleteIncome->bind_param("i", $incomeId);

    if ($stmtDeleteIncome->execute()) {
        //handle response

        // Create a new income record in the income table
        $userId = $_POST['user_id'];
        $incomeDate = $_POST['date'];
        $incomeAmount = $_POST['amount'];
        $incomeCategory = $_POST['category'];
        $incomeNote = $_POST['note'];
        $incomeDesc = $_POST['desc'];
        $incomeAccount = $_POST['account'];

        // Prepare the SQL statement to insert a new income record
        $sqlInsertIncome = "INSERT INTO tbl_income (user_id, income_date, income_amount, income_category, income_note, income_desc, income_account) VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmtInsertIncome = $conn->prepare($sqlInsertIncome);
        $stmtInsertIncome->bind_param("sssssss", $userId, $incomeDate, $incomeAmount, $incomeCategory, $incomeNote, $incomeDesc, $incomeAccount);

        // Execute the insert statement
        if ($stmtInsertIncome->execute()) {
            $response = ['status' => 'success', 'message' => 'Income record created successfully'];
        } else {
            $response = ['status' => 'failed', 'error' => 'Failed to create income record'];
        }
    } else {
        $response = ['status' => 'failed', 'error' => 'Failed to delete current income record'];
    }
} else { // Assuming the selected type is Income
    // Update date if provided
    if (!empty($_POST['date'])) {
        $incomeDate = $_POST['date'];
        $incomeDateObj = DateTime::createFromFormat('d/m/Y', $incomeDate);
        $incomeDateFormatted = $incomeDateObj->format('Y-m-d');
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_date = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("si", $incomeDateFormatted, $incomeId);
        $responses['date'] = executeUpdate($stmt);
    }

    // Update amount if provided
    if (!empty($_POST['amount'])) {
        $incomeAmount = $_POST['amount'];
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_amount = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("di", $incomeAmount, $incomeId);
        $responses['amount'] = executeUpdate($stmt);
    }

    // Update category if provided
    if (!empty($_POST['category'])) {
        $incomeCategory = $_POST['category'];
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_category = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("si", $incomeCategory, $incomeId);
        $responses['category'] = executeUpdate($stmt);
    }

    // Update account if provided
    if (!empty($_POST['account'])) {
        $incomeAccount = $_POST['account'];
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_account = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("si", $incomeAccount, $incomeId);
        $responses['account'] = executeUpdate($stmt);
    }

    // Update note if provided
    if (!empty($_POST['note'])) {
        $incomeNote = $_POST['note'];
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_note = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("si", $incomeNote, $incomeId);
        $responses['note'] = executeUpdate($stmt);
    }

    // Update desc if provided
    if (!empty($_POST['desc'])) {
        $incomeDesc = $_POST['desc'];
        $incomeId = $_POST['record_id'];
        $sqlupdate = "UPDATE tbl_income SET income_desc = ? WHERE income_id = ?";
        $stmt = $conn->prepare($sqlupdate);
        $stmt->bind_param("si", $incomeDesc, $incomeId);
        $responses['desc'] = executeUpdate($stmt);
    }
}

// Function to execute the SQL update statement
function executeUpdate($stmt) {
    if ($stmt->execute()) {
        return ['status' => 'success'];
    } else {
        return ['status' => 'failed', 'error' => $stmt->error];
    }
}

// Function to send JSON response
function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
}

// Send the combined responses
sendJsonResponse($responses);
?>