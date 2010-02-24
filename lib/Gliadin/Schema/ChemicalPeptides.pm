package Gliadin::Schema::ChemicalPeptides;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Gliadin::Schema::ChemicalPeptides

=cut

__PACKAGE__->table("chemical_peptides");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: undef
  is_nullable: 0
  size: undef

=head2 sequence

  data_type: text
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


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-24 14:21:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ohefomt0LMvDtxQycgR+qA

__PACKAGE__->has_many('proteins_chemical_peptides', "Gliadin::Schema::ProteinsChemicalPeptides", { "foreign.peptide_id" => 'self.id' });

__PACKAGE__->many_to_many('proteins', 'proteins_chemical_peptides', 'protein');

__PACKAGE__->resultset_class("Gliadin::ResultSet::Peptides");

1;
