package Gliadin::ResultSet::Peptides;
use Modern::Perl;
use base 'DBIx::Class::ResultSet';

sub of_type {
    my ( $self, $type ) = @_;

    return $self->_join_to_proteins( 'type', '=', $type );
}

sub not_of_type {
    my ( $self, $type ) = @_;

    return $self->_join_to_proteins( 'type', '!=', $type );
}

sub of_species {
    my ( $self, $species ) = @_;

    return $self->_join_to_proteins( 'species', '=', $species );
}

sub not_of_species {
    my ( $self, $species ) = @_;

    return $self->_join_to_proteins( 'species', '!=', $species );
}

sub _join_to_proteins {
    my ( $self, $field, $operator, $value ) = @_;

    return $self->search(
        { "protein.$field" => { $operator => $value } },
        {
            join     => { proteins_peptides => 'protein' },
            distinct => 1
        }
    );
}

sub union {
    my ( $self, @other ) = @_;

    # Create a new, empty resultset
    my $union_rs = $self->result_source->resultset;

    # Filter out duplicate peptides
    my %peptides;

    foreach my $rs ($self, @other) {
        foreach my $peptide ($rs->all) {
            $peptides{ $peptide->id } = $peptide;
        }
    }

    # Populate the empty rs with the unique peptides, without hitting
    # the db
    $union_rs->set_cache([ values %peptides ]);

    return $union_rs;
}

sub intersection {
    my ( $self, @other ) = @_;

    return $self->search(
        {
            'me.id' =>
              [ map { { IN => $_->get_column('id')->as_query } } @other ]
        }
    );
}

1;
