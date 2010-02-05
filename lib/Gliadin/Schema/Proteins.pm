package Gliadin::Schema::Proteins;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("proteins");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "species",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "type",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "sequence",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "gi",
  { data_type => "", default_value => undef, is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("gi_unique", ["gi"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-05 11:57:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SiRrZds32xRFi5kUnmGKVw

use Modern::Perl;
use Bio::SlidingWindow 'subsequence_iterator';

## Set many_to_many for peptides
__PACKAGE__->has_many(
    'proteins_peptides',
    "Gliadin::Schema::ProteinsPeptides",
    { "foreign.protein_id" => 'self.id' }
);
__PACKAGE__->many_to_many( 'peptides', 'proteins_peptides', 'peptide' );

## Set many_to_many for chemical peptides
__PACKAGE__->has_many(
    'proteins_chemical_peptides',
    "Gliadin::Schema::ProteinsChemicalPeptides",
    { "foreign.protein_id" => 'self.id' }
);
__PACKAGE__->many_to_many( 'chemical_peptides', 'proteins_chemical_peptides', 'peptide' );

## Set many_to_many for functional peptides
__PACKAGE__->has_many(
    'proteins_functional_peptides',
    "Gliadin::Schema::ProteinsFunctionalPeptides",
    { "foreign.protein_id" => 'self.id' }
);
__PACKAGE__->many_to_many( 'functional_peptides', 'proteins_functional_peptides', 'peptide' );

## Set many_to_many for sneath peptides
__PACKAGE__->has_many(
    'proteins_sneath_peptides',
    "Gliadin::Schema::ProteinsSneathPeptides",
    { "foreign.protein_id" => 'self.id' }
);
__PACKAGE__->many_to_many( 'sneath_peptides', 'proteins_sneath_peptides', 'peptide' );

sub populate_peptides {
    my ( $self, $alphabet ) = @_;

    my $add =
      defined $alphabet
      ? "add_to_" . $alphabet . "_peptides"
      : "add_to_peptides";

    my @peptides =
      map { { sequence => $_ } }
      _get_peptides( _to_alphabet( $self->sequence, $alphabet ), 2, 12 );

    foreach my $peptide (@peptides) {
        $self->$add( $peptide )
    }
}

sub populate_sneath_peptides {
    my $self = shift;

    $self->populate_peptides( 'sneath' );
}

sub populate_chemical_peptides {
    my $self = shift;

    $self->populate_peptides( 'chemical' );
}

sub populate_functional_peptides {
    my $self = shift;

    $self->populate_peptides( 'functional' );
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

sub _to_alphabet {

    # Transform 20-residues to different aminoacid alphabets

    my ( $sequence, $type ) = @_;

    $type or return $sequence;

    $type = lc $type;

    given ($type) {
        when ('functional') {
            $sequence =~ tr/DERKHPAGWFMILVQYCTSN/AACCCHHHHHHHHHPPPPPP/;
        }
        when ('chemical') {
            $sequence =~ tr/DERKHAGLIVYWFTSPCMNQ/AACCCLLLLLRRRHHISSMM/;
        }
        when ('sneath') {
            $sequence =~ tr/ILVAGPMNQCSTDEKRFHWY/AAACCCDDDEEEFFGGHHHH/;
        }
    }

    return $sequence;
}

1;
