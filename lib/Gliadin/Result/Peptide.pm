package Gliadin::Result::Peptide;
use strict;
use warnings;

use base 'DBIx::Class::Core';

sub frequency {
    my ($peptide, $seq) = @_;
    $seq || die "No sequence argument\n";

    my %frequency_of;
    if ( ref $seq and $seq->isa("Gliadin::ResultSet::Proteins") ) {
        foreach my $protein ($seq->all) {
            $frequency_of{$protein->id} = $peptide->_frequency($protein->sequence);
        }

        return \%frequency_of;
    }
    else {
        return $peptide->_frequency($seq);
    }
}

sub _frequency {
    my ($peptide, $seq) = @_;

    my @count = $seq =~ /${\$peptide->sequence}/g;

    return @count / length($seq);
}

1;
