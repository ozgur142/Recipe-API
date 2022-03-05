/*
 * Fichier : creation_Groupe7.sql
 * Gestion de recettes de cuisine
 *--------------------------------
 * Auteurs:
 * PUJADE Joffrey - 22011040
 * DOGAN Ozgur - 21811290
 * BENSIKHALED Madani - 21801055
 * BANDO Sio - 21802005
 */

-- Suppressions.

-- Suppression des triggers si ils existent.

DROP TRIGGER IF EXISTS insertionModificationAllergique ON Allergique CASCADE;
DROP TRIGGER IF EXISTS insertionModificationContient ON Contient CASCADE;
DROP TRIGGER IF EXISTS insertionModificationRecette ON Recette CASCADE;

-- Suppression des fonctions si elles existent.

DROP FUNCTION IF EXISTS fctInsertionModificationAllergique() CASCADE;
DROP FUNCTION IF EXISTS fctInsertionModificationContient() CASCADE;
DROP FUNCTION IF EXISTS fctInsertionModificationRecette() CASCADE;
DROP FUNCTION IF EXISTS nombreCalories(nbR NUMERIC(4, 0)) CASCADE;
DROP FUNCTION IF EXISTS nombreLikes(nbR NUMERIC(4, 0)) CASCADE;

-- Suppression des procédures si elles existent.

DROP PROCEDURE IF EXISTS obtenirUneRecette(IN idR NUMERIC(4, 0), INOUT resRec RECORD, INOUT resCont RECORD, INOUT resIngr RECORD) CASCADE;

-- Suppression des tables si elles existent.

DROP TABLE IF EXISTS Allergique;
DROP TABLE IF EXISTS Consulte;
DROP TABLE IF EXISTS Aime;
DROP TABLE IF EXISTS Commente;
DROP TABLE IF EXISTS Respecte;
DROP TABLE IF EXISTS TypeDiete;
DROP TABLE IF EXISTS Contient;
DROP TABLE IF EXISTS Ingredient;
DROP TABLE IF EXISTS Recette;
DROP TABLE IF EXISTS Utilisateur;

-- Suppression de la base de données si elle existe.

DROP DATABASE IF EXISTS BDDRecettes;

-- Créations.

-- Création de la base de données.

CREATE DATABASE BDDRecettes;

-- Création des tables.

CREATE TABLE Utilisateur
(
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	nom VARCHAR(25),
	prenom VARCHAR(25),
	age NUMERIC(3,0),
	genre CHAR(1) CHECK (genre IN ('M','F', 'N')), /* M=masculin, F=feminin,  N=neutre*/
	nomUtilisateur VARCHAR(50) NOT NULL,
	email VARCHAR(150) NOT NULL,
	motDePasse VARCHAR(64) NOT NULL,
	niveauDeCuisine NUMERIC(1,0),      -- 1, 2, 3
	CONSTRAINT PK_Utilisateur PRIMARY KEY (idUtilisateur),
	CONSTRAINT DOM_age CHECK (age BETWEEN 0 AND 120),
	CONSTRAINT UN_nomUtilisateur UNIQUE (nomUtilisateur), -- Un nom d'utilisateur est associé à un seul utilisateur.
	CONSTRAINT UN_email UNIQUE (email), -- Une adresse email est associée à un seul utilisateur.
	CONSTRAINT DOM_niveauDeCuisine CHECK (niveauDeCuisine BETWEEN 1 AND 3)
);

CREATE TABLE Recette
(
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	paysOriginaire VARCHAR(20),
	nomRecette VARCHAR(50),
	nomRecetteApi VARCHAR(55), -- À REVOIR : Un nom de recette pour des requêtes faites à l'API lorsqu'elle sera développée.
	difficulte NUMERIC(1, 0),
	tempsPreparation NUMERIC(3, 0),
	preparation TEXT,
	typeRecette VARCHAR(15) CHECK (typeRecette IN ('PLAT','COCKTAIL')),
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	recetteAccompagnant NUMERIC(4, 0),
	CONSTRAINT PK_Recette PRIMARY KEY (idRecette),
	CONSTRAINT UN_nomRecette UNIQUE (nomRecette), -- À REVOIR : Un nom de recette unique pour mieux la rechercher dans la base de données.
	CONSTRAINT UN_nomRecetteApi UNIQUE (nomRecetteApi), -- À REVOIR : Un nom de recette de l'API unique pour mieux la rechercher dans la base de données.
	CONSTRAINT DOM_difficulte CHECK (difficulte BETWEEN 1 AND 3),
	CONSTRAINT FK_Recette_Utilisateur FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
	CONSTRAINT FK_Recette_recetteAccompagnant FOREIGN KEY (recetteAccompagnant) REFERENCES Recette(idrecette) --ON DELETE CASCADE A VERIFIER PAR PROF!!!
);

