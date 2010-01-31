use strict;
use warnings;
use Test::More;
use Test::Exception;
use autodie;

use_ok( 'Gliadin::Schema' );

my $db;

Basic: {

    lives_ok {
        $db = Gliadin::Schema->connect("dbi:SQLite::memory:");
        $db->deploy;
    } 'Lived through database connection and deployment';

    isa_ok($db, 'Gliadin::Schema');

}

{
    package Protein;
    use Moose;

    has [qw(species description seq type accession_number)] => ( is => 'ro' );
}

{
    package Species;
    use Moose;

    has common_name => ( is => 'ro' );
}

my $protein_rs;

Inserting: {

    # Inserting Protein

    my $p = Protein->new(
        seq              => 'MAEEL',
        species          => Species->new( common_name => 'wheat' ),
        description      => 'foobar',
        accession_number => 'abd',
    );

    $protein_rs = $db->insert_protein($p, 'gliadin');

    isa_ok($protein_rs, 'Gliadin::Schema::Proteins');

}

Peptides: {

    # Adding a peptide

    my $peptide_rs = $protein_rs->add_to_peptides({
        sequence => 'FOO',
    });

    isa_ok($peptide_rs, 'Gliadin::Schema::Peptides');

}

Integrity: {

    # When the same peptide is added to different proteins, the peptide
    # keeps connected to both of the parent proteins

    my $p = Protein->new(
        seq              => 'MAEOL',
        species          => Species->new( common_name => 'wheat' ),
        description      => 'foobar',
        accession_number => 'abd2',
    );

    $protein_rs = $db->insert_protein($p, 'gliadin');

    my $peptide_rs = $protein_rs->add_to_peptides({
        sequence => 'FOO',
    });

    my @proteins = $peptide_rs->proteins;

    isa_ok($_, 'Gliadin::Schema::Proteins') for @proteins;

    is @proteins, 2, 'Peptide <-> Protein relationship';
}

done_testing();
