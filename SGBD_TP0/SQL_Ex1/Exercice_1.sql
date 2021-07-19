create database STAGIAIRES

create table Stagiaire (
	Code_Stgr int primary key,
	Nom_Stgr varchar(30),
	Prenom_Stgr varchar(30),
	Date_Naissance date,
	Tel_Fixe varchar(30),
	Tel_Portable varchar(30),
	E_Mail varchar(30),
	Code_Groupe varchar(30) foreign key references Groupe(Code_Groupe) 
	)
create table Groupe (
	Code_Groupe varchar(30) primary key,
	Annee int,Code_Filiere int foreign key references Filiere(Code_Filiere)
	)
create table Filiere (
	Code_Filiere int primary key identity(1,2),
	Libelle_Filiere varchar(30)
	)
create table Module (
	Code_Module int primary key identity(2,2),
	Libelle_Module varchar(30)
	)
create table Note (
	Code_Stgr int foreign key references Stagiaire(Code_Stgr),
	Code_Module int foreign key references Module(Code_Module),
	Note_1 float,
	Note_2 float,
	Note_3 float,
	primary key(Code_Stgr,Code_Module)
	)

-- 1. Année vaut 1 ou 2
alter table Groupe add constraint c_annee check(Annee in(1,2))

-- 2. Tél_Fixe commence par 05 et Tél_Portable par 06, les deux ne peuvent pas dépasser 10 chiffres
alter table Stagiaire add constraint c_fixe check (Tel_Fixe like '05________')
alter table Stagiaire add constraint c_portable check (Tel_Portable like '06________')

-- 3. L’e-mail doit contenir @ et .
alter table Stagiaire add constraint c_email check (E_Mail like '%@%.%')

-- 4. Les colonnes (Nom_Stgr, Prénom_Stgr, Date_Naissance) ne peuvent pas être, toutes les trois, redondantes
alter table Stagiaire add constraint c_coordonnes unique (Nom_Stgr,Prenom_Stgr,Date_Naissance)

-- 5. Code_Groupe dépend de l’année, s’il s’agit d’un groupe de première année alors le code ressemble à 
-- G[un caractère entre A et H] et G[un chiffre entre 1 et 8]
alter table Groupe add constraint c_groupes check((Annee=1 and Code_Groupe like 'G[A-H]') or (Annee=2 and Code_Groupe like 'G[1-8]'))

-- 6. Note_1, Note_2 et Note_3 sont comprises entre 0 et 20, s’elles ne sont pas remplies elles valent 0
alter table Note add default 0 for Note_1
alter table Note add default 0 for Note_2
alter table Note add default 0 for Note_3
alter table Note add constraint c_notes check(Note_1 between 0 and 20 and Note_2 between 0 and 20 and Note_3 between 0 and 20)

-- 7. Ajouter une colonne Moyenne à la table Note qui vaut : (Note_1 + Note_2 + Note_3)/3
alter table Note add Moyenne as (Note_1+Note_2+Note_3)/3
