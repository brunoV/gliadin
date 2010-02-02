#!/usr/bin/env perl
use Modern::Perl;
use Set::Object;

use lib qw(./lib);
$ENV{DBIC_TRACE} = 1;
use Gliadin::Schema;

my $db = Gliadin::Schema->connect("dbi:SQLite:db.sqlite");

my $prs = $db->resultset('Peptides');

my $hordeins = $prs->of_type('hordein');

my $secalins = $prs->of_type('secalin');

my $alfa_gliadins   = $prs->of_type('alpha gliadin');
my $beta_gliadins   = $prs->of_type('beta gliadin' );
my $gamma_gliadins  = $prs->of_type('gamma gliadin');
my $omega_gliadins  = $prs->of_type('omega gliadin');
my $restof_gliadins = $prs->of_type('gliadin');

my $gliadins = $beta_gliadins->union(
    [ $gamma_gliadins, $omega_gliadins ]
);

my $not_glutelins = $prs->not_of_type('glutelin');
my $not_oat       = $prs->not_of_species('oat');

my $rs1 = $hordeins->intersection($secalins);

my $rs2 = $rs1->intersection($gliadins);

my $rs3 = $rs2->intersection($not_glutelins);

my $rs4 = $rs2->intersection($not_oat);

say $_->sequence for $rs4->all;