CREATE TABLE Ingredient
(
	idIngredient NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	nom VARCHAR(25),
	calorie FLOAT,
	unite VARCHAR(10),
	CONSTRAINT PK_Ingredient PRIMARY KEY (idIngredient)
);

CREATE TABLE Contient
(
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idIngredient NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	quantite numeric(4, 0),
	CONSTRAINT PK_Contient PRIMARY KEY (idRecette, idIngredient),
	CONSTRAINT FK_Contient_Recette FOREIGN KEY (idRecette) REFERENCES Recette(idRecette) ON DELETE CASCADE,
	CONSTRAINT FK_Contient_Ingredient FOREIGN KEY (idIngredient) REFERENCES Ingredient(idIngredient) ON DELETE CASCADE
);

CREATE TABLE TypeDiete
(
	idDiete NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	nomDiete VARCHAR(20),
	CONSTRAINT PK_TypeDiete PRIMARY KEY (idDiete)
);

CREATE TABLE Respecte
(
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idDiete NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	CONSTRAINT PK_Respecte PRIMARY KEY (idRecette, idDiete),
	CONSTRAINT FK_Respecte_Recette FOREIGN KEY (idRecette) REFERENCES Recette(idRecette) ON DELETE CASCADE,
	CONSTRAINT FK_Respecte_TypeDiete FOREIGN KEY (idDiete) REFERENCES TypeDiete(idDiete) ON DELETE CASCADE
);

CREATE TABLE Commente
(
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	dateCommentaire TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	texteCommentaire TEXT,
	CONSTRAINT PK_Commente PRIMARY KEY (idUtilisateur, idRecette, dateCommentaire),
	CONSTRAINT FK_Commente_Utilisateur FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
	CONSTRAINT FK_Commente_Recette FOREIGN KEY (idRecette) REFERENCES Recette(idRecette) ON DELETE CASCADE
);

CREATE TABLE Aime
(
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	CONSTRAINT PK_Aime PRIMARY KEY (idUtilisateur, idRecette),
	CONSTRAINT FK_Aime_Utilisateur FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
	CONSTRAINT FK_Aime_Recette FOREIGN KEY (idRecette) REFERENCES Recette(idRecette) ON DELETE CASCADE
);

CREATE TABLE Consulte
(
	dateConsultation TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idRecette NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère. 
	CONSTRAINT PK_Consulte PRIMARY KEY (dateConsultation, idUtilisateur, idRecette),
	CONSTRAINT FK_Consulte_Utilisateur FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
	CONSTRAINT FK_Consulte_Recette FOREIGN KEY (idRecette) REFERENCES Recette(idRecette) ON DELETE CASCADE
);

CREATE TABLE Allergique
(
	idUtilisateur NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	idIngredient NUMERIC(4, 0) NOT NULL, -- NOT NULL pour + de sécurité, même si pas forcément nécessaire si clef primaire ou clef étrangère.
	CONSTRAINT PK_Allergique PRIMARY KEY (idUtilisateur, idIngredient),
	CONSTRAINT FK_Allergique_Utilisateur FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur(idUtilisateur) ON DELETE CASCADE,
	CONSTRAINT FK_Allergique_Ingredient FOREIGN KEY (idIngredient) REFERENCES Ingredient(idIngredient) ON DELETE CASCADE
);

-- Création des procédures.

/*
	Procédure obtenirUneRecette(-> idR : Entier, <-> resRec : Indéfini, <-> resCont : Indéfini, <-> resIngr : Indéfini)
	Entrée :
		idR : Identifiant d'une recette.
	Sortie :
		resRec : Toutes les données d'une recette.
		resCont : Toutes les relation entre la recette et tous ses ingrédients.
		resIngr : Tous les ingrédients de la recette.
	Traitement : Recherche une recette et en renvoie toutes ses données ainsi
				 que la totalité de ses ingrédients.
*/

CREATE OR REPLACE PROCEDURE obtenirUneRecette(IN idR NUMERIC(4, 0), INOUT resRec RECORD, INOUT resCont RECORD, INOUT resIngr RECORD) LANGUAGE plpgsql AS $$
BEGIN
	SELECT * INTO resRec
	FROM Recette
	WHERE idRecette = idR;
	
	SELECT * INTO resCont
	FROM Contient
	WHERE idRecette = idR;
	
	SELECT I.* INTO resIngr
	FROM Ingredient I
	INNER JOIN Contient C ON I.idIngredient = C.idIngredient
	WHERE C.idRecette = idR;
END;
$$;

-- Création des fonctions.

