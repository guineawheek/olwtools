package OSS;

# VolWheel - set the volume with your mousewheel
# Author : Olivier Duclos <olivier.duclos gmail.com>

# Spacial thanks to uastasi <uastasi archlinux.us> for his help

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


sub volume {

	my $channel = shift;

	my $volume = `ossmix "$channel" | cut -d " " -f 10`;

	if ($volume =~ /\./) {
		# we convert decibels into a percentage
		$volume = sprintf("%d", $volume * 4);
	}
	elsif ($volume =~ /\:/) {
		# we only take the volume from the left
		my @result = split(":", $volume, 2);
		$volume = $result[0];
	}

	return $volume;

}


sub is_muted {

	my $channel = shift;

	if ( volume($channel) == 0 ) {
		return 1;
	}
	else {
		return 0;
	}

}


# Returns both the volume and if muted
sub status {

	my $channel = shift;

	my $volume = volume($channel);

	if ( $volume == 0 ) {
		return (1, $volume);
	}
	else {
		return (0, $volume);
	}

}


sub mute {

	my $channel = shift;

	my $volume = volume($channel);

	if ( $volume == 0 ) {
		return -1;
	}
	else {
		system "ossmix \"$opt{channel}\" 0 > /dev/null";
	}

	return $volume;

}


sub unmute {

	my ($channel, $old_volume) = @_;

	my $volume = volume($channel);

	if ($volume == 0) {
		system "ossmix \"$opt{channel}\" +$old_volume > /dev/null"
	}
	else {
		return -1; # The channel is not muted !
	}

}


sub volume_up {

	my ($channel, $increment) = @_;
	system "ossmix \"$channel\" +$increment > /dev/null";

}


sub volume_down {

	my ($channel, $increment) = @_;
	system "ossmix \"$channel\" -- -$increment > /dev/null";

}

sub set_volume {

	my ($channel, $value) = @_;

	unmute($channel, 0);
	system("ossmix \"$channel\" $value > /dev/null");

}


1;
