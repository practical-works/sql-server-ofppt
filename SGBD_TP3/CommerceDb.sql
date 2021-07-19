-- Base de données d'une entreprise commerciale -- drop database CommerceDb;
create database CommerceDb;
use CommerceDb;
--1. Créer les tables Clients, Commandes et DetailsCommande en précisant les clés
--primaires et étrangères. (2 pts)
--On suppose que les autres tables sont déjà créées dans la base.
create table Client (
	CodeClt int primary key, 
	Societe varchar(30), 
	Adresse varchar(300), 
	CodePostal int, 
	Ville varchar(30), 
	Tel varchar(10)
);
create table Produit (
	RefProd varchar(30) primary key, 
	Designation varchar(30), 
	CodeCat int, -- FK 
	QteStock int, 
	PrixUnitaire money
);
create table Categorie (
	CodeCat int primary key, 
	NomCat varchar(30), 
	DescriptionCat varchar(300)
);
create table Commande (
	NumCmd int primary key, 
	CodeClt int, --FK 
	DateCmd date, 
	DateLivraison date,
	Destinataire varchar(30),
	AdresseLivraison varchar(300)
);
create table DetailsCommande (
	NumCmd int, --FK 
	RefProd varchar(30), --FK 
	Quantite int
);
alter table Produit add constraint fk_CodeCat
foreign key (CodeCat) references Categorie (CodeCat);
alter table Commande add constraint fk_CodeClt
foreign key (CodeClt) references Client (CodeClt);
alter table DetailsCommande add constraint fk_NumCmd
foreign key (NumCmd) references Commande (NumCmd);
alter table DetailsCommande add constraint fk_RefProd
foreign key (RefProd) references Produit (RefProd);

--2. Mettre en place les contraintes d’intégrité suivantes :
	--a. Le code postal doit être un numéro de 5 chiffres. (0,5 pt)
alter table Client add constraint c_CodePostal
check (CodePostal like '_____');
	--b. La date de commande doit être antérieure à la date de livraison. (0,25 pt)
alter table Commande add constraint c_DateCmd
check (DateCmd <= DateLivraison);
	--c. La référence de produit doit comporter au moins 3 caractères, et doit
	--commencer par 2 caractères alphabétiques et non numériques. (0,75 pt)
alter table Produit add constraint c_RefProd
check (RefProd like ' '); 

--3. Lister les commandes entre les deux dates 20/05/2011 et 19/05/2013. (0,25 pt)
select * from Commande where DateCmd between '2011-05-20' and '2013-05-19';

--4. Lister les produits de la catégorie « Informatique » triés par RefProd. (0,5 pt)
select * from Produit where CodeCat in 
(select CodeCat from Categorie where NomCat='Informatique')
order by RefProd;

--5. Donner le nombre de commandes par produit. (0,5 pt)
select RefProd, count(NumCmd) as 'Nombre de commandes'
from DetailsCommande
group by RefProd;

--6. Lister les clients qui n’ont pas fait une commande depuis 5 ans. (1 pt)
select * from Client where CodeClt in (
	select CodeClt from Commande 
	group by Client.CodeClt
	having datediff(year, max(Commande.DateCmd), getdate()) >= 5
);

--7. Supprimer les produits appartenant à la catégorie « Sport ». (0,5 pt)
delete from Produit where CodeCat in (select CodeCat from Categorie where NomCat='Sport');

--8. Modifier la structure de la table Clients afin d'ajouter un champ email. (0,5 pt)
alter table Client add Email varchar(30);

--9. Afficher le montant total de chaque commande (NumCmd). (1,25 pts)
select NumCmd, sum(Quantite*Produit.PrixUnitaire) as 'Montant total de commande'
from DetailsCommande inner join Produit
on DetailsCommande.RefProd = Produit.RefProd
group by NumCmd
