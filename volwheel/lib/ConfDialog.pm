package ConfDialog;

# VolWheel - set the volume with your mousewheel
# Author : Olivier Duclos <olivier.duclos gmail.com>

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


sub show {

	# Globals to this sub
	my $filechooser = Gtk2::FileChooserButton->new("Choose a file", 'open');
	my $combo_theme = Gtk2::ComboBox->new_text;


	my $winconf = Gtk2::Window->new('toplevel');
	$winconf->set_title("VolWheel Settings");
	$winconf->set_border_width(10);
	$winconf->set_position('center');

	my $main_vbox = Gtk2::VBox->new(0,5);

	# FIRST TAB
	my $vbox = Gtk2::VBox->new(0,5);

	my $frame_sound = Gtk2::Frame->new("Sound");
	my $vbox1 = Gtk2::VBox->new(0, 10);

	my $hbox0 = Gtk2::HBox->new(0, 10);
	my $lbl_driver = Gtk2::Label->new("Driver");
	my $combo_driver = Gtk2::ComboBox->new_text;
		$combo_driver->set_size_request(160, 30);
		foreach (("Alsa","OSS")) {
			if ($_ eq $::opt->driver) {
				$combo_driver->prepend_text($_);
			}
			else {
				$combo_driver->append_text($_);
			}
		}
		$combo_driver->set_active(0);
		$combo_driver->signal_connect('changed' => sub {
			$::opt->driver($combo_driver->get_active_text);
			main::update_icon();
			});
	$hbox0->pack_start($lbl_driver, 0, 1, 5);
	$hbox0->pack_end($combo_driver, 0, 1, 5);
	$vbox1->pack_start($hbox0, 0, 1, 2);

	my $hbox1 = Gtk2::HBox->new(0, 2);
	my $lbl_channel = Gtk2::Label->new("Default channel");
	my $entry_channel = Gtk2::Entry->new;
	$entry_channel->set_text($::opt->channel);
	$hbox1->pack_start($lbl_channel, 0, 1, 5);
	$hbox1->pack_end($entry_channel, 0, 1, 5);
	$vbox1->pack_start($hbox1, 0, 1, 2);

	my $hbox2 = Gtk2::HBox->new(0, 2);
	my $lbl_mixer = Gtk2::Label->new("Default mixer");
	my $entry_mixer = Gtk2::Entry->new;
	$entry_mixer->set_text($::opt->mixer);
	$hbox2->pack_start($lbl_mixer, 0, 0, 5);
	$hbox2->pack_end($entry_mixer, 0, 0, 5);
	$vbox1->pack_start($hbox2, 1, 0, 2);

	my $hbox3 = Gtk2::HBox->new(0, 2);
	my $lbl_incr = Gtk2::Label->new("Volume incrementation");
	my $spin_incr = Gtk2::SpinButton->new_with_range(1, 99, 1);
	$spin_incr->set_value($::opt->increment);
	$hbox3->pack_start($lbl_incr, 0, 0, 5);
	$hbox3->pack_end($spin_incr, 0, 0, 5);
	$vbox1->pack_start($hbox3, 1, 0, 5);

	$frame_sound->add($vbox1);
	$vbox->pack_start($frame_sound, 1, 0, 5);


	my $frame_icons = Gtk2::Frame->new("Icons");
	my $vbox2 = Gtk2::VBox->new(0, 10);

	my $hbox4 = Gtk2::HBox->new(0, 2);
	my $lbl_icomod = Gtk2::Label->new("Icon Mode");
	my $radio_stc = Gtk2::RadioButton->new_with_label(undef, "Static");
	   $radio_stc->signal_connect('toggled' => sub {
					$filechooser->set_sensitive(1);
					$combo_theme->set_sensitive(0);
					$::opt->icon_static(1);
					main::update_icon();
					});
	my $radio_dyn = Gtk2::RadioButton->new_with_label($radio_stc, "Dynamic");
	   $radio_dyn->signal_connect('toggled' => sub {
					$filechooser->set_sensitive(0);
					$combo_theme->set_sensitive(1);
					$::opt->icon_static(0);
					main::update_icon();
					});
	if ($::opt->icon_static == 1) {
		$radio_stc->set_active(1);
		$radio_dyn->set_active(0);
	}
	else {
		$radio_dyn->set_active(1);
		$radio_stc->set_active(0);
	}
	$hbox4->pack_start($lbl_icomod, 0, 0, 5);
	$hbox4->pack_end($radio_stc, 0, 0, 5);
	$hbox4->pack_end($radio_dyn, 0, 0, 5);
	$vbox2->add($hbox4);

	my $hbox5 = Gtk2::HBox->new(0, 2);
	my $lbl_static = Gtk2::Label->new("Static icon path");
	$filechooser->select_filename($::opt->icon_path);
	$filechooser->set_width_chars(12);
	if ($::opt->icon_static != 1) { $filechooser->set_sensitive(0); }
	$filechooser->signal_connect('file-set' => sub {
			$::opt->icon_path($filechooser->get_filename);
			main::update_icon();
			});
	$hbox5->pack_start($lbl_static, 0, 0, 5);
	$hbox5->pack_end($filechooser, 0, 0, 5);
	$vbox2->add($hbox5);

	my $hbox6 = Gtk2::HBox->new(0, 2);
	my $lbl_icothm= Gtk2::Label->new("Icon theme");
	$combo_theme->append_text($::opt->icon_theme);
	opendir(DIR, "/usr/share/volwheel/icons")
		or die ("Cannot open themes directory : /usr/share/volwheel/icons\n");
	my @theme_list = grep !/^\.\.?$/, readdir DIR;
	closedir(DIR);
	my $theme = undef;
	foreach $theme (@theme_list) {
		if (($theme ne $::opt->icon_theme) and
		 (-d "/usr/share/volwheel/icons/$theme")) {
			$combo_theme->append_text($theme);
		}
	}
	$combo_theme->set_active(0);
	if ($::opt->icon_static == 1) { $combo_theme->set_sensitive(0); }
	$combo_theme->signal_connect('changed' => sub {
			$::opt->icon_theme($combo_theme->get_active_text);
			main::update_icon();
			});
	$hbox6->pack_start($lbl_icothm, 0, 0, 5);
	$hbox6->pack_end($combo_theme, 0, 0, 5);
	$vbox2->pack_end($hbox6, 1, 0, 5);

	$frame_icons->add($vbox2);
	$vbox->pack_start($frame_icons, 1, 0, 5);
	# END OF FIRST TAB

	# START SECOND TAB
	#my $tab2_vbox = Gtk2::VBox->new(0,2);
	#my $label = Gtk2::Label->new("Hahaha");
	#$tab2_vbox->add($label);
	# END OF SECOND TAB

	# START THIRD TAB
	#my $tab3_vbox = Gtk2::VBox->new(0,2);
	#my $label2 = Gtk2::Label->new("In your dreams !");
	#$tab3_vbox->add($label2);
	# END OF THIRD TAB

	# The NOTEBOOK
	my $notebook = Gtk2::Notebook->new;
	$notebook->append_page($vbox, "General");
	#$notebook->append_page($tab2_vbox, "MiniMixer");
	#$notebook->append_page($tab3_vbox, "Mouse Bindings");
	$main_vbox->pack_start($notebook, 1, 0, 5);
	##

	# BOTTOM
	my $hbox_bottom = Gtk2::HBox->new(0, 2);
	my $btn_cancel = Gtk2::Button->new_from_stock('gtk-cancel');
	$btn_cancel->signal_connect('clicked' => sub { $winconf->destroy });
	my $btn_save = Gtk2::Button->new_from_stock('gtk-save');
	$btn_save->signal_connect('clicked' => sub {
			  my $temp = $entry_channel->get_text;
			  if ( $temp eq "" ) { return 666; }
			  $temp =~ s/^"(.*)"$/$1/; # No quotes !
			  $::opt->driver($combo_driver->get_active_text);
			  $::opt->channel($temp);
			  $::opt->mixer($entry_mixer->get_text);
			  $::opt->increment($spin_incr->get_value_as_int);
			  $::opt->icon_path($filechooser->get_filename);
			  $::opt->icon_theme($combo_theme->get_active_text);
			  $::opt->write_conf;
			  $winconf->destroy;
			 });
	$hbox_bottom->add($btn_cancel);
	$hbox_bottom->add($btn_save);
	$main_vbox->pack_start($hbox_bottom, 1, 0, 5);
	# END OF BOTTOM

	$winconf->add($main_vbox);
	$btn_save->set('can-default', 1);
	$btn_save->grab_default;
	$winconf->show_all;

}

1;
