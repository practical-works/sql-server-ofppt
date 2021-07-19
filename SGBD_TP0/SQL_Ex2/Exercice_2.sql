-- 1. Créer la base de données GestionLogement
create database LOGEMENTS

-- 2. Créer les cinq tables en désignant les clés primaires mais pas les clés étrangères.
create table INDIVIDU(
	N_IDENTIFICATION int primary key,
	N_LOGEMENT int,NOM varchar(30),
	PRENOM varchar(30),
	DATE_DE_NAISSANCE date,
	N_TELEPHONE varchar(30)
	)
create table LOGEMENT(
	N_LOGEMENT int primary key,
	TYPE_LOGEMENT varchar(30),
	ID_QUARTIER int,
	NO int,
	RUE varchar(30),
	SUPERFICIE float,
	LOYER float
	)
create table QUARTIER(
	ID_QUARTIER int primary key,
	ID_COMMUNE int,
	LIBELLE_QUARTIER varchar(30)
	)
create table TYPE_DE_LOGEMENT(
	TYPE_LOGEMENT varchar(30) primary key,
	CHARGES_FORFAITAIRES varchar(30)
	)
create table COMMUNE(
	ID_COMMUNE int primary key,
	NOM_COMMUNE varchar(30),
	DISTANCE_AGENCE float ,
	NOMBRE_D_HABITANTS int
	)

-- 3. Créer les contraintes permettant de préciser les clés étrangères avec suppression et modification en cascade.
alter table INDIVIDU add constraint fk_INDIVIDU foreign key (N_LOGEMENT) references LOGEMENT(N_LOGEMENT) on delete cascade on update cascade
alter table LOGEMENT add constraint fk1_LOGEMENT foreign key (TYPE_LOGEMENT) references TYPE_DE_LOGEMENT(TYPE_LOGEMENT) on delete cascade on update cascade
alter table LOGEMENT add constraint fk2_LOGEMENT foreign key (ID_QUARTIER) references QUARTIER(ID_QUARTIER) on delete cascade on update cascade
alter table QUARTIER add constraint fk_QUARTIER foreign key (ID_COMMUNE) references COMMUNE(ID_COMMUNE) on delete cascade on update cascade

-- 4. Modifier la colonne N_TELEPHONE de la table INDIVIDU pour qu’elle n’accepte pas la valeur nulle.
alter table INDIVIDU alter  column  N_TELEPHONE varchar(30) not null

-- 5. Créer une contrainte df_Nom qui permet d’affecter ‘SansNom’ comme valeur par défaut à la colonne Nom de la table INDIVIDU.
alter table INDIVIDU add constraint Def_Nom default 'SansNom' for NOM

-- 6. Créer une contrainte ck_dateNaissance sur la colonne DATE_DE_NAISSANCE qui empêche la saisie d’une date postérieure 
-- à la date d’aujourd’hui ou si l’âge de l’individu ne dépasse pas 18 ans.
alter table INDIVIDU add constraint ck_dateNaissance check (DATEDIFF(YEAR,DATE_DE_NAISSANCE, GETDATE())>=18)

-- 7. Supprimer la contrainte df_Nom que vous avez défini dans la question 5.
alter table INDIVIDU drop constraint Def_Nom

