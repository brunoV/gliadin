package Gliadin::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-30 16:26:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JX4jLpPPQCuJyqPc6qR+Zw

use Bio::SlidingWindow 'subsequence_iterator';

sub insert_protein {
    my ( $self, $protein, $type, $species ) = @_;

    unless ($type)    { die "Undefined protein type" }
    unless ($species) { die "Undefined species" }

    my $protein_rs;

    $self->txn_do(
        sub {

            $protein_rs = $self->resultset('Proteins')->update_or_create(
                {
                    species  => $species,
                    name     => $protein->description,
                    sequence => $protein->seq,
                    type     => $type,
                    gi       => $protein->accession_number,
                }
            );

            my @peptides =
              map { { sequence => $_ } } _get_peptides( $protein->seq, 2, 12 );

            my $peptides_rs = $self->resultset('Peptides');

            foreach my $peptide (@peptides) {
                my $exists =
                  $peptides_rs->find( $peptide, { key => 'sequence_unique' } );

                $protein_rs->add_to_peptides($peptide) unless $exists;
            }
        }
    );

    return $protein_rs;
}

sub _get_peptides {

    # Take a sequence, an upper and a lower bound and return a list of
    # peptides of size $lower to $upper that span the sequence in a
    # sliding window of step 1. Ommits repeated peptides.

    my ( $seq, $lower, $upper ) = @_;

    my %peptides;

    foreach my $length ( $lower .. $upper ) {
        my $it = subsequence_iterator( \$seq, $length, 1 );

        while ( my $peptide = $it->() ) { $peptides{$peptide} = 1 }
    }

    return keys %peptides;
}

1;
