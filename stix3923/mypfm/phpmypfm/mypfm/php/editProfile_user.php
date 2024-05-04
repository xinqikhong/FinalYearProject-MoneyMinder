<?php

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'error' => 'Invalid request method']);
    exit;
}

// Check if the required parameters are present in the POST data
if (empty($_POST['userid'])) {
    sendJsonResponse(['status' => 'failed', 'error' => 'User ID is missing']);
    exit;
}

// Include the database connection
include_once("dbconnect.php");

$responses = [];

// Update name if provided
if (!empty($_POST['name'])) {
    $name = $_POST['name'];
    $userid = $_POST['userid'];
    $sqlupdate = "UPDATE tbl_users SET user_name = ? WHERE user_id = ?";
    $stmt = $conn->prepare($sqlupdate);
    $stmt->bind_param("si", $name, $userid);
    $responses['name'] = executeUpdate($stmt);
}

// Update phone if provided and not empty
if (isset($_POST['phone'])) {
  $phone = $_POST['phone'];
  $userid = $_POST['userid'];
  if ($phone === '') {
      $phone = null; // Set to null if empty string
  }
  $sqlupdate = "UPDATE tbl_users SET user_phone = ? WHERE user_id = ?";
  $stmt = $conn->prepare($sqlupdate);
  $stmt->bind_param("si", $phone, $userid);
  $responses['phone'] = executeUpdate($stmt);
}

// Update address if provided and not empty
if (isset($_POST['address'])) {
  $address = $_POST['address'];
  $userid = $_POST['userid'];
  if ($address === '') {
      $address = null; // Set to null if empty string
  }
  $sqlupdate = "UPDATE tbl_users SET user_address = ? WHERE user_id = ?";
  $stmt = $conn->prepare($sqlupdate);
  $stmt->bind_param("si", $address, $userid);
  $responses['address'] = executeUpdate($stmt);
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