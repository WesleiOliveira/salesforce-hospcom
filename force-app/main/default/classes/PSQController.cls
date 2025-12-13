public with sharing class PSQController {
    public PSQ__c psqRecord { get; set; }
    public List<HISTORICO_DE_REVISAO__c> historicosOrdenados { get; set; }

    // Construtor do controlador
    public PSQController() {
        String psqId = ApexPages.currentPage().getParameters().get('id'); // Obtenha o ID do registro PSQ__c a partir da URL
        if (String.isNotBlank(psqId)) {
            // Agora você pode acessar as propriedades de PSQ__c usando psqRecord
            if (String.isNotBlank(psqId)) {
                // Consulta para obter os registros de histórico associados e ordená-los pela Data__c
                historicosOrdenados = [SELECT Id, Item__c, Natureza_da_Alteracao__c, Data__c, Procedimento_do_Sistema_de_Qualidade__c
                                      FROM HISTORICO_DE_REVISAO__c
                                      WHERE Procedimento_do_Sistema_de_Qualidade__c = :psqId
                                      ORDER BY Data__c];
            }
        } else {
            // Lida com erro ou redirecionamento caso o ID esteja em branco
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'O ID do procedimento não foi fornecido.'));
            
            
            
        String a1449 = '1449';
        String a1450 = '1450';
        String a1451 = '1451';
        String a1452 = '1452';
        String a1453 = '1453';
        String a1454 = '1454';
        String a1455 = '1455';
        String a1456 = '1456';
        String a1457 = '1457';
        String a1458 = '1458';
        String a1459 = '1459';
        String a1460 = '1460';
        String a1461 = '1461';
        String a1462 = '1462';
        String a1463 = '1463';
        String a1464 = '1464';
        String a1465 = '1465';
        String a1466 = '1466';
        String a1467 = '1467';
        String a1468 = '1468';
        String a1469 = '1469';
        String a1470 = '1470';
        String a1471 = '1471';
        String a1472 = '1472';
        String a1473 = '1473';
        String a1474 = '1474';
        String a1475 = '1475';
        String a1476 = '1476';
        String a1477 = '1477';
        String a1478 = '1478';
        String a1479 = '1479';
        String a1480 = '1480';
        String a1481 = '1481';
        String a1482 = '1482';
        String a1483 = '1483';
        String a1484 = '1484';
        String a1485 = '1485';
        String a1486 = '1486';
        String a1487 = '1487';
        String a1488 = '1488';
        String a1489 = '1489';
        String a1490 = '1490';
        String a1491 = '1491';
        String a1492 = '1492';
        String a1493 = '1493';
        String a1494 = '1494';
        String a1495 = '1495';
        String a1496 = '1496';
        String a1497 = '1497';
        String a1498 = '1498';
        String a1499 = '1499';
        String a13283 = '13283';
        String a13284 = '13284';
        String a13285 = '13285';
        String a13286 = '13286';
        String a13287 = '13287';
        String a13288 = '13288';
        String a13289 = '13289';
        String a13290 = '13290';
        String a13291 = '13291';
        String a13292 = '13292';
        String a13293 = '13293';
        String a13294 = '13294';
        String a13295 = '13295';
        String a13296 = '13296';
        String a13297 = '13297';
        String a13298 = '13298';
        String a13299 = '13299';
        String a14000 = '1400';
        String a14001 = '1401';
        String a14002 = '1402';
        String a14003 = '1403';
        String a14004 = '1404';
        String a14005 = '1405';
        String a14006 = '1406';
        String a14007 = '1407';
        String a14008 = '1408';
        String a14009 = '1409';
        String a14010 = '1410';
        String a14011 = '1411';
        String a14012 = '1412';
        String a140132 = '14132';
        String a14014 = '1414';
        String a14015 = '1415';
        String a14016 = '1416';
        String a14017 = '1417';
        String a14018 = '1418';
        String a14019 = '1419';
        String a14020 = '1420';
        String a14021 = '1421';
        String a14022 = '1422';
        String a14023 = '1423';
        String a14024 = '1424';
        String a14025 = '1425';
        String a14026 = '1426';
        String a14027 = '1427';
        String a14028 = '1428';
        String a14029 = '1429';
        String a14030 = '1430';
        String a14031 = '1431';
        String a14032 = '1432';
        String a14033 = '1433';
        String a14034 = '1434';
        String a14035 = '1435';
        String a14036 = '1436';
        String a14037 = '1437';
        String a14038 = '1438';
        String a14039 = '1439';
        String a14040 = '1440';
        String a14041 = '1441';
        String a14042 = '1442';
        String a14043 = '1443';
        String a14044 = '1444';
        String a14045 = '1445';
        String a14046 = '1446';
        String a14047 = '1447';
        String a14048 = '1448';
        String a14049 = '1449';
        String a14050 = '1450';
        String a14051 = '1451';
        String a14052 = '1452';
        String a14053 = '1453';
        String a14054 = '1454';
        String a14055 = '1455';
        String a14056 = '1456';
        String a14057 = '1457';
        String a14058 = '1458';
        String a14059 = '1459';
        String a14060 = '1460';
        String a14061 = '1461';
        String a14062 = '1462';
        String a14063 = '1463';
        String a14064 = '1464';
        String a14065 = '1465';
        String a14066 = '1466';
        String a14067 = '1467';
        String a14068 = '1468';
        String a14069 = '1469';
        String a14070 = '1470';
        String a14071 = '1471';
        String a14072 = '1472';
        String a14073 = '1473';
        String a14074 = '1474';
        String a14075 = '1475';
        String a14076 = '1476';
        String a14077 = '1477';
        String a14078 = '1478';
        String a14079 = '1479';
        String a14080 = '1480';
        String a14081 = '1481';
        String a14082 = '1482';
        String a14083 = '1483';
        String a14084 = '1484';
        String a14085 = '1485';
        String a14086 = '1486';
        String a14087 = '1487';
        String a14088 = '1488';
        String a14089 = '1489';
        String a14090 = '1490';
            
        }
    }
}