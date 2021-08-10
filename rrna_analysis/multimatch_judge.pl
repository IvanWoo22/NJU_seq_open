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

my @info;
chomp( my $first_read = <> );
my ( $first_qname, $first_rname, $first_site, $first_cigar ) =
  split( /\t/, $first_read );
$info[0] = $first_read;

while (<>) {
    chomp( my $read = $_ );
    if ( $read =~ /^$first_qname\t/ ) {
        push( @info, $read );
    }
    else {
        if ( $#info > 0 ) {
            my %name;
            my %map;
            my @all_match;
            my @first_align = COUNT_CIGAR($first_cigar);
            $map{ $first_rname . $first_site }  = $first_align[1];
            $name{ $first_rname . $first_site } = $info[0];
            if ( $first_align[0] == $first_align[1] ) {
                $all_match[0] = $first_rname . $first_site;
            }

            foreach ( 1 .. $#info ) {
                my ( undef, $rname, $site, $cigar ) = split( /\t/, $info[$_] );
                my @align = COUNT_CIGAR($cigar);
                if ( exists $map{ $rname . $site } ) {
                    if ( $align[1] > $map{ $rname . $site } ) {
                        $map{ $rname . $site }  = $align[1];
                        $name{ $rname . $site } = $info[$_];
                        if ( $align[0] == $align[1] ) {
                            push( @all_match, $rname . $site );
                        }
                    }
                }
                else {
                    $map{ $rname . $site }  = $align[1];
                    $name{ $rname . $site } = $info[$_];
                    if ( $align[0] == $align[1] ) {
                        push( @all_match, $rname . $site );
                    }
                }
            }
            if ( $#all_match > -1 ) {
                foreach ( 0 .. $#all_match ) {
                    print "$name{$all_match[$_]}\n";
                }
            }
            elsif ( $#all_match == -1 ) {
                my @key = sort { $map{$a} <=> $map{$b} } keys %map;
                print "$name{$key[-1]}\n";
            }
        }
        elsif ( $#info == 0 ) {
            print "$info[0]\n";
        }
        splice(@info);
        $info[0] = $read;
        ( $first_qname, $first_rname, $first_site, $first_cigar ) =
          split( /\t/, $read );
    }
}

if ( $#info > 0 ) {
    my %name;
    my %map;
    my @all_match;
    my @first_align = COUNT_CIGAR($first_cigar);
    $map{ $first_rname . $first_site }  = $first_align[1];
    $name{ $first_rname . $first_site } = $info[0];
    if ( $first_align[0] == $first_align[1] ) {
        $all_match[0] = $first_rname . $first_site;
    }

    foreach ( 1 .. $#info ) {
        my ( undef, $rname, $site, $cigar ) = split( /\t/, $info[$_] );
        my @align = COUNT_CIGAR($cigar);
        if ( exists $map{ $rname . $site } ) {
            if ( $align[1] > $map{ $rname . $site } ) {
                $map{ $rname . $site }  = $align[1];
                $name{ $rname . $site } = $info[$_];
                if ( $align[0] == $align[1] ) {
                    push( @all_match, $rname . $site );
                }
            }
        }
        else {
            $map{ $rname . $site }  = $align[1];
            $name{ $rname . $site } = $info[$_];
            if ( $align[0] == $align[1] ) {
                push( @all_match, $rname . $site );
            }
        }
    }
    if ( $#all_match > -1 ) {
        foreach ( 0 .. $#all_match ) {
            print "$name{$all_match[$_]}\n";
        }
    }
    elsif ( $#all_match == -1 ) {
        my @key = sort { $map{$a} <=> $map{$b} } keys %map;
        print "$name{$key[-1]}\n";
    }
}
elsif ( $#info == 0 ) {
    print "$info[0]\n";
}

__END__
