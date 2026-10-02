<?php

declare(strict_types=1);

$rootFolder = getenv('RENAME_ROOT') ?: '/data';

$books = [
    '1946 Jihočeský kalendář' => ['start' => 1, 'oddNumbers' => true],
    '1947 JČ v boji x okupantům' => ['start' => 3, 'oddNumbers' => true],
    '2023 Umění neúspěchu' => ['start' => 1, 'oddNumbers' => true],
    '2026 ČS-letci 1938-1945' => ['start' => 1, 'oddNumbers' => true],
    'Knížky z Wisconsinu/1989 Town of Emery' => ['start' => 0, 'oddNumbers' => true],
    'Knížky z Wisconsinu/1991 Phillips CS-Community' => ['start' => 1, 'oddNumbers' => true],
    'Knížky z Wisconsinu/1992 Directory of the Koci family' => ['start' => 0, 'oddNumbers' => true],
    'Knížky z Wisconsinu/2000 A True Life Story' => ['start' => 1, 'oddNumbers' => true],
    'Knížky z Wisconsinu/2002 Stories of the Koci Family' => ['start' => 2, 'oddNumbers' => true],
    'Knížky z Wisconsinu/2003 Cranberry Cookbook' => ['start' => 1, 'oddNumbers' => true],
];

if ($argc < 2) {
    echo "Použití: php rename.php <název_knihy> [--dry-run]\n\n";
    echo "Dostupné knihy:\n";
    foreach (array_keys($books) as $i => $name) {
        echo "  " . ($i + 1) . ". $name\n";
    }
    echo "\n  --dry-run  Pouze zobrazí co by se přejmenovalo, nic nepřejmenuje\n";
    exit(0);
}

$dryRun = in_array('--dry-run', $argv);
$bookArg = $argv[1];

if (is_numeric($bookArg)) {
    $keys = array_keys($books);
    $index = (int)$bookArg - 1;
    if (!isset($keys[$index])) {
        echo "Neplatné číslo knihy.\n";
        exit(1);
    }
    $bookName = $keys[$index];
} else {
    $bookName = $bookArg;
}

if (!isset($books[$bookName])) {
    echo "Kniha '$bookName' nenalezena.\n";
    exit(1);
}

$config = $books[$bookName];
$path = $rootFolder . '/' . $bookName;

if (!is_dir($path)) {
    echo "Složka neexistuje: $path\n";
    exit(1);
}

$allFiles = array_diff(scandir($path), ['.', '..', 'Nechat být']);
$files = array_values($allFiles);

$firstFile = null;
$fileNaming = null;
foreach ($files as $file) {
    if (!str_starts_with($file, 'Scan_') && !str_starts_with($file, 'doc0')) {
        $firstFile = $file;
        $fileNaming = preg_replace('/\s*[-\s]*\d+\.jpg$/', '', $file);
        break;
    }
}

if ($firstFile === null) {
    echo "Nenalezen vzorový soubor v '$bookName'.\n";
    exit(1);
}

echo "Kniha: $bookName\n";
echo "Vzor pojmenování: '$fileNaming' (z '$firstFile')\n";
echo "Start: {$config['start']}, Lichá čísla: " . ($config['oddNumbers'] ? 'ano' : 'ne') . "\n";
echo "Počet souborů k přejmenování: " . (count($files) - 1) . "\n";

if ($dryRun) {
    echo "\n--- DRY RUN ---\n\n";
}

$increment = $config['oddNumbers'] ? 2 : 1;
$counter = $config['start'];
$renamed = 0;

foreach ($files as $file) {
    $pageNumber = $counter;
    $fileName = $fileNaming . ' ';

    if ($pageNumber < 10) {
        $fileName .= '0';
    }
    if ($pageNumber < 100) {
        $fileName .= '0';
    }

    $fileName .= $pageNumber . '.jpg';

    $sourcePath = $path . '/' . $file;
    $targetPath = $path . '/' . $fileName;

    if ($file === $fileName) {
        echo "  [SKIP] $file (už má správný název)\n";
        $counter += $increment;
        continue;
    }

    if ($dryRun) {
        echo "  $file  =>  $fileName\n";
    } else {
        if (file_exists($sourcePath)) {
            rename($sourcePath, $targetPath);
            echo "  [OK] $file  =>  $fileName\n";
            $renamed++;
        } else {
            echo "  [ERR] Soubor neexistuje: $file\n";
        }
    }

    $counter += $increment;
}

echo "\n" . ($dryRun ? "Simulace dokončena" : "Přejmenováno $renamed souborů") . ".\n";