/*
	Fonction nombreLikes(idR : Entier) : Entier
	Entrée : Identifiant d'une recette.
	Sortie : Nombre de likes de la recette.
	Traitement : Calcule le nombre de likes d'une recette.
*/
CREATE OR REPLACE FUNCTION nombreLikes(idR NUMERIC(4, 0)) RETURNS INTEGER AS $$
DECLARE
	nbLikes INTEGER := 0;
BEGIN
	nbLikes = (SELECT COUNT(*)::INTEGER
			   FROM Aime
			   WHERE idRecette = idR);
	
	RETURN nbLikes;
END;
$$ LANGUAGE plpgsql;

/*
	Fonction nombreCalories(idR : Entier) : Réel
	Entrée : Identifiant d'une recette.
	Sortie : Nombre de calories de la recette.
	Traitement : Calcule le nombre de likes d'une recette.
*/
CREATE OR REPLACE FUNCTION nombreCalories(idR NUMERIC(4, 0)) RETURNS FLOAT AS $$
DECLARE
	nbCalories FLOAT := 0;
BEGIN
	nbCalories := (SELECT SUM((I.calorie * C.quantite))::FLOAT
				   FROM Ingredient I
				   INNER JOIN Contient C ON I.idIngredient = C.idIngredient
				   INNER JOIN Recette R ON C.idRecette = R.idRecette
				   WHERE R.idRecette = idR);
	
	RETURN nbCalories;
END;
$$ LANGUAGE plpgsql;

-- Création des triggers.

/*
	Fonction fctInsertionModificationRecette() : Trigger
	Entrée : Rien / Aucune.
	Sortie : Un trigger.
	Traitement : Vérifie que le nouvel identifiant de la recette est bel et bien différent
				 l'identifiant de la recette accompagnante, que l'auteur n'est pas allergique
				 à l'un des ingrédients de sa propre recette, ainsi que la difficulté de la
				 recette ne dépasse pas le niveau de cuisine de son auteur.
*/
CREATE OR REPLACE FUNCTION fctInsertionModificationRecette() RETURNS TRIGGER AS $$
DECLARE
	nbr INTEGER := 0;
	ndc NUMERIC(1,0) := 0;
	ageUtilisateur NUMERIC(3,0) := 0;
BEGIN
	IF NEW.idRecette = NEW.recetteAccompagnant THEN
		RAISE EXCEPTION 'L"id de la recette (%) doit être différent de l"id de la recette accompagnant (%).', NEW.idRecette, NEW.recetteAccompagnant;
	END IF;
	
	nbr := (SELECT COUNT(A.*)::INTEGER
			FROM Allergique A
			INNER JOIN Contient C ON A.idIngredient = C.idIngredient
			INNER JOIN Recette R ON C.idRecette = R.idRecette
			WHERE R.idUtilisateur = NEW.idUtilisateur AND C.idRecette = NEW.idRecette);
	
	IF nbr > 0 THEN
		RAISE EXCEPTION 'L"utilisateur (%) ne peut pas écrire de recette avec au moins un ingrédient dont il est allergique.', NEW.idUtilisateur;
	END IF;
	
	ndc := (SELECT niveauDeCuisine::NUMERIC(1,0)
			FROM Utilisateur
			WHERE idUtilisateur = NEW.idUtilisateur);
	
	IF ndc = 0 THEN
		RAISE EXCEPTION 'Le niveau de cuisine (%) d"un utilisateur (%) ne peut pas être égal à zéro (0).', ndc, NEW.idUtilisateur;
	END IF;
	
	IF ndc < NEW.difficulte THEN
		RAISE EXCEPTION 'Le niveau de cuisine (%) d"un utilisateur (%) ne peut pas être inférieur à la difficulté d"une recette.', ndc, NEW.idUtilisateur;
	END IF;
	
	ageUtilisateur := (SELECT age
			FROM Utilisateur
			WHERE idUtilisateur = NEW.idUtilisateur);
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
	Trigger insertionModificationRecette
	Ce trigger vérifie, lors de l'insertion ou de la modification dans la table recette,
	pour chaque colonne, si le nouvel identifiant de la recette est bel et bien différent
	l'identifiant de la recette accompagnante, que l'auteur n'est pas allergique à l'un
	des ingrédients de sa propre recette, ainsi que la difficulté de la recette ne
	dépasse pas le niveau de cuisine de son auteur.
*/
CREATE TRIGGER insertionModificationRecette BEFORE INSERT OR UPDATE ON Recette FOR EACH
	ROW EXECUTE PROCEDURE fctInsertionModificationRecette();

