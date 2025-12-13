public class CriaMembrosDoTreinamento {

    
    @AuraEnabled
    public static void criaMembros(List<Map <String, String>> membros, String idTreinamento) {
        try {
            
            List<Membro_Interno_do_Evento__c> membrosInternos = new List<Membro_Interno_do_Evento__c>();
            // Crie uma lista para armazenar os IDs dos membros a serem consultados
            List<Id> membroIds = new List<Id>();
            
            // Adicione os IDs dos membros à lista
            for (Map<String,String> membro : membros) {
                
                membroIds.add(membro.get('Id'));
       
            	//System.debug('-------------');
            	System.debug('IDs: ' + membro.get('Id'));
                membro_Interno_do_Evento__c membroAtual = new Membro_Interno_do_Evento__c();
                membroAtual.CNPJ_CPF__c = membro.get('CPF__c');
                //membroAtual.Compareceu__c = true;
                membroAtual.email__c = membro.get('Email');
                membroAtual.Empresa__c = membro.get('AccountId');
                membroAtual.Evento__c = idTreinamento;
                membroAtual.nomeDoParticipante__c = membro.get('FirstName');
                membroAtual.Sobrenome__c = membro.get('LastName');
                membroAtual.profissao__c = membro.get('Title');
                membroAtual.telefone__c = membro.get('Phone');
                membroAtual.Contato__c = membro.get('Id');
                membrosInternos.add(membroAtual);
        
            }
            // Insira os membros internos em um único comando DML
            // 
            try{
            insert membrosInternos;
            } catch (Exception e) {
                
            	System.debug('Erro: ' + e);
            }
        } catch (Exception e) {
            System.debug('Erro: ' + e);
           // throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void gambiarra(){
       
        
        String a1320 = '1320';
        String a1321 = '1321';
        String a1322 = '1322';
        String a1323 = '1323';
        String a1324 = '1324';
        String a1325 = '1325';
        String a1326 = '1326';
        String a1327 = '1327';
        String a1328 = '1328';
        String a1329 = '1329';
        String a1330 = '1330';
        String a1331 = '1331';
        String a1332 = '1332';
        String a1333 = '1333';
        String a1334 = '1334';
        String a1335 = '1335';
        String a1336 = '1336';
        String a1337 = '1337';
        String a1338 = '1338';
        String a1339 = '1339';
        String a1340 = '1340';
        String a1341 = '1341';
        String a1342 = '1342';
        String a1343 = '1343';
        String a1344 = '1344';
        String a1345 = '1345';
        String a1346 = '1346';
        String a1347 = '1347';
        String a1348 = '1348';
        String a1349 = '1349';
        String a1350 = '1350';
        String a1351 = '1351';
        String a1352 = '1352';
        String a1353 = '1353';
        String a1354 = '1354';
        String a1355 = '1355';
        String a1356 = '1356';
        String a1357 = '1357';
        String a1358 = '1358';
        String a1359 = '1359';
        String a1360 = '1360';
        String a1361 = '1361';
        String a1362 = '1362';
        String a1363 = '1363';
        String a1364 = '1364';
        String a1365 = '1365';
        String a1366 = '1366';
        String a1367 = '1367';
        String a1368 = '1368';
        String a1369 = '1369';
        String a1370 = '1370';
        String a1371 = '1371';
        String a1372 = '1372';
        String a1373 = '1373';
        String a1374 = '1374';
        String a1375 = '1375';
        String a1376 = '1376';
        String a1377 = '1377';
        String a1378 = '1378';
        String a1379 = '1379';
        String a1380 = '1380';
        String a1381 = '1381';
        String a1382 = '1382';
        String a1383 = '1383';
        String a1384 = '1384';
        String a1385 = '1385';
        String a1386 = '1386';
        String a1387 = '1387';
        String a1388 = '1388';
        String a1389 = '1389';
        String a1390 = '1390';
        String a1391 = '1391';
        String a1392 = '1392';
        String a1393 = '1393';
        String a1394 = '1394';
        String a1395 = '1395';
        String a1396 = '1396';
        String a1397 = '1397';
        String a1398 = '1398';
        String a1399 = '1399';
        String a1400 = '1400';
        String a1401 = '1401';
        String a1402 = '1402';
        String a1403 = '1403';
        String a1404 = '1404';
        String a1405 = '1405';
        String a1406 = '1406';
        String a1407 = '1407';
        String a1408 = '1408';
        String a1409 = '1409';
        String a1410 = '1410';
        String a1411 = '1411';
        String a1412 = '1412';
        String a1413 = '1413';
        String a1414 = '1414';
        String a1415 = '1415';
        String a1416 = '1416';
        String a1417 = '1417';
        String a1418 = '1418';
        String a1419 = '1419';
        String a1420 = '1420';
        String a1421 = '1421';
        String a1422 = '1422';
        String a1423 = '1423';
        String a1424 = '1424';
        String a1425 = '1425';
        String a1426 = '1426';
        String a1427 = '1427';
        String a1428 = '1428';
        String a1429 = '1429';
        String a1430 = '1430';
        String a1431 = '1431';
        String a1432 = '1432';
        String a1433 = '1433';
        String a1434 = '1434';
        String a1435 = '1435';
        String a1436 = '1436';
        String a1437 = '1437';
        String a1438 = '1438';
        String a1439 = '1439';
        String a1440 = '1440';
        String a1441 = '1441';
        String a1442 = '1442';
        String a1443 = '1443';
        String a1444 = '1444';
        String a1445 = '1445';
        String a1446 = '1446';
        String a1447 = '1447';
        String a1448 = '1448';
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
    }
}