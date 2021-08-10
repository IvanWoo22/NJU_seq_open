#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use POSIX;

sub JUDGE_ZERO {
    my $IN = shift;
    if ( $IN == 0 ) {
        $IN = 1;
    }
    return ($IN);
}

sub SCORE {
    my $TR_END_COUNT = $_[0];
    my $NC_END_COUNT = $_[1];

    my @SCORE;
    $SCORE[0] = 0;
    $SCORE[1] = 0;
    for my $CURRENT ( 2 .. $#{$TR_END_COUNT} - 2 ) {
        my ( $T_END, $T_END_P1, $N_END, $N_END_P1 ) = (
            JUDGE_ZERO( ${$TR_END_COUNT}[$CURRENT] ),
            JUDGE_ZERO( ${$TR_END_COUNT}[ $CURRENT + 1 ] ),
            JUDGE_ZERO( ${$NC_END_COUNT}[$CURRENT] ),
            JUDGE_ZERO( ${$NC_END_COUNT}[ $CURRENT + 1 ] )
        );

        if ( ( $T_END < 4 ) and ( $N_END < 4 ) ) {
            if ( $T_END > $N_END ) {
                $N_END = $T_END;
            }
            else {
                $T_END = $N_END;
            }
        }
        my $SCORE = $T_END_P1 / $T_END - $N_END_P1 / $N_END;
        if ( ( $SCORE >= 10 ) and ( $T_END_P1 <= $N_END_P1 * 5 ) ) {
            $SCORE = 10;
        }
        push( @SCORE, $SCORE );
    }
    push( @SCORE, 0 );
    push( @SCORE, 0 );
    foreach my $HEAD ( 0 .. 19 ) {
        $SCORE[$HEAD] = 0;
    }
    foreach my $TAIL ( $#SCORE - 19 .. $#SCORE ) {
        $SCORE[$TAIL] = 0;
    }

    return (@SCORE);
}

my @site;
my @base;
my @end_count;
my @score;
open( my $IN_NC, "<", $ARGV[0] );
while (<$IN_NC>) {
    chomp;
    my ( $site, $base, undef, $end_count ) = split /\t/;
    push( @site,              $site );
    push( @base,              $base );
    push( @{ $end_count[0] }, $end_count );
}
close($IN_NC);

foreach my $sample ( 1 .. $#ARGV ) {
    open( my $IN_TR, "<", $ARGV[$sample] );
    while (<$IN_TR>) {
        chomp;
        my ( undef, undef, undef, $end_count ) = split /\t/;
        push( @{ $end_count[$sample] }, $end_count );
    }
    @{ $score[$sample] } =
      SCORE( \@{ $end_count[$sample] }, \@{ $end_count[0] } );
    close($IN_TR);
}

foreach my $site ( 0 .. $#site ) {
    print("$site[$site]\t$base[$site]\t\t$end_count[0][$site]\t\t");
    foreach my $sample ( 1 .. $#ARGV ) {
        print("$end_count[$sample][$site]\t");
    }
    print("\t");
    my $score_sum = 0;
    foreach my $sample ( 1 .. $#ARGV ) {
        print("$score[$sample][$site]\t");
        $score_sum += $score[$sample][$site];
    }
    print("\t$score_sum\t");
    print("\n");
}

__END__