/*
	Fonction fctInsertionModificationContient() : Trigger
	Entrée : Rien / Aucune.
	Sortie : Un trigger.
	Traitement : Vérifie que l'auteur n'est pas allergique à l'un des ingrédients
				 de sa propre recette, sinon ladite recette est supprimée et une
				 erreur est lancée.
*/
CREATE OR REPLACE FUNCTION fctInsertionModificationContient() RETURNS TRIGGER AS $$
DECLARE
	nbr INTEGER := 0;
BEGIN
	nbr := (SELECT COUNT(A.*)::INTEGER
			FROM Allergique A
			INNER JOIN Contient C ON A.idIngredient = C.idIngredient
			INNER JOIN Recette R ON C.idRecette = R.idRecette
			WHERE R.idUtilisateur = A.idUtilisateur AND C.idRecette = NEW.idRecette);
	
	IF nbr > 0 THEN
		DELETE FROM Recette
		WHERE idRecette = NEW.idRecette;
		RAISE EXCEPTION 'L"utilisateur (%) ne peut pas écrire de recette avec au moins un ingrédient dont il est allergique. La recette a été supprimée de la base de données.', NEW.idUtilisateur;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
	Trigger insertionModificationContient
	Ce trigger vérifie, lors de l'insertion ou de la modification dans la table contient,
	pour chaque colonne, si l'auteur n'est pas allergique à l'un des ingrédients de sa
	propre recette, sinon ladite recette est supprimée et une erreur est lancée.
*/
CREATE TRIGGER insertionModificationContient BEFORE INSERT OR UPDATE ON Contient FOR EACH
	ROW EXECUTE PROCEDURE fctInsertionModificationContient();

/*
	Fonction fctInsertionModificationAllergique() : Trigger
	Entrée : Rien / Aucune.
	Sortie : Un trigger.
	Traitement : Vérifie que si l'utilisateur a déjà écrit des recettes lorsqu'il ajoute
				 des ingrédients auquel il est allergique, il n'a pas posté de recettes
				 possédant des ingrédients auquel il est allergique.
*/
CREATE OR REPLACE FUNCTION fctInsertionModificationAllergique() RETURNS TRIGGER AS $$
DECLARE
	nbRecettesPostees INTEGER := 0;
	nbAllergiesDesRecettes INTEGER := 0;
BEGIN
	nbRecettesPostees := (SELECT COUNT(*)::INTEGER
						  FROM Recette
						  WHERE idUtilisateur = NEW.idUtilisateur);
	
	IF nbRecettesPostees > 0 THEN
		nbAllergiesDesRecettes := (SELECT COUNT(A.*)::INTEGER
								   FROM Allergique A
								   INNER JOIN Contient C ON A.idIngredient = C.idIngredient
								   INNER JOIN Recette R ON C.idRecette = R.idRecette
								   WHERE R.idUtilisateur = NEW.idUtilisateur);
		
		IF nbAllergiesDesRecettes > 0 THEN
			RAISE EXCEPTION 'L"utilisateur (%) ne peut pas être allergique à un ingrédient contenu dans au moins une de ses propres recettes.', NEW.idUtilisateur;
		END IF;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
	Trigger insertionModificationAllergique
	Ce trigger vérifie, lors de l'insertion ou de la modification dans la table allergique,
	pour chaque colonne, si l'utilisateur a déjà écrit des recettes lorsqu'il ajoute des
	ingrédients auquel il est allergique, il n'a pas posté de recettes possédant des
	ingrédients auquel il est allergique.
*/
CREATE TRIGGER insertionModificationAllergique BEFORE INSERT OR UPDATE ON Allergique FOR EACH
	ROW EXECUTE PROCEDURE fctInsertionModificationAllergique();

-- Insertion de données.

-- Table Utilisateur.

INSERT INTO Utilisateur VALUES(000, 'Admin', 'Admin', 100, 'N', 'Admin', 'admin@admin.fr', 'password', 3);
INSERT INTO Utilisateur VALUES(001, 'Luc', 'Cadieux', 33, 'M', 'Luc Cad', 'Luc@Cad.fr', '12345', 1);
INSERT INTO Utilisateur VALUES (002,'Emmanuel','Rochefort', 43, 'M', 'Super Manu', 'super@manu.fr', 'superlarem', 2);
INSERT INTO Utilisateur VALUES (003,'Brigitte','Rochefort', 68, 'F', 'Brigitte Rochefort', 'brigitte@rochefort.fr', 'voila_56', 3);
INSERT INTO Utilisateur VALUES (004,'Laurette','Meunier', 56, 'F', 'LauretteCookies', 'laurette@cookies.fr', 'laulaucookies56', 2);
INSERT INTO Utilisateur VALUES (005,'Maurice','Chabot', 42, 'M', 'MauriceChabot', 'maurice@chabot.com', 'deft89_ata', 1);
INSERT INTO Utilisateur VALUES (006,'Harbin','Pyeonseul', 35, 'M', 'Army Forever', 'army@forever.net', 'jiminmylove', 1);
INSERT INTO Utilisateur VALUES (007,'Anton','Labbé', 33, 'M', 'Antonton', 'anton@ton.net', 'mpmp/89', 3);
INSERT INTO Utilisateur VALUES (008,'Xiaomi','Song', 23, 'F', 'Xiaomi Song', 'xiaomi@song.com', 'xingxing47', 2);
INSERT INTO Utilisateur VALUES (009,'Sven','Sverige', 19, 'M', 'Sven00', 'sven@sv00.fr', 'ui58_mp', 1);
INSERT INTO Utilisateur VALUES(010, 'Gaston', 'Bélanger', 42, 'M', 'Gaston', 'gaston@bel.com', '12345', 3);
INSERT INTO Utilisateur VALUES(011, 'utilisateur11', 'uti11', 36, 'N', 'user', 'sudo@bel.com', 'azerty', 3);

