 		------------------------------------------------------------------------------------------------------------------
 		------------------------------------------------------------------------------------------------------------------
		--						                    _																	--
		--						                  _(_)_                          wWWWw   _								--
		--						      @@@@       (_)@(_)   vVVVv     _     @@@@  (___) _(_)_							--
		--						     @@()@@ wWWWw  (_)\    (___)   _(_)_  @@()@@   Y  (_)@(_)							--
		--						      @@@@  (___)     `|/    Y    (_)@(_)  @@@@   \|/   (_)\							--
		--						       /      Y       \|    \|/    /(_)    \|      |/      |							--
		--						    \ |     \ |/       | / \ | /  \|        |/    \|      \|/							--
		--						      |//   \\|///  \\\|//\\\|/// \|//   \\\|//  \\|//  \\\|//							--
		--						  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^						--
		--																												--
		--											  CHAPITRE 7 : SÉCURITÉ												--
		--																												--												
		------------------------------------------------------------------------------------------------------------------
 		------------------------------------------------------------------------------------------------------------------
/*
	SQL SERVER adopte une sécurité à 2 niveaux :

		• Au niveau serveur : A ce niveau la sécurité est gérée :
			♦ En créant des LOGINS (COMPTES ou CONNEXIONS).
			♦ En attribuant des rôles de niveau serveur aux logins crées.

		• Au niveau base de données, cela est effectué : 
			♦ Par le biais des objets USERS (UTILISATEURS).
			♦ En spécifiant les rôles et privilèges des utilisateurs sur les différents objets de la base de données (tables, vues, schémas, ...)																																							  
*/

-- LOGINS / COMPTES / Connexions :

	-- Windows :

		create login [anouar-pc\invité] 
		from windows

	-- SQL SERVER :

		-- Création :

			--> Propriétés du serveur --> Sécurité --> Authentification au serveur : Mode d'authentification SQL Server et Windows

			--> Il faut redémarrer ensuite le service ...

			create	login c_sqlserver_1
			with	password = 'azerty'
			go
			
		-- Modification :

			alter	login c_sqlserver_1 
			with	password = 'qwerty'
			go

			alter login c_sqlserver_1 with name = cnx_sqlserver_1
			go

			alter login cnx_sqlserver_1 disable -- Désactivation de la connexion
			go

			alter login cnx_sqlserver_1 enable	-- Activation de la connexion
			go

		-- Suppression :

			drop login cnx_sqlserver_1	--> Attention : La suppression peut générer des erreurs dans certaines cas.

		-- Utilisation : 

			create	login c_sqlserver_1
			with	password = 'azerty'

				--> On se connecte en utilisant c_sqlserver_1

			-- Affichage de la connexion en cours :

				select system_user

			-- Tentavie de création d'une base de données par la nouvelle connexion:

				create database bd_test		--> ERREUR

				--> La connexion c_sqlserver_1 a le droit de se connecter au serveur mais elle ne peut pas créer des bases de données dedans.

				--> On se connecte en utilisant la connexion par defaut et on affecte à la connexion c_sqlserver_1 le droit DBCREATOR
		
					exec sp_addsrvrolemember 'c_sqlserver_1', 'dbcreator'

			-- Reconnectez à nouveau en utilisant c_sqlserver_1 :

				create database bd_test

				--> DBCREATOR est un rôle de serveur. Les membres de ce rôle peuvent créer, modifier, supprimer et restaurer des bases de données. 

					--> Un rôle est un ensemble de privilèges (ou permissions). On affiche les privilèges d'un rôle de serveur en utilisant :

						exec sp_srvrolepermission 'dbcreator'

					--> On trouve d'autres rôles de serveur autres que DBCREATOR notamment le rôle SYSADMIN dont les membres peuvent effectuer toutes activités sur le serveur. 

						--> On peut afficher les privilèges de tous les rôles de serveur en exécutant :

							exec sp_srvrolepermission

				--> SP_ADDSRVROLEMEMBER est une procédure stockée permettant d’ajouter une connexion à un rôle de serveur. Dans l'exemple, on a ajouté C_SQLSERVER_1 au rôle de serveur DBCREATOR. Cette connexion peut maintenant créer, modifier, supprimer, ... des bases de données

--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--
--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--

-- Utilisateurs : 

	-- Après avoir créer une connexion, on doit créer un utilisateur apparenté, pour permettre à la connexion d’accéder aux bases de données du serveur. 

	-- Un utilisateur est crée au niveau d’une base de données et non au niveau serveur ; Pour créer l'utilisateur, il faut, alors, se situer dans le contexte de la base de données concernée.

		--> Premièrement, connectez vous en utilisant la connexion par défaut :

		use volavion
		go

		create user user1 for login c_sqlserver_1
		go

	-- Pour emprunter l’identité de l’utilisateur crée précédemment on utilise EXECUTE AS dans le contexte de sa base de données.

		use volavion
		go

		execute as user = 'user1'
		go

		select current_user
		select system_user
		go
		
		revert
		go

		select current_user
		select system_user
		go	

	-- Essayons maintenant de voir si user1 a le droit d'exécuter un ordre SELECT. 

		execute as user = 'user1'
		go

		select * from pilote	--> ERREUR

		--> Pour résoudre le problème, on peut ajouter l'utilisateur à un rôle de base de données convenable :
			
			--> On se connecte en utilisant la connextion par defaut

			use volavion
			go

			exec sp_addrolemember 'db_owner', 'user1'
			go

			execute as user = 'user1'
			go

			select * from passager
			go

				--> La procédure stockée SP_ADDROLEMEMBER ajoute un utilisateur à un rôle.

				--> DB_OWNER est un rôle fixe de base de données dont les membres peuvent réaliser toutes les activités de configuration et de mainteannce sur la base de données.

					--> Pour afficher les permissions du rôle db_owner on exécute :

						exec sp_dbfixedrolepermission 'db_owner'

				--> On trouve des rôles autres que DB_OWNER, par exemple les membres de DB_DENYDATAREADER ne peuvent pas exécuter la clause SELECT. Pour afficher les privilèges de tous les rôles fixes de base de données on utilise :

						exec sp_dbfixedrolepermission

				--> Pour retirer un utilisateur d’un rôle on utilise la procèdure stockée SP_DROPROLEMEMBER : 

						--> On se connecte en utilisant le onnexion par défaut. On ajoute user1 au rôle de base de données DB_DENYDATAWRITER ; les membres de ce rôle ne peuvent pas exécuter les clauses INSERT, UPDATE et DELETE.

						use volavion
						go

						exec sp_addrolemember 'db_denydatawriter', 'user1'
						go
						
						execute as user = 'user1'
						go

						insert into passager (pas#, nom, prenom, ville) values (10, 'soulaimani', 'mohamed', 'rabat')	--> erreur
						go							

						-- On bascule vers le compte par défaut

						use volavion
						go

						exec sp_droprolemember 'db_denydatawriter', 'user1'
						go

						execute as user = 'user1'
						go
						
						insert into passager (pas#, nom, prenom, ville) values (10, 'soulaimani', 'mohamed', 'rabat')
						go

						select * from passager
						go

						delete passager where pas# = 10
						go	

						select * from passager
						go

		--> On peut octroyer des privilèges à un utilisateur en utilisant la commande GRANT, pour les retirer on utilise REVOKE. DENY est utilisée pour	interdire une opération. L’utilisation de cette instruction est déconseillée.

			--> Basculez vers le compte par défaut

			use volavion
			go

			exec sp_droprolemember 'db_owner', 'user1'
			go

			--> Octroi du privilège SELECT à user1 sur la table Vol

			grant select on vol to user1 with grant option
			go	--> l’instruction WITH GRANT OPTION permet à l’utilisateur User1 d’accorder le privilège SELECT à d'autres utilisateurs.
	
			execute as user = 'user1'
			go				

			select * from vol
			go
			
			--> Basculez vers le compte par défaut

			use volavion
			go

			-- Révocation du privilège SELECT à USER1 sur la table Vol

			revoke select on vol from user1 cascade
			go	--> CASCADE est obligatoire si on a spécifié WITH GRANT OPTION

			execute as user = 'user1'
			go				

			select * from vol
			go

		--> les privilèges sont cumulatifs. On peut ainsi obtenir plusieurs fois le même privilège sur le même objet en provenance de différents utilisateurs. Le privilège sera totalement retiré lorsque tous les utilisateurs ayant donné ce privilége l'auront retiré.

--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--
--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--

-- Schémas :

	-- On peut octroyer, retirer ou interdire des privilèges en utilisant les schémas. Un schéma est un ensemble d’objet (des tables par exemple). 

		--> Basculez vers le login par défaut :

		--> Création : 

			use volavion
			go
	
			create schema schema1
			go

		--> Transfert de la table Passager au schéma Schema1 :

			alter schema schema1 transfer passager
			
			go

			--> Le schéma par défaut de Passager est dbo, la table Passager n'appartient plus à dbo mais à Schema1

				select * from passager	--> Erreur
				go

				select * from schema1.passager
				go

			--> On peut transférer plusieurs objets à un schéma donné

		execute as user = 'user1'
		go
			
		select * from schema1.passager	--> Erreur
		go

		--> Basculez vers le compte par défaut

		--> Octroie du privilège SELECT sur les tables du schéma Schema1 à l’utilisateur User1 :

			use volavion
			go

			grant select on schema ::schema1 to user1
			go

		execute as user = 'user1'
		go
			
		select * from schema1.passager
		go
		
		--> Basculez vers le compte par défaut
		
		alter schema dbo transfer schema1.passager
		
--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--
--.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.__.-**-.--