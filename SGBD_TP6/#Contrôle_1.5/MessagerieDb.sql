create database MessagerieDb; -- drop database MessagerieDb
use MessagerieDb;

create table Membre (
	id_membre int primary key,
	nom varchar(30),
	prenom varchar(30),
	date_naissance date
);
create table Messagee (
	id_emetteur int foreign key references Membre(id_membre),
	id_recepteur int foreign key references Membre(id_membre),	
	sujet varchar(30),
	body text,
	date_msg date,
	primary key(id_emetteur, id_recepteur, date_msg)
);

-- Ajouter un jeu de données pour chaque table
insert into Membre values
(1,'Zahiri','Fatima','1989-11-30'),
(2,'Rahmani','Kamal','1991-02-27'),
(3,'Ronar','Marama','1980-11-22'),
(4,'Ait Ali','Hafsa','1990-04-20'),
(5,'Saidaoui','Naim','1990-11-22');
insert into Messagee values
(1,2,'Demande','Appelle-moi!','2016-09-22'),
(1,1,'Remarque','Je viens demain','2016-11-21'),
(3,4,'Préparation','Prépare toi pour le soir','2016-11-03'),
(2,5,'Rendez-vous','On se revois ce soir à maison','2016-12-01');

-- Afficher les messages reçus par le memebre id = 2
select * from Messagee where id_recepteur = 2;

-- Afficher les messages envoyés au moins à 5 memebres
select * from Messagee where id_recepteur in (
	select id_recepteur from Messagee
	group by id_recepteur
	having count(*) >= 5
);

-- Afficher les membres qui vont fêter leur anniversaires demain
-- Méthode 1
select * from Membre
where dateadd(year, datediff(year, date_naissance, getdate()), date_naissance) 
= cast(dateadd(day, 1, getdate()) as date);
-- Méthode 2
select * from Membre 
where month(date_naissance) = month(getdate())
and day(date_naissance) = day(getdate())+1;

-- Ajouter la colonne état du message qui prend deux valeurs (0 : lu) et 1 : (non-lu)
alter table Messagee add etat bit;
select * from Messagee;

-- Afficher les membres qui ont envoyé et reçu le plus de messages (max émissions et réceptions)
select * from Membre where id_membre in (
	select id_emetteur from Messagee
	group by id_emetteur
	having count(*) in (
		select top 1 count(*) as 'NbrMsgEmis' from Messagee
		group by id_emetteur order by [NbrMsgEmis] desc
	)
)
and id_membre in (
	select id_recepteur from Messagee
	group by id_recepteur
	having count(*) in (
		select top 1 count(*) as 'NbrMsgReçus' from Messagee
		group by id_recepteur order by [NbrMsgReçus] desc
	)
);

-- Créer un profil 'SuperAdmin' avec mot de passe 'azerty'
create login SuperAdmin with password = 'azerty';

-- Créer un utilisateur avec le profil 'SuperAdmin', propriétaire de la base de données
-- drop user user1; 
create user admin_user for login SuperAdmin;
-- exec sp_droprolemember 'db_owner', 'user1';
exec sp_addrolemember 'db_owner', 'admin_user';
-- Afficher les permissions du rôle db_owner
exec sp_dbfixedrolepermission 'db_owner';

-- Connecter avec le nouveau utilisateur: 
-- execute as user = 'dbo';
execute as user = 'admin_user';
--Afficher le profile utilisé et l'utilisateur actuel
select system_user as 'Profile', current_user as 'Utilisateur'; 

--		Créer un utilisateur avec les privilèges suivants:
--			Consulter le nom et prénom d'un memebre et ses messages envoyés
create login UserProfile with password = 'abc123';
create user the_user for login UserProfile;
create view M as 
	select nom, prenom, Messagee.* 
	from Membre inner join Messagee
	on Membre.id_membre = Messagee.id_emetteur;
grant select on M to user2;
--			Supprimer le droit de séléctionner pour les différents tables
deny select on Membre to admin_user;
deny select on Messagee to admin_user;