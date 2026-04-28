<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('POST');
aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$body = aims_body();
$bookingId = aims_int($body['bookingId'] ?? 0);
if ($bookingId <= 0) {
    aims_error(400, 'Missing required field: bookingId.');
}

$pdo = aims_pdo();
$update = $pdo->prepare(
    "UPDATE bookings SET status = 'Cancelled' WHERE booking_id = :booking_id"
);
$update->execute([':booking_id' => $bookingId]);

if ($update->rowCount() < 1) {
    aims_error(404, 'Booking not found.');
}

aims_ok([
    'bookingId' => $bookingId,
    'status' => 'cancelled',
]);
