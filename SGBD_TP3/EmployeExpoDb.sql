create database EmployeExpoDb; 
use EmployeExpoDb;
-- drop table Employe;
create table Employe (
	id int primary key identity(1,1),
	nom varchar(50),
	prenom varchar(50),
	ville varchar(50),
	Adresse varchar(300),
	Sexe varchar(1)
);
insert into Employe values
('El madani','Hassan','Marrakech','Syba 10','M'),
('Ramzi','Latifa','Fès','Massira 7','F'),
('Edahib','Fatima','Rabat','Kotban 80','F'),
('Kozan','Othman','Marrakech','Saba 10 Ziran','M'),
('Chadoglu','Farida','Ifran','Syba 7000','F'),
('Aidan','Nadia','Chefchaoun','Azar Mount','F');

select Nom+' '+Prenom as 'Nom complet' from Employe;
select concat(Nom, ' ', Prenom) as 'Nom complet' from Employe;

select concat(Nom, ' ', Prenom) as 'Nom complet' from Employe
where len(Nom) = (select max(len(Nom)) from Employe);

select left(Nom,2) as 'Deux premières lettres du Nom' from Employe;

select right(Prenom,2) as 'Deux dernières lettres du Prénom' from Employe;

select upper(Nom)+' '+upper(left(Prenom,1))+lower(substring(Prenom,2,len(Prenom))) 
as 'Nom en majuscule et prénom en capital'
from Employe;

select * from Employe where Prenom = reverse(Nom);

select concat (
	Nom, 
	' : ', 
	iif(Sexe='M', 'Homme', 'Femme')
)  as 'Nom : Sexe'
from Employe;
select concat (
	Nom, 
	' : ', 
	(case when Sexe='M' then 'Homme' else 'Femme' end)
)  as 'Nom : Sexe'
from Employe;
 