--Base de données pour la gestion de stock d’une pépinière.
--☼ La pépinière (المنبت أو المشتل) 
--☼ Les serres (البيوت البلاستيكية أو الدفيئات الزراعية)
--☼ Les bacs (الصواني أو الحاويات أو العلب)
--================================================================
--1. Créer la base de données relative au schéma relationnel ci-dessus et ajouter un
--jeu d’enregistrements pour toutes les tables. (4 pts)
create database Pépinière_v2_Db; --drop database Pépinière_v2_Db;
use Pépinière_v2_Db;
create table Administrateur (
	numAdmin int primary key identity(1,1), 
	loginAdmin varchar(30), 
	passwordAdmin varchar(30)
);
create table Serre (
	numSerre int primary key identity(1,1), 
	nomSerre varchar(30), 
	nbrBacs int,
	dateCreation date
);
create table Bac (
	numBac int primary key identity(1,1), 
	numSerre int foreign key references Serre (numSerre)
	on delete set null on update cascade, 
	nomBac varchar(30)
);
insert into Administrateur values
('admin', '123'),
('moder', '123'),
('user', '123');
insert into Serre values
('Serre Aîcha', 10, '01-01-2016'),
('serre de la gazelle', 2, '21-07-2015'),
('serre X-Plants-Projet88', 1, '30-09-2016'),
('serre des plantes tropicaux', 7, '10-10-2016'),
('Serre antique', 0, '22-01-1701');
insert into Bac values
(1,'Abricotier'),(1,'Acacia'),(1,'Agapanthe'),(1,'Aloès'),(1,'Althéa'),
(1,'Amandier'),(1,'Amaryllis'),(1,'Ancolie'),(1,'Anémone'),(1,'Anthémis'),
(2,'Bambou'),(2,'Bananier'),(3,'Chardon'),(4,'Dahlia'),(4,'Datura'),
(4,'Digitale'),(4,'Edelweiss'),(4,'Églantier'),(4,'Érable'),(4,'Eucalyptus');

--2. Ajouter les contraintes suivantes :
	--a. Le champ « nrbBacs » doit être une valeur numérique comprise entre 0 et 10. (0,5 pt)
alter table Serre add constraint c_nbrBacs check (nbrBacs between 0 and 10);
	--b. Le champ « nomBac » doit être unique. (0.5 pt)
alter table Bac add unique (nomBac);
	--c. Le champ « dateCreation » doit être inférieure ou égale à la date d’aujourd’hui. (0.5 pt)
alter table Serre add check (dateCreation <= getdate());

--3. Créer les requêtes suivantes :
	--a. Afficher la liste des serres qui contient au moins 5 bacs. (1 pt)
--• Méthode 1 en se basant sur la colonne nbrBacs de la table Serre
select * from Serre where nbrBacs >= 5;
--• Méthode 2 en se basant sur la relation entre les tables Serre et Bac
select * from Serre where numSerre in (
	select numSerre from Bac
	group by numSerre
	having count(*) >= 5
);
	--b. Afficher la liste des serres qui ne contient aucun bac. (2 pts)
--• Méthode 1 en se basant sur la colonne nbrBacs de la table Serre
select * from Serre where nbrBacs = 0;
--• Méthode 2 en se basant sur la relation entre les tables Serre et Bac
select * from Serre where numSerre not in ( select numSerre from Bac );

--4. Ecrire une procédure permettant de lister les serres créés entre deux date, les
--dates sont fournies en paramètre. (2,5 pts)
create proc serres_par_date
@date_min date, @date_max date 
as
select * from Serre where dateCreation between @date_min and @date_max;
--• Exécuter la procédure
exec serres_par_date '01-01-2016', '30-09-2016';

--5. Créer un déclencheur permettant de vérifier si le nombre des bacs insérés dans
--une serre est égale 9. Indiquant ainsi qu’il reste un seul bac à insérer dans cette serre. (3 pts)
-- drop trigger vérifier_bacs;
create trigger vérifier_bacs on Bac
instead of insert
as
begin
	declare @nbr_bacs_inérés int = (select count(*) from inserted);
	if (@nbr_bacs_inérés = 9)
	begin
		print 'Il vous reste un seul bac à insérer dans cette serre.';
	end	
end
--• Tester le déclencheur
insert into Bac values
(3, 'bac_test1'),(3, 'bac_test2'),(3, 'bac_test3'),
(3, 'bac_test4'),(3, 'bac_test5'),(3, 'bac_test6'),
(3, 'bac_test7'),(3, 'bac_test8'),(3, 'bac_test9');
select * from Bac;
select * from Bac where numSerre = 1;

-- ===================================================================
-- * Améliorations du déclencheur
-- ===================================================================
-- drop trigger vérifier_bacs;
create trigger vérifier_bacs on Bac
instead of insert
as
begin
	declare cur_serres cursor for
		select numSerre from Serre where numSerre in (select distinct numSerre from inserted);
	declare @numSerre int;
	open cur_serres;
	fetch cur_serres into @numSerre;
		while @@fetch_status = 0
		begin
			print '----------------------------------------------------------------';
			print '   Serre ' + convert(varchar, @numSerre);
			print '----------------------------------------------------------------';
			declare @nbr_bacs_existants int = (select count(*) from Bac where numSerre = @numSerre);
			print '• Nombre bacs existants : ' + convert(varchar, @nbr_bacs_existants) + ' / 10 max';
			declare @nbr_bacs_insérés int = (select count(*) from inserted where numSerre = @numSerre);
			print '• Nombre bacs à insérer : ' + convert(varchar, @nbr_bacs_insérés);
			declare @nbr_bacs_restants int = 10 - (@nbr_bacs_existants + @nbr_bacs_insérés);
			if @nbr_bacs_restants < 0
				begin
					print 'Bac(s) NON inséré !';
					print '=> AUCUN bac restant à insérer dans la serre ' + convert(varchar, @numSerre) + '!';
					--rollback;
				end
			else
				begin
					insert into Bac select numSerre, nomBac from inserted;
					print 'Bac(s) INSÉRÉ avec succés.';
					print '=> ' + convert(varchar, @nbr_bacs_restants) + 
						  ' bac(s) restants à insérer dans la serre ' + convert(varchar, @numSerre) + '.';
					print '';
				end
			fetch cur_serres into @numSerre;
		end
	close cur_serres;
	deallocate cur_serres;
end

insert into Bac values --(3, 'hhhhhhhhhhhhhhhhhh'),
(3, 'bac_test1'),(3, 'bac_test2'),(3, 'bac_test3'),
(3, 'bac_test4'),(3, 'bac_test5'),(3, 'bac_test6'),
(3, 'bac_test7'),(3, 'bac_test8'),(3, 'bac_test9'),
(1, 'bac_test'), (1,'');
select * from Bac;
select * from Bac where numSerre = 3;
select count(*) from Bac where numSerre = 3;