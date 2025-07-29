
<?php
include 'db.php';

$servo1 = isset($_POST['servo1']) ? intval($_POST['servo1']) : 90;
$servo2 = isset($_POST['servo2']) ? intval($_POST['servo2']) : 90;
$servo3 = isset($_POST['servo3']) ? intval($_POST['servo3']) : 90;
$servo4 = isset($_POST['servo4']) ? intval($_POST['servo4']) : 90;

$conn->query("UPDATE run SET status = 0");

$stmt = $conn->prepare("INSERT INTO run (servo1, servo2, servo3, servo4, status) VALUES (?, ?, ?, ?, 1)");
$stmt->bind_param("iiii", $servo1, $servo2, $servo3, $servo4);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Run pose saved']);
} else {
    echo json_encode(['success' => false, 'error' => $conn->error]);
}

$stmt->close();
$conn->close();
?>


