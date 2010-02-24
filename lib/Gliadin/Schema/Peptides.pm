package Gliadin::Schema::Peptides;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Gliadin::Schema::Peptides

=cut

__PACKAGE__->table("peptides");

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:57V5unpBC2h9eIvcSWOrIg

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
