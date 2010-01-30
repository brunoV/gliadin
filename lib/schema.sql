create table proteins (
    id integer primary key not null,
    species text not null,
    name text,
    type text not null,
    sequence text not null,
    gi,
    unique(gi)
);

create table peptides (
    id integer primary key not null,
    sequence text not null,
    unique(sequence)
);

create table proteins_peptides (
    id integer primary key not null,
    peptide_id integer not null,
    protein_id integer not null,
    unique(peptide_id, protein_id)
);

