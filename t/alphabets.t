use Modern::Perl;
use Test::More;
use Test::Exception;

use Gliadin::Schema;

my $db = Gliadin::Schema->connect("dbi:SQLite::memory:");
$db->deploy;

my $protein = $db->resultset('Proteins')->create(
    {
        sequence => 'DERKHAGLIVYWFTSPCMNQ',
        gi       => 'test',
        type     => 'test',
        species  => 'test',
    }
);

lives_ok { $protein->populate_peptides            } 'populate_peptides';
lives_ok { $protein->populate_functional_peptides } 'populate_functional_peptides';
lives_ok { $protein->populate_chemical_peptides   } 'populate_chemical_peptides';
lives_ok { $protein->populate_sneath_peptides     } 'populate_sneath_peptides';


# Regular alphabet
my $p = $db->resultset('Peptides');

my @longest = qw( AGLIVYWFTSPC DERKHAGLIVYW ERKHAGLIVYWF GLIVYWFTSPCM
  HAGLIVYWFTSP IVYWFTSPCMNQ KHAGLIVYWFTS LIVYWFTSPCMN RKHAGLIVYWFT );

is_deeply [ _12_mers($p) ], [ @longest ];

# Functional alphabet
$p = $db->resultset('FunctionalPeptides');

@longest = qw(AACCCHHHHHPH ACCCHHHHHPHH CCCHHHHHPHHP CCHHHHHPHHPP
 CHHHHHPHHPPH HHHHHPHHPPHP HHHHPHHPPHPH HHHPHHPPHPHP HHPHHPPHPHPP );

is_deeply [ _12_mers($p) ], [ @longest ];

# Chemical alphabet
$p = $db->resultset('ChemicalPeptides');

@longest = qw(AACCCLLLLLRR ACCCLLLLLRRR CCCLLLLLRRRH CCLLLLLRRRHH
 CLLLLLRRRHHI LLLLLRRRHHIS LLLLRRRHHISS LLLRRRHHISSM LLRRRHHISSMM);

is_deeply [ _12_mers($p) ], [ @longest ];

# Sneath alphabet
$p = $db->resultset('SneathPeptides');

@longest = qw(AAAHHHEECEDD AAHHHEECEDDD CAAAHHHEECED CCAAAHHHEECE
 FFGGHCCAAAHH FGGHCCAAAHHH GGHCCAAAHHHE GHCCAAAHHHEE HCCAAAHHHEEC);

is_deeply [ _12_mers($p) ], [ @longest ];

sub _12_mers {
    my $rs = shift;

    return grep { length($_) == 12 } sort map { $_->sequence } $p->all;
}

done_testing();

