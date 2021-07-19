-- Créer la base de données EntrepriseDb
create database EntrepriseDb;
use EntrepriseDb;
-- Créer les 5 tables
create table Departement (
	num_dep int primary key,
	nom_dep varchar(50),
	site_dep varchar(50)
);
create table Employe (
	num_emp int primary key,
	nom_emp varchar(50),
	fonction_emp varchar(50),
	sup_emp int foreign key references Employe(num_emp),
	salaire_emp float,
	num_dep int foreign key references Departement(num_dep)
);
create table Projet (
	code_proj varchar(50) primary key,
	nom_proj varchar(50)
);
create table Historique (
	num_emp int foreign key references Employe(num_emp),
	date_fonction date,
	fonction_emp varchar(50)
	primary key (num_emp,date_fonction)
);
create table Travailler (
	code_proj varchar(50) foreign key references Projet(code_proj),
	num_emp int foreign key references Employe(num_emp),
	primary key (code_proj,num_emp)
);
-- Ajouter des enregistrement aux tables
insert into Departement values (1,'Présidence','Grand Centre')
insert into Departement values (2,'Communication','Pavillon centrale')
insert into Departement values (3,'Dévelopement','Pavillon Nord')
insert into Employe values (1,'El hassan Hassani','Directeur', null, 1000000, 1);
insert into Employe values (2,'Nadira El fassi','Secretaire', 1, 3000, 1);
insert into Employe values (3,'Moulay Arak','Programmeur', 1, 5000, 1);
insert into Employe values (4,'Said Niman','Testeur', 3, 4500, 1);
insert into Employe values (5,'Nadia Berkoks','Marketing', 2, 3000, 1);
insert into Employe values (6,'Farid Siyaj','Support', 2, 2500, 1);
insert into Projet values ('1','Plateforme en ligne');
insert into Projet values ('2','Logiciel de Montage');
insert into Travailler values ('1',3),('1',4),('2',6),('2',5);
insert into Travailler values ('2',3),('1',2),('2',2);

--1. Écrire les requêtes SELECT répondant aux questions suivantes:

--2. Donner la liste des numéros et noms des employés du département 20
select num_emp,nom_emp from Employe where num_dep=20;

--3. Donner la liste des numéros et noms des ouvriers et leur numéro de département
select num_emp,nom_emp,num_dep from Employe where fonction_emp='Ouvrier';

--4. Donner les noms des vendeurs du département 30 dont le salaire est supérieur à 1500
select nom_emp from Employe where fonction_emp='Vendeur' and num_dep=30 and salaire_emp>1500;

--5. Donner la liste des noms, fonctions et salaires des directeurs et des présidents
select nom_emp,fonction_emp,salaire_emp from Employe where fonction_emp in ('Directeur','Président');

--6. Donner la liste des noms, fonctions et salaires des directeurs et des employés qui ont un
--salaire > 5000
select nom_emp,fonction_emp,salaire_emp from Employe where fonction_emp='Directeur' or salaire_emp>5000;

--7. Donner la liste des noms et fonctions des directeurs du département 10 et des ouvriers du
--département 20.
select nom_emp,fonction_emp from Employe where (fonction_emp='Directeur' and num_dep=10) 
or (fonction_emp='Ouvrier' and num_dep=20);

--8. Donner la liste des noms, des fonctions et des numéros du département des employés qui ne
--sont pas ni ouvrier ni directeur
select nom_emp,fonction_emp,num_dep from Employe where fonction_emp not in('Ouvrier','Directeur');

--9. Donner la liste des noms, fonctions et salaires des employés qui gagnent entre 2200 et 2800
select nom_emp,fonction_emp,salaire_emp from Employe where salaire_emp between 2200 and 2800;

--10. Donner la liste des noms, des fonctions et des numéros du département des employés ouvrier,
--secrétaire ou vendeur
select nom_emp,fonction_emp,num_dep from Employe where fonction_emp in ('Ouvrier','Secretaire','Vendeur');

--11. Donner la liste des employés dont le responsable est connu
select * from Employe where sup_emp is not null;

--12. Donner la liste des employés dont le responsable n’est pas connu
select * from Employe where sup_emp is null;

--13. Donner la liste des salaires, fonctions et noms des employés du département 20, selon l’ordre
--croissant des salaires
select salaire_emp,fonction_emp,nom_emp from Employe where num_dep=20 order by salaire_emp asc;

