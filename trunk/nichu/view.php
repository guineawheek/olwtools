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

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>NICHU - Image Hosting Service</title>
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
  <br />
  <a href="<?php echo $img_url; ?>">
    <img src="<?php echo $thumb_url; ?>" width="<?php echo $dest_x; ?>" height="<?php echo $dest_y; ?>" border="0" /></a>
  <br />
  <br />
  <br />
  <table border="0" cellspacing="20" cellpadding="0">
    <tr>
      <td>HTML : </td>
      <td><input name="txt1" type="text" size="60" value="<?php
       $strr = ("<a href=\"$img_url\"><img src=\"$thumb_url\" width=\"$dest_x\" height=\"$dest_y\" border=\"0\" /></a>");
       echo (htmlspecialchars($strr));
       ?>" />
      <input type="submit" onclick="document.txt1.select();" value="Copy" /></td>
    </tr>
    <tr>
      <td>BBCODE :</td>
      <td><input name="txt2" type="text" size="60" value="[url=<?php echo $img_url; ?>][img]<?php echo $thumb_url; ?>[/img][/url]" />
      <input type="submit" onclick="document.txt2.select();" value="Copy" /></td>
    </tr>
    <tr>
      <td>LINK : </td>
      <td><input name="txt3" type="text" size="60" value="<?php echo $img_url; ?>" />
      <input type="submit" onclick="document.txt3.select();" value="Copy" /></td>
    </tr>
  </table>
  <br />
  <br />
  <form method="post" action="index.php">
    <input type="submit" value="Host another image" />
  </form>
  <br />
  <br />
</div>
</body>
</html>
