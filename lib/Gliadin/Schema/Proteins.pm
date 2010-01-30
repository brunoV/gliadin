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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-30 16:26:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:01otrdy6R5Xt3fOJ6uyNFQ

__PACKAGE__->has_many(
    'proteins_peptides',
    "Gliadin::Schema::ProteinsPeptides",
    { "foreign.protein_id" => 'self.id' }
);
__PACKAGE__->many_to_many( 'peptides', 'proteins_peptides', 'peptide' );


1;