--14. Donner la liste des salaires, fonctions et noms des employés du département 20, selon l’ordre
--décroissant des salaires
select salaire_emp,fonction_emp,nom_emp from Employe where num_dep=20 order by salaire_emp desc;

--15. Donner la liste des employés triée selon l’ordre croissant des fonctions et l’ordre décroissant
--des salaires
select * from Employe order by fonction_emp asc, salaire_emp desc;

--16. Donner la moyenne des salaires des tous les employés
select AVG(salaire_emp) as 'Moyenne des salaires des employés' from Employe;

--17. Donner la moyenne des salaires des ouvriers.
select AVG(salaire_emp) as 'Moyenne des salaires des ouvriers' 
from Employe where fonction_emp='Ouvrier';

--18. Donner le plus haut salaire et le plus bas salaire de tous les employés
select MAX(salaire_emp) as 'Plus haut salaire', MIN(salaire_emp) as 'Plus bas salaire' from Employe;

--19. Donner le nombre d’employés du départment 10
select count(*) as 'Nombre d’employés du départment 10' 
from Employe where num_dep=1;

--20. Donner le nombre de différentes fonctions occupées par les employés du département 10
select count(distinct fonction_emp) as 'Nombre de fonctions du département 10'
from Employe where num_dep=1;

--21. Donner la moyenne des salaires pour chaque département (afficher numéro de département et moyenne)
select num_dep,avg(salaire_emp) as 'Moyenne des salaires' from Employe group by num_dep;

--22. Donner pour chaque département, le salaire annuel moyen des employés qui ne sont pas ni
--directeurs ni président
select num_dep,avg(salaire_emp)*12 as 'Salaire Annuel Moyen' from Employe 
where fonction_emp not in ('Directeur','Présient') group by num_dep;

--23. Donner pour chaque fonction de chaque département le nombre d’employés et le salaire moyen.
select num_dep as 'Département', 
count(*) as 'Nombre d''employés par fonction',
avg(salaire_emp) as 'Salaire moyen'  
from Employe group by fonction_emp,num_dep;

--24. Donner la liste des salaires moyens pour les fonctions comportant plus de deux employés.
select avg(salaire_emp),fonction_emp from Employe group by fonction_emp having count(num_emp)>=2;

--25. Donner la liste des numéros de départements avec au moins deux secrétaires.
select num_dep as 'numéros de départements avec au moins deux secrétaires'
from Employe where fonction_emp='Secretaire' group by num_dep having count(fonction_emp)<=2;

--26. Donner le nom de chaque employé et la ville (site_dep) dans laquelle il/elle travaille.
-- Méthode 1
select Employe.nom_emp, Departement.site_dep
from Employe, Departement
where Employe.num_dep = Departement.num_dep;
-- Méthode 2
select Employe.nom_emp, Departement.site_dep 
from Employe inner join Departement 
on Employe.num_dep = Departement.num_dep;

--27. Donner la ville (site_dep) dans laquelle travaille l'employé 1035.
-- Méthode 1
select Employe.num_dep, site_dep 
from Departement, Employe 
where Employe.num_dep = Departement.num_dep 
and num_emp=3;
-- Méthode 2
select Employe.num_emp,Employe.num_dep, site_dep 
from Departement inner join Employe 
on Employe.num_dep = Departement.num_dep
where num_emp=3;

--28. Donner les noms, fonctions et noms des départements des employés des départements 20 et 30
-- Méthode 1
select Employe.nom_emp, Employe.fonction_emp, Departement.nom_dep 
from Employe, Departement
where Employe.num_dep = Departement.num_dep
and (Departement.num_dep=2 or Departement.num_dep=3);
-- Méthode 2
select Employe.nom_emp,Employe.fonction_emp,Departement.nom_dep 
from Employe inner join Departement
on Employe.num_dep = Departement.num_dep
where Departement.num_dep=2 or Departement.num_dep=3; --Departement.num_dep in(2,3)

--29. Donner les noms des tous employés et les noms de leur responsable (renommer l’attribut
--responsable en ‘CHEF’)
-- Méthode 1 (équivalent à inner join)
select EMP.nom_emp as 'Employé', CHEF.nom_emp as 'Chef'
from Employe as EMP, Employe as CHEF
where EMP.sup_emp = CHEF.num_emp;
-- Méthode 2 (self join)
select EMP.nom_emp as 'Employé', CHEF.nom_emp as 'Chef'
from Employe EMP inner join Employe CHEF
on EMP.sup_emp = CHEF.num_emp;

