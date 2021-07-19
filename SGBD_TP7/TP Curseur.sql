--Exercice n°1 :
--Considérer la table produit suivante : Produit(noproduit,pxunite,libelleproduit)
create database ProduitDb;
use ProduitDb;
create table Produit (
	noproduit int primary key,
	pxunite money,
	libelleproduit varchar(30)
);
--Réalisez un curseur qui affiche les informations suivantes dans chaque enregistrement lu :
	-- Le numéro produit
	-- Le libellé produit,
	-- Le prix unité du produit ,
	-- Le message suivant : « le produit est chère si le prix est supérieure à 100 » et le message
--«Le produit n’est pas chère » si le prix est inférieur strictement à 100.
declare CursorProduits cursor for
	select noproduit, libelleproduit, pxunite from Produit;
open CursorProduits
	declare @noproduit int, @libelleproduit varchar(max), @pxunite money;
	fetch next from CursorProduits into @noproduit, @libelleproduit, @pxunite;
	while @@fetch_status = 0
		begin
			print '----------------------------------------------------------';
			print 'Numéro du produit : ' + convert(varchar, @noproduit);
			print 'Libellé : ' + @libelleproduit;
			print 'Prix unitaire : ' + convert(varchar, @pxunite) + ' DH';
			if (@pxunite > 100)
				print 'Produit chère !';
			else
				print 'Produit pas chère :)';
			fetch next from CursorProduits into @noproduit, @libelleproduit, @pxunite;
		end
close CursorProduits;
deallocate CursorProduits;

--Exercice n°2 :
--Utilisez la base VolAvion. Réalisez un curseur scroll qui extrait la liste des pilotes avec pour
--informations l’identifiant, le nom et le salaire du pilote Affichez les informations à l’aide de
--l’instruction PRINT
use AeoroportDb;
declare @NUMPIL int, @NOMPIL varchar(max), @SAL money;
declare CursorPilotes cursor scroll for select NUMPIL, NOMPIL, SAL from PILOTE
open CursorPilotes
	fetch Next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
	while @@fetch_status = 0
		begin
			print '-----------------------------------------------------';
			print 'Numéro du pilote : ' + convert(varchar, @NUMPIL);
			print 'Nom : ' + @NOMPIL;
			print 'Salaire : ' + convert(varchar,@SAL) + ' DH';
			fetch next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
		end
close CursorPilotes;
deallocate CursorPilotes;

--Exercice n°3 :
--Complétez le script précédent en imbriquant un deuxième curseur qui va préciser pour chaque pilote,
--quels sont les vols effectués par celui-ci.
--Vous imprimerez alors, pour chaque pilote une liste sous la forme suivante :
	--Le pilote ‘ xxxxx xxxxxxxxxxxxxxxxx est affecté aux vols :
	--Départ : xxxx Arrivée : xxxx
	--Départ : xxxx Arrivée : xxxx
	--Départ : xxxx Arrivée : xxxx
	--Le pilote ‘ YYY YYYYYYYY est affecté aux vols :
	--Départ : xxxx Arrivée : xxxx
	--Départ : xxxx Arrivée : xxxx
use AeoroportDb;
declare @NUMPIL int, @NOMPIL varchar(max), @SAL money;
declare CursorPilotes cursor for select NUMPIL, NOMPIL, SAL from PILOTE
open CursorPilotes
	fetch Next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
	while @@fetch_status = 0
		begin
			print '-----------------------------------------------------';
			print 'Numéro du pilote : ' + convert(varchar, @NUMPIL);
			print 'Nom : ' + @NOMPIL;
			print 'Salaire : ' + convert(varchar,@SAL) + ' DH';
			print 'Le pilote ' + @NOMPIL + ' est affecté aux vols :';
			if not exists (select H_DEP, H_ARR from Vol where NUMPIL = @NUMPIL)
				print '( Aucun vol )';
			else
				begin			
					declare CursorVols cursor for select H_DEP, H_ARR from Vol where NUMPIL = @NUMPIL;
					declare @H_DEP int, @H_ARR int;
					open CursorVols
						fetch Next from CursorVols into @H_DEP, @H_ARR;
						while @@fetch_status = 0
							begin
								print 'Départ : ' + convert(varchar, @H_DEP) + 'h | Arrivée : ' + convert(varchar, @H_ARR) + 'h';
								fetch Next from CursorVols into @H_DEP, @H_ARR;
							end
					close CursorVols;
					deallocate CursorVols;
				end
			fetch next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
		end
