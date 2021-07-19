--///////////////////////////////////////////////////////////////
create database FabricationDb;
use FabricationDb;
--///////////////////////////////////////////////////////////////
create table Fournisseur (
	NumFour int primary key,
	RsFour varchar(50),
	AdrFour varchar(50),
	NbrProduitsFournis int
);
create table ProduitBrut (
	CodProBrut int primary key,
	NomProBrut varchar(50),
	PrixAchat money,
	NumFour int foreign key references Fournisseur (NumFour)
	on delete set null on update cascade
);
create table ProduitFini (
	CodProFini int primary key,
	NomPro varchar(30),
	QteEnStock int
);
create table Mouvement (
	NumMvt int primary key,
	TypeMvt varchar(30),
	Quantite int,
	CodProFini int foreign key references ProduitFini (CodProFini)
	on delete set null on update cascade
);
create table Composition (
	CodProFini int foreign key references ProduitFini (CodProFini)
	on delete set null on update cascade,
	CodProBrut int foreign key references ProduitBrut (CodProBrut)
	on delete set null on update cascade,
	QteUtilisee int
);
--///////////////////////////////////////////////////////////////
--Créer les procédures stockées suivantes :
--///////////////////////////////////////////////////////////////

--==================================================================================================
--PS 1. Qui crée les tables ProduitBrut et Composition
--_______________________
-- Procédure :
create proc SP_Créer_ProduitBrut_Composition
as
	create table ProduitBrut (
		CodProBrut int primary key,
		NomProBrut varchar(50),
		PrixAchat money,
		NumFour int foreign key references Fournisseur (NumFour)
		on delete set null on update cascade
	);
	create table Composition (
		CodProFini int foreign key references ProduitFini (CodProFini)
		on delete set null on update cascade,
		CodProBrut int foreign key references ProduitBrut (CodProBrut)
		on delete set null on update cascade,
		QteUtilisee int
	);
-- Exécuter :
exec SP_Créer_ProduitBrut_Composition;
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 2. Qui affiche le nombre de produits bruts par produit Fini
--_______________________
-- Procédure :
create proc SP_NombreProduitsBruts
	@CodProFini int
as
	select count(distinct CodProFini) from Composition where CodProFini = @CodProFini
	group by CodProFini;
-- Exécuter :
exec SP_NombreProduitsBruts 1;
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 3. Qui retourne en sortie le prix d'achat le plus élevé
--_______________________
-- Procédure :
CREATE PROCEDURE SP_PrixAchatPlusElevé
    @PrixAchatPlusElevé money output
AS
    set @PrixAchatPlusElevé = (select max(PrixAchat) from ProduitBrut); 
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 4. Qui affiche la liste des produits finis utilisant plus de deux produits bruts
--_______________________
-- Procédure :
CREATE PROCEDURE SP_ListeProduitsFinis 
    @param1 int = 0,
    @param2 int  
AS
    select * from ProduitFini where CodProFini in (
		select CodProFini from Composition
		group by CodProFini
		having count(CodProBrut) >= 2
	);
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 5. Qui reçoit le nom d'un produit brut et retourne en sortie 
--la raison sociale de son fournisseur
--_______________________
-- Procédure :
CREATE PROCEDURE SP_RaisonSosciale 
    @NomProBrut varchar(50)
AS
    select RsFour from Fournisseur where NumFour in (
		select NumFour from ProduitBrut where NomProBrut = @NomProBrut
	);
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 6. Qui reçoit le code d'un produit fini et qui affiche la liste des mouvements de sortie
--pour ce produit
--_______________________
-- Procédure :
CREATE PROCEDURE SP_ListeMouvements 
    @CodProFini int
AS
    select * from Mouvement where CodProFini = @CodProFini;
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 7. Qui reçoit le code d'un produit fini et le type de mouvement et qui affiche la liste des
--mouvements de ce type pour ce produit fini
--_______________________
-- Procédure :
CREATE PROCEDURE SP_ListeMouvementsType 
    @CodProFini int,
    @TypeMvt varchar(50)  
AS
    select * from
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 8. Qui pour chaque produit fini affiche :
--	♦ La quantité en stock pour ce produit
--	♦ La liste des mouvements concernant ce produit
--	♦ La quantité totale en sortie et la quantité totale en entrée
--	♦ La différence sera comparée à la quantité en stock. Si elle correspond afficher
--'Stock Ok' sinon afficher 'Problème de Stock'
--_______________________
-- Procédure :
ALTER PROCEDURE SP_InfosProduitsFinis  
AS
    declare CurPro cursor for 
		select * from ProduitFini;
	declare @CodProFini int, @NomPro varchar(max), @QteEnStock int;
	open CurPro;
		fetch CurPro into @CodProFini, @NomPro, @QteEnStock; 
		while @@fetch_status = 0
		begin
			print '-------------------------------------------';
			print ' Code Produit : ' + convert(varchar, @CodProFini);
			print ' Nom Produit : ' + @NomPro;
			print '';
			print ' Quantité en stock : ' + convert(varchar, @QteEnStock);
			
			print ' Liste des mouvements : ';
			declare CurMov cursor for
				select NumMvt, TypeMvt, Quantite from Mouvement where CodProFini = @CodProFini;
			declare @NumMvt int, @TypeMvt varchar(max), @Quantite int;
			open CurMov;
				fetch CurMov into @NumMvt, @TypeMvt, @Quantite;
				while @@fetch_status = 0
				begin
					print '		Numéro Mouvement : ' + convert(varchar, @NumMvt);
					print '		Type : ' + @TypeMvt;
					print '		Quantité : ' + convert(varchar, @Quantite);
					print '';
					fetch CurMov into @NumMvt, @TypeMvt, @Quantite;
				end
			close CurMov;
			deallocate CurMov;
			
			declare @QteSortie int = (select sum(Quantite) from Mouvement where TypeMvt = 'S' and CodProFini = @CodProFini);
			declare @QteEntrée int = (select sum(Quantite) from Mouvement where TypeMvt = 'E' and CodProFini = @CodProFini);
			print 'Quantité totale en sortie : ' + convert(varchar, @QteSortie);
			print 'Quantité totale en entrée : ' + convert(varchar, @QteEntrée);

			declare @Diff int = abs(@QteEnStock - @QteSortie);
			if @Diff = @QteEnStock
				print 'Stock OK.';
			else
				print 'Problème de stock !';
			print '-------------------------------------------';
			fetch CurPro into @CodProFini, @NomPro, @QteEnStock;
		end
	close CurPro;
	deallocate CurPro;
-- Exécuter :
exec SP_InfosProduitsFinis;
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================
--PS 9. Qui reçoit un code produit fini et retourne en sortie son prix de reviens
--==================================================================================================
--PS 10. Qui affiche pour chaque produit fini :
--	♦ Le prix de reviens (utiliser la procédure précédente)
--	♦ La liste des produits bruts le composant (nom, Mt, RSFour)
--	♦ Le nombre de ces produits
--_______________________
-- Procédure :
CREATE PROCEDURE dbo.Sample_Procedure 
    @param1 int = 0,
    @param2 int  
AS
    SELECT @param1,@param2 
-- Exécuter :
--_______________________
-- Fonction :
-- Exécuter :
--==================================================================================================