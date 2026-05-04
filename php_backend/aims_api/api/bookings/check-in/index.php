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
$pdo->beginTransaction();
try {
    $bookingStmt = $pdo->prepare(
        <<<SQL
SELECT
    b.booking_id,
    b.user_id,
    b.status,
    COALESCE(bm.space_type, 'Open Space') AS space_type
FROM bookings b
LEFT JOIN booking_meta bm ON bm.booking_id = b.booking_id
WHERE b.booking_id = :booking_id
LIMIT 1
SQL
    );
    $bookingStmt->execute([':booking_id' => $bookingId]);
    $booking = $bookingStmt->fetch();

    if (!$booking) {
        aims_error(404, 'Booking not found.');
    }

    if (strtolower((string) $booking['status']) === 'cancelled') {
        aims_error(409, 'Cancelled bookings cannot be checked in.');
    }

    $userId = aims_int($booking['user_id'] ?? 0);
    if ($userId <= 0) {
        aims_error(500, 'Booking user is invalid.');
    }

    $pdo->prepare(
        "UPDATE bookings SET status = 'Confirmed' WHERE booking_id = :booking_id"
    )->execute([':booking_id' => $bookingId]);

    $activeSessionStmt = $pdo->prepare(
        <<<SQL
SELECT session_id
FROM sessions
WHERE user_id = :user_id
  AND LOWER(status) = 'active'
ORDER BY session_id DESC
LIMIT 1
SQL
    );
    $activeSessionStmt->execute([':user_id' => $userId]);
    $existingSessionId = $activeSessionStmt->fetchColumn();

    if ($existingSessionId !== false) {
        $sessionId = aims_int($existingSessionId);
    } else {
        $sessionId = aims_insert_returning_id(
            $pdo,
            <<<SQL
INSERT INTO sessions (user_id, check_in, check_out, status)
VALUES (:user_id, CURRENT_TIMESTAMP, NULL, 'Active')
SQL,
            [':user_id' => $userId],
            'session_id'
        );
    }

    $sessionMetaUpsertClause = aims_upsert_clause('session_id', ['space_used']);
    $upsertSessionMeta = $pdo->prepare(
        <<<SQL
INSERT INTO session_meta (session_id, space_used)
VALUES (:session_id, :space_used)
{$sessionMetaUpsertClause}
SQL
    );
    $upsertSessionMeta->execute([
        ':session_id' => $sessionId,
        ':space_used' => aims_space_label((string) ($booking['space_type'] ?? 'Open Space')),
    ]);

    $pdo->prepare(
        "UPDATE users SET status = 'Active' WHERE user_id = :user_id"
    )->execute([':user_id' => $userId]);

    append_user_history($pdo, $userId, 'User checked in');

    $pdo->commit();

    aims_ok([
        'bookingId' => $bookingId,
        'sessionId' => $sessionId,
        'status' => 'checkedIn',
    ]);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    aims_error(500, 'Failed to check in booking.');
}

function append_user_history(PDO $pdo, int $userId, string $label): void
{
    $historyStmt = $pdo->prepare(
        'SELECT history_json FROM user_profiles WHERE user_id = :user_id LIMIT 1'
    );
    $historyStmt->execute([':user_id' => $userId]);
    $historyRaw = $historyStmt->fetchColumn();

    $history = [];
    if (is_string($historyRaw) && trim($historyRaw) !== '') {
        $decoded = json_decode($historyRaw, true);
        if (is_array($decoded)) {
            $history = array_values(array_map('aims_str', $decoded));
        }
    }
    $history[] = $label . ' on ' . date('Y-m-d h:i A');

    $firstNameSql = aims_first_name_sql('full_name');
    $lastNameSql = aims_last_name_sql('full_name');
    $profileUpsertClause = aims_upsert_clause('user_id', ['history_json']);
    $upsert = $pdo->prepare(
        <<<SQL
INSERT INTO user_profiles (user_id, first_name, last_name, user_type, membership_type, history_json)
VALUES (
    :user_id,
    COALESCE((SELECT {$firstNameSql} FROM users WHERE user_id = :user_id_lookup), 'User'),
    COALESCE((SELECT {$lastNameSql} FROM users WHERE user_id = :user_id_lookup2), ''),
    'Student',
    'Open Time',
    :history_json
)
{$profileUpsertClause}
SQL
    );
    $upsert->execute([
        ':user_id' => $userId,
        ':user_id_lookup' => $userId,
        ':user_id_lookup2' => $userId,
        ':history_json' => json_encode($history),
    ]);
}