close CursorPilotes;
deallocate CursorPilotes;

--Exercice n°4 :
--Vous allez modifier le curseur précédent de l’exercice 4 pour pouvoir mettre à jour le salaire du
--pilote. Vous imprimerez une ligne supplémentaire à la suite de la liste des vols en précisant l’ancien et
--le nouveau salaire du pilote.
--Le salaire brut du pilote est fonction du nombre de vols auxquels il est affecté :
	-- Si 0 alors le salaire est 5 000
	-- Si entre 1 et 3, salaire de 7 000
	-- Plus de 3, salaire de 800
--Pour mettre à jour la ligne courante, utilisez la clause WHERE CURRENT OF associée au curseur à mettre à jour.
use AeoroportDb;
declare @NUMPIL int, @NOMPIL varchar(max), @SAL money;
declare CursorPilotes cursor for select NUMPIL, NOMPIL, SAL from PILOTE
open CursorPilotes
	fetch Next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
	while @@fetch_status = 0
		begin
			print '-----------------------------------------------------';
			print 'Numéro du pilote : ' + convert(varchar, @NUMPIL);
			print 'Nom : ' + @NOMPIL;
			print 'Salaire : ' + convert(varchar,@SAL) + ' DH';
			print 'Le pilote ' + @NOMPIL + ' est affecté aux vols :';
			if not exists (select H_DEP, H_ARR from Vol where NUMPIL = @NUMPIL)
				print '( Aucun vol )';
			else
				begin			
					declare CursorVols cursor for select H_DEP, H_ARR from Vol where NUMPIL = @NUMPIL;
					declare @H_DEP int, @H_ARR int;
					open CursorVols
						fetch Next from CursorVols into @H_DEP, @H_ARR;
						while @@fetch_status = 0
							begin
								print 'Départ : ' + convert(varchar, @H_DEP) + 'h | Arrivée : ' + convert(varchar, @H_ARR) + 'h';
								fetch Next from CursorVols into @H_DEP, @H_ARR;
							end
					close CursorVols;
					deallocate CursorVols;
				end
			declare @OLD_SAL int = @SAL;
			declare @NBR_VOLS int = (select count(*) from Vol where NUMPIL = @NUMPIL);
			if (@NBR_VOLS = 0) set @SAL = 5000;
			else if (@NBR_VOLS between 1 and 3) set @SAL = 7000
			else if (@NBR_VOLS = 3) set @SAL = 8000;
			print 'Ancien salaire : ' + convert(varchar, @OLD_SAL) + ' DH';
			print 'Nouveau salaire : ' + convert(varchar, @SAL) + ' DH';
			update Pilote set SAL = @SAL where current of CursorPilotes;
			fetch next from CursorPilotes into @NUMPIL, @NOMPIL, @SAL;
		end
close CursorPilotes;
deallocate CursorPilotes;

--Exercice n°5 :
--Considérer la table lignecommande(noproduit,qteproduit)
--Réaliser une mise à jour de la table lignecommande , si qteproduit <50 alors la qteproduit s’augmente
--de 10,sinon la qteproduit diminue de 5 en utilisant :
	-- La commande update
	-- La fonction CASE
	-- Un curseur (Pour mettre à jour la ligne courante, utilisez la clause WHERE
	--CURRENT OF associée au curseur à mettre à jour).*
use ProduitDb;
create table LigneCommande (
	noproduit int foreign key references Produit (noproduit),
	qteproduit int,
	primary key (noproduit, qteproduit)
);
declare CursorLC cursor for select noproduit, qteproduit from LigneCommande;
declare @noproduit int, @qteproduit int;
open CursorLC;
	fetch next from CursorLC into @noproduit, @qteproduit;
	while @@fetch_status = 0
		begin
			print '-------------------------------------------';
			print '=> ID Produit: ' + convert(varchar, @noproduit);
			print 'Quantité Avant: ' + convert(varchar, @qteproduit);
			set @qteproduit = case 
				when @qteproduit <= 50 then @qteproduit+10
				else @qteproduit-5
			end
			print 'Quantité Après: ' + convert(varchar, @qteproduit);
			update LigneCommande set qteproduit = @qteproduit where current of CursorLc;
			fetch next from CursorLC into @noproduit, @qteproduit;
		end
close CursorLC;
deallocate CursorLC;
