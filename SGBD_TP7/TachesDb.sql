create database TachesDb;
use TachesDb;
create table Projet (
	idProjet int primary key,
	nom varchar(50),
	dateDebut date,
	dateFin date,
);
create table Tache (
	idTache int primary key,
	idProjet int foreign key references Projet (idProjet),
	nomTache varchar(50),
	dateDebut date,
	dateFin date,
	etat bit,
	montant money
);

-- 1) Pour chaque projet afficher : Nom_Projet, Nom_Tâche, Montant_Projet
declare CurPrj cursor for 
	select Projet.idProjet, nom, sum(montant) as montantProjet
	from Tache inner join Projet on Tache.idProjet = Projet.idProjet
	group by Projet.idProjet, nom;
declare @idProjet int, @nom varchar(max), @nomTache varchar(max), @montantProjet money;
open CurPrj;
	fetch next from CurPrj into @idProjet, @nom, @montantProjet;
	while @@fetch_status = 0
		begin
		print '----------------------------------------------------';
		print '(*) Projet: ' + @nom;
		print '(@) Tâches: ';
		declare CurT cursor for 
			select nomTache from Tache where idProjet = @idProjet;
		open CurT;
		fetch next from CurT into @nomTache;
			while @@fetch_status = 0
				begin
				print '	• ' + @nomTache;
				fetch next from CurT into @nomTache;
				end
		close CurT;
		deallocate CurT;
		print '($) Montant Total: ' + convert(varchar, @montantProjet) + ' DH';
		fetch next from CurPrj into @idProjet, @nom, @montantProjet;
		end
close CurPrj;
deallocate CurPrj;

-- 2) Pour chaque projet afficher : Nom_Projet, Nombre_Tâches_Réalisées, Nombre_Tâches_Restantes
declare CurPrj cursor for 
	select Projet.idProjet, nom
	from Tache inner join Projet on Tache.idProjet = Projet.idProjet
	group by Projet.idProjet, nom;
declare @idProjet int, @nom varchar(max), @nbrTaches_Real int, @nbrTaches_Rest int;
open CurPrj;
	fetch next from CurPrj into @idProjet, @nom;
	while @@fetch_status = 0
		begin
		print '----------------------------------------------------';
		print 'Projet: ' + @nom;
		set @nbrTaches_Real = (select count(*) from Tache where etat = 1 and idProjet = @idProjet);
		set @nbrTaches_Rest = (select count(*) from Tache where etat = 0 and idProjet = @idProjet);
		print 'Nombre Tâches Réalisées: ' + convert(varchar, @nbrTaches_Real);
		print 'Nombre Tâches Restantes: ' + convert(varchar, @nbrTaches_Rest);
		fetch next from CurPrj into @idProjet, @nom;
		end
close CurPrj;
deallocate CurPrj;