-- Table Recette.

INSERT INTO Recette VALUES (001, 'France', 'Hachis parmentier', 'Hachis-parmentier', 3, 45, '1) Hacher l''oignon et l''ail. Les faire revenir jusqu''à ce qu''ils soient tendres.\n2) Ajouter les tomates coupées en dés, la viande hachée, la farine, du sel, du poivre. \n3) Quand tout est cuit, couper le feu et ajouter un peu de parmesan. Bien mélanger. \n4) Préchauffer le four à 200°C (thermostat 6-7). Etaler au fond du plat à gratin. Préparer la purée. L''étaler au dessus de la viande. Saupoudrer de fromage râpé et faire gratiner.', 'PLAT', 003, NULL);
INSERT INTO Recette VALUES (002, 'Corée', 'Tteokbokki', 'Tteokbokki', 1, 15, '1) Dans une poêle, ajouter les tteoks et de l''eau. \n2) Ajouter le reste des ingrédients dans la poêle. \n3) Faire bouillir le tout pendant 10 minutes.', 'PLAT', 006, NULL);
INSERT INTO Recette VALUES (003, 'France', 'Tartiflette', 'Tartiflette', 2, 35, '1) Ajouter les oignons dans une poêle et les faire fondre. \n2) Couper les pommes de terre, les ajouter dans la poêle et les faire dorer. \n3) Ajouter les lardons. \n4) Mettre le tout au four et ajouter du roblochon. Faire gratiner pendant 20 minutes', 'PLAT', 010, NULL);
INSERT INTO Recette VALUES (004, 'Chine', 'Nouilles au poulet', 'Nouilles-au-poulet', 1, 25, '1) Faire bouillir les nouilles chinoises pendant 10 minutes. \n2) Couper le poulet en dés. \n3) Faire revenir le poulet avec des poivrons. \n4) Ajouter les nouilles au poulet et aux poivrons.', 'PLAT', 008, NULL);
INSERT INTO Recette VALUES (005, 'France', 'Crêpe', 'Crêpe', 1, 25, '1) Dans un saladier, versez la farine, ajoutez les oeufs, le sucre, l''huile et le beurre.\n2)Mélanger délicatement puis puis verser une louche de pâte à chaque fois sur une poêle.', 'PLAT', 001, NULL);
INSERT INTO Recette VALUES (006, 'France', 'Panacota', 'Panacota', 2, 25, '1) Faire ramollir les feuilles de gélatine dans de l''eau froide. Mettre la mascarpone, la crème liquide entière et le sucre dans une casserole et faire frémir. \n2)Dès le début de l''ébullition, retirer la casserole du feu et ajouter la gélatine égouttée. \3) Bien remuer et verser dans des coupelles. Laisser refroidir puis placer quelques heures au réfrigérateur pour faire prendre. \n4) Ajouter du coulis de fraise avant de servir.', 'PLAT', 002, NULL);
INSERT INTO Recette VALUES (007, 'Cuba', 'Mojito', 'Mojito', 1, 10, '1) Placer les feuilles de menthe dans le verre, ajoutez le sucre et le jus de citrons. Piler consciencieusement afin d''exprimer l''essence de la menthe mais sans la broyer. \n2) Ajouter le rhum, remplir le verre à moitié de glaçons et compléter avec de l''eau gazeuse. Mélanger doucement et servir avec une paille.','COCKTAIL', 009, NULL);
INSERT INTO Recette VALUES (008, 'Angleterre', 'Gin Tonic', 'Gin-Tonic', 1, 10, '1) Déposez quelques glaçons dans un verre et versez le gin. 2) Complétez avec du Tonic et remuez délicatement. Ajoutez 1 rondelle de citron vert et dégustez bien frais.','COCKTAIL', 003, NULL);
INSERT INTO Recette VALUES (009, 'France', 'Vin chaud', 'Vin-chaud', 2, 15, '1) Mettre le vin, du sucre et de la gingembre dans une casserole. \n2) Faire bouillir pendant 5 minutes et servir très chaud', 'COCKTAIL', 004, NULL);
INSERT INTO Recette VALUES (010, 'Cuba', 'Virgin Cuba Libre', 'Virgin-Cuba-Libre', 1, 8, '1) Remplir le verre de glaçons, verser le sirop de rhum puis verser le cola.', 'COCKTAIL', 006, NULL);

