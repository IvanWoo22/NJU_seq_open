#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

sub COUNT_CIGAR {
    my $CIGAR   = shift;
    my $LENGTH  = 0;
    my $MATCHED = 0;
    my $INSERT  = 0;
    my $DELETE  = 0;
    my $XMATCH  = 0;

    # Alignment column containing two identical letters
    while ( $CIGAR =~ /([0-9]+)=/g ) {
        $LENGTH  += $1;
        $MATCHED += $1;
    }

    # Alignment column containing a mismatch, i.e. two different letters
    while ( $CIGAR =~ /([0-9]+)X/g ) {
        $LENGTH += $1;
        $XMATCH += $1;
    }

    # Deletion (gap in the target sequence)
    while ( $CIGAR =~ /([0-9]+)D/g ) {
        $LENGTH += $1;
        $DELETE += $1;
    }

    # Insertion (gap in the query sequence)
    while ( $CIGAR =~ /([0-9]+)I/g ) {
        $INSERT += $1;
    }

    return ( $LENGTH, $MATCHED, $XMATCH, $DELETE, $INSERT );
}

while (<>) {
    my ( undef, undef, undef, $cigar ) = split /\t/;
    my ( $l, undef, $x, $d, $i ) = COUNT_CIGAR($cigar);

    if ( ( $l < 20 ) and ( $x + $d + $i < 1 ) ) {
        print;    # LENGTH < 20 and all matched
    }
    elsif ( ( $l > 19 )
        and ( $l < 30 )
        and ( $x + $d + $i < 2 ) )
    {
        print;    # LENGTH is [20,30) and at most 1 mismatch
    }
    elsif ( ( $l > 29 )
        and ( $l < 40 )
        and ( $x + $d + $i < 3 ) )
    {
        print;    # LENGTH is [30,40) and at most 2 mismatches
    }
    elsif ( ( $l > 39 ) and ( $x + $d + $i < 4 ) ) {
        print;    # LENGTH > 40 and at most 3 mismatches
    }
}

__END__
