package Gliadin::ResultSet::Peptides;
use Modern::Perl;
use base 'DBIx::Class::ResultSet';

sub of_type {
    my ( $self, $type ) = @_;

    return $self->_join_to_proteins( 'type', '=', $type );
}

sub not_of_type {
    my ( $self, $type ) = @_;

    my $of_type = $self->of_type($type)->search( {}, { distinct => 1 } );

    return $self->search(
        { id => { 'NOT IN' => $of_type->get_column('id')->as_query } } );
}

sub of_species {
    my ( $self, $species ) = @_;

    return $self->_join_to_proteins( 'species', '=', $species );
}

sub not_of_species {
    my ( $self, $species ) = @_;

    my $of_species =
      $self->of_species($species)->search( {}, { distinct => 1 } );

    return $self->search(
        { id => { 'NOT IN' => $of_species->get_column('id')->as_query } } );
}

sub _join_to_proteins {
    my ( $self, $field, $operator, $value ) = @_;

    return $self->search(
        { "protein.$field" => { $operator => $value } },
        {
            join     => { proteins_peptides => 'protein' },
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
