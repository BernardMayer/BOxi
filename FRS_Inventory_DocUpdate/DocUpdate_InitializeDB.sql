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
(764, 'DP', 'Chalus'), 
(802, 'NE', 'Nord-Est'), 
(810, 'JP', 'Champagne-Bourgogne'), 
(812, 'NM', 'Nord Midi Pyrenees'), 
(813, 'AL', 'Alpes Provence'), 
(817, 'CS', 'Charente Maritime Deux Sevres'), 
(820, 'CR', 'Corse'), 
(822, 'CA', 'Cetes-d Armor'), 
(824, 'CE', 'Charente Perigord'), 
(825, 'FC', 'Franche-Comte'), 
(829, 'FI', 'Finistere'), 
(831, 'TO', 'Toulouse'), 
(833, 'AQ', 'Aquitaine'), 
(835, 'LA', 'Languedoc'), 
(836, 'IV', 'Ille-et-Vilaine'), 
(839, 'RP', 'Sud Rhene-Alpes'), 
(844, 'VF', 'Val-de-France'), 
(845, 'KP', 'Loire-Haute Loire'), 
(847, 'AV', 'Atlantique-Vendee'), 
(848, 'CL', 'Centre Loire'), 
(860, 'MO', 'Morbihan'), 
(861, 'LO', 'Lorraine'), 
(866, 'NO', 'Normandie'), 
(867, 'NF', 'Nord de France'), 
(868, 'BP', 'Centre France'), 
(869, 'PG', 'Pyrenees-Gascogne'), 
(871, 'SM', 'Sud Mediterranee'), 
(872, 'AO', 'Alsace-Vosges'), 
(878, 'LP', 'Centre-Est'), 
(879, 'AM', 'de l Anjou et du Maine'), 
(881, 'AP', 'Des Savoies'), 
(882, 'IF', 'Paris-Ile-de-France'), 
(883, 'NS', 'Normandie-Seine'), 
(887, 'BI', 'Brie-Picardie'), 
(891, 'CP', 'Provence Cotes d Azur'), 
(894, 'TP', 'Touraine-Poitou'), 
(895, 'CO', 'Centre-Ouest'), 
(900, 'GU', 'Guadeloupe'), 
(902, 'MA', 'Martinique'), 
(903, 'RE', 'Reunion')
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
(0,  '?', 'Nature inconnue'),
(1,  'FullClient', 'Document .rep'), 
(2,  'Agnostic',  'Agnostic'), 
(3,  'CrystalReport',  'CrystalReport'), 
(4,  'Excel',  'Excel'), 
(5,  'FavoritesFolder', 'FavoritesFolder'),
(6,  'FullClientAddin',  'FullClientAddin'), 
(7,  'Hyperlink',  'Hyperlink'), 
(8,  'ObjectPackage',  'ObjectPackage'), 
(9,  'Pdf',  'Pdf'), 
(10, 'Powerpoint',  'Powerpoint'), 
(11, 'Program', 'Program'), 
(12, 'Publication', 'Publication'), 
(13, 'Rtf', 'Rtf'),
(14, 'Shortcut', 'Shortcut'),
(15, 'Txt', 'Txt'), 
(16, 'Webi', 'Webi'), 
(17, 'Word', 'Word')
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