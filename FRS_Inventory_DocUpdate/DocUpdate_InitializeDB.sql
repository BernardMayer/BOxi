-- 
-- Initialisation de la DB de stockage de l'inventaire des documents BO (de type FullClient) presents dans le FRS
-- 

-- 20171109 Bernard Mayer 

-- Les traces des inventaires
drop table if exists run;
create table run (
	run_id integer not null,
	run_start_epoch integer,
	run_start_ts timestamp,
	run_start_dt datetime,
	run_stop_epoch integer,
	run_stop_ts timestamp,
	run_stop_dt datetime
);
create unique index run_idx_upk on run(run_id);
insert into run (run_id, run_start_epoch, run_start_ts, run_start_dt)
values (0, 0, '20171109221300', '09/11/2017 22:13:00')
;

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

vacuum;