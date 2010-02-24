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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-02-05 11:57:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l5fVlnQFoqRWyJFEI9jQiA

__PACKAGE__->has_many('proteins_peptides', "Gliadin::Schema::ProteinsPeptides", { "foreign.peptide_id" => 'self.id' });

__PACKAGE__->many_to_many('proteins', 'proteins_peptides', 'protein');

__PACKAGE__->resultset_class("Gliadin::ResultSet::Peptides");

sub frequency {
    my ($peptide, $seq) = @_;
    $seq || die "No sequence argument\n";

    my %frequency_of;
    if ( ref $seq and $seq->isa("Gliadin::ResultSet::Proteins") ) {
        foreach my $protein ($seq->all) {
            $frequency_of{$protein->id} = $peptide->_frequency($protein->sequence);
        }

        return \%frequency_of;
    }
    else {
        return $peptide->_frequency($seq);
    }
}

sub _frequency {
    my ($peptide, $seq) = @_;

    my @count = $seq =~ /${\$peptide->sequence}/g;

    return @count / length($seq);
}

1;
