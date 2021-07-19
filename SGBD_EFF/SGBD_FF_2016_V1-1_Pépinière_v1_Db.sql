--Base de données pour la gestion de stock d’une pépinière.
--☼ La pépinière (المنبت أو المشتل) 
--☼ Les variétés (الأنواع)
--☼ Les parcs (الحدائق أو المنتزهات)
--☼ Les plantes (النباتات)
--================================================================
create database Pépinière_v1_Db; --drop database Pépinière_v1_Db;
Use Pépinière_v1_Db;
--1. Créer la base de données relative au schéma relationnel ci-dessus 
--et ajouter un jeu d’enregistrements pour toutes les tables. (4 pts)
create table Administrateur (
	numAdmin int primary key identity(1,1), 
	loginAdmin varchar(50), 
	passwordAdmin varchar(50)
);
create table Variété (
	numVariete int primary key identity(1,1),
	nomVariete varchar(50)
);
create table Parc (
	numParc int primary key identity(1,1), 
	nomParc varchar(50),
	dateCreation date, 
	origine varchar(50),
	modeMultiplication varchar(50), 
	numVariete int foreign key references Variété (numVariete)
	on delete set null on update cascade
);
create table Plante (
	numPlante int primary key identity(1,1),
	numVariete int foreign key references Variété (numVariete)
	on delete set null on update cascade,
	numParc int foreign key references Parc (numParc)
);
--• Enregistrements
insert into Administrateur values
('admin', '123'),
('moder', '123'),
('user', '123');
insert into Variété values
('Phanérophytes'),('Chaméphytes'),('Hémicriptophytes'),('Thérophytes'),
('Géophytes'),('Hydrophytes'),('Hélophytes');
insert into Parc values 
('Parc du pouce', '01-01-2000', 'Marrakech', 'Par voie sexuée', 3),
('Parc de l''index', '02-02-2002', 'Rabat', 'Par suppression du tronc', 4),
('Parc du majeur', '03-03-2003', 'Fès', 'Par éclatement des souches', 7),
('Parc de l''annulaire', '04-04-2004', 'Tétouan', 'Par les rejetons', 5),
('Parc de l''auriculaire', '05-05-2005', 'Tanger', 'Par voie sexuée', 2);
insert into Plante values
(1,1),(3,2),(3,3),(3,4),(3,5),
(3,1),(3,2),(3,3),(3,4),(3,5),
(3,1),(4,2),(7,3),(5,4),(2,5);

--2. Ajouter les contraintes  suivantes :
	--a. Le champ « modeMultiplication » doit appartenir à la liste des constantes suivantes : 
	--Semi-ligneux, Par les rejetons, Par éclatement des souches, Par voie sexuée, 
	--Par suppression du tronc.(0,5pt)
alter table Parc add constraint c_modeMultiplication
check (
	modeMultiplication in (
		'Semi-ligneux', 'Par les rejetons', 'Par éclatement des souches', 
		'Par voie sexuée', 'Par suppression du tronc'
	)
);
	--b. Le champ « nomParc » doit être unique.(0.5 pt)
alter table Parc add constraint uni_nomParc unique (nomParc);

--3. Créer les requêtes suivantes :
	--a. Afficher la liste variétés qui contient au moins 10 plantes. (1 pt)
select * from Variété where numVariete in (
	select numVariete from Plante
	group by numVariete
	having count(*) >= 10
);
	--b. Afficher la liste des variétés qui appartient au moins à deux parcs. (2 pts)
select * from Variété where numVariete in (
	select numVariete from Parc
	group by numVariete
	having count(*) >= 2
);
	--c. Afficher les plantes d’une variété : (3 pts)
	--Exemple :
	-- ___________________________________________________________
	--|	Variété : Picholine languedoc	     Nombre de plante : 2 |
	--|	Plante1 : 3		                                          |
	--|	Plante2 : 5	                                              |
	--|___________________________________________________________|
declare CurVar cursor for
	select Variété.numVariete, Variété.nomVariete 
	from Plante inner join Variété on Plante.numVariete = Variété.numVariete
	group by Variété.numVariete, Variété.nomVariete;
declare @nomVariete varchar(max), @numVariete int;
open CurVar;
	fetch CurVar into @numVariete, @nomVariete;
	while @@fetch_status = 0
		begin
			declare CurPlan cursor for
				select numPlante from Plante where numVariete=@numVariete;
			declare @numPlante int;
			declare @nombrePlantes int = (
				select count(*) from Plante where numVariete=@numVariete
			);
			print '==================================================================';
			print 'Variété: ' + @nomVariete + '         Nombre de plantes: '
				   + convert(varchar, @nombrePlantes);
			open CurPlan;
				fetch CurPlan into @numPlante;
				declare @i int = 0;
				while @@fetch_status = 0
					begin
						set @i+=1;
						print 'Plante ' + convert(varchar, @i) + ' : ' + convert(varchar,@numPlante);
						fetch CurPlan into @numPlante;
					end
			close CurPlan;
			deallocate CurPlan;
			fetch CurVar into @numVariete, @nomVariete;
		end
close CurVar;
deallocate CurVar;
	
--4.Ecrire une procédure permettant de lister les plantes situées dans un parc précis 
--et dans le modeMultiplication sera fourni en paramètre.(3 pts)
create procedure liste_plantes
@numParc int, @modeMultiplication varchar(50)
as
select * from Plante where numParc = @numParc and numParc in (
	select numParc from Parc where modeMultiplication = @modeMultiplication );
--• Exécuter la procédure
execute liste_plantes 1, 'Par voie sexuée';