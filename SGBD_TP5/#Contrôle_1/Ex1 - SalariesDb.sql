if exists (select * from sys.databases where name='SalariesDb')
drop database SalariesDb;
create database SalariesDb;
use SalariesDb;

--1. Créer les tables et les contraintes
create table Servicee (
	numService int primary key,
	nomService varchar(30),
	lieu varchar(30)
);
create table Salarie (
	matricule int primary key,
	nom varchar(30),
	poste varchar(30),
	email varchar(30),
	dateEmb date,
	salaire money,
	numService int foreign key references Servicee (numService),
	prime money
);
create table Projet (
	codeProjet int primary key,
	nomProjet varchar(300),
	dateDebut date,
	dateFin date
);
create table Participation (
	matricule int foreign key references Salarie (matricule),
	codeProjet int foreign key references Projet (codeProjet),
	fontion varchar(30),
	nbrJours int,
	primary key (matricule, codeProjet)
);
--a. Email valide et unique
alter table Salarie add constraint c_email
check (email like '%@%.%');
alter table Salarie add unique (email);

--b. DateFin du projet postèrieure à la DateDebut
alter table Projet add constraint c_dates
check (dateDebut <= DateFin);

--c. Salarié participe au moins 2 jours à un projet
alter table Participation add constraint c_jours
check (nbrJours >= 2);

--2. Insértions
insert into Servicee values
(1, 'Direction', 'Présidence'),
(2, 'Secrétariat', 'Présidence'),
(3, 'Ressources', 'Département Principal'),
(4, 'Développement', 'Département Principal'),
(5, 'Communication', 'Accueil');
insert into Salarie values
(1, 'El madani Hassan', 'Président', 'elmadani@thecompany.com', '1991-11-25', 1000000000, 1, 0),
(2, 'Mandor Nour', 'Secrétaire', 'mandor@thecompany.com', '1999-01-18', 100000, 1, 10000),
(3, 'Korman Mehdi', 'Guichetier', 'korman@thecompany.com', '2008-11-25', 10000, 3, 5000),
(4, 'Zator Abdelhadi', 'Rechercheur', 'zator@thecompany.com', '2000-11-25', 20000, 3, 2000),
(5, 'El maâlam Hasna', 'Technicienne', 'elmaalam@thecompany.com', '2002-11-25', 200000, 4, 10000),
(6, 'Safi Karima', 'Hôtesse d''accueil', 'safi@thecompany.com', '2016-01-27', 5000, 5, 800);
insert into Projet values
(1, 'Application mobile de gestion de temps', '2016-01-01', '2016-11-11'),
(2, 'RPG en ligne multiplateforme', '2014-07-17', '2016-11-27'),
(3, 'Carapasse géante', '2000-01-01', '2016-01-01'),
(4, 'Projet X', '1999-01-01', null);
insert into Participation values
(4, 3, 'Modéliseur', 30),
(4, 1, 'Concepteur', 10),
(5, 3, 'Testeuse de qualité', 2),
(5, 2, 'Développeuse', 60),
(1, 1, 'Principal', null);

--3. Afficher pour chaque salarié (nom salarié) le nombre de projets auxquels il a participé
--et le nombre total des participations
select s.nom, count(*) as 'Nombre Projets', sum(nbrJours) as 'Total des participations'
from Salarie s inner join Participation p
on s.matricule = p.matricule
group by s.nom;

--4. Afficher pour chaque service (nom service) la masse salariale (salaire+prime)
--totale des salariés
select ser.nomService, sum(Salaire+Prime) as 'Masse salariale'
from Servicee ser inner join Salarie sal
on ser.numService = sal.numService
group by ser.nomService;

--5. Afficher pour chaque service (nom service) le nombre de salariés qui ont un salaire
--(sans prime) supérieur à la moyenne des salaires de tous les salariés
select ser.nomService, count(*) as 'Nombre salariés avec salaire > Moyenne des salaires'
from Servicee ser inner join Salarie sal
on ser.numService = sal.numService
group by ser.nomService

--6. Augmenter les salaires du service 'Ressources humaines' de:
--		- 500dh pour salariés avec 5 années d'ancienneté
--		- 900dh pour salariés entre 5 et 15 années d'ancienneté
--		- 1000dh pour le reste
update Salarie set Salaire += ( 
	case
		when floor(datediff(day,dateEmb,getdate())/365.25) = 5 then 500
		when floor(datediff(day,dateEmb,getdate())/365.25) between 5 and 15 then 900
		else 1000
	end
) where nomService='Ressources humaines';

--7. Créer une table ProjetEnRealisation qui a la même structure que la table Projet,
-- et insérer dans cette table les projets qui sont en cours de réalisation
create table ProjetEnRealisation (
	codeProjet int primary key,
	nomProjet varchar(300),
	dateDebut date,
	dateFin date
);
insert into ProjetEnRealisation select * from Projet where DateFin < getdate();
select * from ProjetEnRealisation;

--8. Supprimer les salariés qui n'ont pas participé à aucun projet
delete from Salarie where matricule not in (select matricule from Participation);

--9. Augmenter la prime des salariés qui ont participé à plus de 1à projets de 10%
update Salarie set prime += 10*prime/100 where matricule in (
	select matricule from Participation
	group by matricule
	having count(*) > 10
);

--10. Afficher les salariés qui n'ont pas participé à aucun projet
select * from Salarie where matricule not in (select matricule from Participation);
