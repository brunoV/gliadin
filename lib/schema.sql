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
    frequency number not null,
    peptide_id integer not null,
    protein_id integer not null,
    unique(peptide_id, protein_id)
);

create table chemical_peptides (
    id integer primary key not null,
    sequence text not null,
    unique(sequence)
);

create table proteins_chemical_peptides (
    id integer primary key not null,
    peptide_id integer not null,
    protein_id integer not null,
    unique(peptide_id, protein_id)
);

create table functional_peptides (
    id integer primary key not null,
    sequence text not null,
    unique(sequence)
);

create table proteins_functional_peptides (
    id integer primary key not null,
    peptide_id integer not null,
    protein_id integer not null,
    unique(peptide_id, protein_id)
);

create table sneath_peptides (
    id integer primary key not null,
    sequence text not null,
    unique(sequence)
);

create table proteins_sneath_peptides (
    id integer primary key not null,
    peptide_id integer not null,
    protein_id integer not null,
    unique(peptide_id, protein_id)
);

