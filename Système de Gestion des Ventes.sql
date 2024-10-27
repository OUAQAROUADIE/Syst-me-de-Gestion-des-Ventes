-- Table des clients
CREATE TABLE Clients (
    client_id NUMBER PRIMARY KEY,
    nom VARCHAR2(100),
    email VARCHAR2(100),
    telephone VARCHAR2(15)
);

-- Table des produits
CREATE TABLE Produits (
    produit_id NUMBER PRIMARY KEY,
    nom VARCHAR2(100),
    prix NUMBER(10, 2),
    quantite NUMBER
);

-- Table des ventes
CREATE TABLE Ventes (
    vente_id NUMBER PRIMARY KEY,
    client_id NUMBER,
    produit_id NUMBER,
    quantite NUMBER,
    date_vente DATE,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (produit_id) REFERENCES Produits(produit_id)
);

-- Ajouter un client
CREATE OR REPLACE PROCEDURE ajouter_client(
    p_client_id IN NUMBER,
    p_nom IN VARCHAR2,
    p_email IN VARCHAR2,
    p_telephone IN VARCHAR2
) AS
BEGIN
    INSERT INTO Clients (client_id, nom, email, telephone)
    VALUES (p_client_id, p_nom, p_email, p_telephone);
    COMMIT;
END ajouter_client;
/

-- Modifier un client
CREATE OR REPLACE PROCEDURE modifier_client(
    p_client_id IN NUMBER,
    p_nom IN VARCHAR2,
    p_email IN VARCHAR2,
    p_telephone IN VARCHAR2
) AS
BEGIN
    UPDATE Clients
    SET nom = p_nom, email = p_email, telephone = p_telephone
    WHERE client_id = p_client_id;
    COMMIT;
END modifier_client;
/

-- Supprimer un client
CREATE OR REPLACE PROCEDURE supprimer_client(
    p_client_id IN NUMBER
) AS
BEGIN
    DELETE FROM Clients
    WHERE client_id = p_client_id;
    COMMIT;
END supprimer_client;
/
-- Créer la procédure pour ajouter un produit
CREATE OR REPLACE PROCEDURE ajouter_produit (
    p_produit_id IN NUMBER,
    p_nom IN VARCHAR2,
    p_prix IN NUMBER,
    p_quantite IN NUMBER
) AS
BEGIN
    INSERT INTO Produits (produit_id, nom, prix, quantite)
    VALUES (p_produit_id, p_nom, p_prix, p_quantite);
    COMMIT; -- Assurez-vous que les changements sont enregistrés
    DBMS_OUTPUT.PUT_LINE('Produit ajouté : ' || p_nom);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Produit avec cet ID existe déjà.');
END;
/
-- Enregistrer une vente
CREATE OR REPLACE PROCEDURE enregistrer_vente(
    p_vente_id IN NUMBER,
    p_client_id IN NUMBER,
    p_produit_id IN NUMBER,
    p_quantite IN NUMBER
) AS
BEGIN
    INSERT INTO Ventes (vente_id, client_id, produit_id, quantite, date_vente)
    VALUES (p_vente_id, p_client_id, p_produit_id, p_quantite, SYSDATE);
    
    -- Mettre à jour la quantité de produit
    UPDATE Produits
    SET quantite = quantite - p_quantite
    WHERE produit_id = p_produit_id;

    COMMIT;
END enregistrer_vente;
/
-- Générer une facture pour une vente
CREATE OR REPLACE PROCEDURE generer_facture(
    p_vente_id IN NUMBER
) AS
    v_client_nom VARCHAR2(100);
    v_produit_nom VARCHAR2(100);
    v_quantite NUMBER;
    v_prix NUMBER;
    v_total NUMBER;
BEGIN
    -- Récupérer les détails de la vente
    SELECT c.nom, p.nom, v.quantite, p.prix
    INTO v_client_nom, v_produit_nom, v_quantite, v_prix
    FROM Ventes v
    JOIN Clients c ON v.client_id = c.client_id
    JOIN Produits p ON v.produit_id = p.produit_id
    WHERE v.vente_id = p_vente_id;

    -- Calculer le total
    v_total := v_quantite * v_prix;

    -- Afficher la facture
    DBMS_OUTPUT.PUT_LINE('Facture pour la vente ID: ' || p_vente_id);
    DBMS_OUTPUT.PUT_LINE('Client: ' || v_client_nom);
    DBMS_OUTPUT.PUT_LINE('Produit: ' || v_produit_nom);
    DBMS_OUTPUT.PUT_LINE('Quantité: ' || v_quantite);
    DBMS_OUTPUT.PUT_LINE('Prix unitaire: ' || v_prix);
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total);
END generer_facture;
/
-- Générer un rapport de ventes
CREATE OR REPLACE PROCEDURE rapport_ventes IS
    CURSOR vente_cur IS
        SELECT v.vente_id, c.nom AS client_nom, p.nom AS produit_nom, v.quantite, v.date_vente
        FROM Ventes v
        JOIN Clients c ON v.client_id = c.client_id
        JOIN Produits p ON v.produit_id = p.produit_id;

    v_vente_id Ventes.vente_id%TYPE;
    v_client_nom Clients.nom%TYPE;
    v_produit_nom Produits.nom%TYPE;
    v_quantite Ventes.quantite%TYPE;
    v_date_vente Ventes.date_vente%TYPE;
BEGIN
    OPEN vente_cur;
    LOOP
        FETCH vente_cur INTO v_vente_id, v_client_nom, v_produit_nom, v_quantite, v_date_vente;
        EXIT WHEN vente_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Vente ID: ' || v_vente_id || ', Client: ' || v_client_nom || ', Produit: ' || v_produit_nom || ', Quantité: ' || v_quantite || ', Date: ' || v_date_vente);
    END LOOP;
    CLOSE vente_cur;
END rapport_ventes;
/
