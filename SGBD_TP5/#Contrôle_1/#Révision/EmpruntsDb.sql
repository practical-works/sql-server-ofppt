--Exercice 3 : Définition et mise à jour des données
--Base de données : EMPRUNTS
if exists (select * from sys.databases where name='EmpruntsDb') drop database EmpruntsDb;
create database EmpruntsDb;
use EmpruntsDb;

--1. Créez toutes les tables avec les contraintes d’intégrité PK et FK, et ajouter un enregistrement par table.
create table AGENCE (
	Num_Ag int primary key,
	Nom_Ag varchar(30),
	Ville_Ag varchar(30)
);
insert into AGENCE values
(1, 'Agence du plaisir', 'Marrakech'),
(2, 'Agence Sidi Maârouf', 'Rabat'),
(3, 'Agence X', 'Casa');
select * from AGENCE;

create table CLIENT (
	Num_Cl int primary key,
	Nom_Cl varchar(30),
	Prenom_Cl varchar(30),
	Ville_Cl varchar(30)
);
insert into CLIENT values
(1, 'El ghamidi', 'Ali', 'Ouarzazate'),
(2, 'Kassandra', 'Aliyah', 'Marrakech'),
(3, 'Razi', 'Abdellah', 'Chefchaoun'),
(4, 'Komran', 'Rania', 'Fès'),
(5, 'El omani', 'Fatima Ezzahra', 'Casa'),
(6, 'Anonyme', 'Anonyme', 'Rabat');
select * from CLIENT;

create table COMPTE (
	Num_Cp int primary key,
	Num_Cl int foreign key references CLIENT (Num_Cl) on delete set null on update cascade,
	Num_Ag int foreign key references AGENCE (Num_Ag) on delete set null on update cascade,
	Solde money
);
insert into COMPTE values
(1, 2, 1, 5000), (2, 5, 3, 4500), (3, 1, 1, 10000), (4, 4, 2, 5780), (5, 3, 2, 10800);
select * from COMPTE;

create table EMPRUNT (
	Num_Ep int primary key,
	Num_Cl int foreign key references CLIENT (Num_Cl) on delete set null on update cascade,
	Num_Ag int foreign key references AGENCE (Num_Ag) on delete set null on update cascade,
	Montant money
);
insert into EMPRUNT values
(1, 2, 1, 5000), (2, 5, 1, 5500), (3, 2, 1, 800), (4, 4, 3, 4220), (5, 1, 1, 800);
select * from EMPRUNT;

--2. Ajouter une contraint strictement positif (>) pour Montant.
alter table EMPRUNT add constraint c_montant
check (Montant > 0);

--3. Modifier la valeur Null des Montants par la valeur 0.
update EMPRUNT set Montant = 0 where Montant is null;
select * from EMPRUNT;

--4. Modifier les villes des Clients en minuscule.
update CLIENT set Ville_Cl = lower(Ville_Cl);
-- Extra: Modifier les villes des Clients en capitale.
update CLIENT set Ville_Cl = upper(left(Ville_Cl,1))+lower(substring(Ville_Cl,2,len(Ville_Cl))); -- Remettre en normal (Capitalisée)
--select upper(left(Ville_Cl,1))+lower(substring(Ville_Cl,2,len(Ville_Cl))) from CLIENT;
--select * from CLIENT;

--5. Augmenter le solde de tous les clients habitant “Rabat” de “0,5%”.
--select * from CLIENT, COMPTE where CLIENT.Num_Cl = COMPTE.Num_Cl order by CLIENT.Num_Cl;
--select * from CLIENT left join COMPTE on CLIENT.Num_Cl = COMPTE.Num_Cl order by CLIENT.Num_Cl;

--select * from CLIENT left join COMPTE on CLIENT.Num_Cl = COMPTE.Num_Cl where Ville_Cl='Rabat';
--insert into COMPTE values (6, 6, null, null);
--update COMPTE set Solde = 1 where Num_Cl in (select Num_Cl from CLIENT where Nom_Cl = 'Anonyme');

update COMPTE set Solde += (0.5*Solde)/100 where Num_Cl in (select Num_Cl from CLIENT where Ville_Cl='Rabat');

--6. Afficher la Liste des clients dont le nom se termine par E et le quatrième caractère est un A.
--update CLIENT set Nom_Cl = 'Hibadoe' where Num_Cl = 6;
select * from CLIENT where Nom_Cl like '___A%E';

--7. Afficher la Liste des agences ayant des emprunts-clients.
-- Méthode 1
select distinct AGENCE.* from AGENCE, EMPRUNT where AGENCE.Num_Ag = EMPRUNT.Num_Ag;
-- Méthode 2
select * from AGENCE where Num_Ag in (select Num_Ag from EMPRUNT);

