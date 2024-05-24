-- Quelle est la surface en eau du Golo à moins de 19 km de la mer.


SELECT * FROM france.rn_rna WHERE name ~~* '%Golo%' AND issea


SELECT sum(COALESCE (wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.rn_rna WHERE seaidsegment ='FR24470'
AND distanceseam <=19000 

-- 410098.06 656020.31


-- Rhône
(seaidsegment IN ('FR21724','FR21645') AND nature in ('Ecoulement naturel','Canal','Retenue')
AND persistance = 'Permanent') OR -- canal ON prends tout
(seaidsegment IN ('FR22333') and distanceseam < 7320 AND nature in ('Ecoulement naturel','Canal','Retenue')
AND persistance = 'Permanent') -- aval de la LSE sur le rhone
-- Petit Rhône
-- le bras du rhône coule à l'envers, je prends tout le cours d'eau avec code hydro plus 
-- deux segments en aval de la LSE
OR (code_hydro ='06S0000000357915954' AND idsegment in ('FR21199','FR21162'))
OR (seaidsegment = 'FR21653' AND nature in ('Ecoulement naturel','Canal', 'Retenue'))

/*
|wettedsurfacem2|wettedsurfaceotherm2    |
|---------------|------------------------|
|6 950 864,52   |4 789 168 081,2918458122|
*/
SELECT sum(COALESCE (wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.temp_waterbody_unitbv_rn_rna_rne
WHERE
(seaidsegment IN ('FR21724','FR21645') AND nature in ('Ecoulement naturel','Canal','Retenue')
AND persistance = 'Permanent') OR -- canal ON prends tout
(seaidsegment IN ('FR22333') and distanceseam >= 7320 and distanceseam <=56698 AND nature in ('Ecoulement naturel','Canal','Retenue')
AND persistance = 'Permanent') -- amont de la LSE sur le rhone
-- le bras du rhône coule à l'envers, je prends tout le cours d'eau avec code hydro plus 
-- deux segments en aval de la LSE
OR (code_hydro in ('06S0000000040266082',
'06S0000000040266090',
'06S0000000040266092',
'06S0000000040266255',
'06S0000000040266089',
'06S0000000040266091',
'06S0000000318324499',
'06S0000000357915953',
'06S0000000040266093',
'06S0000000040266477',
'06S0000000040266250',
'06S0000000343474565',
'06S0000000027503930',
'06S0000000027503931',
'06S0000000357915950',
'06S0000000343474562',
'06S0000000040267037',
'06S0000000318323530',
'06S0000000318323540',
'06S0000000318323541',
'06S0000000318323533',
'06S0000000318323534',
'06S0000000318323535',
'06S0000000040267209',
'06S0000000343474562',
'06S0000000027504369',
'06S0000000040267044',
'06S0000000040267045',
'06S0000000040266475',
'06S0000000040266477',
'06S0000000027504285',
'06S0000000027504284',
'06S0000000318323543',
'06S0000000318323529',
'06S0000000318323531',
'06S0000000318323536',
'06S0000000356417687',
'06S0000000040267196',
'06S0000000040266817',
'06S0000000348098566',
'06S0000000027504253',
'06S0000000357915953',
'06S0000000343474562',
'06S0000000040266255',
'06S0000000343474564',
'06S0000000318324496',
'06S0000000343474565',
'06S0000000357915953',
'06S0000000079231166',
'06S0000000343474562',
'06S0000000318323450',
'06S0000000305402107',
'06S0000000318324483',
'06S0000000081767986',
'06S0000000226866481',
'06S0000000040265798',
'06S0000000305402106',
'06S0000002012603757',
'06S0000000027503929',
'06S0000000040266255','06S0000000027504135','06S0000000040266260',
'06S0000000040266261','06S0000000040266262','06S0000000040266263',
'06S0000000040266264','06S0000000027503930','06S0000000348797404',
'06S0000000357915953','06S0000000040267689','06S0000000027504539',
'06S0000000040267691','06S0000000040267692',
'06S0000000343474562','06S0000000343474562',
'06S0000000040267396','06S0000000027504369',
'06S0000000343474562','06S0000000348098566','06S0000000040267400',
'06S0000000318323677','06S0000000027504411',
'06S0000000348797403','06S0000000040266474','06S0000000356417677',
'06S0000000040266777','06S0000000318323614'
))

SELECT sum(COALESCE (wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.temp_waterbody_unitbv_rn_rna_rne
WHERE seaidsegment IN ('FR22333') 
AND distanceseam <= 346363 and distanceseam >56698 
AND nature in ('Ecoulement naturel','Canal','Retenue','Retenue-barrage')
AND persistance = 'Permanent';


SELECT sum(COALESCE (rr.wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (rr.wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.temp_waterbody_unitbv_rn_rna_rne rr
JOIN france.rn_rna ON rn_rna.idsegment = rr.idsegment
WHERE rr.seaidsegment IN ('FR22333','FR21724','FR21645') 
AND altitudem <1000
AND rr.nature in ('Ecoulement naturel','Canal','Retenue','Retenue-barrage')
AND rr.persistance = 'Permanent';



SELECT sum(COALESCE (wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.temp_waterbody_unitbv_rn_rna_rne
WHERE seaidsegment IN ('FR22333') 
AND distanceseam <= 159700 and distanceseam >56698 
AND nature in ('Ecoulement naturel','Canal','Retenue','Retenue-barrage')
AND persistance = 'Permanent';


--surface de la Saône


SELECT sum(COALESCE (rr.wettedsurfacem2,0)) AS wettedsurfacem2, 
sum(COALESCE (rr.wettedsurfaceotherm2,0)) AS wettedsurfaceotherm2
FROM france.temp_waterbody_unitbv_rn_rna_rne rr
JOIN france.rn_rna ON rn_rna.idsegment = rr.idsegment
WHERE rr.seaidsegment IN ('FR22333','FR21724','FR21645') 
AND  path ~ '*.FR12390.*'
AND altitudem <1000
AND rr.nature in ('Ecoulement naturel','Canal','Retenue','Retenue-barrage')
AND rr.persistance = 'Permanent';
