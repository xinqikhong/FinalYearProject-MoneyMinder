<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

// Check if user_id is provided
if (isset($_POST['user_id'])) {
    $userId = $_POST['user_id'];

    // Fetch income categories for the given user_id
    $sql = "SELECT * FROM tbl_incat WHERE user_id = '$userId'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $response['status'] = "success";
        $response['categories'] = array();

        while ($row = $result->fetch_assoc()) {
            array_push($response['categories'], $row['incat_name']);
        }
    } else {
        $response['status'] = "failed";
    }
} else {
    $response['status'] = "error";
    $response['message'] = "Missing user_id parameter";
}

sendJsonResponse($response);
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
