#!/usr/bin/env perl

# VolWheel - set the volume with your mousewheel
# Author : Olivier Duclos <oliwer@free.fr>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Gtk2 '-init';
use Gtk2::TrayIcon;
use vars qw/$channel $mixer $tooltip/;

our $APPNAME = "VolWheel";
our $VERSION = "0.2"; # 2007.11.12

# M A I N #

($channel, $mixer) = &get_conf;

# Tray icon
my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file("/usr/share/icons/gnome/24x24/apps/multimedia-volume-control.png");
my $icon = Gtk2::Image->new_from_pixbuf($pixbuf);
my $trayicon = Gtk2::TrayIcon->new("volwheel");
$tooltip= Gtk2::Tooltips->new;
&update_tooltip;
my $eventbox = Gtk2::EventBox->new;
$eventbox->add($icon);
$trayicon->add($eventbox);
$eventbox->signal_connect( 'button_release_event', \&click_handler );
$eventbox->signal_connect( 'scroll_event', \&scroll_handler );
$trayicon->show_all;

Gtk2->main;





# S U B S #

sub volup {
	system "amixer set $channel 3%+ > /dev/null";
	&update_tooltip;
}

sub voldown {
	system "amixer set $channel 3%- > /dev/null";
	&update_tooltip;
}

sub mute {
	if (`amixer get $channel | grep '\[on\]'` eq "") {
		system "amixer set $channel unmute";
	}
	else {
		system "amixer set $channel mute";
	}
	&update_tooltip;
}

sub launchMixer {
	exec $mixer unless fork;
}

sub click_handler {
	my ($check, $event) = @_;
	
	if (1 eq $event->button) {
		&launchMixer;
	}
	else {
		if (3 eq $event->button) {
			&popup;
		}
		else {
			&mute;
		}
	}
}

sub scroll_handler {
	my ($check, $event) = @_;
	
	if ("up" eq $event->direction) {
		&volup;
	}
	else {
		&voldown;
	}
}

sub popup {
	my $item_factory = Gtk2::ItemFactory->new("Gtk2::Menu", '<main>', undef);
	my $popup_menu = $item_factory->get_widget('<main>');
	my @menu_items = (
			   { path => '/About',    item_type => '<Item>', callback => \&about_dialog},
			   { path => '/Settings', item_type => '<Item>', callback => \&config_dialog},
			   { path => '/Exit',     item_type => '<Item>', callback => \&out}
			 );

	$item_factory->create_items(undef, @menu_items);
	$popup_menu->show_all;
	$popup_menu->popup(undef, undef, undef, undef, 0, 0);
}

sub get_conf {
	my $chan = "PCM";
	my $mix = "xterm -e 'alsamixer'";
	if (-w "$ENV{HOME}/.config/volwheel") {
		open (CONFIG, "$ENV{HOME}/.config/volwheel") or die "Error : cannot open existing config file.";
		my @config = <CONFIG>;
		$chan = $config[0] or print "Incorrect config file. Removing it. Please restart $APPNAME.\n" &&
					unlink "$ENV{HOME}/.config/volwheel";
		$mix = $config[1] or print "Incorrect config file. Removing it. Please restart $APPNAME.\n" &&
					unlink "$ENV{HOME}/.config/volwheel";
		chomp($chan);
		chomp($mix);
		close CONFIG;
	}
	else {
		# autodetect the mixer
		if (-x "/usr/bin/gnome-alsamixer") { $mix = "gnome-alsamixer"; }
		if (-x "/usr/bin/xfce4-mixer") { $mix = "xfce4-mixer"; }
	}
	
	return ($chan, $mix);
}

sub save_config {
	open (CONFIG, ">$ENV{HOME}/.config/volwheel") or die "Error : Cannot open configuration file";
	print CONFIG "$channel\n$mixer\n";
	close CONFIG;
}

sub config_dialog {
	my $winconf = Gtk2::Window->new('toplevel');
	$winconf->set_title("$APPNAME Settings");
	$winconf->set_border_width(10);
	$winconf->set_position('center');
	$winconf->set_destroy_with_parent(0);
	
	my $vbox = Gtk2::VBox->new(1, 5);
	
	my $hbox1 = Gtk2::HBox->new(0, 2);
	my $lbl_channel = Gtk2::Label->new("Default channel : ");
	my $entry_channel = Gtk2::Entry->new;
	$entry_channel->set_text($channel);
	$lbl_channel->show;
	$entry_channel->show;
	$hbox1->pack_start($lbl_channel, 0, 0, 5);
	$hbox1->pack_end($entry_channel, 0, 0, 5);
	$hbox1->show;
	$vbox->pack_start($hbox1, 0, 0, 0);
	
	my $hbox2 = Gtk2::HBox->new(0, 2);
	my $lbl_mixer = Gtk2::Label->new("Default mixer : ");
	my $entry_mixer = Gtk2::Entry->new;
	$entry_mixer->set_text($mixer);
	$lbl_mixer->show;
	$entry_mixer->show;
	$hbox2->pack_start($lbl_mixer, 0, 0, 5);
	$hbox2->pack_end($entry_mixer, 0, 0, 5);
	$hbox2->show;
	$vbox->pack_start($hbox2, 0, 0, 0);
	
	my $hbox3 = Gtk2::HBox->new(0, 2);
	my $btn_cancel = Gtk2::Button->new_from_stock('gtk-cancel');
	$btn_cancel->signal_connect(clicked => sub { $winconf->destroy });
	my $btn_save = Gtk2::Button->new_from_stock('gtk-save');
	$btn_save->signal_connect(clicked => sub {
							$channel = $entry_channel->get_text;
							$mixer = $entry_mixer->get_text;
							&save_config;
							$winconf->destroy;
						 } );
	$btn_cancel->show;
	$btn_save->show;
	$hbox3->pack_start($btn_cancel, 0, 0, 5);
	$hbox3->pack_end($btn_save, 0, 0, 5);
	$hbox3->show;
	$vbox->pack_start($hbox3, 0, 0, 0);
	
	$vbox->show;
	$winconf->add($vbox);
	$winconf->show;
}

sub update_tooltip {
	my $level = `amixer cget name='PCM Playback Volume' | grep :`;
	$level =~ s/^.*=([0-9]*),.*$/$1/;
	chomp($level);
	my $percent = sprintf("%d%%", $level/255*100);
	if ($percent eq "0%") { $percent = "Mute" }
	$tooltip->set_tip($trayicon, "$channel : $percent");
}

sub about_dialog {
	my $about = Gtk2::AboutDialog->new;
	$about->set_program_name($APPNAME);
	$about->set_version($VERSION);
	$about->set_copyright("Copyright (c) Olivier Duclos 2007");
	$about->set_comments("Set volume with the mousewheel.");
	$about->set_website("oliwer\@free.fr");
	$about->set_logo($pixbuf);
	$about->run;
	$about->destroy;
}

sub out {
	Gtk2->main_quit;
}