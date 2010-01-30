package Gliadin::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-30 16:26:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JX4jLpPPQCuJyqPc6qR+Zw

sub insert_protein {
    my ($self, $protein, $type) = @_;

    $self->resultset('Proteins')->create({
        species  => $protein->species->common_name,
        name     => $protein->description,
        sequence => $protein->seq,
        type     => $type,
        gi       => $protein->accession_number,
    });
}

1;
