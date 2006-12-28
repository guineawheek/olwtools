#!/usr/bin/perl -w   #coding: utf-8

package ghexdump ;

use strict ;
require Exporter ;
#use vars qw(@EXPORT_OK) ;
#@EXPORT_OK = qw ($gladexml) ;
use vars qw($gladexml) ;

use Gtk2 '-init' ;
use Gtk2::GladeXML ;

# Chargement de l'interface
$gladexml = Gtk2::GladeXML->new('ghexdump.glade') ;

# On initialise les variables du module rappels
rappels::init () ;

# On connecte les fonctions de rappels de l’arbre xml
# à leurs définitions qui sont contenues dans le module rappels
$gladexml->signal_autoconnect_from_package('rappels') ;

1 ;

# ------------------------------------------------------------

package rappels ;

use strict ;
use vars qw($gladexml) ;

# main vars
our $filename ;
our $buffer = Gtk2::TextBuffer->new ;
our $cache ;

# widgets import
our $textbox = $gladexml->get_widget('textview1') ;
our $fs_box = $gladexml->get_widget('filechooserdialog1') ;
our $save_box = $gladexml->get_widget('filechooserdialog2');

# textview font
my $font_desc = Gtk2::Pango::FontDescription->from_string("Monospace 10") ;
$textbox->modify_font($font_desc) ;

sub init {
    $gladexml = $ghexdump::gladexml ;
}

sub on_window1_destroy {
    Gtk2->main_quit ;
}

sub on_ouvrir1_activate {
    $fs_box->show;
}

sub on_enregistrer1_activate {
    # todo
}

sub on_enregistrer_sous1_activate {
    $save_box->show;
}

sub on_quitter1_activate {
    Gtk2->main_quit ;
}

# ----------------------

sub on_onebyte_octal1_activate {
    $cache = &file_hex_open($filename, "-b") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_onebyte_character1_activate {
    $cache = &file_hex_open($filename, "-c") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_twobyte_decimal1_activate {
    $cache = &file_hex_open($filename, "-d") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_twobyte_octal1_activate {
    $cache = &file_hex_open($filename, "-o") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_twobyte_hexa1_activate {
    $cache = &file_hex_open($filename, "-x") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_hexaascii1_activate {
    $cache = &file_hex_open($filename, "-C") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_characteroctal1_activate {
    $cache = &file_hex_open($filename, "-c -b") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_characterdecimal1_activate {
    $cache = &file_hex_open($filename, "-c -d") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

sub on_characterhexa1_activate {
    $cache = &file_hex_open($filename, "-c -x") ;
     $buffer->set_text($cache) ;
     &update_gtk_textview ;
}

# -------------------------

sub on_A_propos1_activate {
    my $about_box = $gladexml->get_widget('aboutdialog1') ;
     $about_box->show ;
}

# -------------------------

sub on_btn_abort_fs_clicked {
    $fs_box->hide;
}

sub on_btn_open_file_clicked {
    $filename = "" ;
     $filename = $fs_box->get_filename ;
     if ($filename ne "") {
        $fs_box->hide ;
        $cache = &file_hex_open($filename) ;
        $buffer->set_text($cache) ;
        &update_gtk_textview ;
    }
}

# ---------------------------

sub on_button_abort_save_clicked {
    $save_box->hide;
}

sub on_button_dosave_clicked {
    $filename = "";
    $filename = $save_box->get_filename;
    if ($filename ne "") {
       #test if overwrite
       my $start; my $end;
       ($start, $end) = $buffer->get_bounds;
       my $text = $buffer->get_text($start, $end, 0);
       #save the file
       $save_box->hide;
    }
 }


# -------------------------------------------
#                    SUBS
# -------------------------------------------

########################################
### file_hex_open($filename, [arg1])
sub file_hex_open {
    my $file = $_[0] ;
     my $arg ;
     if (defined($_[1])) {
          $arg = $_[1] ;
    }
     else {
         $arg = '-C' ;
    }

     if ($file eq "") { die "E: file_hex_open: no file specified !\n" }

     my $content = `hexdump $arg -v "$file" >&1` ;
     return $content ;
}

######################################
### update_gtk_textview($buffer)
sub update_gtk_textview {
    #$textbox->set_buffer("") ;
     $textbox->set_buffer($buffer) ;
}

1 ;
