<?php
include 'db.php';

$result = $conn->query("SELECT * FROM Run WHERE status = 1");

if ($result && $row = $result->fetch_assoc()) {
    echo json_encode($row);
} else {
    echo json_encode(["message" => "No active run"]);
}

$conn->close();
?>