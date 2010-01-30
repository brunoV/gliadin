package Gliadin::Schema::Peptides;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("peptides");
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-30 16:26:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ULl4vtLfQyKT+XTEHnb5IA

__PACKAGE__->has_many('proteins_peptides', "Gliadin::Schema::ProteinsPeptides", { "foreign.peptide_id" => 'self.id' });

__PACKAGE__->many_to_many('proteins', 'protein_peptides', 'protein');

1;
