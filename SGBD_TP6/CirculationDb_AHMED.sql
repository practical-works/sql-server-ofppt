--Tp08
--Soit la base de données suivante :
if exists (select * from sys.databases where name='CirculationDb') drop database CirculationDb;
create database CirculationDb;
use CirculationDb;
create table Personne (
	CIN int primary key,
	nom varchar(30),
	prenom varchar(30),
	ville_p varchar(30)
);
insert into Personne values
(1, 'Ben hadi', 'Loubna', 'Rabat'),
(2, 'El manar', 'Abdellatif', 'Fès'),
(3, 'Krrmaoui', 'Nouhaila', 'Ouarzazate'),
(4, 'Ibn katib', 'Jamal eddine', 'Rabat'),
(5, 'Kamoni', 'Ahmed', 'Casablanca');
create table Voiture (
	imma varchar(30) primary key,
	modele varchar(30),
	annee int,
	CIN int foreign key references Personne (CIN)
);
insert into Voiture values
('E1', 'Renault', 2010, 2),
('B2', 'Mercedes', 2011, 3),
('X3Y', 'Fiat', 2014, 3),
('OP4', 'Ford', 2016, 4),
('F5', 'Kia', 2015, 1);
create table Accident (
	N_Accident int primary key,
	Date_Acc date,
	dommage money,
	ville_Acc varchar(30),
	CIN int foreign key references Personne (CIN),
	imma varchar(30) foreign key references Voiture (imma)
);
insert into Accident values
(1, '2011-09-21', 5000, 'Sebta', 1, 'F5'),
(2, '2015-10-26', 10000, 'Ouarzazate', 3, 'B2'),
(3, '2016-01-01', 50000, 'Rabat', 4, 'OP4'),
(4, '2016-01-01', 70000, 'Rabat', 4, 'OP4');

--Développer les vues suivantes :
--1.
--a) les enregistrements de la table personne
create view V_Personne as
	select * from Personne;
select * from V_Personne;
--•utiliser la vue 1 pour insérer une nouvelle personne
insert into V_Personne values (6, 'Chdida', 'Siham', 'Tétouan');
select * from Personne;
select * from V_Personne;
--•utiliser la vue 1 pour modifier la ville d’une personne
update V_Personne set ville_p='Tanger' where CIN=6;
--•utiliser la vue 1 pour supprimer une personne
delete from V_Personne where CIN=6;
--b) Modifier la vue 1 pour contenir le cin et le nom des personnes
alter view V_Personne as
	select CIN,nom from Personne;
select * from V_Personne;
--•utiliser la vue 1 pour insérer une nouvelle personne
insert into V_Personne values (6, 'Chdida');
select * from Personne;
select * from V_Personne;
--•utiliser la vue 1 pour modifier la ville d’une personne
update V_Personne set ville_p='Casablanca' where CIN=6; -- /!\
--•utiliser la vue 1 pour supprimer une personne
delete from V_Personne where CIN=6;
select * from V_Personne;
--c) supprimer la vue 1
drop view V_Personne;
--2. Trouver le nom et le cin des propriétaires de voiture qui ont fait plus de deux accidents.
select * from Personne where CIN in (
	select CIN from Accident group by CIN having count(*) >= 2
);
--3. Afficher les accidents ayant des dommages supérieurs à 5000
select * from Accident where dommage>5000;
--4. Trouver le total des dommages subis par les voitures qui appartiennent à des conducteurs de Tanger.
select sum(dommage) from Accident where CIN in(select CIN from Personne where ville_p='rabat')
--5. Lister l’année de la voiture accidentée la plus ancienne.
select annee from Voiture where imma in (select imma from Accident where Date_Acc in (select min(Date_Acc) from Accident ))
--6. Afficher les immatriculations de voiture qui contiennent la lettre B.
select imma from Voiture where imma like'%B%';
--7. Afficher pour chaque ville le nombre total d’accidents enregistrés.
select ville_Acc,count(*) as 'nombre d''accidents' from Accident group by ville_Acc
--8. Afficher les villes où il y a plus de 1000 accidents enregistrés dans la base.
select ville_Acc from Accident group by ville_Acc having count(*)>1;

--9. Afficher les noms des propriétaires de voiture qui résident dans une ville où il y a eu plus de 1000
--accidents.
select nom from Personne where ville_p in (
		select ville_Acc from Accident group by ville_Acc having count(*)>1
);
--10. Afficher le nom des propriétaires d’une voiture accidentée, qui résident dans une ville où il y a eu plus de
--1000 accidents.
select nom from Personne where CIN in (
	select CIN From Accident group by CIN, ville_Acc having count(*)>1
);
--11. Afficher le ratio du nombre d’accidents par ville et cela par rapport au nombre total des accidents. Pour
--répondre à cette question, vous pouvez créer une vue NbAc qui calcule le nombre total d’accidents.
drop view Total_Acc;
create view Total_Acc as
	select cast(count(*) as float) as 'Tatal' from Accident;
select * from Total_Acc;
select ville_Acc, 100*count(*)/(select count(*) from Accident) as 'Ratio d''accidents (%)' from Accident 
group by ville_Acc;

--select 1/cast(2 as float)

--12. Lister le nom des personnes qui ont eu un ou plusieurs accidents dans la ville de Marrakech.
select nom from Personne where CIN in (
	 select CIN from Accident where ville_Acc='rabat'
);

--13. Afficher les accidents ayant des dommages compris entre 2000 et 5000.
select * from Accident where dommage between 2000 and 5000;

--14. Afficher les dates des accidents dans lesquels sont impliqués le véhicule immatriculé 1234-A-24.
select Date_Acc from Accident where imma = 'OP4';

--15. Quelle est la date du premier accident qui a fait l’objet d’un enregistrement ?
select top 1 Date_Acc from Accident order by Date_Acc asc;

--16. Compter le nombre d’accidents survenus à Casa le 1/1/2004.
select count(*) as 'Nombre d''accidents' from Accident where ville_Acc='Rabat' and Date_Acc='2016-01-01';

--17. Afficher la date de l’accident le plus récent à Casa impliquant un modèle Fiat.
select max(Date_Acc) from Accident where ville_Acc='Rabat' and imma in (
	select imma from Voiture where modele='Ford'
);

--18. Afficher pour chaque ville le cin et le nom des personnes impliquées dans les accidents survenus entre le
--20/2/2005 et 28/2/2005.
select * from Personne 
where CIN in (
	select CIN from Accident where Date_Acc between '20140101' and '20160101'
);
