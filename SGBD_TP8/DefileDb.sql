--///////////////////////////////////////////////////////////////
create database DefileDb;
use DefileDb;
--///////////////////////////////////////////////////////////////
create table MemebreJury (
	NumMemebreJury int primary key,
	NomMemebreJury varchar(50),
	FonctionMemebreJury varchar(50)
);
create table Styliste (
	NumStyliste int primary key,
	NomStyliste varchar(30),
	AdrStyliste varchar(100)
);
create table Costume (
	NumCostume int primary key,
	DesignationCostume varchar(30),
	NumStyliste int foreign key references Styliste (NumStyliste)
	on delete set null on update cascade
);
create table NoteJury (
	NumCostume int foreign key references Costume (NumCostume)
	on delete set null on update cascade,
	NumMemebreJury int foreign key references MemebreJury (NumMemebreJury)
	on delete set null on update cascade,
	NoteAttribuée float,
	primary key (NumCostume, NumMemebreJury) 
);
create table Fonction (
	Fonction int primary key
);
--///////////////////////////////////////////////////////////////
--Créer les procédures stockées suivantes :
--(On propose aussi de réécrire chaque procédure en tant que fonction)
--///////////////////////////////////////////////////////////////

--==================================================================================================
--PS 1. Qui affiche la liste des costumes avec pour chaque costume le numéro, la
--désignation, le nom et l'adresse du styliste qui l'a réalisé.
--**************************************************************
-- Procédure :
--**************************************************************
create proc SP_ListeCostumes
as
	select C.DesignationCostume, S.NomStyliste, S.AdrStyliste  
	from Costume C inner join Styliste S on C.NumStyliste = S.NumStyliste;
-- Exécuter :
exec SP_ListeCostumes;
--**************************************************************
-- Fonction :
--**************************************************************
create function F_ListeCostumes() 
returns table
as
	return (select C.DesignationCostume, S.NomStyliste, S.AdrStyliste  
	from Costume C inner join Styliste S on C.NumStyliste = S.NumStyliste);
-- Exécuter :
select * from F_ListeCostumes();
--==================================================================================================
--PS 2. Qui reçoit un numéro de costume et qui affiche la désignation, le nom et
--l'adresse du styliste concerné.
--_______________________
-- Procédure :
create proc SP_Costume
	@NumCostume int
as
	select C.DesignationCostume, S.NomStyliste, S.AdrStyliste  
	from Costume C inner join Styliste S on C.NumStyliste = S.NumStyliste
	where NumCostume = @NumCostume;
-- Exécuter :
exec SP_Costume 3;
--_______________________
-- Fonction :
create function F_Costume(@NumCostume int) 
returns table
as
	return (select C.DesignationCostume, S.NomStyliste, S.AdrStyliste  
	from Costume C inner join Styliste S on C.NumStyliste = S.NumStyliste
	where NumCostume = @NumCostume);
-- Exécuter : 
select * from F_Costume(3);
--==================================================================================================
--PS 3. Qui reçoit un numéro de costume et qui affiche la liste des notes attribuées
--avec pour chaque note le numéro du membre de jury qui l'a attribué, son nom, sa
--fonction et la note.
--_______________________
-- Procédure :
create proc SP_ListeNotes
	@NumCostume int
as
	select N.NumCostume, N.NumMemebreJury, M.NomMemebreJury, 
	M.FonctionMemebreJury, N.NoteAttribuée 
	from NoteJury N inner join MemebreJury M
	on N.NumMemebreJury = M.NumMemebreJury
	where NumCostume = @NumCostume;
-- Exécuter :
exec SP_ListeNotes 3;
--_______________________
-- Fonction :
create function SP_ListeNotes(@NumCostume int)
returns table
as
	return (select N.NumCostume, N.NumMemebreJury, M.NomMemebreJury, 
	M.FonctionMemebreJury, N.NoteAttribuée 
	from NoteJury N inner join MemebreJury M
	on N.NumMemebreJury = M.NumMemebreJury
	where NumCostume = @NumCostume);
-- Exécuter :
exec SP_ListeNotes 3;
--==================================================================================================
--PS 4. Qui retourne le nombre total de costumes.
--_______________________
-- Procédure :
create proc SP_NombreTatalCostumes 
as
    select count(*) as 'Nombre total de costumes' from Costume;
-- Exécuter :
exec SP_NombreTatalCostumes;
--_______________________
-- Fonction :
create function F_NombreTatalCostumes()
returns int 
as
begin
	declare @nbr int = (select count(*) from Costume);
	return @nbr;
end
-- Exécuter
select dbo.F_NombreTatalCostumes() as 'Nombre total de costumes';
--==================================================================================================
--PS 5. Qui reçoit un numéro de costume et un numéro de membre de jury et qui
--retourne la note que ce membre a attribué à ce costume.
--_______________________
-- Procédure :
create proc SP_Note 
    @NumCostume int,
    @NumMemebreJury int  
as
    select * from NoteJury 
	where NumCostume = @NumCostume
	and NumMemebreJury = @NumMemebreJury;
-- Exécuter :
exec SP_Note 1, 1;
--_______________________
-- Fonction :
create function F_Note(@NumCostume int, @NumMemebreJury int)
returns float
as
begin
    declare @Note float = (select NoteAttribuée from NoteJury 
	where NumCostume = @NumCostume and NumMemebreJury = @NumMemebreJury);
	return @Note;
end
-- Exécuter :
select dbo.F_Note(1, 1) as 'Note';
--==================================================================================================
--PS 6. Qui reçoit un numéro de costume et qui retourne sa moyenne.
--_______________________
-- Procédure :
create proc SP_Moyenne 
    @NumCostume int  
as
    select avg(NoteAttribuée) as 'Moyenne' from NoteJury where NumCostume = @NumCostume;
-- Exécuter :
exec SP_Moyenne 1;
--_______________________
-- Fonction :
create function F_Moyenne (@NumCostume int)
returns float
as
begin
    declare @Moyenne float = (select avg(NoteAttribuée) as 'Moyenne' 
	from NoteJury where NumCostume = @NumCostume);
	return @Moyenne;
end
-- Exécuter :
select dbo.F_Moyenne(1) as 'Moyenne';
--==================================================================================================
