use GCommandeDb;
--=================================================================
-- * Créer les procédures stockées suivantes :
--=================================================================
--Procédure qui affiche la liste des articles avec pour chaque 
--article le numéro et la désignation :
create proc sp_articles as
select NumArt, DesArt from Article;
--Exécuter :
exec sp_articles;
--=================================================================
--Procédure qui calcule le nombre d'articles par commande :
create proc sp_NbrArticlesParCommande as
select Commande.NumCom, DatCom, count(NumArt) as 'Nombre d''articles'
from Commande, LigneCommande 
where Commande.NumCom = LigneCommande.NumCom 
group by Commande.NumCom, DatCom;
--Exécuter :
exec sp_NbrArticlesParCommande;
--=================================================================
--Procédure qui afficher les commandes entre deux dates données :
alter proc sp_commandes_par_date
@date_min date, @date_max date 
as
if (@date_min > @date_max) print('Erreur! La 1ère date doit être antérieure à la 2ème.');
else select * from Commande where DatCom between @date_min and @date_max;
--Exécuter :
exec sp_commandes_par_date '01-01-2016', '02-01-2016';
exec sp_commandes_par_date '03-01-2016', '02-01-2016';
--================================================================= 
--Procédure pour stocker le nombre de commandes dans une variable :
create proc sp_nbr_commandes
@nbr_com int output
as
set @nbr_com = (select count(*) from Commande);
--Exécuter :
declare @n int;
exec sp_nbr_commandes @n output;
select @n as 'Nombre de commandes';
--=================================================================
--Procédure pour stocker le nombre de d'articles commandés
--d'une commande donnée dans une variable :
create proc sp_nbr_articles_par_commande
@NumCom int, @nbr_art int output
as
set @nbr_art = (select count(*) from LigneCommande where NumCom = @NumCom);
--Exécuter :
declare @n int;
exec sp_nbr_articles_par_commande 3, @n output;
select @n as 'Nombre d''articles de la commande';
--=================================================================
--Procédure pour stocker le montant et l'état d'une commande
--dans des variables
create proc sp_montant_commande
@NumCom int, @montant money output, @couleur varchar(max) output
as
set @montant = (select sum(A.PUArt*LC.QteCommandee) 
			     from Article A inner join LigneCommande LC
			     on A.NumArt = LC.NumArt
			     where NumCom = @NumCom); 
if (@montant between 0 and 1000)
	set @couleur = 'Verte';
else if (@montant between 1000 and 8000)
	set @couleur = 'Orange';
else if (@montant > 300)
	set @couleur = 'Rouge';
--Exécuter :
declare @m money, @c varchar(max);
exec sp_montant_commande 3, @m output, @c output;
print('Montant : ' + convert(varchar, @m) + ' DH .......... Commande ' + @c); 
--=================================================================
--Procédure pour retourner le montant et l'état d'une commande
--dans des variables
create proc sp_max_prix
as
declare @max_prix money = (select max(PUArt) from Article);
return @max_prix;
--Exécuter :
declare @p money;
exec @p = sp_max_prix;
select @p as 'Maximum des prix d''articles';
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================
--Exécuter :
--=================================================================