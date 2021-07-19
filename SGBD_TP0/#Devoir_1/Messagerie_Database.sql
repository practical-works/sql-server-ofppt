--drop database Messagerie
---------------------------------------------------
-- 1) Créer la base de données Messagerie
create database Messagerie;
use Messagerie;

-- 2) Créer les tables Employé et Message
create table Employe (
	id_employe int primary key,
	nom varchar(30),
	prenom varchar(30),
	date_naissance date,
	email varchar(30),
	telephone varchar(10)
);
create table Messagee (
	id_emetteur int,
	id_recepteur int,
	objet varchar(30),
	msg varchar(30),
	date_msg varchar(30)
	foreign key (id_emetteur) references Employe(id_employe),
	foreign key (id_recepteur) references Employe(id_employe)
);

-- 3) Ajouter les contraintes :

--		3-1) Nom en majuscules
alter table Employe add constraint c_nom
check ( nom = upper(nom) );

--		3-2) Prénom Commence par une majuscule et le reste en miniscule
alter table Employe add constraint c_prenom
check ( -- substring(string, start_index, characters_count)
		substring(prenom, 0, 1) = upper( substring(prenom, 0, 1) ) 
		and 
		substring(prenom, 1, len(prenom)) = lower( substring(prenom, 1, len(prenom)) ) 
      );

--		3-3) Format Email Valide
alter table Employe add constraint c_email
check ( email like '%@%.%' );

--		3-4) Format Téléphone marocain
alter table Employe add constraint c_telephone
check ( telephone like '06________' );

--		3-5) Age de l'employé entre 25 et 40 ans
alter table Employe add constraint c_age
check ( datediff(year,date_naissance,getdate()) between 25 and 40 );

--		3-6) Les champs objet et msg sont obligatoire
alter table Messagee alter column objet varchar(30) not null;
alter table Messagee alter column msg varchar(30) not null;

-- 4) Remplir les tables avec des enregistrements
delete from Employe;
insert into Employe values
(1,'Zahiri','Fatima','1989-11-30','fati@gmail.com','0623465678'),
(2,'Rahmani','Kamal','1985-02-27','kamal@gamil.com','0611456789'),
(3,'Ronar','Marama','19987-02-10','roro123@hotmail.com','0623667812'),
(4,'Ait Ali','Hafsa','1988-04-20','simaax7@gmail.com','0623661904'),
(5,'Saidaoui','Naim','1988-08-10','monhil@live.com','0677443211');
insert into Messagee values
(1,2,'Demande','Appelle-moi!','2016-09-22'),
(3,1,'Remarque','Je viens demain','2016-10-21'),
(1,4,'Préparation','Prépare toi pour le soir','2016-11-03'),
(2,5,'Rendez-vous','On se revois ce soir à maison','2016-12-01');

-- 5) Afficher les employés avec l'âge dépassant 30 ans
select * from Employe where datediff(year,date_naissance,getdate()) > 30;

-- 6) Afficher les messages reçu par l'employé 3
select * from Messagee where id_recepteur=3;

-- 7) Afficher les employés par ordre décroissant des noms
select * from Employe order by nom desc;