--30. Donner la liste des noms et salaires des employés qui gagnent au moins que leur responsable
--(afficher aussi les noms des responsables)
select EMP.nom_emp as 'Employé', EMP.salaire_emp as 'Salaire', CHEF.nom_emp as 'Chef'
from Employe EMP left join Employe CHEF
on EMP.sup_emp = CHEF.num_emp
where EMP.salaire_emp < CHEF.salaire_emp;

--31. Donner la liste des noms, salaires, fonctions des employés qui gagnent plus que l'employé 1035.
select nom_emp as 'Employé', salaire_emp  as 'Salaire', fonction_emp as 'Fonction'
from Employe where salaire_emp >= (select salaire_emp from Employe where num_emp=3)
order by salaire_emp;

--32. Donner les noms des tous employés et, s’il est connu, les noms de leur responsable
--(renommer l’attribut responsable en ‘CHEF’)
select EMP.nom_emp as 'Employé', CHEF.nom_emp as 'Chef' 
from Employe EMP left join Employe CHEF
on EMP.sup_emp = CHEF.num_emp;

--33. Donner les noms des employés et les noms de projets aux quels ils participent.
select Employe.nom_emp as 'Employé', Projet.nom_proj as 'Projet'
from Travailler 
inner join Employe on Employe.num_emp = Travailler.num_emp
inner join Projet on Projet.code_proj = Travailler.code_proj
order by nom_emp;
------------- Nombre de projets pour chaque employé
select Employe.nom_emp as 'Employé', count(*) as 'Nombre de Projets'
from Travailler 
inner join Employe on Employe.num_emp = Travailler.num_emp
inner join Projet on Projet.code_proj = Travailler.code_proj
group by Employe.nom_emp;
-------------

--34. Donner les projets aux quels l'employé 1035 participe.
select Projet.*
from Travailler 
inner join Projet on Projet.code_proj = Travailler.code_proj
where Travailler.num_emp=2;

--35. Donner les noms des ingénieurs qui participent au projet ‘EAST_MARKETS’
select Employe.nom_emp
from Travailler 
inner join Employe on Employe.num_emp = Travailler.num_emp
inner join Projet on Projet.code_proj = Travailler.code_proj
where Employe.fonction_emp='Marketing' and Projet.nom_proj='Jeu vidéo RPG'

--36. Donner les noms des tous les employés et les noms de projets aux quels ils participent (même
--s’ils ne participent à aucun projet)
select Employe.nom_emp as 'Employé', Projet.nom_proj as 'Projet'
from Travailler 
right join Employe on Employe.num_emp = Travailler.num_emp
left join Projet on Projet.code_proj = Travailler.code_proj

--37. Donner les noms des tous les directeurs et les noms de projets aux quels ils participent (même
--s’ils ne participent à aucun projet)
select Employe.nom_emp as 'Directeurs', Projet.nom_proj as 'Projet'
from Travailler
right join Employe on Employe.num_emp = Travailler.num_emp
left join Projet on Projet.code_proj = Travailler.code_proj
where fonction_emp = 'Directeur';

--38. Donner les noms et fonctions des employés qui gagnent plus que 'Mahmoudi'.
select nom_emp,fonction_emp from Employe 
where salaire_emp > (select salaire_emp from Employe where nom_emp='Nadira El fassi'); 

--39. Donner les noms département où il y a des employés qui gagnent plus de 3000.
select distinct Departement.nom_dep from Departement inner join Employe
on Departement.num_dep = Employe.num_dep where salaire_emp>3000;

--40. Donner les fonctions dont la moyenne des salaires est inférieure à la moyenne de celle des ingénieurs
select fonction_emp from Employe 
group by fonction_emp 
having AVG(salaire_emp) < (select AVG(salaire_emp) from Employe where fonction_emp='Secretaire');

--41. Donner les employés qui ont occupé les fonctions de vendeurs et d’ouvriers
select Employe.*
from Historique inner join Employe on Historique.num_emp = Employe.num_emp
where Employe.fonction_emp = 'Support'
intersect
select Employe.* 
from Historique inner join Employe on Historique.num_emp = Employe.num_emp
where Employe.fonction_emp = 'Secretaire';

--42. Donner les employés qui n’ont jamais été vendeurs
select Employe.nom_emp, Historique.fonction_emp 
from Historique inner join Employe on Historique.num_emp = Employe.num_emp
where Historique.fonction_emp != 'Support';

--43. Donner les projets où ne travaillent que des ingénieurs

