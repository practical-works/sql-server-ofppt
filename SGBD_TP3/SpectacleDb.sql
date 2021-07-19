create database SpectacleDb;
use SpectacleDb;
create table Salle (
	Salle_ID int primary key, 
	Nom varchar(50), 
	Adresse varchar(300), 
	Capacite int
);
create table Spectacle (
	Spectacle_ID int primary key, 
	Titre varchar(50), 
	DateDeb date, 
	Duree int, 
	Salle_ID int foreign key references Salle (Salle_ID), 
	Chanteur varchar(50)
);
create table Concert (
	Concert_ID int primary key, 
	Date_Concert date, 
	Heure varchar(5), 
	Spectacle_ID int foreign key references Spectacle (Spectacle_ID)
);
create table Billet (
	Billet_ID int primary key, 
	Concert_ID int foreign key references Concert (Concert_ID), 
	Num_Place int, 
	Categorie varchar(50), 
	Prix money
);
create table Vente (
	Vente_ID int, 
	Date_Vente date, 
	Billet_ID int foreign key references Billet (Billet_ID), 
	MoyenPaiement varchar(50)
);

--1. Quelles sont les dates du concert de Corneille (chanteur) au Zenith (nom salle)?
select Date_Concert from Concert

--2. Quels sont les noms des salles ayant la plus grande capacité ?


--3. Quels sont les chanteurs n'ayant jamais réalisé de concert à la Cygale ?


--4. Quels sont les chanteurs ayant réalisé au moins un concert dans toutes les salles ?


--5. Quels sont les dates et les identificateurs des concerts pour lesquels il ne reste aucun billet

