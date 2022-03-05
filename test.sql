/*
 * Fichier : test_Groupe7.sql
 * Gestion de recettes de cuisine
 *--------------------------------
 * Auteurs:
 * PUJADE Joffrey - 22011040
 * DOGAN Ozgur - 21811290
 * BENSIKHALED Madani - 21801055
 * BANDO Sio - 21802005
 */

-- 5 requêtes demandées :

-- (Utilisation du GROUP BY)
\echo 1- Quelles sont 3 premières recettes les plus consultées pour les utilisateurs qui ont entre 30 et 40 ans ? (nom recette, nmbr de consultation)

SELECT nomRecette, COUNT(nomRecette) AS nombre_de_consultation FROM Recette
    INNER JOIN Consulte ON Recette.idRecette = Consulte.idRecette
    INNER JOIN Utilisateur On Utilisateur.idUtilisateur = Consulte.idUtilisateur
        WHERE Utilisateur.age BETWEEN 30 AND 40 GROUP BY nomRecette
            ORDER BY nombre_de_consultation DESC LIMIT 3;


-- (Utilisation d'une divison)
\echo 2- Existe-t-il une recette qui est consultée par tous les utilisateurs ?

SELECT nomRecette FROM Recette
    WHERE NOT EXISTS (SELECT * FROM Utilisateur
        WHERE NOT EXISTS (
            SELECT * FROM Consulte WHERE Recette.idRecette = Consulte.idRecette AND 
                                            Consulte.idUtilisateur = Utilisateur.idUtilisateur));


-- (Utilisation d'une sous-requête)
\echo 3- Quelles sont les recettes consultées mais pas likées ? 

SELECT nomRecette FROM Recette
    INNER JOIN Consulte ON Recette.idRecette = Consulte.idRecette
        WHERE Consulte.idRecette NOT IN (SELECT idRecette FROM AIME) GROUP BY nomRecette;


-- (Utilisation de plusieurs sous-requêtes)
\echo 4- Quelles sont les recettes qui ont été consultées et qui respectent les mêmes types de diète que la recette "Virgin Cuba Libre" ?

SELECT nomRecette FROM Recette
    WHERE idRecette IN (SELECT idRecette FROM Consulte)
        AND idRecette IN (SELECT idRecette FROM Respecte
                              WHERE idDiete IN (SELECT idDiete FROM Respecte WHERE idRecette = (SELECT idRecette FROM RECETTE WHERE nomRecette='Virgin Cuba Libre'))
                                  GROUP BY idRecette HAVING COUNT(*)=(SELECT count(*) FROM Respecte WHERE idRecette = (SELECT idRecette FROM RECETTE WHERE nomRecette='Virgin Cuba Libre')));


-- (Utilisation d'une sous-requête correlée)
\echo 5- Quelles sont les recettes de plus grande difficulté de réalisation pour chaque utilisateur ?

SELECT U.nom, U.prenom, nomRecette FROM Utilisateur U
    INNER JOIN Recette ON U.idUtilisateur = Recette.idUtilisateur
        WHERE Recette.difficulte = (SELECT MAX(difficulte) FROM Recette WHERE idUtilisateur = U.idUtilisateur);


-- Requêtes testant nos deux triggers : 

\echo
\echo -TEST TRIGGERS-
\echo

\echo -Test trigger fctinsertionmodificationrecette() -> insertion d'' un plat accompagnant qui s''accompagne lui-même :
INSERT INTO Recette VALUES (100, 'Italie', 'Pâtes', 'Pâtes', 1, 10, '1) Mettre les pâtes dans l''eau bouillante pendant 10 minutes.' , 'PLAT', 11, 100);
\echo -Test trigger fctinsertionmodificationrecette() -> insertion d''un plat contenant un ingrédient dont l''utilisateur est allergique :
INSERT INTO Allergique VALUES (011, 016);
INSERT INTO Recette VALUES (100, 'Italie', 'Pâtes', 'Pâtes', 1, 10, '1) Mettre les pâtes dans l''eau bouillante pendant 10 minutes.' , 'PLAT', 11, null);
INSERT INTO Contient VALUES (100, 016, 3);
\echo -Test trigger fctinsertionmodificationrecette() -> le niveau de cuisine d''un utilisateur ne peut pas être 0:
INSERT INTO Utilisateur VALUES(012, 'utilisateur12', 'uti12', 38, 'N', 'use1r', 'sudosu@bel.com', 'azerty123', 0);
\echo -Test trigger fctinsertionmodificationrecette() -> le niveau de cuisine d''un utilisateur ne peut pas être < que la niveau requis pour la recette quand il propose cette recette:
INSERT INTO Recette VALUES (50, 'Italie', 'Pâtes2', 'Pâtes2', 2, 10, '1) Mettre les pâtes dans l''eau bouillante pendant 10 minutes.' , 'PLAT', 9, NULL);
\echo -Test trigger fctInsertionModificationAllergique() -> un utilisateur ne peut pas être allergique à l''un des ingrédients d''une recette qu''il a proposé autrefois:
INSERT INTO Allergique VALUES (3, 1);


-- Requêtes testant nos deux fonctions :

\echo
\echo -TEST FONCTIONS-
\echo

\echo - Test de la fonction nombreCalories() avec sélection de toutes les recettes avec leur nombre de calories par ordre décroissant :
SELECT nomRecette, typeRecette, nombreCalories(idRecette) AS Calories FROM Recette ORDER BY Calories DESC;

\echo - Test de la fonction nombreLikes() avec sélection de toutes les recettes avec leur nombre de likes par orde décroissant :
SELECT nomRecette, typeRecette, nombreLikes(idRecette) AS nombre_de_likes FROM Recette ORDER BY nombre_de_likes DESC;


-- Requêtes testant notre procédure :

\echo
\echo -TEST PROCÉDURE-
\echo

\echo - Test de la procédure obtenirUneRecette() avec sélection de l''une des recettes choisie arbitrairement:

DROP FUNCTION IF EXISTS appel1() CASCADE;
DROP FUNCTION IF EXISTS appel2() CASCADE;
DROP FUNCTION IF EXISTS appel3() CASCADE;
DROP FUNCTION IF EXISTS appelProcedure() CASCADE;

CREATE OR REPLACE FUNCTION appel1() RETURNS TEXT AS $$
DECLARE
	recetteChoisie RECORD;
	contientRecetteChoisie RECORD;
	ingredientsRecetteChoisie RECORD;
BEGIN
	CALL obtenirUneRecette(1, recetteChoisie, contientRecetteChoisie, ingredientsRecetteChoisie);
	
	RETURN recetteChoisie;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION appel2() RETURNS TEXT AS $$
DECLARE
	recetteChoisie RECORD;
	contientRecetteChoisie RECORD;
	ingredientsRecetteChoisie RECORD;
BEGIN
	CALL obtenirUneRecette(1, recetteChoisie, contientRecetteChoisie, ingredientsRecetteChoisie);
	
	RETURN contientRecetteChoisie;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION appel3() RETURNS TEXT AS $$
DECLARE
	recetteChoisie RECORD;
	contientRecetteChoisie RECORD;
	ingredientsRecetteChoisie RECORD;
BEGIN
	CALL obtenirUneRecette(1, recetteChoisie, contientRecetteChoisie, ingredientsRecetteChoisie);
	
	RETURN ingredientsRecetteChoisie;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION appelProcedure() RETURNS TEXT AS $$
BEGIN
	RETURN appel1() || appel2() || appel3();
END;
$$ LANGUAGE plpgsql;

SELECT nomRecette, appelProcedure() AS appel FROM Recette WHERE idRecette = 1;

DROP FUNCTION IF EXISTS appel1() CASCADE;
DROP FUNCTION IF EXISTS appel2() CASCADE;
DROP FUNCTION IF EXISTS appel3() CASCADE;
DROP FUNCTION IF EXISTS appelProcedure() CASCADE;
