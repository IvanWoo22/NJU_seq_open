#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

open my $REF,    "<", $ARGV[0];
open my $IN_SAM, "<", $ARGV[1];

sub COUNT_ALIGNMENT_LENGTH {
    my $CIGAR  = shift;
    my $LENGTH = 0;
    while ( $CIGAR =~ /([0-9]+)=/g )
    {    # Alignment column containing two identical letters.
        $LENGTH += $1;
    }
    while ( $CIGAR =~ /([0-9]+)X/g )
    {    # Alignment column containing a mismatch, i.e. two different letters.
        $LENGTH += $1;
    }
    while ( $CIGAR =~ /([0-9]+)D/g ) {  # Deletion (gap in the target sequence).
        $LENGTH += $1;
    }
    return $LENGTH;
}

my @site_start;
my @site_end;
my @site_base;

readline($REF);
my $ref;
while (<$REF>) {
    s/\r?\n//;
    $ref .= $_;
}
close($REF);

@site_base = split( "", $ref );

foreach ( 0 .. $#site_base ) {
    $site_start[$_] = 0;
    $site_end[$_]   = 0;
}

while (<$IN_SAM>) {
    chomp;
    if ( $_ =~ /\t$ARGV[2]\t/ ) {
        my ( undef, undef, $site, $cigar ) = split( "\t", $_ );
        my $length = COUNT_ALIGNMENT_LENGTH($cigar);
        my $no     = $site + $length - 2;
        $site_end[$no]++;
        $site_start[ $site - 1 ]++;
    }
}
close($IN_SAM);

foreach ( 0 .. $#site_base ) {
    my $site_number = $_ + 1;
    print "$site_number\t$site_base[$_]\t$site_start[$_]\t$site_end[$_]\n";
}

__END__
