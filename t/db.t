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

    has [qw(description seq type accession_number)] => ( is => 'ro' );
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
        accession_number => 'abd',
    );

    $protein_rs = $db->insert_protein($p, 'gliadin', 'wheat');

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
        accession_number => 'abd2',
    );

    $protein_rs = $db->insert_protein($p, 'spagetti', 'buffalo');

    my $peptide_rs = $protein_rs->add_to_peptides({
        sequence => 'FOO',
    });

    my @proteins = $peptide_rs->proteins;

    isa_ok($_, 'Gliadin::Schema::Proteins') for @proteins;

    is @proteins, 2, 'Peptide <-> Protein relationship';

    dies_ok { $db->insert_protein($p, 'gliadin', 'wheat') };
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

    is $pep_rs->of_type('gliadin')->count,        11;
    is $pep_rs->of_type('spagetti')->count,       11;
    is $pep_rs->not_of_type('spagetti')->count,   11;
    is $pep_rs->not_of_type('gliadin')->count,    11;
    is $pep_rs->of_species('wheat')->count,       11;
    is $pep_rs->of_species('buffalo')->count,     11;
    is $pep_rs->not_of_species('buffalo')->count, 11;
    is $pep_rs->not_of_species('wheat')->count,   11;

    # Testing intersection
    my $rs1 = $pep_rs->of_type('gliadin');
    my $rs2 = $pep_rs->of_species('wheat');
    my $rs3 = $pep_rs->of_species('buffalo');

    my $i1 = $rs1->intersection($rs2);
    is $i1->count, $rs1->count;

    my $i2 = $rs1->intersection($rs3);
    is $i2->count, 4;

    # Testing union
    my $u1 = $rs1->union($rs2);
    is $u1->count, $rs1->count;

    my $u2 = $rs1->union($rs3);
    is $u2->count, $total_count;

}

done_testing();
