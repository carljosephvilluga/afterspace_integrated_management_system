<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('POST');
aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$body = aims_body();
$userEmail = strtolower(aims_require_field($body, 'userEmail'));
$spaceUsed = aims_space_label(aims_str($body['spaceUsed'] ?? 'Open Space'));
$checkInAt = aims_str($body['checkInAt'] ?? '');

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

if ($activeSession) {
    aims_ok([
        'sessionId' => aims_int($activeSession['session_id'] ?? 0),
        'userId' => $userId,
        'status' => 'active',
        'checkInAt' => aims_str($activeSession['check_in'] ?? ''),
        'alreadyActive' => true,
    ]);
}

$pdo->beginTransaction();
try {
    $checkInTime = $checkInAt === ''
        ? (new DateTimeImmutable('now'))
        : aims_parse_datetime($checkInAt, 'checkInAt');

    $sessionId = aims_insert_returning_id(
        $pdo,
        <<<SQL
INSERT INTO sessions (user_id, check_in, check_out, status)
VALUES (:user_id, :check_in, NULL, 'Active')
SQL,
        [
        ':user_id' => $userId,
        ':check_in' => $checkInTime->format('Y-m-d H:i:s'),
        ],
        'session_id'
    );

    $insertMeta = $pdo->prepare(
        <<<SQL
INSERT INTO session_meta (session_id, space_used)
VALUES (:session_id, :space_used)
SQL
    );
    $insertMeta->execute([
        ':session_id' => $sessionId,
        ':space_used' => $spaceUsed,
    ]);

    $pdo->prepare(
        "UPDATE users SET status = 'Active' WHERE user_id = :user_id"
    )->execute([':user_id' => $userId]);

    append_user_history($pdo, $userId, 'User checked in');

    $pdo->commit();

    aims_ok([
        'sessionId' => $sessionId,
        'userId' => $userId,
        'status' => 'active',
        'checkInAt' => $checkInTime->format('Y-m-d H:i:s'),
        'alreadyActive' => false,
    ]);
} catch (Throwable $error) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    aims_error(500, 'Failed to check in user.');
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
