use strict;
use warnings;
use Test::More;
use Test::Exception;
use autodie;

use Gliadin::Schema;

{
    package Protein;
    use Moose;

    has [qw(description seq type accession_number)] => ( is => 'ro' );
}

my $db;

$db = Gliadin::Schema->connect("dbi:SQLite::memory:");
$db->deploy;

my $protein_rs;

my $p1 = Protein->new(
    seq              => 'MAEEL',
    accession_number => 'abd',
);

$db->insert_protein($p1, 'type1', 'wheat');

my $p2 = Protein->new(
    seq              => 'MAEELPKP',
    accession_number => 'abc',
);

$db->insert_protein($p2, 'type2', 'wheat');

my $type2_only = $db->resultset('Peptides')->not_of_type('type1');

is $type2_only->search({ 'me.sequence' => 'MAEEL' })->count, 0;

done_testing();
