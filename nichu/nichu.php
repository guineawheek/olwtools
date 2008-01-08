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


require ("config.php");

function createThumb ($filename) {

	global $width, $height, $dest_x, $dest_y;
	
	if ($width <= STD_X && $height <= STD_Y) {
		// We don't need to rezise the image because it is very small
		copy (IMG_DIR.$filename, THUMB_DIR."th_".$filename);
		$dest_x = $width;
		$dest_y = $height;
	}
	else {
		if ($width >= $height) {
			$dest_x = STD_X;
			$dest_y = round($height * (STD_Y / $width), 0);
		}
		else {
			$dest_y = STD_Y;
			$dest_x = round($width * (STD_X / $height), 0);
		}
		
		// Import orginal image
		$ext = explode (".", $filename);
		switch ($ext[1]) {
			case "jpg" :
				$original = imagecreatefromjpeg (IMG_DIR.$filename);
				break;
			case "gif" :
				$original = imagecreatefromgif (IMG_DIR.$filename);
				break;
			case "png" :
				$original = imagecreatefrompng (IMG_DIR.$filename);
				break;
			default :
				die ("Error : Could not import orginal image.");
		}
		
		// Create the thumb
		$thumb=ImageCreateTrueColor($dest_x,$dest_y);
		imagecopyresampled($thumb,$original,0,0,0,0,$dest_x,$dest_y,$width,$height);
		
		/* Add a black rectangle
		$temp = imagecreate (1, 1);
		$white = ImageColorAllocate($temp,255,255,255);
		$black = ImageColorAllocate($temp,0,0,0);
		imagefilledrectangle ($thumb, 0, $dest_y-20, $dest_x, $dest_y, $black);
		
		// Add text inside the rectangle
		$string = $width . " x " . $height;
		imagestring ($thumb, 2, 10, $dest_y-18, $string, $white);
		*/
		
		// Save it according to its extension
		switch ($ext[1]) {
			case "jpg" :
				imagejpeg ($thumb, THUMB_DIR."th_".$filename, 80);
				break;
			case "gif" :
				imagegif ($thumb, THUMB_DIR."th_".$filename);
				break;
			case "png" :
				imagepng ($thumb, THUMB_DIR."th_".$filename, 8);
				break;
			default :
				die ("Error : Could not save the thumb image. ");
		}
		imagedestroy ($thumb);
	}
	
}


function dirTest () {

	if (!is_writable(IMG_DIR)) {
		die (IMG_DIR." is not writable ! Please set correct permissions.");
	}
	
	if (!is_writable(THUMB_DIR)) {
		die (THUMB_DIR." is not writable ! Please set correct permissions.");
	}

}



// M A I N

if (empty($_FILES)) {
	header ("Location: index.php?err=ER1");
}

$orig_name = $_FILES["image_file"]["name"];
$temp_name = $_FILES["image_file"]["tmp_name"];

// Check file type and put the extention in $match
$pattern = "/.*\.(jpg|jpeg|gif|png)$/i";
if (!preg_match ($pattern, $orig_name, $match) & empty($match)) {
	header ("Location: index.php?err=ER2");
	die();
}

// Test if directories have right permissions
dirTest();

// Upload the file
if(!move_uploaded_file($temp_name, IMG_DIR.$orig_name)) {
	header ("Location: index.php?err=ER3");
	die();
}

// Get some infos about the image
$infos = getimagesize (IMG_DIR.$orig_name);
$width = $infos[0];
$height = $infos[1];
$type = $infos[2];
$dest_x = 0;
$dest_y = 0;

// Build the new filename
$extension = image_type_to_extension($type) 
		or (unlink (IMG_DIR.$orig_name) && header ("Location: index.php?err=ER4"));
if ($extension == ".jpeg") {
	$extension = ".jpg";
}
$name = (time() . sprintf ('%02d', rand(0, 99)));
$new_name = $name . $extension;

// Rename the file
rename (IMG_DIR.$orig_name, IMG_DIR.$new_name);

// Now we make the thumb
createThumb ($new_name);

// And finaly we've got our two URLs
$img_url = "http://" . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) ."/". IMG_DIR . $new_name;
$thumb_url = "http://" . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) ."/". THUMB_DIR . "th_" . $new_name;

// Show the result
include ("view.php");

?>
