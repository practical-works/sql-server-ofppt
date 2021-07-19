--1. Créer la base de données ANALYSES
create database ANALYSES

--2. Créer la table CLIENT en précisant la clé primaire
create table Client(
	codeclient varchar(30) primary key,
	nom varchar(30),
	rue varchar(30),
	cpclient varchar(30),
	villeclient varchar(30),
	tel varchar(30)
	)

--3. Modifier les colonnes cpclient et villeclient pour qu'elles n'acceptent pas une valeur nulle.
alter table Client alter column cpclient varchar(30) not null
alter table Client alter column villeclient varchar(30) not null

--4. Modifier les colonnes Nom pour qu'elle prend la valeur 'Anonyme' par défaut.
alter table Client add constraint c_nom default 'Anonyme' for nom

--5. Créer la table Echantillon en précisant la clé primaire qui commence de 10 et s'incrémente automatiquement de 1, 
-- codeclient est la clé étrangère vers la table Client.
create table Echantillon(
	codeEchantillon int primary key identity(10,1),
	dateEntree date,
	codeclient varchar(30) foreign key references Client(codeclient)
	)

--6. Créer la table Typeanalyse en précisant de clé primaire.
create table Typeanalyse(
	RefTypeAnalyse varchar(30) primary key,
	designation varchar(50),
	TypeAnalyse varchar(50),
	prixTypeAnalyse money
	)

--7. Créer une contrainte ck_prixTypeAnalyse qui impose de saisir un prixTypeAnalyse dans la table Typeanalyse 
-- qui doit être entre 100 et 1000.
alter table Typeanalyse add constraint ck_prixTypeAnalyse check(prixTypeAnalyse between 100 and 1000)

--8. Créer la table Realiser en précisant que le couple (codeEchantillon,refTypeAnalyse) est une clé primaire, 
-- en même temps, codeEchantillon est une clé étrangère vers la table Echantillon et refTypeAnalyse est clé étrangère 
-- vers la table TypeAnalyse.
create table Realiser(
	codeEchantillon int foreign key references Echantillon(codeEchantillon),
	refTypeAnalyse varchar(30) foreign key references Typeanalyse(RefTypeAnalyse),
	dateRealisation date, 
	primary key(codeEchantillon,refTypeAnalyse)
	)

--9. Créer une contrainte ck_dateRealisation qui vérifie que la date de dateRealisation est entre la date du jour même et 3 jours après.
alter table Realiser add constraint ck_dateRealisation check(datediff(day,getdate(),dateRealisation)<=3)

--10. Supprimer la colonne rue de la table Client.
alter table Client drop column rue