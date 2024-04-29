<?php

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

$responses = [];

// Check if the selected record type is Expense
if ($_POST['selected_type'] === "Expense") {
    $expenseId = $_POST['record_id'];

    // Delete the current income record from the income table based on the expense_id
    $sqlDeleteIncome = "DELETE FROM tbl_income WHERE expense_id = ?";
    $stmtDeleteIncome = $conn->prepare($sqlDeleteIncome);
    $stmtDeleteIncome->bind_param("i", $expenseId);

    if ($stmtDeleteIncome->execute()) {
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
    // Update fields if provided
    $incomeId = $_POST['record_id'];
    $incomeDate = $_POST['date'];
    $incomeAmount = $_POST['amount'];
    $incomeCategory = $_POST['category'];
    $incomeNote = $_POST['note'];
    $incomeDesc = $_POST['desc'];
    $incomeAccount = $_POST['account'];

    // Prepare and execute SQL update statements
    $sqlUpdate = "UPDATE tbl_income SET ";
    $updates = array();

    // Check and add fields to update array
    if (!empty($incomeDate)) {
        $updates[] = "income_date = '$incomeDate'";
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
        $response = array('status' => 'success', 'message' => 'Income record updated successfully');
        //sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'error' => $conn->error);
        //sendJsonResponse($response);
    }
}


// Function to update a field in the tbl_income table
/*function updateField($field, $value, $incomeId)
{
    global $conn;
    $sqlUpdate = "UPDATE tbl_income SET $field = ? WHERE income_id = ?";
    $stmt = $conn->prepare($sqlUpdate);
    $stmt->bind_param("si", $value, $incomeId);
    if ($stmt->execute()) {
        return ['status' => 'success'];
    } else {
        return ['status' => 'failed', 'error' => $stmt->error];
    }
}*/

// Function to send JSON response
function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}

// Send the responses
sendJsonResponse($responses);

?>