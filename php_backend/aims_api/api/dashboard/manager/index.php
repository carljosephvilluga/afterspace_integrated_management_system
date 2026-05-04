<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
aims_ensure_operational_tables();
$user = aims_current_user(true);
aims_require_roles($user, ['admin', 'manager']);

$pdo = aims_pdo();
$todaySql = aims_today_sql();
$sessionCheckInDateSql = aims_date_sql('check_in');
$transactionCreatedDateSql = aims_date_sql('created_at');

$customersToday = aims_int(
    $pdo->query(
        "SELECT COUNT(DISTINCT user_id) FROM sessions WHERE {$sessionCheckInDateSql} = {$todaySql}"
    )->fetchColumn()
);
$revenueToday = aims_float(
    $pdo->query(
        "SELECT COALESCE(SUM(final_amount), 0) FROM transactions WHERE {$transactionCreatedDateSql} = {$todaySql}"
    )->fetchColumn()
);
$reservedBookings = aims_int(
    $pdo->query("SELECT COUNT(*) FROM bookings WHERE LOWER(status) = 'pending'")->fetchColumn()
);
$completedPayments = aims_int(
    $pdo->query(
        "SELECT COUNT(*) FROM transactions WHERE LOWER(status) = 'paid' AND {$transactionCreatedDateSql} = {$todaySql}"
    )->fetchColumn()
);

$pendingReservationsStmt = $pdo->query(
    <<<SQL
SELECT
    b.booking_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    u.full_name,
    u.email,
    u.contact_number
FROM bookings b
INNER JOIN users u ON u.user_id = b.user_id
WHERE LOWER(b.status) = 'pending'
ORDER BY b.booking_date ASC, b.start_time ASC, b.booking_id ASC
LIMIT 8
SQL
);
$pendingReservations = [];
foreach ($pendingReservationsStmt->fetchAll() ?: [] as $row) {
    $pendingReservations[] = [
        'bookingId' => aims_int($row['booking_id'] ?? 0),
        'customerName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'contactDetails' => aims_str($row['email'] ?? '') !== ''
            ? aims_str($row['email'] ?? '')
            : aims_str($row['contact_number'] ?? ''),
        'startAt' => aims_str($row['booking_date'] ?? '') . ' ' . aims_str($row['start_time'] ?? ''),
        'endAt' => aims_str($row['booking_date'] ?? '') . ' ' . aims_str($row['end_time'] ?? ''),
    ];
}

$latestTransactionsStmt = $pdo->query(
    <<<SQL
SELECT
    t.transaction_id,
    t.amount,
    t.discount_applied,
    t.final_amount,
    t.payment_method,
    t.status,
    t.created_at,
    u.full_name,
    u.email
FROM transactions t
INNER JOIN users u ON u.user_id = t.user_id
ORDER BY t.created_at DESC, t.transaction_id DESC
LIMIT 10
SQL
);
$latestTransactions = [];
foreach ($latestTransactionsStmt->fetchAll() ?: [] as $row) {
    $latestTransactions[] = [
        'transactionId' => aims_int($row['transaction_id'] ?? 0),
        'customerName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'amount' => aims_float($row['amount'] ?? 0),
        'discountApplied' => aims_float($row['discount_applied'] ?? 0),
        'finalAmount' => aims_float($row['final_amount'] ?? 0),
        'paymentMethod' => aims_str($row['payment_method'] ?? 'cash'),
        'status' => aims_str($row['status'] ?? 'paid'),
        'createdAt' => aims_str($row['created_at'] ?? ''),
    ];
}

aims_ok([
    'customersToday' => $customersToday,
    'revenueToday' => $revenueToday,
    'reservedBookings' => $reservedBookings,
    'completedPayments' => $completedPayments,
    'pendingReservations' => $pendingReservations,
    'latestTransactions' => $latestTransactions,
]);
