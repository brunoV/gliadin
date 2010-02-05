package Gliadin::ResultSet::Proteins;
use Modern::Perl;
use base 'DBIx::Class::ResultSet';

sub populate_peptides {
    my ( $self, $alphabet ) = @_;

    my $add =
      defined $alphabet
      ? "add_to_" . $alphabet . "_peptides"
      : "add_to_peptides";

    foreach my $protein ( $self->all ) {
        my @peptides = map { { sequence => $_ } }
        _get_peptides( _to_alphabet( $protein->sequence, $alphabet ) );

        foreach my $peptide (@peptides) {
            $protein->$add( $peptide )
        }
    }
}

sub populate_sneath_peptides {
    my $self = shift;

    $self->populate_peptides( 'sneath' );
}

sub populate_chemical_peptides {
    my $self = shift;

    $self->populate_peptides( 'chemical' );
}

sub populate_functional_peptides {
    my $self = shift;

    $self->populate_peptides( 'functional' );
}

sub _get_peptides {

    # Take a sequence, an upper and a lower bound and return a list of
    # peptides of size $lower to $upper that span the sequence in a
    # sliding window of step 1. Ommits repeated peptides.

    my ( $seq, $lower, $upper ) = @_;

    my %peptides;

    foreach my $length ( $lower .. $upper ) {
        my $it = subsequence_iterator( \$seq, $length, 1 );

        while ( my $peptide = $it->() ) { $peptides{$peptide} = 1 }
    }

    return keys %peptides;
}

sub _to_alphabet {

    # Transform 20-residues to different aminoacid alphabets

    my ( $sequence, $type ) = @_;

    $type or return $sequence;

    $type = lc $type;

    given ($type) {
        when ('functional') {
            $sequence =~ tr/DERKHPAGWFMILVQYCTSN/AACCCHHHHHHHHHPPPPPP/;
        }
        when ('chemical') {
            $sequence =~ tr/DERKHAGLIVYWFTSPCMNQ/AACCCLLLLLRRRHHISSMM/;
        }
        when ('sneath') {
            $sequence =~ tr/ILVAGPMNQCSTDEKRFHWY/AAACCCDDDEEEFFGGHHHH/;
        }
    }

    return $sequence;
}

1;
