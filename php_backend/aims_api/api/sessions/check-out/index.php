<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('POST');
aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$body = aims_body();
$userEmail = strtolower(aims_require_field($body, 'userEmail'));
$amount = aims_float($body['amount'] ?? 0);
$discountApplied = aims_float($body['discountApplied'] ?? 0);
$paymentMethod = aims_str($body['paymentMethod'] ?? 'cash');
if ($paymentMethod === '') {
    $paymentMethod = 'cash';
}
$paymentStatus = strtolower(aims_str($body['paymentStatus'] ?? 'paid'));
if (!in_array($paymentStatus, ['paid', 'pending', 'failed'], true)) {
    aims_error(400, 'paymentStatus must be paid, pending, or failed.');
}

$amount = max(0, $amount);
$discountApplied = max(0, $discountApplied);
$finalAmount = max(0, $amount - $discountApplied);

$pdo = aims_pdo();
$userStmt = $pdo->prepare(
    'SELECT user_id, full_name, email FROM users WHERE LOWER(email) = :email LIMIT 1'
);
$userStmt->execute([':email' => $userEmail]);
$user = $userStmt->fetch();

if (!$user) {
    aims_error(404, 'User account not found for this email.');
}

$userId = aims_int($user['user_id'] ?? 0);
$activeSessionStmt = $pdo->prepare(
    <<<SQL
SELECT session_id, check_in
FROM sessions
WHERE user_id = :user_id
  AND LOWER(status) = 'active'
ORDER BY session_id DESC
LIMIT 1
SQL
);
$activeSessionStmt->execute([':user_id' => $userId]);
$activeSession = $activeSessionStmt->fetch();

if (!$activeSession) {
    aims_error(409, 'No active session found for this user.');
}

$sessionId = aims_int($activeSession['session_id'] ?? 0);

$pdo->beginTransaction();
try {
    $checkOutTime = new DateTimeImmutable('now');

    $updateSession = $pdo->prepare(
        <<<SQL
UPDATE sessions
SET check_out = :check_out, status = 'Completed'
WHERE session_id = :session_id
SQL
    );
    $updateSession->execute([
        ':check_out' => $checkOutTime->format('Y-m-d H:i:s'),
        ':session_id' => $sessionId,
    ]);

    $transactionId = aims_insert_returning_id(
        $pdo,
        <<<SQL
INSERT INTO transactions (
    user_id,
    session_id,
    amount,
    discount_applied,
    final_amount,
    payment_method,
    status
)
VALUES (
    :user_id,
    :session_id,
    :amount,
    :discount_applied,
    :final_amount,
    :payment_method,
    :status
)
SQL,
        [
        ':user_id' => $userId,
        ':session_id' => $sessionId,
        ':amount' => $amount,
        ':discount_applied' => $discountApplied,
        ':final_amount' => $finalAmount,
        ':payment_method' => $paymentMethod,
        ':status' => $paymentStatus,
        ],
        'transaction_id'
    );

    $remainingActiveStmt = $pdo->prepare(
        "SELECT COUNT(*) FROM sessions WHERE user_id = :user_id AND LOWER(status) = 'active'"
    );
    $remainingActiveStmt->execute([':user_id' => $userId]);
    $remainingActive = aims_int($remainingActiveStmt->fetchColumn());

    if ($remainingActive === 0) {
        $pdo->prepare(
            "UPDATE users SET status = 'Inactive' WHERE user_id = :user_id"
        )->execute([':user_id' => $userId]);
    }

    append_user_history($pdo, $userId, 'User checked out & paid');

    $pdo->commit();

    aims_ok([
        'transactionId' => $transactionId,
        'sessionId' => $sessionId,
        'userId' => $userId,
        'amount' => $amount,
        'discountApplied' => $discountApplied,
        'finalAmount' => $finalAmount,
        'paymentMethod' => $paymentMethod,
        'paymentStatus' => $paymentStatus,
        'checkOutAt' => $checkOutTime->format('Y-m-d H:i:s'),
    ]);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    aims_error(500, 'Failed to check out user.');
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
