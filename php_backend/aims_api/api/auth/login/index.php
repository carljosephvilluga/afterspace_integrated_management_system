<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('POST');
$body = aims_body();

$role = aims_role_normalize(aims_require_field($body, 'role'));
$identifier = aims_str(
    $body['employeeId'] ??
    $body['staffId'] ??
    $body['managerId'] ??
    $body['adminId'] ??
    $body['email'] ??
    ''
);
$password = aims_require_field($body, 'password');

if ($identifier === '') {
    aims_error(400, 'Missing required field: employeeId/email.');
}

$sql = <<<SQL
SELECT
    staff_id,
    employee_id,
    full_name,
    email,
    password_hash,
    role,
    status,
    created_at
FROM staff_accounts
WHERE LOWER(role) = :role
  AND (LOWER(employee_id) = :identifier_employee OR LOWER(email) = :identifier_email)
LIMIT 1
SQL;

$stmt = aims_pdo()->prepare($sql);
$stmt->execute([
    ':role' => $role,
    ':identifier_employee' => strtolower($identifier),
    ':identifier_email' => strtolower($identifier),
]);
$account = $stmt->fetch();

if (!$account || strtolower((string) $account['status']) !== 'active') {
    aims_error(401, 'Invalid login credentials.');
}

$stored = (string) ($account['password_hash'] ?? '');
$verified = password_verify($password, $stored) || hash_equals($stored, $password);
if (!$verified) {
    aims_error(401, 'Invalid login credentials.');
}

$token = aims_issue_session_token((int) $account['staff_id']);
$safeAccount = aims_user_without_secret($account);

aims_ok([
    'token' => $token,
    'user' => $safeAccount,
]);
