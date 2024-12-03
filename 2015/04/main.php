<?php

$key = "yzbqklnj";

//$prefix = "00000"; // part 1
$prefix = "000000"; // part 2

for ($i = 0; !str_starts_with(md5("$key$i"), $prefix); ++$i) { }

echo "$i\n";
