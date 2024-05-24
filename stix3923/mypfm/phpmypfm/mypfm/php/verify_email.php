<?php
error_reporting(0);
include_once("dbconnect.php");

$email = $_GET['email'];
$otp = $_GET['otp'];

$sqlverify = "SELECT * FROM tbl_users WHERE user_email = '$email' AND user_otp = '$otp'";
$result = $conn->query($sqlverify);

if ($result->num_rows > 0) {
    $newotp = '1';
    $sqlupdate = "UPDATE tbl_users SET user_otp = '$newotp' WHERE user_email = '$email'";
    if ($conn->query($sqlupdate) === TRUE) {
        $userId = ''; // Initialize userId variable
        // Retrieve user ID from the database
        $sqlGetUserId = "SELECT user_id FROM tbl_users WHERE user_email = '$email'";
        $resultUserId = $conn->query($sqlGetUserId);
        if ($resultUserId->num_rows > 0) {
            $row = $resultUserId->fetch_assoc();
            $userId = $row['user_id'];
        }

        if ($userId != '') {
            // Insert default income categories for the user
            $sqlinsertincat = "INSERT INTO tbl_incat (incat_name, user_id) VALUES 
            ('Salary', $userId),
            ('Wages', $userId),
            ('Interest', $userId),
            ('Rental', $userId),
            ('Gifts', $userId),
            ('Awards', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertincat);

            // Insert default expense categories for the user
            $sqlinsertexcat = "INSERT INTO tbl_excat (excat_name, user_id) VALUES 
            ('Food', $userId),
            ('Rent', $userId),
            ('Bills', $userId),
            ('Transportation', $userId),
            ('Entertainment', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertexcat);

            // Insert default account for the user
            $sqlinsertaccount = "INSERT INTO tbl_account (account_name, user_id) VALUES 
            ('Cash', $userId),
            ('Bank Account', $userId),
            ('E-wallet', $userId),
            ('Other', $userId)";
            $conn->query($sqlinsertaccount);

            echo "success";
        } else {
            echo "failed";
        }
    } else {
        echo "failed";
    }
} else {
    echo "failed";
}
$conn->close();
?>
