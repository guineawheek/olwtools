<?php

/*
    Nichu - Imageshack killer
    Copyright (C) 2008  Olivier Duclos <oliwer@free.fr>
    Check for updates at http://oliwer.net

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


// This is for error handling
require ("config.php");
if (!empty($_GET['err'])) {
	$err_mesg = constant ($_GET['err']) or header ("Location: index.php");
	$show_mesg = true;
}
else {
	$show_mesg = false;
}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>NICHU -  Image Hosting Service</title>
<style type="text/css">
<!--
.Style3 {font-size: 56px}
.Style4 {
	font-size: 14px;
	font-weight: bold;
}
.Style5 {
	color: #FF0000;
	font-weight: bold;
}
body {
	background-color: #FFFFCC;
}
-->
</style>
</head>

<body>
<div align="center"><span class="Style3">N I C H U</span><br />
  <span class="Style4">IMAGE HOSTING SERVICE</span><br />
</div>
<div align="center"><br />
  <br />
  <br />
  Upload Size Limit : <?php echo (ini_get('upload_max_filesize')); ?><br />
  <br />
Supported File Types : jpg, gif, png
<br />
<?php
if ($show_mesg == true) {
	echo "<br />\n<span class=\"Style5\">" . $err_mesg . "</span><br />\n";
} ?>
<br />
</div>
<form action="nichu.php" method="post" enctype="multipart/form-data">
  <div align="center">
    <input type="file" name="image_file" />
    <br />  
    <input type="submit" value="Host !" />
  </div>
</form>
</body>
</html>