-- Table Ingredient.

INSERT INTO Ingredient VALUES (001, 'Oignon', 40, 'Unite');
INSERT INTO Ingredient VALUES (002, 'Ail', 149, 'Unite');
INSERT INTO Ingredient VALUES (003, 'Tomate', 35, 'Unite');
INSERT INTO Ingredient VALUES (004, 'Viande hachée', 2.50, 'Gramme');
INSERT INTO Ingredient VALUES (005, 'Farine', 3.64, 'Gramme');
INSERT INTO Ingredient VALUES (006, 'Purée', 0.80, 'Gramme');
INSERT INTO Ingredient VALUES (007, 'Parmesan', 4.31, 'Gramme');

INSERT INTO Ingredient VALUES (008, 'Tteok', 1.45, 'Gramme');
INSERT INTO Ingredient VALUES (009, 'Pâte de piment rouge', 0.31, 'Gramme');

INSERT INTO Ingredient VALUES (010, 'Pomme de terre', 0.80, 'Gramme');
INSERT INTO Ingredient VALUES (011, 'Lardon', 1.33, 'Gramme');
INSERT INTO Ingredient VALUES (012, 'Roblochon', 3.30, 'Gramme');

INSERT INTO Ingredient VALUES (013, 'Nouilles chinoises', 1.38, 'Gramme');
INSERT INTO Ingredient VALUES (014, 'Poulet', 2.39, 'Gramme');
INSERT INTO Ingredient VALUES (015, 'Poivron', 0.36, 'Gramme');

INSERT INTO Ingredient VALUES (016, 'Oeuf', 85, 'Unite');
INSERT INTO Ingredient VALUES (017, 'Huile', 8.84, 'Gramme');
INSERT INTO Ingredient VALUES (018, 'Lait', 0.42, 'Gramme');
INSERT INTO Ingredient VALUES (019, 'Sucre', 3.87, 'Gramme');
INSERT INTO Ingredient VALUES (020, 'Beurre', 7.17, 'Gramme');

INSERT INTO Ingredient VALUES (021, 'Feuille de gélatine', 0.01, 'Unite');
INSERT INTO Ingredient VALUES (022, 'Mascarpone', 3.55, 'Gramme');
INSERT INTO Ingredient VALUES (023, 'Crème liquide entière', 2.98, 'Gramme');
INSERT INTO Ingredient VALUES (024, 'Coulis de fraise', 0.91, 'Gramme');

INSERT INTO Ingredient VALUES (025, 'Rhum', 2.39, 'Gramme');
INSERT INTO Ingredient VALUES (026, 'Citron', 0.29, 'Gramme');
INSERT INTO Ingredient VALUES (027, 'Feuille de menthe', 0.01, 'Unite');

INSERT INTO Ingredient VALUES (028, 'Gin', 2.63, 'Gramme');
INSERT INTO Ingredient VALUES (029, 'Tonic', 0.34, 'Gramme');

INSERT INTO Ingredient VALUES (030, 'Vin', 0.83, 'Gramme');
INSERT INTO Ingredient VALUES (031, 'Gigembre', 0.80, 'Gramme');

INSERT INTO Ingredient VALUES (032, 'Sirop de rhum', 3.03, 'Gramme');
INSERT INTO Ingredient VALUES (033, 'Cola', 0.42, 'Gramme');

-- Table Contient.

