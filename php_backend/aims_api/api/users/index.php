<?php

require __DIR__ . '/../../lib/bootstrap.php';

aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$method = strtoupper($_SERVER['REQUEST_METHOD']);
if ($method === 'GET') {
    handle_get_users();
}
if ($method === 'POST') {
    handle_create_user();
}
if ($method === 'PATCH') {
    handle_update_user();
}
if ($method === 'DELETE') {
    handle_delete_user();
}
aims_error(405, 'Method not allowed.');

function handle_get_users(): void
{
    $pdo = aims_pdo();
    $sql = <<<SQL
SELECT
    u.user_id,
    u.full_name,
    u.contact_number,
    u.email,
    u.status,
    u.created_at,
    COALESCE(up.first_name, SUBSTRING_INDEX(u.full_name, ' ', 1)) AS first_name,
    COALESCE(up.last_name, TRIM(SUBSTRING(u.full_name, LENGTH(SUBSTRING_INDEX(u.full_name, ' ', 1)) + 1))) AS last_name,
    COALESCE(up.user_type, 'Student') AS user_type,
    COALESCE(up.membership_type, 'Open Time') AS membership_type,
    COALESCE(up.history_json, '[]') AS history_json
FROM users u
LEFT JOIN user_profiles up ON up.user_id = u.user_id
ORDER BY u.user_id DESC
SQL;

    $rows = $pdo->query($sql)->fetchAll() ?: [];
    $users = array_map('to_user_payload', $rows);
    aims_ok(['users' => $users]);
}

function handle_create_user(): void
{
    $body = aims_body();
    $firstName = aims_require_field($body, 'firstName');
    $lastName = aims_require_field($body, 'lastName');
    $email = strtolower(aims_require_field($body, 'email'));
    $phoneNumber = aims_require_field($body, 'phoneNumber');
    $userType = normalize_user_type(aims_str($body['userType'] ?? 'Student'));
    $membershipType = normalize_membership_type(aims_str($body['membershipType'] ?? 'Open Time'));
    $isActive = bool_from_body($body['isActive'] ?? false);
    $status = $isActive ? 'Active' : 'Inactive';

    $fullName = trim("{$firstName} {$lastName}");
    $history = [history_label('User added')];

    $pdo = aims_pdo();
    $pdo->beginTransaction();
    try {
        $insertUser = $pdo->prepare(
            <<<SQL
INSERT INTO users (full_name, contact_number, email, status)
VALUES (:full_name, :contact_number, :email, :status)
SQL
        );
        $insertUser->execute([
            ':full_name' => $fullName,
            ':contact_number' => $phoneNumber,
            ':email' => $email,
            ':status' => $status,
        ]);
        $userId = aims_int($pdo->lastInsertId());

        $insertProfile = $pdo->prepare(
            <<<SQL
INSERT INTO user_profiles (
    user_id,
    first_name,
    last_name,
    user_type,
    membership_type,
    history_json
)
VALUES (
    :user_id,
    :first_name,
    :last_name,
    :user_type,
    :membership_type,
    :history_json
)
SQL
        );
        $insertProfile->execute([
            ':user_id' => $userId,
            ':first_name' => $firstName,
            ':last_name' => $lastName,
            ':user_type' => $userType,
            ':membership_type' => $membershipType,
            ':history_json' => json_encode($history),
        ]);

        upsert_membership($pdo, $userId, $membershipType);
        $pdo->commit();
    } catch (PDOException $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        if ($error->getCode() === '23000') {
            aims_error(409, 'Email already exists.');
        }
        aims_error(500, 'Failed to create user.');
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        aims_error(500, 'Failed to create user.');
    }

    aims_ok(['user' => fetch_user_payload($userId)]);
}

function handle_update_user(): void
{
    $body = aims_body();
    $userId = aims_int($body['userId'] ?? 0);
    if ($userId <= 0) {
        aims_error(400, 'Missing required field: userId.');
    }

    $firstName = aims_require_field($body, 'firstName');
    $lastName = aims_require_field($body, 'lastName');
    $email = strtolower(aims_require_field($body, 'email'));
    $phoneNumber = aims_require_field($body, 'phoneNumber');
    $userType = normalize_user_type(aims_str($body['userType'] ?? 'Student'));
    $membershipType = normalize_membership_type(aims_str($body['membershipType'] ?? 'Open Time'));
    $isActive = bool_from_body($body['isActive'] ?? false);
    $status = $isActive ? 'Active' : 'Inactive';

    $existing = fetch_user_row($userId);
    $existingHistory = decode_history($existing['history_json'] ?? '[]');
    $history = [...$existingHistory, history_label('User edited')];

    $fullName = trim("{$firstName} {$lastName}");
    $pdo = aims_pdo();
    $pdo->beginTransaction();
    try {
        $updateUser = $pdo->prepare(
            <<<SQL
UPDATE users
SET full_name = :full_name,
    contact_number = :contact_number,
    email = :email,
    status = :status
WHERE user_id = :user_id
SQL
        );
        $updateUser->execute([
            ':full_name' => $fullName,
            ':contact_number' => $phoneNumber,
            ':email' => $email,
            ':status' => $status,
            ':user_id' => $userId,
        ]);

        $upsertProfile = $pdo->prepare(
            <<<SQL
INSERT INTO user_profiles (
    user_id,
    first_name,
    last_name,
    user_type,
    membership_type,
    history_json
)
VALUES (
    :user_id,
    :first_name,
    :last_name,
    :user_type,
    :membership_type,
    :history_json
)
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),
    user_type = VALUES(user_type),
    membership_type = VALUES(membership_type),
    history_json = VALUES(history_json)
SQL
        );
        $upsertProfile->execute([
            ':user_id' => $userId,
            ':first_name' => $firstName,
            ':last_name' => $lastName,
            ':user_type' => $userType,
            ':membership_type' => $membershipType,
            ':history_json' => json_encode($history),
        ]);

        upsert_membership($pdo, $userId, $membershipType);
        $pdo->commit();
    } catch (PDOException $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        if ($error->getCode() === '23000') {
            aims_error(409, 'Email already exists.');
        }
        aims_error(500, 'Failed to update user.');
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        aims_error(500, 'Failed to update user.');
    }

    aims_ok(['user' => fetch_user_payload($userId)]);
}

