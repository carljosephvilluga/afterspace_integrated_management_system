<?php

return [
    'db_host' => getenv('AIMS_DB_HOST') ?: '127.0.0.1',
    'db_port' => getenv('AIMS_DB_PORT') ?: '3306',
    'db_name' => getenv('AIMS_DB_NAME') ?: 'afterspace_db',
    'db_user' => getenv('AIMS_DB_USER') ?: 'root',
    'db_pass' => getenv('AIMS_DB_PASS') ?: '',
    'token_ttl_hours' => (int) (getenv('AIMS_TOKEN_TTL_HOURS') ?: 12),
];

