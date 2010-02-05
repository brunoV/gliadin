package Gliadin::Schema::ProteinsChemicalPeptides;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("proteins_chemical_peptides");
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-05 11:57:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zMwMnxrQiq69vvxv73flJQ

__PACKAGE__->belongs_to( 'peptide', "Gliadin::Schema::ChemicalPeptides",
    { id => "peptide_id" } );
__PACKAGE__->belongs_to( 'protein', "Gliadin::Schema::Proteins",
    { id => "protein_id" } );

1;
