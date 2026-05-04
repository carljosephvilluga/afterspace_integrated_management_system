<?php

require __DIR__ . '/../../lib/bootstrap.php';

$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin']);

$method = strtoupper($_SERVER['REQUEST_METHOD']);
if ($method === 'GET') {
    handle_get_staff_accounts();
}
if ($method === 'POST') {
    handle_create_staff_account();
}
if ($method === 'PATCH') {
    handle_update_staff_account();
}
if ($method === 'DELETE') {
    handle_delete_staff_account($currentUser);
}
aims_error(405, 'Method not allowed.');

function handle_get_staff_accounts(): void
{
    $sql = <<<SQL
SELECT
    staff_id,
    employee_id,
    full_name,
    email,
    role,
    status,
    created_at
FROM staff_accounts
ORDER BY staff_id DESC
SQL;

    $rows = aims_pdo()->query($sql)->fetchAll() ?: [];
    aims_ok(['staffAccounts' => array_map('to_staff_account_payload', $rows)]);
}

function handle_create_staff_account(): void
{
    $body = aims_body();
    $fullName = aims_require_field($body, 'fullName');
    $email = strtolower(aims_require_field($body, 'email'));
    $role = normalize_staff_role(aims_require_field($body, 'role'));
    $status = normalize_staff_status(aims_str($body['status'] ?? 'Active'));
    $password = aims_require_field($body, 'password');

    if (strlen($password) < 6) {
        aims_error(400, 'Password must be at least 6 characters.');
    }

    $pdo = aims_pdo();
    $requestedEmployeeId = strtoupper(aims_str($body['employeeId'] ?? ''));
    $employeeId = $requestedEmployeeId === ''
        ? generate_next_employee_id($pdo, $role)
        : $requestedEmployeeId;

    try {
        insert_staff_account($pdo, $employeeId, $fullName, $email, $password, $role, $status);
    } catch (PDOException $error) {
        if ($error->getCode() === '23000') {
            if (staff_email_exists($pdo, $email)) {
                aims_error(409, 'Email already exists.');
            }

            $employeeId = generate_next_employee_id($pdo, $role);
            try {
                insert_staff_account($pdo, $employeeId, $fullName, $email, $password, $role, $status);
            } catch (PDOException $retryError) {
                if ($retryError->getCode() === '23000') {
                    aims_error(409, 'Employee ID or email already exists.');
                }
                aims_error(500, 'Failed to create staff account.');
            }
        } else {
            aims_error(500, 'Failed to create staff account.');
        }
    }

    aims_ok(['staffAccount' => fetch_staff_account_payload(aims_int($pdo->lastInsertId()))]);
}

function insert_staff_account(
    PDO $pdo,
    string $employeeId,
    string $fullName,
    string $email,
    string $password,
    string $role,
    string $status
): void {
    $insert = $pdo->prepare(
        <<<SQL
INSERT INTO staff_accounts (
    employee_id,
    full_name,
    email,
    password_hash,
    role,
    status
)
VALUES (
    :employee_id,
    :full_name,
    :email,
    :password_hash,
    :role,
    :status
)
SQL
    );
    $insert->execute([
        ':employee_id' => $employeeId,
        ':full_name' => $fullName,
        ':email' => $email,
        ':password_hash' => password_hash($password, PASSWORD_DEFAULT),
        ':role' => $role,
        ':status' => $status,
    ]);
}

function handle_update_staff_account(): void
{
    $body = aims_body();
    $staffId = aims_int($body['staffId'] ?? 0);
    if ($staffId <= 0) {
        aims_error(400, 'Missing required field: staffId.');
    }

    $employeeId = strtoupper(aims_require_field($body, 'employeeId'));
    $fullName = aims_require_field($body, 'fullName');
    $email = strtolower(aims_require_field($body, 'email'));
    $role = normalize_staff_role(aims_require_field($body, 'role'));
    $status = normalize_staff_status(aims_str($body['status'] ?? 'Active'));
    $password = aims_str($body['password'] ?? '');

    if ($password !== '' && strlen($password) < 6) {
        aims_error(400, 'Password must be at least 6 characters.');
    }

    $pdo = aims_pdo();
    try {
        if ($password === '') {
            $update = $pdo->prepare(
                <<<SQL
UPDATE staff_accounts
SET employee_id = :employee_id,
    full_name = :full_name,
    email = :email,
    role = :role,
    status = :status
WHERE staff_id = :staff_id
SQL
            );
            $update->execute([
                ':employee_id' => $employeeId,
                ':full_name' => $fullName,
                ':email' => $email,
                ':role' => $role,
                ':status' => $status,
                ':staff_id' => $staffId,
            ]);
        } else {
            $update = $pdo->prepare(
                <<<SQL
UPDATE staff_accounts
SET employee_id = :employee_id,
    full_name = :full_name,
    email = :email,
    password_hash = :password_hash,
    role = :role,
    status = :status
WHERE staff_id = :staff_id
SQL
            );
            $update->execute([
                ':employee_id' => $employeeId,
                ':full_name' => $fullName,
                ':email' => $email,
                ':password_hash' => password_hash($password, PASSWORD_DEFAULT),
                ':role' => $role,
                ':status' => $status,
                ':staff_id' => $staffId,
            ]);
        }
    } catch (PDOException $error) {
        if ($error->getCode() === '23000') {
            aims_error(409, 'Employee ID or email already exists.');
        }
        aims_error(500, 'Failed to update staff account.');
    }

    if ($update->rowCount() < 1) {
        fetch_staff_account_row($staffId);
    }

    aims_ok(['staffAccount' => fetch_staff_account_payload($staffId)]);
}

