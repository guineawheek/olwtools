#!/usr/bin/perl -w   #coding: utf-8

package gpip ;

use strict ;
require Exporter ;
use vars qw(@EXPORT_OK) ;
@EXPORT_OK = qw ($gladexml) ;
use vars qw($gladexml) ;

use Gtk2 '-init' ;
use Gtk2::GladeXML ;

# Chargement de l'interface
$gladexml = Gtk2::GladeXML->new('gpip.glade') ;

# On initialise les variables du module rappels
rappels::init () ;
$gladexml->signal_autoconnect_from_package('rappels') ;

1 ;

# ------------------------------------------------------------

package rappels ;

use strict ;
use vars qw($gladexml) ;


sub init {
    $gladexml = $gpip::gladexml ;
    our $namecombo = $gladexml->get_widget('comboboxName') ;
        $namecombo->set_active(1) ;
    our $dhcpcheck = $gladexml->get_widget('checkbuttondhcp') ;
    our $addressbox = $gladexml->get_widget('entryAddress') ;
    our $gatewaybox = $gladexml->get_widget('entryGateway') ;
    our $broadcastbox = $gladexml->get_widget('entryBroadcast') ;
}

sub on_window1_destroy {
    Gtk2->main_quit ;
}

sub on_buttonQuit_clicked {
    Gtk2->main_quit ;
}

sub on_checkbuttondhcp_toggled {
        
    if ($rappels::dhcpcheck->get_active == 1) {
        $rappels::addressbox->set_sensitive(0) ;
        $rappels::gatewaybox->set_sensitive(0) ;
        $rappels::broadcastbox->set_sensitive(0) ;
    }
    else {
        $rappels::addressbox->set_sensitive(1) ;
        $rappels::gatewaybox->set_sensitive(1) ;
        $rappels::broadcastbox->set_sensitive(1) ;
    }
}

sub on_buttonApply_clicked {
    if ($rappels::dhcpcheck->get_active == 1) {
        my $name = $rappels::namecombo->get_active_text ;
        system("sudo dhcpcd -n $name") ;
    }
    else {
        my $args = "" ;
        my $name = $rappels::namecombo->get_active_text ;
        my $ip = $rappels::addressbox->get_text ;
        my $broadcast = $rappels::broadcastbox->get_text ;
        
        if ($ip =~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) { $args .= "$ip/24"; }
        if ($broadcast =~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) { $args .= " broadcast $broadcast"; }
        system ("sudo ip addr $args dev $name") ;
        
        # routing
        my $gateway = $rappels::gatewaybox->get_text ;
        if ($gateway =~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) {
           system ("ip route add default via $gateway dev $name") ;
        }
    }
    
    my $command = 'ifconfig eth1 | sed -rn "s/^.*inet addr:([^ ]+).*$/\1/p"' ;
    my $realip = `$command` ;
    my $result = "IP : $realip\n" ;
    $result .= `ip route` ;
    my $popup = Gtk2::MessageDialog->new (undef, 'modal', 'info', 'ok', $result) ;
    $popup->run ;
    $popup->destroy ;
}

1 ;