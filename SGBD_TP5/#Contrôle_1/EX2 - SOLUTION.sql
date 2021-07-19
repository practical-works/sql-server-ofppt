

//Auteur: CHAOULID
//Copyright: Exelib.net
//**D'autres solutions sont possibles**//

//Partie théorique : Voir Cours

//Partie Pratique:

//A
//1
create database EFM_SGBD_1
go
use EFM_SGBD_1

create table Service(Num_serv int identity(1,1) primary key,Nom_serv varchar(50),Date_creation date)
create table Employe (Matricule int identity(1,1) primary key,Nom varchar(50),Prenom varchar(50),DateNaissance date,Adresse varchar(50),Salaire float,Grade int,Num_serv int foreign key references Service(Num_serv))
create table Projet(Num_prj int identity(1,1) primary key,Nom_prj varchar(50), Lieu varchar(50),nbr_limite_taches int,Num_serv int foreign key references Service(Num_serv))
create table Tache (Num_tache int primary key,Nom_tache varchar(30),date_debut date,date_fin date,cout float,Num_prj int foreign key references Projet(Num_prj))
create table Travaille  (Matricule int foreign key references Employe(Matricule) ,Num_tache int foreign key references Tache(Num_tache),Nombre_heure int,primary key(Matricule,Num_tache))

alter table Employe add constraint CK_Employe_dateNaissance  check( Datediff(YEAR,DateNaissance,getdate() )>=18)
//ceci est inexact car imprécis jusqu à 11 mois et 30 jours près 
alter table Employe add constraint CK_Employe_dateNaissance  check( (Datediff(DAY,DateNaissance,getdate() )/365.25) >=18)

alter table Tache add constraint CK_Tache_duree  check( Datediff(DAY,date_debut,date_fin) >= 3)
alter table Tache add constraint CK_Tache_cout  check ( Datediff(DAY,date_debut,date_fin)*1000 <=cout AND cout>=1000 )

SELECT name, description
FROM fn_helpcollations()

alter table Employe alter column Nom varchar(50) collate French_CS_AS
//2
alter table Employe add Age as FLOOR(Datediff(DAY,DateNaissance,getdate() )/365.25)

//B
//1

select *
from Employe
where Nom like 'El%[^a-f]'
order by DateNaissance

//2
select UPPER(Nom_tache) as "Nom de tâche"
from Tache
where MONTH(date_fin)=MONTH(getdate())

//3
select COUNT(distinct Grade) as "Nombre de grades"
from Employe

//4
select e.*
from Employe e inner join Travaille t on e.Matricule=t.Matricule inner join Tache ta on t.Num_tache=ta.Num_tache inner join Projet p on ta.Num_prj=p.Num_prj
where e.Num_serv!=p.Num_serv

//5
select * from Tache

select *
from Projet
where Num_prj in (select distinct Num_prj from Tache where DATEDIFF(DAY,date_debut,date_fin)<30) and Num_prj in (select distinct Num_prj from Tache where DATEDIFF(DAY,date_debut,date_fin)>60)


//6
select ta.Num_prj,SUM(tr.Nombre_heure) as "Masse horaire"
from Travaille tr inner join Tache ta on tr.Num_tache=ta.Num_tache
where YEAR(date_debut)=YEAR(getdate()) and YEAR(date_fin)=YEAR(GETDATE())
group by Num_prj

//7
select  e.Matricule,e.Nom
from Employe e inner join Travaille tr on e.Matricule=tr.Matricule inner join Tache ta on tr.Num_tache=ta.Num_tache
group by e.Matricule,e.Nom,e.Prenom
having COUNT( distinct ta.Num_prj)>=2

//8

select *,DATEADD(year,Datediff(YEAR,DateNaissance,getdate()),DateNaissance) as "Dateanniversaire"
from Employe
where DATEADD(year,Datediff(YEAR,DateNaissance,getdate()),DateNaissance) between  
cast (DATEADD(DAY,-DATEPART(WEEKDAY,GETDATE())+1+7,GETDATE()) as DATE) //-- la date du premier jour de la semaine prochaine
and
cast (DATEADD(DAY,-DATEPART(WEEKDAY,GETDATE())+1+7+6,GETDATE()) as DATE) //-- la date du dernier jour de la semaine prochaine

//9

select *
from Projet
where Num_prj in
(
select Num_prj
from Tache
group by Num_prj
having count(distinct Num_tache)=
(
select MAX(PT.nombre_taches)    //-- le max de nombre de taches par projet
from 
(
select Num_prj,count(distinct Num_tache)as "nombre_taches" //-- table virtuelle
from Tache
group by Num_prj
) as "PT"
)
)

//10


select Num_prj,DATEDIFF(DAY,MIN(date_debut),max(date_fin)) as "Durée de réalisation"
from Tache
group by Num_prj

//C

//1
update Employe
set Salaire=case
when Age>60 then Salaire+Salaire*5/100
when Age between 58 and 60 then  Salaire+Salaire*0.5/100
else Salaire
end

//2
delete from Tache
where Num_tache in (select Num_tache from Tache where GETDATE()>date_fin) and Num_tache not in (select distinct Num_tache from Travaille)

//D
//1
create login CnxGestionnaire with password='123456'
create login [ChefProjet-PC\ChefProjet] from windows

//2
create user Gestionnaire from login CnxGestionnaire
create user ChefProjet from login [ChefProjet-PC\ChefProjet]

//3
grant insert,update,delete on Service to Gestionnaire
grant insert,update,delete on Projet to Gestionnaire
grant insert,update,delete on Tache to Gestionnaire
grant insert,update,delete on Travaille to Gestionnaire

//4
grant delete on Service to ChefProjet
grant delete on Projet to ChefProjet
grant delete on Tache to ChefProjet
grant delete on Travaille to ChefProjet

grant update (Adresse) on Employe to ChefProjet

create view V_Adress
as
select Adresse
from Employe

grant update on V_Adress to ChefProjet

