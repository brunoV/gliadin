use strict;
use warnings;
use Test::More;

use Gliadin::Schema;

my $db = Gliadin::Schema->connect("dbi:SQLite::memory:");
$db->deploy;

my $protein = 'MAAMAAMAA';

$db->insert_protein(
    { sequence => $protein, gi => 'foo' },
    'foo', 'bar',
);

my $peptide = $db->resultset('Peptides')->find( 'MAA', { key => 'sequence_unique' } );

ok $peptide;

cmp_ok( abs($peptide->frequency($protein) - 1/3), '<', 0.01 );

#$db->resultset('Proteins')->first->populate_chemical_peptides;





done_testing();
