package Gliadin::Schema::Proteins;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Gliadin::Schema::Proteins

=cut

__PACKAGE__->table("proteins");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: undef
  is_nullable: 0
  size: undef

=head2 species

  data_type: text
  default_value: undef
  is_nullable: 0
  size: undef

=head2 name

  data_type: text
  default_value: undef
  is_nullable: 1
  size: undef

=head2 type

  data_type: text
  default_value: undef
  is_nullable: 0
  size: undef

=head2 sequence

  data_type: text
  default_value: undef
  is_nullable: 0
  size: undef

=head2 gi

  data_type: (empty string)
  default_value: undef
  is_nullable: 1
  size: undef

=cut

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


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-24 14:21:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xRHyTB9UfOZ4H4MzDH/ECQ

use Modern::Perl;
use Try::Tiny;
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

    my @peptides =
      map { { sequence => $_ } }
      _get_peptides( _to_alphabet( $self->sequence, $alphabet ), 2, 12 );

    my $db = $self->result_source->schema;

    if ($alphabet) {
        $alphabet =~ s/\b(\w)/\U$1/;
    }

    no warnings 'uninitialized';
    my $peptides_rs = $db->resultset($alphabet . 'Peptides');
    my $linker_rs   = $db->resultset('Proteins' . $alphabet . 'Peptides');

    foreach (@peptides) {
        my $peptide = try { $peptides_rs->find_or_create($_) };
        if ($peptide) {
            $linker_rs->find_or_create(
                {
                    protein_id => $self->id,
                    peptide_id => $peptide->id,
                    frequency  => $peptide->frequency( _to_alphabet($self->sequence, $alphabet) )
                },
                {
                    key => 'peptide_id_protein_id_unique',
                },
            );
        }
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
