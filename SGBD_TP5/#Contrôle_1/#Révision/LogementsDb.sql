--Exercice 1 : Définition des données
--Base de données : LOGEMENTS

--1. Créer la base de données GestionLogement.
if exists (select * from sys.databases where name='LogementsDb') drop database LogementsDb
else create database LogementsDb;
use LogementsDb;

--2. Créer les cinq tables en désignant les clés primaires mais pas les clés étrangères.
create table COMMUNE (
	ID_COMMUNE int primary key,
	NOM_COMMUNE varchar(30),
	DISTANCE_AGENCE float,
	NOMBRE_D_HABITANS int
);
create table QUARTIER (
	ID_QUARTIER int primary key,
    ID_COMMUNE int, --FK
	LIBELLE_QUARTIER varchar(30)
);
create table LOGEMENT (
	N_LOGEMENT int primary key,
	TYPE_LOGEMENT varchar(30), --FK
	ID_QUARTIER int, --FK
	NOO int,
	RUE varchar(30),
	SUPERFICIE float,
	LOYER money
);
create table TYPE_DE_LOGEMENT (
	TYPE_LOGEMENT varchar(30) primary key,
	CHARGES_FORFAITAIRE varchar(30),
);
create table INDIVIDU (
	N_IDENTIFICATION int primary key,
	N_LOGEMENT int, --FK
	NOM varchar(30),
	PRENOM varchar(30),
	DATE_DE_NAISSANCE date,
	N_TELEPHONE varchar(30),
);

--3. Créer les contraintes permettant de préciser les clés étrangères avec suppression et modification en cascade.
alter table QUARTIER add constraint FK_COMMUNE
foreign key (ID_COMMUNE) references COMMUNE (ID_COMMUNE);

alter table LOGEMENT add constraint FK_TYPE
foreign key (TYPE_LOGEMENT) references TYPE_DE_LOGEMENT (TYPE_LOGEMENT);
alter table LOGEMENT add constraint FK_QUARTIER
foreign key (ID_QUARTIER) references QUARTIER (ID_QUARTIER);

alter table INDIVIDU add constraint FK_LOGEMENT
foreign key (N_LOGEMENT) references LOGEMENT (N_LOGEMENT);

--4. Modifier la colonne N_TELEPHONE de la table INDIVIDU pour qu’elle n’accepte pas la valeur nulle.
alter table INDIVIDU alter column N_TELEPHONE varchar(30) not null;

--5. Créer une contrainte df_Nom qui permet d’affecter ‘SansNom’ comme valeur par défaut 
--à la colonne Nom de la table INDIVIDU.
alter table INDIVIDU add constraint DF_NOM
default 'SansNom' for NOM;

--6. Créer une contrainte ck_dateNaissance sur la colonne DATE_DE_NAISSANCE qui empêche la saisie d’une date 
--postérieure à la date d’aujourd’hui ou si l’âge de l’individu ne dépasse pas 18 ans.
alter table INDIVIDU add constraint CK_DATENAISSANCE
check (DATE_DE_NAISSANCE <= GetDate() and DateDiff(year,DATE_DE_NAISSANCE,GetDate())<=18);

--7. Supprimer la contrainte df_Nom que vous avez défini dans la question 5.
alter table INDIVIDU drop constraint DF_NOM;

-- Insértions ----------------------------------------------------------------------------------------------------
insert into COMMUNE values
--(ID_COMMUNE, NOM_COMMUNE, DISTANCE_AGENCE, NOMBRE_D_HABITANS)
(1, 'Sidi Moumen', 10, 1248);

insert into QUARTIER values
--(ID_QUARTIER, ID_COMMUNE, LIBELLE_QUARTIER)
(1, 1, 'Quartier Saâada');

insert into LOGEMENT values
--(N_LOGEMENT, TYPE_LOGEMENT, ID_QUARTIER, NOO, RUE, SUPERFICIE, LOYER)
(1, 1, 1, 17, 'Rue Farah', 1200, 90);

insert into TYPE_DE_LOGEMENT values
--(TYPE_LOGEMENT, CHARGES_FORFAITAIRE)
(1, 'Oui');

insert into INDIVIDU values
--(N_IDENTIFICATION, N_LOGEMENT, NOM, PRENOM, DATE_DE_NAISSANCE, N_TELEPHONE)
(6, 1, default, default, '2016-01-01', '0612345678');

select * from COMMUNE;
select * from QUARTIER;
select * from LOGEMENT;
select * from TYPE_DE_LOGEMENT;
select * from INDIVIDU;

alter table INDIVIDU add AGE as datediff(year,DATE_DE_NAISSANCE,getdate());