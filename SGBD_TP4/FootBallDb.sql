--Une application de gestion des résultats des matchs de football de la saison 2011-2012
--utilise la base de données suivante :
create database FootBallDb;
use FootBallDb;
create table Equipe (
	codeEquipe int primary key,
	nomEquipe varchar(50),
);
create table Stade (
	codeStade int primary key,
	nomStade varchar(50)
);
create table Match (
	numMatch int primary key,
	dateMatch date,
	nombreSpectateur int,
	numJournee int,
	codeStade int foreign key references Stade (codeStade),
	codeEquipeLocaux int foreign key references Equipe (codeEquipe),
	codeEquipeVisiteurs int foreign key references Equipe (codeEquipe),
	nombreButLocaux int,
	nombreButVisiteurs int
);

--Un match se joue entre une équipe locale et une équipe visiteur dans un stade donné et
--pour une journée du championnat national (journée 1, 2 , …). La table Match enregistre
--également le nombre de buts marqués par l’équipe des locaux et le nombre de buts marqués
--par l’équipe des visiteurs.
insert into Equipe values
(1,'Angels'),(2,'Devils'),(3,'Dragons'),(4,'Wings'),(5,'Basiliks'),
(6,'Phoenix'),(7,'BlackCrows'),(8,'BlueCrows'),(9,'Snakes'),(10,'Panthers');
select * from Equipe;

insert into Stade values
(1,'Hall of Rebirth'),(2,'Titanium'),(3,'Final Colossum');
select * from Stade;

insert into Match values
(1, '2016-01-01', 4000, 1, 1, 1,2, 0,0),
(2, '2016-01-01', 3900, 1, 1, 7,8, 2,1),
(3, '2016-01-02', 2000, 2, 1, 3,10, 5,4),
(4, '2016-01-03', 5000, 3, 2, 1,2, 2,1);
select * from Match;

--1) Ecrire une requête qui affiche le nombre de matchs joués dans la journée n°12. (0,5pt)
select count(*) as 'Nombre de matchs joués' from Match where numJournee=2;

--2) Ecrire une requête qui affiche le nombre de matchs joués par journée. (0,5 pt)
select numJournee, count(*) as 'Nombre de matchs joués' from Match group by numJournee;

--3) Ecrire une requête qui affiche le match qui a compté le plus grand nombre de spectateurs. (1pt)
select * from Match where nombreSpectateur in ( select max(nombreSpectateur) from Match );

--4) Ecrire une requête qui affiche le nombre de points de l’équipe de code 112 ; le
--nombre de points se calcule de la façon suivante :        (1 pt)
--			• une victoire = 3 points 
--			• une égalité = 1 point 
--			• une défaite = 0 point
declare @CodeEquipe int = 1 -- Code de l'équipe pour laquelle afficher les points
declare @Points int = 0
select  @Points += count(numMatch)*3 from Match where 
	( codeEquipeLocaux = @CodeEquipe and nombreButLocaux > nombreButVisiteurs ) 
	or 
	( codeEquipeVisiteurs = @CodeEquipe and nombreButVisiteurs > nombreButLocaux )

select @Points += count(numMatch) from Match where 
	( codeEquipeLocaux = @CodeEquipe or codeEquipeVisiteurs = @CodeEquipe ) and nombreButLocaux = nombreButVisiteurs

select @Points as 'Nomrbe de points de l''équipe';

--5) Ecrire une procédure stockée qui affiche les équipes qui ont gagné leur match dans
--une journée dont le numéro est donné comme paramètre. (1 pt)


--6) Ecrire un trigger qui refuse l’ajout d’une ligne à la table Match pour laquelle la colonne
--codeEquipeLocaux est égale à la colonne codeEquipeVisiteurs. (1 pt)

--Avec Trigger
create trigger tr_locaux_VS_visiteurs on Match -- drop trigger tr_locaux_VS_visiteurs
for insert as
begin
	declare @local int
	declare @visiteur int
	select @local = codeEquipeLocaux from inserted
	select @visiteur = codeEquipeVisiteurs from inserted
	if (@local = @visiteur)
	raiserror('L''équipe %d ne peut pas être locaux et visiteurs en même temps !', 10, 1, @local)
end

--Possible aussi avec contrainte 
alter table Match -- alter table Match drop constraint c_locaux_VS_visiteurs
add constraint c_locaux_VS_visiteurs 
check (codeEquipeLocaux != codeEquipeVisiteurs);

--requête insert de test
-- numMatch, dateMatch, nombreSpectateur, numJournee, codeStade, 
-- codeEquipeLocaux, codeEquipeVisiteurs, 
-- nombreButLocaux, nombreButVisiteurs

insert into Match values
(99,'2016-01-30',0,1,1,  9,9,  0,0);
-----------------
delete from Match where numMatch=99;
-----------------
select * from Match;