function handle_delete_staff_account(array $currentUser): void
{
    $body = aims_body();
    $staffId = aims_int($body['staffId'] ?? 0);
    if ($staffId <= 0) {
        aims_error(400, 'Missing required field: staffId.');
    }
    if ($staffId === aims_int($currentUser['staff_id'] ?? 0)) {
        aims_error(400, 'You cannot delete your own account while logged in.');
    }

    $delete = aims_pdo()->prepare('DELETE FROM staff_accounts WHERE staff_id = :staff_id');
    $delete->execute([':staff_id' => $staffId]);

    if ($delete->rowCount() < 1) {
        aims_error(404, 'Staff account not found.');
    }

    aims_ok(['staffId' => $staffId]);
}

function fetch_staff_account_payload(int $staffId): array
{
    return to_staff_account_payload(fetch_staff_account_row($staffId));
}

function fetch_staff_account_row(int $staffId): array
{
    $stmt = aims_pdo()->prepare(
        <<<SQL
SELECT
    staff_id,
    employee_id,
    full_name,
    email,
    role,
    status,
    created_at
FROM staff_accounts
WHERE staff_id = :staff_id
LIMIT 1
SQL
    );
    $stmt->execute([':staff_id' => $staffId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'Staff account not found.');
    }
    return $row;
}

function staff_email_exists(PDO $pdo, string $email): bool
{
    $stmt = $pdo->prepare('SELECT 1 FROM staff_accounts WHERE LOWER(email) = :email LIMIT 1');
    $stmt->execute([':email' => strtolower($email)]);
    return $stmt->fetchColumn() !== false;
}

function generate_next_employee_id(PDO $pdo, string $role): string
{
    $prefix = staff_role_prefix($role);
    $stmt = $pdo->prepare(
        'SELECT employee_id FROM staff_accounts WHERE employee_id LIKE :prefix_like'
    );
    $stmt->execute([':prefix_like' => $prefix . '-%']);

    $highest = 0;
    while (($employeeId = $stmt->fetchColumn()) !== false) {
        $pattern = '/^' . preg_quote($prefix, '/') . '-(\d+)$/';
        if (preg_match($pattern, strtoupper((string) $employeeId), $matches) !== 1) {
            continue;
        }
        $value = (int) $matches[1];
        if ($value > $highest) {
            $highest = $value;
        }
    }

    return $prefix . '-' . str_pad((string) ($highest + 1), 3, '0', STR_PAD_LEFT);
}

function staff_role_prefix(string $role): string
{
    $normalized = strtolower(trim($role));
    if ($normalized === 'admin') {
        return 'ADMIN';
    }
    if ($normalized === 'manager') {
        return 'MGR';
    }
    return 'STF';
}

function to_staff_account_payload(array $row): array
{
    return [
        'staffId' => aims_int($row['staff_id'] ?? 0),
        'employeeId' => aims_str($row['employee_id'] ?? ''),
        'fullName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'role' => normalize_staff_role(aims_str($row['role'] ?? 'Staff')),
        'status' => normalize_staff_status(aims_str($row['status'] ?? 'Active')),
        'createdAt' => aims_str($row['created_at'] ?? ''),
    ];
}

function normalize_staff_role(string $value): string
{
    $normalized = strtolower(trim($value));
    if ($normalized === 'admin') {
        return 'Admin';
    }
    if ($normalized === 'manager') {
        return 'Manager';
    }
    if ($normalized === 'staff') {
        return 'Staff';
    }
    aims_error(400, 'Role must be Admin, Manager, or Staff.');
}

function normalize_staff_status(string $value): string
{
    $normalized = strtolower(trim($value));
    if ($normalized === 'active' || $normalized === 'on duty') {
        return 'Active';
    }
    if ($normalized === 'inactive' || $normalized === 'off duty') {
        return 'Inactive';
    }
    aims_error(400, 'Status must be Active or Inactive.');
}
