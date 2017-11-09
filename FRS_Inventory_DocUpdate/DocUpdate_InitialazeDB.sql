-- 
-- Initialisation de la DB de stockage de l'inventaire des documents BO (de type FullClient) presents dans le FRS
-- 

-- 20171109 Bernard Mayer 

-- Les differents plateformes / serveur
DROP TABLE IF EXISTS CRs;
CREATE TABLE CRs (
	CR_ID INTEGER NOT NULL,
	BO_Key VARCHAR(7) NOT NULL,
	CR_Label VARCHAR(77),
	PRIMARY KEY(CR_ID, BO_Key)
)
;
CREATE UNIQUE INDEX CRs_idx_UPK ON CRs(CR_ID, BO_Key)
;
INSERT INTO CRs (CR_ID, BO_Key, CR_Label)
VALUES 
(1, 'DevTU', 'DevTu'),
(2, 'NEHOM', 'NeHom')
;

-- Les differents types de documents BO
DROP TABLE IF EXISTS BO_Doctypes;
CREATE TABLE BO_Doctypes (
	BO_Doctype_ID INTEGER NOT NULL,
	BO_Kind VARCHAR(77) NOT NULL,
	Doctype_Label VARCHAR(77),
	PRIMARY KEY(BO_Doctype_ID, BO_Kind)
)
;
CREATE UNIQUE INDEX BO_Doctypes_idx_UPK ON BO_Doctypes(BO_Doctype_ID, BO_Kind)
;
INSERT INTO BO_Doctypes (BO_Doctype_ID, BO_Kind, Doctype_Label)
VALUES 
(1, 'FullClient', 'Doc .rep'),
(2, 'NEHOM', 'NeHom')
;
