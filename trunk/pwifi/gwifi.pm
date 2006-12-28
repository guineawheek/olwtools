#!/usr/bin/perl -w


####################################
### Corps principal du programme ###
####################################

package gwifi ;

use strict ;

require Exporter ;
use vars qw(@EXPORT_OK) ;
@EXPORT_OK = qw ($gladexml) ;
use vars qw($gladexml) ;

use Gtk2 '-init' ;
use Gtk2::GladeXML ;

# On crée l’arbre xml complet. Attention, toutes les fenêtres déclarées
# visibles dans le menu Propriétés->commun->visible, seront affichées
# quand on lancera 'Gtk2->main'.
$gladexml = Gtk2::GladeXML->new('/usr/local/share/pwifi/gwifi.glade') ;

# On initialise les variables du module rappels.
rappels::init () ;

# On connecte les fonctions de rappels de l’arbre xml
# à leurs définitions qui sont contenues dans le module rappels.
$gladexml->signal_autoconnect_from_package('rappels') ;

1 ;

################################
### Les Fonctions de rappels ###
################################

package rappels ;

use strict ;

use vars qw($gladexml) ;


sub init {
    $gladexml = $gwifi::gladexml ;

    my $combo_mode = $gladexml->get_widget('comboboxMode');
    $combo_mode->set_active(0);

    my $combo_Keymode = $gladexml->get_widget('comboboxKeymode');
    $combo_Keymode->set_active(0);

    my $combo_dhcp = $gladexml->get_widget('comboboxDhcp');
    $combo_dhcp->set_active(0);
}


sub on_window1_destroy{
    Gtk2->main_quit;
}
sub on_buttonQuit_clicked{
    Gtk2->main_quit;
}

sub on_buttonApply_clicked{
    my @infos = &get_info;
    my $command;

    if ($infos[0] eq "") {
       return;
    }

    if ($infos[1] eq "") {
       $command = "iwconfig eth2 essid $infos[0] mode $infos[2]";
    }
    else {
       $command = "iwconfig eth2 essid $infos[0] mode $infos[2] key $infos[3] $infos[1]";
    }

    if ($infos[4] eq "On") {
       $command = $command . " && dhclient eth2";
    }

    system("urxvt -e $command");
}

sub on_buttonSave_clicked {
    my @infos = &get_info;
    my $file_path = "/home/oliwer/$infos[0].sh";
    my $text;

    if ($infos[0] eq "") {
       return;
    }

    if ($infos[1] eq "") {
       $text = "sudo iwconfig eth2 essid $infos[0] mode $infos[2]\n";
    }
    else {
       $text = "sudo iwconfig eth2 essid $infos[0] mode $infos[2] key $infos[3] $infos[1]\n";
    }

    if ($infos[4] eq "On") {
       $text = $text . "sudo dhclient eth2\n";
    }

    open(FILE, "> $file_path") || die "Cannot write file.\n";
    print FILE "$text";
    close FILE;
    system("chmod +x $file_path");
}



####################################
#              Subs                #
####################################


# On reccupere toutes les informations
sub get_info {
    my @infos;  # contient toutes les infos

    my $entry_essid = $gladexml->get_widget('entryEssid');
    $infos[0] = $entry_essid->get_text;

    my $entry_key = $gladexml->get_widget('entryWepkey');
    $infos[1] = $entry_key->get_text;

    my $combo_mode = $gladexml->get_widget('comboboxMode');
    $infos[2] = $combo_mode->get_active_text;

    my $combo_keymode = $gladexml->get_widget('comboboxKeymode');
    $infos[3] = $combo_keymode->get_active_text;

    my $combo_dhcp = $gladexml->get_widget('comboboxDhcp');
    $infos[4] = $combo_dhcp->get_active_text;

    return @infos;
}

1 ;
