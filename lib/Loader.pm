package Gliadin::Schema;

use base 'DBIx::Class::Schema::Loader';

__PACKAGE__->dump_to_dir('.');

__PACKAGE__->connection("dbi:SQLite:gliadin.sqlite");

1;
