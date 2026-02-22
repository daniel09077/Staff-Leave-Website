<?php
/**
 * AWS Resource URL Updater
 * This script updates local resource references to AWS CloudFront/S3 URLs
 * 
 * Usage: php aws_resource_updater.php
 */

// ==================== CONFIGURATION ====================
$CDN_URL = 'https://d1ncejm8uuedb4.cloudfront.net'; // REPLACE with your CloudFront URL
$PROJECT_ROOT = __DIR__; // Directory to scan (current directory by default)
$BACKUP_ENABLED = true; // Create backups before modifying files

// File extensions to scan
$FILE_EXTENSIONS = ['php', 'html', 'htm', 'css', 'js', 'jsx'];

// Directories to exclude
$EXCLUDE_DIRS = ['vendor', 'node_modules', '.git', 'backups'];

// ==================== PATTERN DEFINITIONS ====================
$PATTERNS = [
    // HTML/PHP image tags
    [
        'pattern' => '/(<img[^>]+src=[\"\'])(\.\/)?(images?\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$3$4',
        'description' => 'HTML img tags'
    ],
    [
        'pattern' => '/(<img[^>]+src=[\"\'])(\/)(images?\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$3$4',
        'description' => 'HTML img tags with leading slash'
    ],
    
    // Assets folder (common for JS, CSS, fonts, etc.)
    [
        'pattern' => '/(<[^>]+(src|href)=[\"\'])(\.\/)?(assets\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$4$5',
        'description' => 'Assets folder references'
    ],
    [
        'pattern' => '/(<[^>]+(src|href)=[\"\'])(\/)(assets\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$4$5',
        'description' => 'Assets folder with leading slash'
    ],
    
    // CSS background images
    [
        'pattern' => '/(url\([\'"]?)(\.\/)?(images?\/[^\)\'\"]+)([\'"]?\))/i',
        'replacement' => '$1' . $CDN_URL . '/$3$4',
        'description' => 'CSS url() references'
    ],
    [
        'pattern' => '/(url\([\'"]?)(\/)(images?\/[^\)\'\"]+)([\'"]?\))/i',
        'replacement' => '$1' . $CDN_URL . '/$3$4',
        'description' => 'CSS url() with leading slash'
    ],
    
    // JavaScript
    [
        'pattern' => '/([\"\'])(\.\/)?(images?\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$3$4',
        'description' => 'JavaScript string references'
    ],
    
    // Static folder
    [
        'pattern' => '/(<[^>]+(src|href)=[\"\'])(\.\/)?(static\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$4$5',
        'description' => 'Static folder references'
    ],
    
    // Media folder
    [
        'pattern' => '/(<[^>]+(src|href)=[\"\'])(\.\/)?(media\/[^\"\']+)([\"\'])/i',
        'replacement' => '$1' . $CDN_URL . '/$4$5',
        'description' => 'Media folder references'
    ],
];

// ==================== FUNCTIONS ====================

function scanDirectory($dir, $excludeDirs = []) {
    $files = [];
    
    if (!is_dir($dir)) {
        echo "Error: Directory '$dir' does not exist.\n";
        return $files;
    }
    
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );
    
    foreach ($iterator as $file) {
        if ($file->isFile()) {
            $path = $file->getPathname();
            
            // Check if file is in excluded directory
            $excluded = false;
            foreach ($excludeDirs as $excludeDir) {
                if (strpos($path, DIRECTORY_SEPARATOR . $excludeDir . DIRECTORY_SEPARATOR) !== false) {
                    $excluded = true;
                    break;
                }
            }
            
            if (!$excluded) {
                $files[] = $path;
            }
        }
    }
    
    return $files;
}

function shouldProcessFile($file, $extensions) {
    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    return in_array($ext, $extensions);
}

function createBackup($file) {
    $backupDir = dirname($file) . DIRECTORY_SEPARATOR . 'backups';
    if (!is_dir($backupDir)) {
        mkdir($backupDir, 0755, true);
    }
    
    $backupFile = $backupDir . DIRECTORY_SEPARATOR . basename($file) . '.backup.' . date('Y-m-d_H-i-s');
    copy($file, $backupFile);
    return $backupFile;
}

function updateFile($file, $patterns, $dryRun = false) {
    $content = file_get_contents($file);
    $originalContent = $content;
    $changes = [];
    
    foreach ($patterns as $patternInfo) {
        $matches = preg_match_all($patternInfo['pattern'], $content, $allMatches);
        
        if ($matches > 0) {
            $content = preg_replace($patternInfo['pattern'], $patternInfo['replacement'], $content);
            $changes[] = [
                'description' => $patternInfo['description'],
                'count' => $matches
            ];
        }
    }
    
    if ($content !== $originalContent) {
        if (!$dryRun) {
            file_put_contents($file, $content);
        }
        return $changes;
    }
    
    return false;
}

// ==================== MAIN SCRIPT ====================

echo "╔════════════════════════════════════════════════════════╗\n";
echo "║        AWS Resource URL Updater                        ║\n";
echo "╚════════════════════════════════════════════════════════╝\n\n";

echo "Configuration:\n";
echo "  CDN URL: $CDN_URL\n";
echo "  Project Root: $PROJECT_ROOT\n";
echo "  Backup Enabled: " . ($BACKUP_ENABLED ? 'Yes' : 'No') . "\n\n";

// Confirmation
echo "⚠️  WARNING: This script will modify your files!\n";
echo "Do you want to proceed? (yes/no): ";
$handle = fopen("php://stdin", "r");
$line = fgets($handle);
fclose($handle);

if (trim(strtolower($line)) !== 'yes') {
    echo "Aborted.\n";
    exit(0);
}

echo "\n🔍 Scanning files...\n";
$files = scanDirectory($PROJECT_ROOT, $EXCLUDE_DIRS);
$processedFiles = 0;
$modifiedFiles = 0;
$totalChanges = 0;

foreach ($files as $file) {
    if (shouldProcessFile($file, $FILE_EXTENSIONS)) {
        $processedFiles++;
        
        $changes = updateFile($file, $PATTERNS, false);
        
        if ($changes) {
            if ($BACKUP_ENABLED) {
                $backupFile = createBackup($file);
                echo "📄 Backup created: $backupFile\n";
            }
            
            $modifiedFiles++;
            $relativePath = str_replace($PROJECT_ROOT, '.', $file);
            echo "✅ Modified: $relativePath\n";
            
            foreach ($changes as $change) {
                echo "   - {$change['description']}: {$change['count']} replacement(s)\n";
                $totalChanges += $change['count'];
            }
            echo "\n";
        }
    }
}

echo "\n╔════════════════════════════════════════════════════════╗\n";
echo "║                    SUMMARY                             ║\n";
echo "╚════════════════════════════════════════════════════════╝\n";
echo "Files scanned: $processedFiles\n";
echo "Files modified: $modifiedFiles\n";
echo "Total replacements: $totalChanges\n";

if ($BACKUP_ENABLED && $modifiedFiles > 0) {
    echo "\n💾 Backups stored in 'backups' folders within each directory\n";
}

echo "\n✨ Done!\n";
?>
