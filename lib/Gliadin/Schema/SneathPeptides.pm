package Gliadin::Schema::SneathPeptides;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Gliadin::Schema::SneathPeptides

=cut

__PACKAGE__->table("sneath_peptides");

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nAF0B1L5VHuF6gX2MC/ucA

__PACKAGE__->has_many('proteins_sneath_peptides', "Gliadin::Schema::ProteinsSneathPeptides", { "foreign.peptide_id" => 'self.id' });

__PACKAGE__->many_to_many('proteins', 'proteins_sneath_peptides', 'protein');

__PACKAGE__->resultset_class("Gliadin::ResultSet::Peptides");

1;
