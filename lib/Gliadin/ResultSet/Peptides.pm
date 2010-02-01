package Gliadin::ResultSet::Peptides;
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
            join     => { proteins_peptides => {'protein'} },
            distinct => 1
        }
    );
}

sub intersection {
    my ($self, $other) = @_;

    return $self->search(
        { 'me.id' => { IN => $other->get_column('id')->as_query } }
    );
}

__PACKAGE__->load_components("Helper::ResultSet::Union");

1;
