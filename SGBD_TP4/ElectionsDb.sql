--Pour gérer les élections des représentants des employés d’une entreprise, une application
--utilise une base de données composée des tables Electeurs, Candidats et Votes :
create database ElectionsDb; -- drop database ElectionsDb
use ElectionsDb;
create table Electeur (
	idElecteur int primary key, 
	nomElecteur varchar(50), 
	prenomElecteur varchar(50), 
	aVote bit --Le champ aVoté prend la valeur 0 quand l’électeur n’a pas encore voté et 1 quand il a voté.
);
create table Candidat (
	idCandidat int primary key, 
	nomCandidat varchar(50), 
	prenomCandidat varchar(50), 
	dateNaissance date,
	nombreVoix int --nombreVoix est le nombre de voix obtenus par le candidat.
);
create table Vote ( --Cette table enregistre les votes des électeurs.
	idElecteur int foreign key references Electeur (idElecteur), 
	idCandidat int foreign key references Candidat (idCandidat),
	primary key (idElecteur, idCandidat)
);
--Un électeur ne peut voter qu'une seule fois pour choisir 1, 2 ou 3 candidats.
alter table Vote add constraint c_votes
check (  );

insert into Electeur values
( 1, 'AAA','aaa', 0),
( 2, 'BBB','bbb', 0),
( 3, 'CCC','ccc', 0),
( 4, 'DDD','ddd', 0),
( 5, 'EEE','eee', 0),
( 6, 'FFF','fff', 0),
( 7, 'GGG','ggg', 0),
( 8, 'HHH','hhh', 0),
( 9, 'III','iii', 0),
(10, 'JJJ','jjj', 0);
select * from Electeur;

insert into Candidat values
(1,'WWW','www', '1985-10-20', 0),
(2,'XXX','xxx', '1990-12-27', 0),
(3,'YYY','yyy', '1985-07-10', 0),
(4,'ZZZ','zzz', '1991-03-01', 0);
select * from Candidat;

insert into Vote values
(1,2),(1,3),(1,4),(2,1),(3,1);
update Electeur set aVote=1 where idElecteur=1;
update Electeur set aVote=1 where idElecteur=2;
update Electeur set aVote=1 where idElecteur=3;
update Candidat set nombreVoix=2 where idCandidat=1;
update Candidat set nombreVoix=1 where idCandidat=2;
update Candidat set nombreVoix=1 where idCandidat=3;
update Candidat set nombreVoix=1 where idCandidat=4;
select * from Vote;
select idElecteur,count(*) as 'Nombre de candidats votés pour' from Vote group by idElecteur;

--1. Ecrire une requête qui affiche la liste des électeurs qui ont choisi un seul candidat pendant le vote. (2 pts)
select * from Electeur where idElecteur in ( 
	select idElecteur from Vote group by idElecteur having count(*) = 1
);
----



--2. Ecrire une requête qui affiche les 3 premiers candidats qui ont gagné les élections
--(ceux qui ont obtenu le plus grand nombre de voix). En cas d’égalité des nombres de
--voix, on retient le candidat le plus âgé. (3 pts)
select top 3 * from Candidat order by nombreVoix desc, dateNaissance asc;

--3. Ecrire une fonction qui retourne dans une table la liste des électeurs ayant votés pour un candidat donné. (2 pts)
declare @idCandidat int = 1;
select Electeur.* from
Electeur inner join Vote on Electeur.idElecteur = Vote.idElecteur
where idCandidat = @idCandidat;

--4. Ecrire un trigger qui permet d’incrémenter de 1, le champ nombreVoix d’un candidat
--à chaque ajout d’une ligne à la table Votes qui concerne ce candidat. Le trigger doit
--également mettre le champ aVoté à 1 pour l’électeur qui vient de voter. (3 pts)
select * from Candidat;
select * from Candidat where idCandidat in (select idCandidat from Candidat where idCandidat in (select idCandidat from Candidat));

--5. Ecrire une procédure stockée qui permet d’enregistrer le vote d’un électeur ; elle a les
--paramètres : (3 pts)
--		• @idElect : identifiant de l’électeur.
--		• @idCandidat1, @idCandidat2 et @idCandidat3 : identifiants des 3 candidats
--			choisis par l’électeur (si l’électeur choisit moins de 3 candidats, les valeurs non
--			choisies restent NULL).
--		• La procédure ajoute 1 à 3 lignes à la table Votes selon les valeurs non NULL
--		  des paramètres @idCandidat1, @idCandidat2 et @idCandidat3.
--Si ces paramètres sont tous NULL, la procédure affiche un message d’erreur.
