-- BASE DE DONNEE : NotationStagiairesDb
create database NotationStagiairesDb;
use NotationStagiairesDb;
--Soit le schéma relationnel suivant qui gère la notation des stagiaires dans un institut de
--l’OFPPT, en précisant que les champs marqués en gras et soulignés représentent les clés
--primaires des tables et ceux marqués par un # représentent les clés étrangères :
--Sachant qu’un module est enseigné par un seul formateur.
--Donner les requêtes SQL qui permettent de :

--1. Créer les tables stagiaire et notation avec les contraintes suivantes : (4 pts)
create table Filiere(
	num_filiere int primary key,
	nom_filiere varchar(30)
);
create table Groupe(
	num_groupe int primary key,
	nom_groupe varchar(30),
	num_filiere int foreign key references Filiere (num_filiere)
	on delete set null on update cascade
);
--Dans la table stagiaire :
create table Stagiaire(
--a. Num_stagiaire doit être numérique <1000 , Num_stagiaire est une clé primaire.
	num_stagiaire int primary key check (num_stagiaire < 1000),
	nom_stagiaire varchar(30),
	prenom_stagiaire varchar(30),
	adresse varchar (300),
	email varchar(30),
--b. Num_groupe est une clé étrangère.
	num_groupe int foreign key references Groupe (num_groupe)
	on delete set null on update cascade
);
create table Formateur(
	num_formateur int primary key,
	nom_formateur varchar(30),
	prenom_formateur varchar(30), 
	num_filiere int foreign key references Filiere
	on delete set null on update cascade
);
create table Module(
	num_module int primary key,
	nom_module varchar(30),
	masse_horaire_prevue int,
	masse_horaire_realise int,
	num_formateur int foreign key references Formateur (num_formateur)
	on delete set null on update cascade
);
create table Controle(
	num_controle int primary key,
	date_controle date,
	num_module int foreign key references Module (num_module)
	on delete set null on update cascade
);
--Dans la table Notation :
create table Notation(
--a. Numcontrôle et Numstagiaire sont des clés étrangères.
	num_stagiaire int foreign key references Stagiaire(num_stagiaire),
	num_controle int foreign key references Controle(num_controle),
--c. L’attribut Note doit être compris entre 0 et 20.
	note float check (note between 0 and 20),
--b. Les colonnes Numcontrôle et Numstagiare forment la clé primaire.
	primary key (num_stagiaire, num_controle)
);
--On suppose que les autres tables sont déjà créées dans la base.

--2. Lister les Stagiaires de la filière nommée ‘TDM’ du groupe nommé ‘A’ et du group nommé ‘B’. (2 pts)
select Stagiaire.*, Filiere.nom_filiere, Groupe.nom_groupe
from Groupe 
inner join Stagiaire on Stagiaire.num_groupe = Groupe.num_groupe
inner join Filiere on Filiere.num_filiere = Groupe.num_filiere
where Groupe.nom_groupe in ('A','B') and Filiere.nom_filiere = 'TDM';

--3. Lister le groupe (toutes les informations) ayant le plus grand nombre de stagiaire (4pts)
select top 1 Stagiaire.num_groupe, Groupe.nom_groupe, count(*) as 'Nombre de Stagiaires' 
from Stagiaire inner join Groupe on Groupe.num_groupe = Stagiaire.num_groupe
group by Stagiaire.num_groupe, Groupe.nom_groupe order by [Nombre de Stagiaires] desc;

--4. Lister les modules enseignés par le(s) formateur(s) ‘ ABDELLAOUI ‘. (1 pt)
select Module.*, Formateur.nom_formateur
from Formateur inner join Module
on Formateur.num_formateur = Module.num_formateur
where nom_formateur='LMALKI';

--5. Lister les modules déjà terminés. (1 pt)
select * from Module 
where masse_horaire_prevue=masse_horaire_realise;

--6. Lister les modules non terminés et enseignés par le formateur ‘ahmadi ‘ pour la filière ‘TDM’. (1 pt)
select Module.*, Formateur.nom_formateur, Filiere.nom_filiere 
from Formateur 
inner join Filiere on Filiere.num_filiere = Formateur.num_filiere
inner join Module on Module.num_formateur = Formateur.num_formateur
where Module.masse_horaire_prevue > Module.masse_horaire_realise 
and Formateur.prenom_formateur='ahmadi' and Filiere.nom_filiere='TDM';

--7. Supprimer tous les groupes dont le nombre de stagiaires ne dépassent pas dix. (1pt)
delete from Groupe
where num_groupe = (select num_groupe from Stagiaire group by num_groupe having count(*) <= 10);

--8. Affecter la note 12/20 pour le contrôle numéro : 2 du module nommé
--‘programmation 3D’ pour la filière ‘TDM’ au stagiaire ayant comme numéro : 3006. (2 pts)
-- Note : 19
-- Stagiaire : 3006
--  Contôle : 2 (Module : Programmation)
-- Filière : TDM
update Notation 
set note=19
where 
num_stagiaire = ( select num_stagiaire 
				 from Groupe 
				 inner join Stagiaire on Stagiaire.num_groupe = Groupe.num_groupe
				 inner join Filiere on Filiere.num_filiere = Groupe.num_filiere
				  where num_stagiaire=3006 and nom_filiere='TDM' )
and 
num_controle = ( select  top 2 with ties num_controle from Controle inner join Module
				on Controle.num_module = Module.num_module
				 where Module.nom_module='Langage C' order by num_controle asc );