--8. Afficher la liste des clients ayant un emprunt à “Casa”.
-- Méthode 1
select CLIENT.*, AGENCE.* from CLIENT, AGENCE, EMPRUNT 
where CLIENT.Num_Cl = EMPRUNT.Num_Cl and EMPRUNT.Num_Ag = AGENCE.Num_Ag 
and Ville_Ag = 'Casa';
-- Méthode 2
select CLIENT.*, AGENCE.* from EMPRUNT
inner join AGENCE on AGENCE.Num_Ag = EMPRUNT.Num_Ag
inner join CLIENT on CLIENT.Num_Cl = EMPRUNT.Num_Cl
where Ville_Ag = 'Casa';
-- Méthode 3
select * from CLIENT where Num_Cl in (
	select Num_Cl from EMPRUNT where Num_Ag in (
		select Num_Ag from AGENCE where Ville_Ag = 'Casa'
	)
);

--9. Afficher la liste des clients ayant un compte et un emprunt à “Casa”.
-- Méthode 1 (!!!!!!!!!)
select distinct CLIENT.* from CLIENT, AGENCE, EMPRUNT, COMPTE
where CLIENT.Num_Cl = EMPRUNT.Num_Cl and CLIENT.Num_Cl = COMPTE.Num_Cl
and AGENCE.Num_Ag = EMPRUNT.Num_Ag and AGENCE.Num_Ag = COMPTE.Num_Ag
and  Ville_Ag = 'Marrakech';
-- Méthode 2
select * from CLIENT where Num_Cl in (
	select Num_Cl from EMPRUNT e inner join AGENCE a
	on e.Num_Ag = a.Num_Ag
	where Ville_Ag = 'Marrakech'
) and Num_Cl in (
	select Num_Cl from COMPTE c inner join AGENCE a
	on c.Num_Ag = a.Num_Ag
	where Ville_Ag = 'Marrakech'
);

--10. Afficher la liste des clients ayant un emprunt à la ville où ils habitent.
select distinct c.*, a.Ville_Ag from EMPRUNT e
inner join CLIENT c on e.Num_Cl = e.Num_Cl
inner join AGENCE a on e.Num_Ag = a.Num_Ag
where c.Ville_Cl = a.Ville_Ag;

--11. Afficher la liste des clients ayant un compte et emprunt dans la même agence.
select distinct cl.*,cp.Num_Ag,ep.Num_Ag from CLIENT cl
inner join COMPTE cp on cp.Num_Cl = cl.Num_Cl
inner join EMPRUNT ep on ep.Num_Cl = cl.Num_Cl
where cp.Num_Ag = ep.Num_Ag;
		
--12. Afficher l'emprunt moyenne des clients dans chaque agence.
-- Pour Afficher le nom d'agence
select AGENCE.Nom_Ag, avg(Montant) as 'Moyenne emprunté' from EMPRUNT
inner join AGENCE on EMPRUNT.Num_Ag = AGENCE.Num_Ag
group by AGENCE.Nom_Ag;
-- Sans afficher le nom d'agence
select Num_Ag, avg(Montant) as 'Moyenne emprunté' from EMPRUNT
group by Num_Ag

--13. Afficher le totale emprunté par client.
-- Pour afficher le nom du client
select CLIENT.Num_Cl, CLIENT.Nom_Cl, CLIENT.Prenom_Cl, sum(Montant) as 'Total empruné' from EMPRUNT
inner join CLIENT on CLIENT.Num_Cl = EMPRUNT.Num_Cl
group by CLIENT.Num_Cl, CLIENT.Nom_Cl, CLIENT.Prenom_Cl;
-- Sans afficher le nom du client
select Num_Cl, sum(Montant) as 'Total empruné' from EMPRUNT
group by Num_Cl;

--14. Afficher Le client qui a le moins des totaux emprunts.
select * from CLIENT where Num_Cl in (
	select c.Num_Cl from CLIENT c inner join EMPRUNT e 
	on c.Num_Cl = e.Num_Cl
	group by c.Num_Cl
	having sum(Montant) in (select min(Montant) from EMPRUNT)
);

--15. Afficher les clients ayant un compte dans toutes les agences de “Rabat”.
select * from CLIENT where Num_Cl in (
	select Num_Cl from COMPTE inner join AGENCE
	on COMPTE.Num_Ag = AGENCE.Num_Ag
	where Ville_Ag = 'Rabat'
	group by Num_Cl
	having count(*) = (select count(*) from AGENCE  where Ville_Ag = 'Rabat')
);