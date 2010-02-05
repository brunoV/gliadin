package Gliadin::Schema::ChemicalPeptides;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("chemical_peptides");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("sequence_unique", ["sequence"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-05 11:57:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v3cBxyumAayshAL/Qsqv4g

__PACKAGE__->has_many('proteins_chemical_peptides', "Gliadin::Schema::ProteinsChemicalPeptides", { "foreign.peptide_id" => 'self.id' });

__PACKAGE__->many_to_many('proteins', 'proteins_chemical_peptides', 'protein');

__PACKAGE__->resultset_class("Gliadin::ResultSet::Peptides");

1;
