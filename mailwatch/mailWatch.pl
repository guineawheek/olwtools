#!/usr/bin/env perl

#
# mailWatch - August 2007
#

use strict;
use warnings;
use Net::POP3;
use Gtk2 '-init';
use Glib qw(TRUE FALSE);


## C O N F I G ##

my $host   = "pop.free.fr";
my $user   = "oliwer";
my $pass   = "victor";
my $time   = 60000; #milliseconds
my $client = "sylpheed";
my $sound  = TRUE;
my $wavs   = "wav/";



## M A I N ##

# The mail watcher
our $previous = 0;
Glib::Timeout->add($time, \&checkMail);

# Reading the sounds catalog
opendir (SND, $wavs);
my @list = grep !/^\.\.?$/, readdir SND;
closedir (SND);
my $sndmax = (scalar(@list) + 1);

# The tray icon
my $pixread = Gtk2::Gdk::Pixbuf->new_from_file("/usr/share/icons/gnome/24x24/stock/net/stock_mail.png");
my $pixunread = Gtk2::Gdk::Pixbuf->new_from_file("/usr/share/icons/gnome/24x24/stock/net/stock_mail-unread.png");
our $trayicon = Gtk2::StatusIcon->new_from_pixbuf($pixread);
$trayicon->set_tooltip("Mail Watcher\nNo new message");
$trayicon->signal_connect( 'popup-menu' => sub { showMenu(@_); } );
$trayicon->signal_connect( 'activate' => \&launchClient );
&checkMail;
Gtk2->main;




## S U B S ##

sub checkMail {
	my $pop = Net::POP3->new($host, Timeout => 60);
	if (! $pop->login($user, $pass) > 0) {
		&connectionError();
	}
	my $ptr = $pop->list();
	my $new = scalar( keys(%$ptr) );
	print "New mails : $new\n"; #DBG
	if ($new > $previous) {
		my $last = $pop->last() + 1;
		print "Last : $last\n"; #DBG
		my $ptr = $pop->top($last);
		my $head = join("",@$ptr);
		$head =~ s/^From:\s+(.*)/$1/im;
		my $sender = $1;
		$head =~ s/^Subject:\s+(.*)/$1/im;
		my $subj = $1;
		&updateIcon($sender, $subj);
		&soundAlert();
	}
	if ($new == 0) {
		$trayicon->set_tooltip("Mail Watcher\nNo new message");
		$trayicon->set_from_pixbuf($pixread);
	}
	$previous = $new;
	$pop->quit();
	return TRUE;
}

sub updateIcon {
	my ($from, $subj) = @_;
	$trayicon->set_tooltip("You have a new mail______________________\nFrom: $from\nSubject: $subj");
	$trayicon->set_from_pixbuf($pixunread);
}

sub soundAlert {
	if ($sound) {
		my $z = int(rand($sndmax));
		system "aplay $wavs$list[$z] &> /dev/null &";
	}
}

sub launchClient {
	exec $client unless fork;
	$trayicon->set_from_pixbuf($pixread);
	$trayicon->set_tooltip("Mail Watcher\nNo new message");
}

sub showMenu {
	my($widget, $event, $activate_time) = @_;
	my $menu = Gtk2::Menu->new();

	my $exit_item = Gtk2::MenuItem->new('Exit');
	$exit_item->show();
	$exit_item->signal_connect('activate', \&out );

	my $about_item = Gtk2::MenuItem->new('About');
	$about_item->show();
	$about_item->signal_connect('activate', \&about_dialog );

	my $refresh_item = Gtk2::MenuItem->new('Refresh');
	$refresh_item->show();
	$refresh_item->signal_connect('activate', \&checkMail );

	my $label = undef;
	if ($sound) { $label = "Mute"; } else { $label = "Unmute"; }
	my $mute_item = Gtk2::MenuItem->new($label);
	$mute_item->show();
	$mute_item->signal_connect('activate', \&muteSound );

	$menu->append($about_item);
	$menu->append($mute_item);
	$menu->append($refresh_item);
	$menu->append($exit_item);
	$menu->show_all();
	$menu->popup(undef,
			undef,
			sub { return Gtk2::StatusIcon::position_menu($menu, 0, 0, $trayicon); },
			$widget,
			$event,
			$activate_time );

}

sub muteSound {
	if ($sound == TRUE) {
		$sound = FALSE;
	}
	else {
		$sound = TRUE;
	}
}

sub connectionError {
	#http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/Dialog.html
}

sub about_dialog {
	my $about = Gtk2::AboutDialog->new;
	$about->set_program_name("Mail Watcher");
	$about->set_version(0.0.0.0.0.0.0.0.1);
	$about->set_copyright("Copyright (c) Olivier Duclos 2007");
	$about->set_comments("Keep and ear on your incoming mail.");
	$about->set_website("http://oliwer.net");
	$about->set_logo($pixread);
	$about->run;
	$about->destroy;
}

sub out {
	Gtk2->main_quit;
}