/* Hachis parmentier */
INSERT INTO Contient VALUES (001, 001, 2);
INSERT INTO Contient VALUES (001, 002, 2);
INSERT INTO Contient VALUES (001, 003, 2);
INSERT INTO Contient VALUES (001, 004, 400);
INSERT INTO Contient VALUES (001, 005, 25);
INSERT INTO Contient VALUES (001, 006, 300);
INSERT INTO Contient VALUES (001, 007, 30);
/* Tteokbokki */
INSERT INTO Contient VALUES (002, 008, 300);
INSERT INTO Contient VALUES (002, 009, 100);
/* Tartiflette */
INSERT INTO Contient VALUES (003, 001, 200);
INSERT INTO Contient VALUES (003, 010, 1000);
INSERT INTO Contient VALUES (003, 011, 200);
INSERT INTO Contient VALUES (003, 012, 300);
/* Nouilles au poulet */
INSERT INTO Contient VALUES (004, 013, 500);
INSERT INTO Contient VALUES (004, 014, 180);
INSERT INTO Contient VALUES (004, 015, 150);
/* Crêpe */
INSERT INTO Contient VALUES (005, 005, 300);
INSERT INTO Contient VALUES (005, 019, 75);
INSERT INTO Contient VALUES (005, 017, 50);
INSERT INTO Contient VALUES (005, 018, 70);
INSERT INTO Contient VALUES (005, 016, 3);
INSERT INTO Contient VALUES (005, 020, 50);
/* Panacota */
INSERT INTO Contient VALUES (006, 019, 100);
INSERT INTO Contient VALUES (006, 021, 2);
INSERT INTO Contient VALUES (006, 022, 250);
INSERT INTO Contient VALUES (006, 023, 250);
INSERT INTO Contient VALUES (006, 024, 150);
/* Mojito */
INSERT INTO Contient VALUES (007, 025, 45);
INSERT INTO Contient VALUES (007, 026, 25);
INSERT INTO Contient VALUES (007, 027, 6);
INSERT INTO Contient VALUES (007, 019, 30);
/* Gin Tonic */
INSERT INTO Contient VALUES (008, 026, 25);
INSERT INTO Contient VALUES (008, 028, 8);
INSERT INTO Contient VALUES (008, 029, 45);
/* Vin chaud aux épices */
INSERT INTO Contient VALUES (009, 019, 250);
INSERT INTO Contient VALUES (009, 030, 1500);
INSERT INTO Contient VALUES (009, 031, 50);
/* Virgin Cuba Libre */
INSERT INTO Contient VALUES (010, 032, 15);
INSERT INTO Contient VALUES (010, 033, 200);

-- Table TypeDiete.

INSERT INTO TypeDiete VALUES (001, 'Végétarien');
INSERT INTO TypeDiete VALUES (002, 'Végane');
INSERT INTO TypeDiete VALUES (003, 'Carnivore');
INSERT INTO TypeDiete VALUES (004, 'Sans alcool');
INSERT INTO TypeDiete VALUES (005, 'Avec alcool');
INSERT INTO TypeDiete VALUES (006, 'Sans porc');
INSERT INTO TypeDiete VALUES (007, 'Cétogène');
INSERT INTO TypeDiete VALUES (008, 'Crudivore');
INSERT INTO TypeDiete VALUES (009, 'Pesco-végétarien');
INSERT INTO TypeDiete VALUES (010, 'Beegan');

-- Table Respecte.

INSERT INTO Respecte VALUES (001, 004);
INSERT INTO Respecte VALUES (001, 006);

INSERT INTO Respecte VALUES (002, 001);
INSERT INTO Respecte VALUES (002, 002);
INSERT INTO Respecte VALUES (002, 004);
INSERT INTO Respecte VALUES (002, 006);
INSERT INTO Respecte VALUES (002, 009);

INSERT INTO Respecte VALUES (003, 004);
INSERT INTO Respecte VALUES (003, 007);

INSERT INTO Respecte VALUES (004, 004);
INSERT INTO Respecte VALUES (004, 006);

INSERT INTO Respecte VALUES (005, 001);
INSERT INTO Respecte VALUES (005, 009);
INSERT INTO Respecte VALUES (005, 004);
INSERT INTO Respecte VALUES (005, 006);

INSERT INTO Respecte VALUES (006, 001);
INSERT INTO Respecte VALUES (006, 009);
INSERT INTO Respecte VALUES (006, 004);
INSERT INTO Respecte VALUES (006, 006);

INSERT INTO Respecte VALUES (007, 001);
INSERT INTO Respecte VALUES (007, 009);
INSERT INTO Respecte VALUES (007, 002);
INSERT INTO Respecte VALUES (007, 005);
INSERT INTO Respecte VALUES (007, 006);

INSERT INTO Respecte VALUES (008, 001);
INSERT INTO Respecte VALUES (008, 009);
INSERT INTO Respecte VALUES (008, 002);
INSERT INTO Respecte VALUES (008, 005);
INSERT INTO Respecte VALUES (008, 006);

INSERT INTO Respecte VALUES (009, 001);
INSERT INTO Respecte VALUES (009, 009);
INSERT INTO Respecte VALUES (009, 002);
INSERT INTO Respecte VALUES (009, 005);
INSERT INTO Respecte VALUES (009, 006);

INSERT INTO Respecte VALUES (010, 001);
INSERT INTO Respecte VALUES (010, 009);
INSERT INTO Respecte VALUES (010, 002);
INSERT INTO Respecte VALUES (010, 004);
INSERT INTO Respecte VALUES (010, 005);
INSERT INTO Respecte VALUES (010, 006);

