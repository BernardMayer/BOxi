-- 
-- Initialisation de la DB de stockage de l'inventaire des documents BO (de type FullClient) presents dans le FRS
-- 

-- 20171109 Bernard Mayer 

-- Les traces des inventaires
DROP TABLE IF EXISTS RUN;
CREATE TABLE RUN (
	RUN_ID INTEGER NOT NULL,
	RUN_START_EPOCH INTEGER,
	RUN_START_TS TIMESTAMP,
	RUN_START_DT VARCHAR(19), --TEXT, --DATETIME,
	RUN_START_D INTEGER, 
	RUN_STOP_EPOCH INTEGER,
	RUN_STOP_TS TIMESTAMP,
	RUN_STOP_DT VARCHAR(19), --TEXT, -- DATETIME,
	RUN_STOP_D INTEGER
);
INSERT INTO RUN (RUN_ID, RUN_START_EPOCH, RUN_START_TS, RUN_START_DT, RUN_START_D, RUN_STOP_EPOCH, RUN_STOP_TS, RUN_STOP_DT, RUN_STOP_D)
VALUES (
0, 
STRFTIME('%s','now'), 
STRFTIME('%Y%m%d%H%M%S','now'), 
DATETIME('now'), 
STRFTIME('%Y%m%d','now'),
STRFTIME('%s','now'), 
STRFTIME('%Y%m%d%H%M%S','now'), 
DATETIME('now'), 
STRFTIME('%Y%m%d','now')
);
CREATE UNIQUE INDEX RUN_IDX_UPK 
	ON RUN(RUN_ID)
;

-- Les differents plateformes / serveurs
DROP TABLE IF EXISTS CRS;
CREATE TABLE CRS (
	CR_ID_INT INTEGER NOT NULL,
	CR_ID VARCHAR(7) NOT NULL,
	CR_LABEL VARCHAR(77),
	PRIMARY KEY(CR_ID_INT, CR_ID)
)
;
CREATE UNIQUE INDEX CR_ID_INTX_UPK 
	ON CRS(CR_ID_INT, CR_ID)
;
INSERT INTO CRS (CR_ID_INT, CR_ID, CR_LABEL)
VALUES 
(1, 'DEVTU', 'DEVTU'), 
(2, 'DEVTUO', 'DEVTUO'), 
(3, 'NEHOM', 'NEHOM'), 
(4, 'REFV1', 'REFV1'), 
(5, 'HPV1B3', 'HPV1B3'), 
(6, 'VMOE', 'VMOE'), 
(7, 'VMOE2', 'VMOE2'), 
(8, 'VMOA', 'VMOA'), 
(9, 'VMOA2', 'VMOA2'), 
(10, 'AL', 'AL'), 
(11, 'AM', 'AM'), 
(12, 'AO', 'AO'), 
(13, 'AP', 'AP'), 
(14, 'AQ', 'Aquitaine'), 
(15, 'AV', 'Atlantique-Vendee'), 
(16, 'BI', 'BI'), 
(17, 'BP', 'BP'), 
(18, 'CA', 'CA'), 
(19, 'CE', 'Charente-Perigord'), 
(20, 'CL', 'CL'), 
(21, 'CO', 'CO'), 
(22, 'CP', 'CP'), 
(23, 'CR', 'CR'), 
(24, 'CS', 'CS'), 
(25, 'DP', 'DP'), 
(26, 'FC', 'FC'), 
(27, 'FI', 'FI'), 
(28, 'GU', 'Guadeloupe'), 
(29, 'IF', 'IF'), 
(30, 'IV', 'IV'), 
(31, 'JP', 'JP'), 
(32, 'KP', 'KP'), 
(33, 'LA', 'LA'), 
(34, 'LO', 'LO'), 
(35, 'LP', 'LP'), 
(36, 'MA', 'Martinique'), 
(37, 'MO', 'MO'), 
(38, 'NE', 'NE'), 
(39, 'NF', 'NF'), 
(40, 'NM', 'NM'), 
(41, 'NO', 'NO'), 
(42, 'NS', 'NS'), 
(43, 'PG', 'PG'), 
(44, 'RE', 'Reunion'), 
(45, 'RP', 'RP'), 
(46, 'SM', 'SM'), 
(47, 'TO', 'TO'), 
(48, 'TP', 'TP'), 
(49, 'VF', 'Val de France')
;

-- Les differents types de documents BO
DROP TABLE IF EXISTS BO_DOC_TYPES;
CREATE TABLE BO_DOC_TYPES (
	BO_DOC_TYPES_ID INTEGER NOT NULL,
	SI_KIND VARCHAR(77) NOT NULL,
	DOCTYPE_LABEL VARCHAR(77),
	PRIMARY KEY(BO_DOC_TYPES_ID, SI_KIND)
)
;
CREATE UNIQUE INDEX BO_DOC_TYPES_IDX_UPK 
	ON BO_DOC_TYPES(BO_DOC_TYPES_ID, SI_KIND)
;
INSERT INTO BO_DOC_TYPES (BO_DOC_TYPES_ID, SI_KIND, DOCTYPE_LABEL)
VALUES 
(0, '?', 'Nature inconnue'),
(1,  'FullClient', 'Document .rep'), 
(2,  'Agnostic',  'Agnostic'), 
(3,  'CrystalReport',  'CrystalReport'), 
(4,  'Excel',  'Excel'), 
(5,  'FullClientAddin',  'FullClientAddin'), 
(6,  'Hyperlink',  'Hyperlink'), 
(7,  'ObjectPackage',  'ObjectPackage'), 
(8,  'Pdf',  'Pdf'), 
(9,  'Powerpoint',  'Powerpoint'), 
(10, 'Program', 'Program'), 
(11, 'Publication', 'Publication'), 
(12, 'Txt', 'Txt'), 
(13, 'Webi', 'Webi'), 
(14, 'Word', 'Word')
;

-- Liste des documents BO de toutes les plateformes
DROP TABLE IF EXISTS BO_DOCS_LISTE;
CREATE TABLE BO_DOCS_LISTE (
	RUN_ID INTEGER NOT NULL,
	CR_ID VARCHAR(7) NOT NULL,
	SI_ID INTEGER NOT NULL,
	SI_CUID VARCHAR(24) NOT NULL,
	SI_NAME VARCHAR(77) NOT NULL,
	SI_KIND VARCHAR(24),
	DOC_FOLDER VARCHAR(333),
	DT_CREATE VARCHAR(19),
	DT_MODIF VARCHAR(19) NOT NULL
);
CREATE UNIQUE INDEX BO_DOCS_LISTE_IDX_UPK 
	ON BO_DOCS_LISTE(RUN_ID, CR_ID, SI_CUID);
CREATE UNIQUE INDEX BO_DOCS_LISTE_IDX_SEARCHDOC 
	ON BO_DOCS_LISTE(RUN_ID, CR_ID, SI_ID);


-- Liste des datetime de modifications des documents
DROP TABLE IF EXISTS BO_DOCS_MODIFS;
CREATE TABLE BO_DOCS_MODIFS (
	RUN_ID INTEGER NOT NULL,
	CR_ID ARCHAR(7) NOT NULL,
	SI_ID INTEGER NOT NULL,
	DT_MODIF VARCHAR(19) NOT NULL,
	D_MODIF INTEGER
);	
CREATE UNIQUE INDEX BO_DOCS_MODIFS_IDX_UPK 
	ON BO_DOCS_MODIFS(RUN_ID, CR_ID, SI_ID, DT_MODIF);

-- VACUUM attached DB if sqlite > 3.15
VACUUM;