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

{   # Mock object to simulate a Bio::Seq class
    package Protein;
    use Moose;

    has [qw(description seq type accession_number)] => ( is => 'ro' );
}

my $protein_r;


Inserting: {

    # Inserting Protein

    my $p = Protein->new(
        seq              => 'MAEEL',
        accession_number => 'abd',
    );

    $protein_r = $db->insert_protein($p, 'gliadin', 'wheat');

    isa_ok($protein_r, 'Gliadin::Schema::Proteins');

    # Inserting just as hashref
    $protein_r = $db->insert_protein( { sequence => 'MAEOL', gi => 'abd2' },
        'spagetti', 'buffalo' );

    isa_ok($protein_r, 'Gliadin::Schema::Proteins');

}


Integrity: {

    # When the same peptide is added to different proteins, the peptide
    # keeps connected to both of the parent proteins

    # First, get the first protein that we added
    my $protein_r =
      $db->resultset('Proteins')->find( 'abd', { key => 'gi_unique' } );

    # peptide that was added to the other protein
    ok my $peptide_r = $db->resultset('Peptides')->find( 'MAE', { key => 'sequence_unique' } );

    # And see what proteins it's connected to
    my @proteins = $peptide_r->proteins;

    isa_ok($_, 'Gliadin::Schema::Proteins') for @proteins;

    is @proteins, 2, 'Peptide <-> Protein relationship';
}

ResultSet: {

    # Using custom ResultSet methods

    my $pep_rs = $db->resultset('Peptides');

    can_ok( $pep_rs,
        qw(union intersection of_type of_species not_of_type not_of_species) );

    isa_ok( $pep_rs->of_type('foo'),        'Gliadin::ResultSet::Peptides' );
    isa_ok( $pep_rs->not_of_type('foo'),    'Gliadin::ResultSet::Peptides' );
    isa_ok( $pep_rs->of_species('foo'),     'Gliadin::ResultSet::Peptides' );
    isa_ok( $pep_rs->not_of_species('foo'), 'Gliadin::ResultSet::Peptides' );

    my $total_count = $pep_rs->count;

    is $pep_rs->of_type('gliadin')->count,        10;
    is $pep_rs->of_type('spagetti')->count,       10;
    is $pep_rs->not_of_type('spagetti')->count,    7;
    is $pep_rs->not_of_type('gliadin')->count,     7;
    is $pep_rs->of_species('wheat')->count,       10;
    is $pep_rs->of_species('buffalo')->count,     10;
    is $pep_rs->not_of_species('buffalo')->count,  7;
    is $pep_rs->not_of_species('wheat')->count,    7;

    # gliadin:   MA AE EE EL MAE AEE EEL MAEE AEEL MAEEL
    # spaguetti: MA AE EO OL MAE AEO EOL MAEO AEOL MAEOL
    # not spaguetti: EE EL AEE EEL MAEE AEEL MAEEL
    # not gliadin:   EO OL AEO EOL MAEO AEOL MAEOL

    # Testing intersection
    my $rs1 = $pep_rs->of_type('gliadin');
    my $rs2 = $pep_rs->of_species('wheat');
    my $rs3 = $pep_rs->of_species('buffalo');

    my $i1 = $rs1->intersection($rs2);
    is $i1->count, $rs1->count;

    my $i2 = $rs1->intersection($rs3);
    is $i2->count, 3;

    # Testing union
    my $u1 = $rs1->union($rs2);
    is $u1->count, $rs1->count;

    my $u2 = $rs1->union($rs3);
    is $u2->count, $total_count;

}

Deleting: {

    my $pep_rs = $db->resultset('Peptides');

    lives_ok { $pep_rs->of_type('gliadin')->delete } 'deleting resultset';

    is $pep_rs->of_type('gliadin')->count, 0;
}

done_testing();
