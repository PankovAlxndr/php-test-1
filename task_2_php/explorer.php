<?php
$script_root_folder = dirname($_SERVER['PHP_SELF']) !== '/' ? dirname($_SERVER['PHP_SELF']) : ''; // запрет на выход из директории

define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'gif', 'ico', 'webp']);
define('SELF_URL', 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF']);
define('ROOT_PATH', rtrim(($_SERVER['DOCUMENT_ROOT'] . $script_root_folder), '\\/'));

if (!isset($_GET['path']))
    redirect(SELF_URL . '?path=');

$p = $_GET['path'] ?? '';
define('PATH', $p);

$path = ROOT_PATH;

if (PATH != '')
    $path .= '/' . PATH;

if (!is_dir($path))
    redirect(SELF_URL . '?path=');

$parent = get_parent_path(PATH);

$objects = is_readable($path) ? scandir($path) : array();
$folders = array();
$files = array();

if (is_array($objects)) {
    foreach ($objects as $file) {
        if ($file == '.' || $file == '..')
            continue;
        if (substr($file, 0, 1) === '.')
            continue;
        $new_path = $path . '/' . $file;
        if (is_file($new_path) && is_allowed_file($file)) {
            $files[] = $file;
        } elseif (is_dir($new_path)) {
            $folders[] = $file;
        }
    }
}
?>
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>file explorer</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet"
              integrity="sha384-GLhlTQ8iRABdZLl6O3oVMWSktQOp6b7In1Zl3/Jr59b6EGGoI1aFkw7cmDA6j6gD"
              crossorigin="anonymous">
    </head>
    <body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-sm-8 col-md-6">
                <nav aria-label="breadcrumb" class="my-3">
                    <ol class="breadcrumb">
                        <li class='breadcrumb-item'><a href='?path='>Корень</a></li>
                        <?php
                        if (PATH != '') {
                            $exploded = explode('/', PATH);
                            $breadcrumbParent = '';
                            foreach ($exploded as $index => $item) {
                                $breadcrumbParent = trim($breadcrumbParent . '/' . $item, '/');
                                echo "<li class='breadcrumb-item'><a href='?path=" . urlencode($breadcrumbParent) . "'>" . $item . "</a></li>";
                            }
                        }
                        ?>
                    </ol>
                </nav>
                <ul class="list-group shadow">
                    <?php if ($parent !== false) { ?>
                        <a href="?path=<?php echo urlencode($parent) ?>"
                           class="list-group-item list-group-item-action" aria-current="true">..назад</a>
                    <?php } ?>

                    <?php foreach ($folders as $f) { ?>
                        <a href="?path=<?php echo urlencode(trim(PATH . '/' . $f, '/')) ?>"
                           class="list-group-item list-group-item-action"><?php echo $f ?></a>
                    <?php } ?>

                    <?php foreach ($files as $f) { ?>
                        <a target="_blank" href="<?php echo urlencode(trim(PATH . '/' . $f, '/')) ?>"
                           class="list-group-item list-group-item-action"><?php echo $f ?></a>
                    <?php } ?>

                    <?php if (empty($folders) && empty($files)) { ?>
                        <li class="list-group-item">Пусто</li>
                    <?php } ?>
                </ul>
            </div>
        </div>
    </div>
    </body>
    </html>
<?php


function redirect($url, $code = 302)
{
    header('Location: ' . $url, true, $code);
    exit;
}

function get_parent_path($path)
{
    if ($path != '') {
        $array = explode('/', $path);
        if (count($array) > 1) {
            $array = array_slice($array, 0, -1);
            return implode('/', $array);
        }
        return '';
    }
    return false;
}


function is_allowed_file($file): bool
{
    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    return in_array($ext, ALLOWED_EXTENSIONS);
}