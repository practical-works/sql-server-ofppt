/*Créer et Utiliser la base de données---------------------------------*/
create database DepartementDb;
use DepartementDb;
/*Créer les tables Salle et Machine---------------------------------*/
create table Salle (
	id_salle int primary key,
	code_salle varchar(3) unique not null,
	);
create table Machine (
	id_machine int primary key,
	marque varchar(30),
	id_salle int
	);
/*Ajouter les contraintes : Format d'écriture du code salle
et Clé étrangère de Machine vers Salle ---------------------------------*/
alter table Salle add constraint c_codesalle check (code_salle like '[A-Z][0-9][0-9]');
alter table Machine add constraint fk_salle foreign key(id_salle) references Salle(id_salle);
/*Insérer des enregistrements dans les tables---------------------------------*/
insert into Salle values (1,'A01'),(2,'A02'),(3,'A03'),(4,'A04'),(5,'A05');
insert into Machine values (1,'HP',1),(2,'Samsung',1),(3,'Vaio',1),(4,'HP',2),
(5,'HP',3),(6,'HP',3),(7,'HP',4),(8,'Centrino',4),(9,'HP',4),(10,'HP',5);
/*Afficher les données stockées dans les tables---------------------------------*/
select * from Salle;
select * from Machine;
select code_salle from Salle;
select marque,id_salle from Machine;
select * from Salle where code_salle='A03';
select * from Machine where id_salle=4;
select distinct marque from Machine; 
/*Supprimer des données sous contrainte---------------------------------*/
alter table Machine drop constraint fk_salle;
alter table Machine add constraint fk_salle 
	foreign key(id_salle) references Salle(id_salle) on delete set null;
delete from Salle where id_salle=2;
select * from Machine where id_salle=null;
/*Mettre à jour des données sous contrainte---------------------------------*/
alter table Machine drop constraint fk_salle; 
alter table Machine add constraint fk_salle  
	foreign key(id_salle) references Salle(id_salle) on delete set null on update cascade;
update Salle set id_salle=17 where id_salle=1;
select * from Machine where id_salle=17;
/*---------------------------------*/
/*---------------------------------*/
/*---------------------------------*/
/*---------------------------------*/
/*---------------------------------*/
