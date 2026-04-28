<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('POST');
$token = aims_bearer_token();
aims_logout_token($token);
aims_ok(['loggedOut' => true]);