-- Table Commente.

INSERT INTO Commente VALUES (008, 001, '2021-12-02', 'J''ai testé cette recette et ce fut une très belle découverte !');
INSERT INTO Commente VALUES (002, 002, '2021-11-23', 'Les gâteaux de riz étaient durs et fades... Recette inutile et le résultat ne ressemble à rien à ce que l''on peut manger dans un restaurant coréen...');
INSERT INTO Commente VALUES (006, 003, '2021-12-04', 'C''est vraiment trop bon :D ...');
INSERT INTO Commente VALUES (001, 004, '2021-12-06', 'J''ai bien aimé, mais ça aurait été mieux sans poivrons.');
INSERT INTO Commente VALUES (010, 005, '2021-12-01', 'Pensez à mettre de la vanille.');
INSERT INTO Commente VALUES (002, 006, '2021-11-22', 'Bah la gelatine prend pas... La recette sert à rien. Sauf si vous aimez les panacotas toutes flasques.');
INSERT INTO Commente VALUES (009, 007, '2021-12-19', 'Super facile à faire ! Vivement l''été.');
INSERT INTO Commente VALUES (009, 008, '2021-12-19', 'Le goût est un peu trop fort mais c''est pas mal. Le gin reste plus agréable avec une autre boisson. Le tonic c''est un peu trop amer.');
INSERT INTO Commente VALUES (003, 009, '2021-12-05', 'Le vin chaud est une merveille pour accompagner les fêtes d''hiver. Il faut ajouter des épices, comme le faisait ma mère. Pas seulement du gimgembre.');
INSERT INTO Commente VALUES (008, 010, '2021-12-03', 'Cette recette est super quand on veut éviter de boire de l''alcool. J''ai acheté le sirop de rhum sur Internet, impossible d''en trouver au supermaché T_T .');

-- Table Aime.

INSERT INTO Aime VALUES (008, 001);
INSERT INTO Aime VALUES (006, 001);
INSERT INTO Aime VALUES (001, 004);
INSERT INTO Aime VALUES (009, 007);
INSERT INTO Aime VALUES (009, 008);
INSERT INTO Aime VALUES (003, 009);
INSERT INTO Aime VALUES (008, 010);
INSERT INTO Aime VALUES (010, 001);
INSERT INTO Aime VALUES (010, 005);
INSERT INTO Aime VALUES (008, 002);

-- Table Consulte.

INSERT INTO Consulte VALUES ('2021-06-04', 008, 001);
INSERT INTO Consulte VALUES ('2021-06-05', 006, 001);
INSERT INTO Consulte VALUES ('2021-06-06', 002, 002);
INSERT INTO Consulte VALUES ('2021-06-07', 006, 003);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (001, 004);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (010, 005);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (002, 006);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (009, 007);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (009, 008);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (003, 009);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (008, 010);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (010, 001);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (010, 006);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (008, 002);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (011, 001);
INSERT INTO Consulte(idUtilisateur, idRecette) VALUES (011, 002);
INSERT INTO Consulte VALUES ('2010-07-01', 000, 002);
INSERT INTO Consulte VALUES ('2021-07-01', 001, 002);
INSERT INTO Consulte VALUES ('2021-07-02', 002, 002);
INSERT INTO Consulte VALUES ('2021-07-03', 003, 002);
INSERT INTO Consulte VALUES ('2011-07-01', 004, 002);
INSERT INTO Consulte VALUES ('2011-07-02', 005, 002);
INSERT INTO Consulte VALUES ('2011-07-03', 006, 002);
INSERT INTO Consulte VALUES ('2012-07-01', 007, 002);
INSERT INTO Consulte VALUES ('2012-07-02', 008, 002);
INSERT INTO Consulte VALUES ('2012-07-03', 009, 002);
INSERT INTO Consulte VALUES ('2013-07-01', 010, 002);
INSERT INTO Consulte VALUES ('2014-07-02', 011, 002);
INSERT INTO Consulte VALUES ('2015-07-03', 009, 001);


-- Table Allergique.

INSERT INTO Allergique VALUES (008, 018);
INSERT INTO Allergique VALUES (008, 022);
INSERT INTO Allergique VALUES (008, 023);
INSERT INTO Allergique VALUES (008, 007);
INSERT INTO Allergique VALUES (008, 012);
INSERT INTO Allergique VALUES (007, 016);
INSERT INTO Allergique VALUES (007, 018);
INSERT INTO Allergique VALUES (007, 022);
INSERT INTO Allergique VALUES (007, 023);
INSERT INTO Allergique VALUES (005, 002);
