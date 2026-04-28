<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
$user = aims_current_user(true);
aims_ok($user);
