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
    unless ($species) { die "Undefined species"      }

    my $protein_rs;

    $self->txn_do(
        sub {

            $protein_rs = $self->resultset('Proteins')->create(
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

            foreach my $peptide (@peptides) {

                $protein_rs->add_to_peptides($peptide);
            }
        }
    );

    return $protein_rs;
}

sub insert_peptide_rr {

    # insert a peptide resultrow

    my ( $self, $peptide ) = @_;

    my $entry = $self->resultset('Peptides')->create(
        {
            id       => $peptide->id,
            sequence => $peptide->sequence,
        }
    );

    foreach my $protein ( $peptide->proteins ) {
        $entry->add_to_proteins(
            {
                id       => $protein->id,
                species  => $protein->species,
                type     => $protein->type,
                sequence => $protein->sequence,
                gi       => $protein->gi,
            }
        );
    }

    return $entry;

}

sub insert_peptide_rs {

    # insert a peptide resultset

    my ( $self, $peptide_rs ) = @_;

    $self->txn_do(
        sub {
            foreach my $peptide ( $peptide_rs->all ) {
                $self->insert_peptide_rr($peptide);
            }
        }
    );
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
