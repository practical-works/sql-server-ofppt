create database ClientsLumiereDb;
use ClientsLumiereDb;

create table CLIENT (
	NumCli int primary key,
	Nom varchar(50),
	Prenom varchar(50),
	DateNaiss date,
	CP int,
	Rue varchar(50),
	Ville varchar(50)
);
create table PRODUIT (
	NumProd int primary key,
	Desi varchar(50),
	PrixUni money
);
create table COMMANDE (
	NumCli int foreign key references CLIENT (NumCli),
	NumProd int foreign key references PRODUIT (NumProd),
	primary key (NumCli, NumProd)
);

--1.  Formuler  à  l’aide  du  langage  SQL  les  requêtes  suivantes  (sans  recopier  les  tables  –  rappel : 
--l’accès  aux  tables  d’un  autre  utilisateur  se  fait  en  préfixant  le  nom  de  la  table  par  le  nom  de 
--l’utilisateur, ex. darmont.client). 

--1-1 • Liste des clients (nom + prénom) qui ont commandé le produit n° 102.
select Nom, Prenom from CLIENT cli, COMMANDE cmd 
where cli.NumCli = cmd.NumCli 
and NumProd = 102;  
 
--1-2 • Nom des clients qui ont commandé au moins un produit de prix supérieur ou égal à 500 €. 
select distinct Nom from CLIENT cli, COMMANDE cmd, PRODUIT prod 
where cli.NumCli = cmd.NumCli and cmd.NumProd = prod.NumProd 
and PrixUni >= 500; 

--1-3 • Nom des clients qui n’ont commandé aucun produit. 
select Nom from CLIENT cli where not exists (
	select * from COMMANDE cmd where cmd.NumCli = cli.NumCli
 ); 

--1-4 • Nom des clients qui n’ont pas commandé le produit n° 101. 
select Nom from CLIENT where NumCli not in ( 
	select NumCli from COMMANDE where NumProd = 101
 ); 

--1-5 • Nom des clients qui ont commandé tous les produits
select CLIENT.Nom from CLIENT inner join COMMANDE on CLIENT.NumCli = COMMANDE.NumCli
group by Nom
having count(COMMANDE.NumProd) = (select count(*) from PRODUIT);
--ou
select Nom from CLIENT cli where not exists ( 
	select * from PRODUIT prod where not exists ( 
		select * from COMMANDE cmd
		where cmd.NumCli = cli.NumCli and cmd.NumProd = prod.NumProd
	)
); 
--ou
select Nom from CLIENT cli, COMMANDE cmd 
where cli.NumCli = cmd.NumCli 
group by Nom 
having count(distinct NumProd) = (select count(NumProd) from PRODUIT); 

--2.  Créer  une  vue  nommée clicopro permettant  de  visualiser  les  caractéristiques  des produits 
--commandés  par  chaque  client  (attributs  à  sélectionner :  NumCli,  Nom,  Prenom,  NumProd,  Desi, PrixUni). 
create view clicopro as 
	select cli.NumCli, Nom, Prenom, prod.NumProd, Desi, PrixUni 
	from CLIENT cli, COMMANDE cmd, PRODUIT prod 
	where cli.NumCli = cmd.NumCli and cmd.NumProd = prod.NumProd; 

--3. Lister le contenu de la vue clicopro. 
select * from clicopro;
select Nom from clicopro group by Nom;

--4.  Reformuler  les  deux  premières  requêtes  de  la  question  1  en  utilisant  la  vue clicopro. Commentaire ?
select Nom, Prenom from clicopro where NumProd = 102;
select distinct Nom from clicopro where PrixUni >= 500; 

--5. Formuler les requêtes suivantes en utilisant la vue clicopro. 

--• Pour chaque client, prix du produit le plus cher qui a été commandé.
select Nom, max(PrixUni) as 'Prix produit plus cher commandé' from clicopro group by Nom;
  
--• Pour  chaque  client  dont  le  prénom  se  termine  par  la lettre  ‘e’,  prix  moyen  des  produits commandés. 
select Nom, avg(PrixUni) from clicopro where Prenom like '%e' group by Nom;

--• Maximum des totaux des prix pour tous les produits commandés par les différents clients.
-- Méthode 1 : top
select top 1 sum(PrixUni) as 'Somme Maximum' from clicopro group by NumCli order by sum(PrixUni) desc;
-- Méthode 2 : view
create view SommePrix as
select sum(PrixUni) as 'Somme' from clicopro group by NumCli;
select * from SommePrix;
select max(Somme) as 'Maximum des totaux des prix' from SommePrix;
 
--• Numéros des produits commandés plus de deux fois. 
select NumProd from clicopro group by NumProd having count(*)>2; 

--6.  Créer  une  vue  nommée clipro basée sur clicopro et  permettant  d’afficher  seulement  les 
--attributs Nom, Prenom et Desi. Lister le contenu de la vue clipro.
create view clipro as 
	select Nom, Prenom, Desi from clicopro; 
select * from clipro; 

--7. Détruire la vue clicopro. Lister le contenu de la vue clipro. Conclusion ? 
drop view clicopro; 
select * from clipro;  