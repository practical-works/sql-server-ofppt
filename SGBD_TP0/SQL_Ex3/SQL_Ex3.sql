--1) Créer la base de données ANALYSES
create database AnalysesDb;
use AnalysesDb;
--2) Créer la table CLIENT en précisant la clé primaire
create table Client (
	code_client int primary key,
	nom varchar(15),
	cp_client varchar(30),
	ville_client varchar(30),
	tel varchar(10)
);
--3) Modifier les colonnes cpclient et villeclient pour qu'elles n'acceptent pas une valeur nulle.
alter table Client alter column cp_client varchar(30) not null;
alter table Client alter column ville_client varchar(30) not null;
--4) Modifier les colonnes Nom pour qu'elle prend la valeur 'Anonyme' par défaut.
alter table Client add constraint c_nom default 'Anonyme' for Nom;
--5) Créer la table Echantillon en précisant la clé primaire qui commence de 10 et s'incrémente automatiquement de 1, 
--codeclient est la clé étrangère vers la table Client.
create table Echantillon (
	code_echantillon int primary key,
	date_entree date,
	code_client int
);
--6) Créer la table Typeanalyse en précisant de clé primaire.
create table TypeAnalyse (
	ref_typeAnalayse int primary key,
	designation varchar(15),
	type_analyse varchar(30),
	prix_typeAnalyse money
);
--7) Créer une contrainte ck_prixTypeAnalyse qui impose de saisir un prixTypeAnalyse dans la table 
--Typeanalyse qui doit être entre 100 et 1000.
alter table TypeAnalyse add constraint ck_prixTypeAnalyse check(prix_typeAnalyse between 100 and 1000);
--8) Créer la table Realiser en précisant que le couple (codeEchantillon,refTypeAnalyse) est une clé primaire, 
--en même temps, codeEchantillon est une clé étrangère vers la table Echantillon et refTypeAnalyse est clé étrangère 
--vers la table TypeAnalyse.
create table Realiser (
	code_echantillon int foreign key references Echantillon(code_echantillon),
	ref_typeAnalayse int foreign key references TypeAnalyse(ref_typeAnalayse),
	date_realisation date,
	primary key(code_echantillon, ref_typeAnalayse)
);
--9 Créer une contrainte ck_dateRealisation qui vérifie que la date de dateRealisation est entre 
--la date du jour même et 3 jours après. ( date_realisation - aujourd'hui <= 3 )
alter table Realiser add constraint ck_dateRealisation check(datediff(day,getdate(),date_realisation)<=3);
--10) Supprimer la colonne rue de la table Client.
alter table Client add rue varchar(15);
alter table Client drop column rue;
--Affichage
select*from Client;