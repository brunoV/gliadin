package Gliadin::Schema::ProteinsFunctionalPeptides;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Gliadin::Schema::ProteinsFunctionalPeptides

=cut

__PACKAGE__->table("proteins_functional_peptides");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: undef
  is_nullable: 0
  size: undef

=head2 peptide_id

  data_type: integer
  default_value: undef
  is_nullable: 0
  size: undef

=head2 protein_id

  data_type: integer
  default_value: undef
  is_nullable: 0
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
  "peptide_id",
  {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "protein_id",
  {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("peptide_id_protein_id_unique", ["peptide_id", "protein_id"]);


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-24 14:21:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EIrdQUxbI83xAIcaK2U9cg

__PACKAGE__->belongs_to( 'peptide', "Gliadin::Schema::FunctionalPeptides",
    { id => "peptide_id" } );
__PACKAGE__->belongs_to( 'protein', "Gliadin::Schema::Proteins",
    { id => "protein_id" } );

1;
