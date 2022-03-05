/*
 * Fichier : suppression_Groupe7.sql
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