function handle_delete_user(): void
{
    $body = aims_body();
    $userId = aims_int($body['userId'] ?? 0);
    if ($userId <= 0) {
        aims_error(400, 'Missing required field: userId.');
    }

    $pdo = aims_pdo();
    $delete = $pdo->prepare('DELETE FROM users WHERE user_id = :user_id');
    $delete->execute([':user_id' => $userId]);

    if ($delete->rowCount() < 1) {
        aims_error(404, 'User not found.');
    }

    aims_ok(['userId' => $userId]);
}

function fetch_user_payload(int $userId): array
{
    $row = fetch_user_row($userId);
    return to_user_payload($row);
}

function fetch_user_row(int $userId): array
{
    $pdo = aims_pdo();
    $sql = <<<SQL
SELECT
    u.user_id,
    u.full_name,
    u.contact_number,
    u.email,
    u.status,
    u.created_at,
    COALESCE(up.first_name, SUBSTRING_INDEX(u.full_name, ' ', 1)) AS first_name,
    COALESCE(up.last_name, TRIM(SUBSTRING(u.full_name, LENGTH(SUBSTRING_INDEX(u.full_name, ' ', 1)) + 1))) AS last_name,
    COALESCE(up.user_type, 'Student') AS user_type,
    COALESCE(up.membership_type, 'Open Time') AS membership_type,
    COALESCE(up.history_json, '[]') AS history_json
FROM users u
LEFT JOIN user_profiles up ON up.user_id = u.user_id
WHERE u.user_id = :user_id
LIMIT 1
SQL;
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':user_id' => $userId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'User not found.');
    }
    return $row;
}

function to_user_payload(array $row): array
{
    $userId = aims_int($row['user_id'] ?? 0);
    return [
        'userId' => $userId,
        'userCode' => 'USR-' . str_pad((string) $userId, 4, '0', STR_PAD_LEFT),
        'firstName' => aims_str($row['first_name'] ?? ''),
        'lastName' => aims_str($row['last_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'phoneNumber' => aims_str($row['contact_number'] ?? ''),
        'userType' => aims_str($row['user_type'] ?? 'Student'),
        'membershipType' => aims_str($row['membership_type'] ?? 'Open Time'),
        'isActive' => strtolower(aims_str($row['status'] ?? 'inactive')) === 'active',
        'history' => decode_history($row['history_json'] ?? '[]'),
        'createdAt' => aims_str($row['created_at'] ?? ''),
    ];
}

function decode_history($value): array
{
    if (is_array($value)) {
        return array_values(array_map('aims_str', $value));
    }

    $raw = aims_str($value);
    if ($raw === '') {
        return [];
    }
    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        return [];
    }
    return array_values(array_map('aims_str', $decoded));
}

function bool_from_body($value): bool
{
    if (is_bool($value)) {
        return $value;
    }
    if (is_int($value) || is_float($value)) {
        return ((int) $value) !== 0;
    }
    $normalized = strtolower(trim((string) $value));
    return in_array($normalized, ['1', 'true', 'yes', 'on', 'active'], true);
}

function normalize_user_type(string $value): string
{
    $normalized = strtolower(trim($value));
    if ($normalized === 'professional') {
        return 'Professional';
    }
    if ($normalized === 'student') {
        return 'Student';
    }
    aims_error(400, 'userType must be Student or Professional.');
}

function normalize_membership_type(string $value): string
{
    $trimmed = trim($value);
    $allowed = ['Annual', 'Loyalty Rewards', 'Monthly Membership', 'Open Time'];
    foreach ($allowed as $allowedType) {
        if (strcasecmp($trimmed, $allowedType) === 0) {
            return $allowedType;
        }
    }
    aims_error(
        400,
        'membershipType must be Annual, Loyalty Rewards, Monthly Membership, or Open Time.'
    );
}

function history_label(string $label): string
{
    return $label . ' on ' . date('Y-m-d h:i A');
}

function upsert_membership(PDO $pdo, int $userId, string $membershipType): void
{
    $existingStmt = $pdo->prepare(
        'SELECT membership_id FROM memberships WHERE user_id = :user_id ORDER BY membership_id DESC LIMIT 1'
    );
    $existingStmt->execute([':user_id' => $userId]);
    $membershipId = $existingStmt->fetchColumn();

    if ($membershipId !== false) {
        $updateMembership = $pdo->prepare(
            'UPDATE memberships SET membership_type = :membership_type WHERE membership_id = :membership_id'
        );
        $updateMembership->execute([
            ':membership_type' => $membershipType,
            ':membership_id' => aims_int($membershipId),
        ]);
        return;
    }

    $insertMembership = $pdo->prepare(
        <<<SQL
INSERT INTO memberships (user_id, membership_type, discount_rate, start_date, end_date)
VALUES (:user_id, :membership_type, NULL, NULL, NULL)
SQL
    );
    $insertMembership->execute([
        ':user_id' => $userId,
        ':membership_type' => $membershipType,
    ]);
}
