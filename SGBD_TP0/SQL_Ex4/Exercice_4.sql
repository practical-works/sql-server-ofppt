create database AeoroportDb;
use AeoroportDb;
create table Pilote (
	NUMPIL int primary key,
	NOMPIL varchar(15),
	ADR varchar(30),
	SAL float
);
create table Avion (
	NUMAV int primary key,
	NOMAV varchar(15),
	CAPACITE int,
	LOC varchar(30)
);
create table Vol (
	NUMVOL int primary key,
	NUMPIL int,
	NUMAV int,	
	VILLE_DEP varchar(30),
	VILLE_ARR varchar(30),
	H_DEP int check(H_DEP between 0 and 23),
	H_ARR int check(H_ARR between 0 and 23)
);
alter table VOL add constraint fk_numpil foreign key(NUMPIL) references Pilote(NUMPIL)
on delete set null on update cascade;
alter table VOL add constraint fk_numav foreign key(NUMAV) references Avion(NUMAV)
on delete set null on update cascade;

--1) Donnez toutes les informations sur les pilotes de la compagnie.
select * from Pilote;

--2) Quels sont les numéros des pilotes en service et les villes de départ de leurs vols ?
select NUMPIL,VILLE_DEP from Vol;

--3) Donnez la liste des avions dont la capacité est supérieure à 350 passagers.
select * from Avion where CAPACITE>350;

--4) Quels sont les numéros et noms des avions localisés à 'Tanger' ?
select NUMAV,NOMAV from Avion where LOC='Tanger';

--5) Dans combien de villes distinctes sont localisées des avions ?
select distinct LOC from Avion;

--6) Quel est le nom des pilotes domiciliés à 'Casa' dont le salaire est supérieur à 15000 DH ?
select * from Pilote where ADR='Casablanca' and SAL>15000;

--7) Quels sont les avions (numéro et nom) localisés à 'Tanger' 
--ou dont la capacité est inférieure à 350 passagers ?
select NUMAV,NOMAV from Avion where LOC='Tanger' or CAPACITE<350;

--8) Liste des vols au départ de 'Rabat' allant à 'Paris' après 18 heures ?
select * from Vol where VILLE_DEP='Rabat' and VILLE_ARR='Paris' and (H_ARR-H_DEP)=18;

--9) Quels sont les numéros des pilotes qui ne sont pas en service ?
select NUMPIL,NOMPIL from Pilote where NUMPIL not in (select NUMPIL from Vol);

--10) Quels sont les vols (numéro, ville de départ) effectués par les pilotes de numéro 100 et 204 ?
select NUMVOL,VILLE_DEP from Vol where NUMPIL=100 and NUMPIL=204;

--11) Quels sont les pilotes dont le nom commence par « S » ?
select * from Pilote where NOMPIL like 'S%';

--12) Quels sont les pilotes qui comportent le groupe de caractères « cie » ?
select * from Pilote where NOMPIL like '%cie%';

--13) Quels sont les pilotes dont la troisième lettre est un « b » ?
select * from Pilote where NOMPIL like '__b%';

