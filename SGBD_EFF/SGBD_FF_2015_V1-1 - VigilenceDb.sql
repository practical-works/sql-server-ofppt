--====================================================
-- Société VIGILENCE
--====================================================
create database VigilenceDb;
use VigilenceDb;
--====================================================
create table Region (
	code_region int primary key, 
	nom_region varchar(50), 
	population_region int, 
	total_region money
);
create table Ville (
	code_ville int primary key, 
	nom_ville varchar(50), 
	code_region int foreign key references Region (code_region)
	on delete set null on update cascade, 
	total_ville money
);
create table Quartier (
	code_quartier int primary key, 
	nom_quartier varchar(50), 
	population_quartier int, 
	code_ville int foreign key references Ville (code_ville)
	on delete set null on update cascade, 
	total_quartier money
);
create table Bien_immobilier (
	code_bien int primary key, 
	adresse_bien varchar(100), 
	num_enregistrement bigint,
	superficie float, 
	type_bien varchar(50), 
	code_quartier int foreign key references Quartier (code_quartier)
	on delete set null on update cascade, 
	date_construction date
);
create table Syndic (
	code_syndic int primary key, 
	nom_syndic varchar(50), 
	prenom_syndic varchar(50), 
	telephone_syndic varchar(50), 
	mot_depasse varchar(50)
);
create table Contrat (
	numcontrat int primary key, 
	datecontrat date, 
	prix_mensuel money, 
	code_bien int foreign key references Bien_immobilier (code_bien)
	on delete set null on update cascade, 
	code_syndic int foreign key references Syndic (code_syndic)
	on delete set null on update cascade,
	etat varchar(50)
);
--====================================================
-- Requêtes pour ADO
--====================================================
select * from Syndic where code_syndic in ( 
	select code_syndic from Contrat where code_bien in (
		select code_bien from Bien_immobilier where code_quartier = 3 and type_bien='Appartement' ))
--====================================================
select * from Contrat;
--====================================================
select count(*) from Contrat where code_bien in (
	select code_bien from Bien_immobilier where code_quartier = 1)
	and
	datecontrat > '01-01-' + convert(varchar(4), datepart(year, getdate()));
--====================================================
select sum(total_quartier) from Quartier where code_quartier = 1
and code_quartier in (select code_quartier from Bien_immobilier where code_bien in (
select code_bien from Contrat where datecontrat > '01-01-' + convert(varchar(4), datepart(year, getdate()))));
--====================================================
select count(*) from Syndic where code_syndic in (
	select code_syndic from Contrat where 
	code_bien in (select code_bien from Bien_immobilier where code_quartier = 1)
	and 
	datecontrat >= '01-01-' + convert(varchar(4), datepart(year, getdate()))
);
--====================================================
--====================================================
--====================================================
--====================================================
select TABLE_NAME from INFORMATION_SCHEMA.TABLES;
--====================================================
--1. Créer la base de données avec un jeu de trois enregistrements pour chaque table.(3 pts)
insert into Region values
(1, 'Région de la fontaine', 2000, 10000), 
(2, 'Région du Ciel', 1000, 19000),
(3, 'Région de la victoire', 5000, 489000);
select * from Region;
--====================================================
insert into Ville values
(1, 'Santa Maria Town', 2, 989),
(2, 'Maro Kichi Kich', 3, 1792),
(3, 'Holy Island', 2, 724);
select * from Ville;
--====================================================
insert into Quartier values
(1, 'Quartier de la requête', 120, 2, 132),
(2, 'Quartier de la commande', 111, 2, 119),
(3, 'Quartier sacré', 19, 3, 290);
select * from Quartier;
--====================================================
insert into Bien_immobilier values
(1, 'Place Mércure L10', 2367306, 120.60, 'Appartement', 2, '12-03-1990'),
(2, 'Xandra Area X1245', 7645390, 120.60, 'Appartement', 1, '12-03-2000'),
(3, 'Place de la bible, Couverture N°99', 3004580, 120.60, 'Villa', 3, '12-03-2016');
select * from Bien_immobilier;
--====================================================
insert into Syndic values
(1, 'Ilamiz', 'Mouna', '0645095678', 'mimi1234'),
(2, 'Kinoss', 'Soufiana', '0645790023', 'azerty111'),
(3, 'Chojâa', 'Horona', '0630502946', 'kiskisne7la');
select * from Syndic;
--====================================================
insert into Contrat values
(1, '22-11-2016', 3000, 1, 2, 'En cours'),
(2, '02-09-2016', 2000, 3, 1, 'En cours'), 
(3, '21-10-2016', 1000, 2, 3, 'Résilié');
select * from Contrat;
--====================================================

--2. Donner le nombre de biens de type appartement par quartier géré par la société VIGILENCE. (3 pts)
select code_quartier, count(*) as 'Nombre de biens' from Bien_immobilier 
where type_bien = 'Appartement'
group by code_quartier;

--3. Dans la table contrat ont veut appliquer la contrainte suivante : la colonne état ne peut
--prendre que deux valeurs possibles : actif ou résilié (3 pts)
alter table Contrat add constraint c_etat
check (etat in ('En cours', 'Résilié')); 

--4. Créer une procédure qui retourne dans des paramètres de sortie le nombre de biens
--immobiliers ainsi que le chiffre d'affaires pour un bien de type <<villa>> saisi comme paramètre. (3 pts)
create proc sp_infos_type_bien
	@type_bien varchar(max),
	@nbr_biens int output, @chiff_aff money output
as
	set @nbr_biens = ( select count(*) from Bien_immobilier where type_bien = @type_bien );
	set @chiff_aff = ( select sum(total_quartier) from Quartier where code_quartier in (
								select code_quartier from Bien_immobilier where type_bien = @type_bien ) );
--Exécuter la procédure :
declare @nombre int , @chiffre money;
exec sp_infos_type_bien 'Villa', @nombre output, @chiffre output;
select @nombre as 'Nombre de biens', @chiffre as 'Chiffre d''affaire';

--5. Créer une fonction qui retourne pour les biens de type << villa > localisés à
--Casablanca, Le chiffre d'affaire total réalisé et ceci pour un quartier saisi comme
--paramètre. (3 pts)
alter function nbr_biens (@code_quartier int)
	returns money
as
begin
	return ( select sum(total_quartier) from Quartier where 
				code_quartier = @code_quartier
				and 
				code_quartier in (select code_quartier from Bien_immobilier where type_bien = 'Appartement')
				and 
				code_ville in (select code_ville from Ville where nom_ville = 'Maro Kichi Kich')
		   );
end
--Exécuter la fonction :
select dbo.nbr_biens(1) as 'Chiffre d''affaire total réalisé';

--6. Créer un déclencheur qui calcul automatiquement la valeur du champ total_quartier en DH, 
--réalisé par l'agence, suite à une mise à jour d'un bien relatif au quartier en question. (3 pts)
create trigger calculer_total_quartier
	on Quartier
	for insert, update, delete
as
begin
	
end
--Exécuter le déclencheur :

