#!/usr/bin/perl

use strict;
use warnings;
use Shell qw(install cp);

my $package = "volwheel";

my $destdir = "";
my $prefix  = "/usr/local";

if (@ARGV > 0) {
	foreach my $arg (@ARGV) {
		if    ($arg =~ /destdir/)
				{ my @value = split '=', $arg; $destdir = $value[1]; }
		elsif ($arg =~ /prefix/)
				{ my @value = split '=', $arg; $prefix  = $value[1]; }
	}
}

my $path    = $destdir.$prefix;
my $bindir  = "$path/bin";
my $libdir  = "$path/lib/$package";
my $datadir = "$path/share/$package";

my $output = install ("-v -d {$bindir,$libdir,$datadir}");
print $output;
$output = install ("-v -m755 volwheel $bindir");
print $output;
$output = install ("-v -m644 lib/* $libdir");
print $output;
$output = cp      ("-v -r icons $datadir/");
print $output;

print "\nVolWheel has been succesfully installed.\n\n";
