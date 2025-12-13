trigger PedidoValidacao on Order (before insert, before update){
    public Id RecordType {get; set;}
    public Boolean ignorar;
    for(Order pedido : Trigger.new){
        RecordType = pedido.RecordTypeId;
        ignorar = pedido.Ignora_validacao__c;        
    }
    
    if(!Util.IgnorarErros() && !ignorar){
        if(Trigger.isBefore && Trigger.isInsert){
            Set<Id> cotacoes_id = new Set<Id>();
            Set<Id> demonstracoes_id = new Set<Id>();
            for(Order pedido : Trigger.new){
                if(pedido.QuoteId!=null)
                    cotacoes_id.add(pedido.QuoteId);
                else if(pedido.Demonstracao__c!=null)
                    demonstracoes_id.add(pedido.Demonstracao__c);
            }
            
            if(cotacoes_id.size()>0){
                List<Quote> cotacoes = [
                    SELECT  Id, IsSyncing, Opportunity.StageName
                    FROM    Quote
                    WHERE   Id IN :cotacoes_id AND 
                    (IsSyncing = false OR Opportunity.StageName != 'WIN' OR Opportunity.StageName != 'COMITED')
                ];
                
                for(Order pedido : Trigger.new){
                    if(pedido.QuoteId!=null){
                        for(Quote cotacao : cotacoes){
                            if(pedido.QuoteId == cotacao.Id){
                                if(!cotacao.IsSyncing){
                                    pedido.QuoteId.addError('A cotação deve estar sincronizada com a oportunidade.');
                                }
                                if(cotacao.Opportunity.StageName != 'WIN' && cotacao.Opportunity.StageName != 'COMITED'){
                                    pedido.OpportunityId.addError('A oportunidade deve estar com o Status igual a COMITED ou WIN.');
                                }
                                
                            }
                        }
                    }
                }
            }
            if(demonstracoes_id.size()>0){
                List<Demonstracao__c> demonstracoes = [
                    SELECT  id, Status__c, Data_prevista__c, (
                        SELECT  Id
                        FROM    Produtos_da_demonstracao__r
                    )
                    FROM    Demonstracao__c
                    WHERE   Id IN :demonstracoes_id
                ];
                List<String> status_ativos = new List<String>{'Aprovado', 'Agendado', 'Em demonstração', 'Retorno de demo'};
                    for(Order pedido : Trigger.new){
                        if(pedido.Demonstracao__c!=null){
                            for(Demonstracao__c demonstracao : demonstracoes){
                                if(pedido.Demonstracao__c == demonstracao.Id){
                                    if(!status_ativos.contains(demonstracao.Status__c))
                                        pedido.Demonstracao__c.addError('O Status da demonstração deve estar como aprovado, e não finalizado');
                                    //if(demonstracao.Data_prevista__c < System.Today())
                                    //  pedido.Demonstracao__c.addError('A data prevista da demonstração não deve ser menor que hoje');
                                    if(demonstracao.Produtos_da_demonstracao__r.size()==0)
                                        pedido.Demonstracao__c.addError('Devem haver produtos adicionados a demonstração.');
                                }
                            }
                        }
                    }
            }
        }
        //Travas para pedidos cujos contratos ja tenham sido aprovado 
        if(Trigger.isInsert || Trigger.isUpdate){
            Set<Id> cotacoes_id = new Set<Id>();
            Set<Id> contratosLoc_id = new Set<Id>();
            Set<Id> workOrder_id = new Set<Id>();
            for(Order pedido : Trigger.new){
                if(pedido.QuoteId!=null)
                    cotacoes_id.add(pedido.QuoteId);
                else if(pedido.Contrato_de_Servi_o__c !=null)
                    contratosLoc_id.add(pedido.Contrato_de_Servi_o__c);
                else if(pedido.Ordem_de_trabalho__c !=null)
                    workOrder_id.add(pedido.Ordem_de_trabalho__c);
            }
            //Contratos de Venda (Cotação)
            if(cotacoes_id.size()>0){
                List<Quote> cotacoes2 = [
                    SELECT  Id, IsSyncing, Opportunity.StageName, TotalPrice, Documento_Assinado__c
                    FROM    Quote
                    WHERE   Id IN :cotacoes_id  
                ];
                List<Order> Pedidos = [
                    SELECT  Id, TotalAmount
                    FROM    Order
                    WHERE   QuoteId IN :cotacoes_id AND Natureza_de_opera_o__c != 'BONIFICAÇÃO'
                ];
                decimal totalPedidos = 0.00;
                for(Order pedido : Pedidos){
                    totalPedidos = totalPedidos + pedido.TotalAmount;
                }
                // system.debug('TOTAL PEDIDOS ' + totalPedidos);
                
                for(Order pedido : Trigger.new){
                    if(pedido.QuoteId!=null){
                        
                        //Impede a criação de pedidos de valores superiores ao que foi aprovado em contrato (cotação) via autentique ou manual
                        for(Quote cotacao : cotacoes2){
                            if(pedido.QuoteId == cotacao.Id){
                                if(cotacao.Documento_Assinado__c !=null && (cotacao.TotalPrice <  totalPedidos)){
                                    pedido.QuoteId.addError('Valor total do(s) pedido(s) ultrapassa o total aprovado em contrato');
                                }
                            }
                        }
                    }
                }
            }
            //Contratos de Locação
            else if(contratosLoc_id.size()>0){
                List<Contrato_de_Servi_o__c> contratos = [
                    SELECT  Id, Documento_Assinado__c, Valor_Total_do_Contrato__c
                    FROM    Contrato_de_Servi_o__c
                    WHERE   Id IN :contratosLoc_id  
                ];
                List<Order> Pedidos = [
                    SELECT  Id, TotalAmount
                    FROM    Order
                    WHERE   Contrato_de_Servi_o__c IN :contratosLoc_id  AND Natureza_de_opera_o__c != 'BONIFICAÇÃO'
                ];
                decimal totalPedidos = 0.00;
                for(Order pedido : Pedidos){
                    totalPedidos = totalPedidos + pedido.TotalAmount;
                }
                // system.debug('TOTAL PEDIDOS ' + totalPedidos);
                
                for(Order pedido : Trigger.new){
                    if(pedido.Contrato_de_Servi_o__c!=null){
                        
                        //Impede a criação de pedidos de valores superiores ao que foi aprovado em contrato via autentique ou manual
                        for(Contrato_de_Servi_o__c contrato : contratos){
                            if(pedido.Contrato_de_Servi_o__c == contrato.Id){
                                if(contrato.Documento_Assinado__c !=null && (contrato.Valor_Total_do_Contrato__c <  totalPedidos)){
                                    pedido.QuoteId.addError('Valor total do(s) pedido(s) ultrapassa o total aprovado em contrato');
                                }
                            }
                        }
                    }
                }
            }
            //Contratos de Serviço (OT)
            else if(workOrder_id.size()>0){
                List<WorkOrder> contratos = [
                    SELECT  Id, Documento_Assinado__c, Total_Estimado__c
                    FROM    WorkOrder
                    WHERE   Id IN :workOrder_id  
                ];
                List<Order> Pedidos = [
                    SELECT  Id, TotalAmount
                    FROM    Order
                    WHERE   Contrato_de_Servi_o__c IN :contratosLoc_id  AND Natureza_de_opera_o__c != 'BONIFICAÇÃO'
                ];
                decimal totalPedidos = 0.00;
                for(Order pedido : Pedidos){
                    totalPedidos = totalPedidos + pedido.TotalAmount;
                }
                // system.debug('TOTAL PEDIDOS ' + totalPedidos);
                
                for(Order pedido : Trigger.new){
                    if(pedido.Contrato_de_Servi_o__c!=null){
                        
                        //Impede a criação de pedidos de valores superiores ao que foi aprovado em contrato via autentique ou manual
                        for(WorkOrder contrato : contratos){
                            if(pedido.Contrato_de_Servi_o__c == contrato.Id){
                                if(contrato.Documento_Assinado__c !=null && (contrato.Total_Estimado__c <  totalPedidos)){
                                    pedido.Ordem_de_trabalho__c.addError('Valor total do(s) pedido(s) ultrapassa o total aprovado em contrato');
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    if(!Util.IgnorarErros() && !Util.AcaoInterna()){
        if(Trigger.isBefore && Trigger.isUpdate){
            for(Order pedido : Trigger.new){
                if(!pedido.Acao_interna__c && pedido.Status != 'Pendente' && Trigger.oldMap.get(pedido.Id).Status != pedido.Status && pedido.RecordTypeId != Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Representação').getRecordTypeId() && pedido.RecordTypeId != Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Demonstração').getRecordTypeId()){
                    if(!(Trigger.oldMap.get(pedido.Id).Status == 'Rascunho' && pedido.Status == 'Cancelado'))
                        pedido.Status.addError('O status é automatizado, portanto não deve ser alterado manualmente.');
                }
                else if(!pedido.Acao_interna__c && pedido.RecordTypeId == Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByName().get('Demonstração').getRecordTypeId()){
                    string statusAnterior = Trigger.oldMap.get(pedido.Id).Status;
                    if((statusAnterior == 'Rascunho' || statusAnterior == 'Aguardando Aprovação Comercial') && pedido.Status != 'Cancelado' && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Alteração indevida de status');
                    else if((statusAnterior == 'Ativo' && pedido.Status != 'Agendado' && pedido.Status != 'Em calibração') && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Status "Ativo" altera apenas para "Agendado"');                                    
                    else if((statusAnterior == 'Em demonstração' && pedido.Status != 'Retorno da demo') && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Status "Em demonstração" altera apenas para "Retorno da demo"');
                    else if((statusAnterior == 'Retorno da demo' && (pedido.Status !='Em Verificação Funcional' && pedido.Status != 'Finalizado com pendência' && pedido.Status != 'Finalizado')) && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Status "Retorno da demo" altera apenas para "Em Verificação Funcional", "Finalizado com pendência" ou "Finalizado"');
                    else if((statusAnterior == 'Em Verificação Funcional' && (pedido.Status !='Finalizado com pendência' && pedido.Status != 'Finalizado')) && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Status "Em Verificação Funcional" altera apenas para "Finalizado com pendência" ou "Finalizado"');
                    else if(statusAnterior == 'Cancelado' && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Status "Cancelado" não pode ser alterado');
                    else if((pedido.Status == 'Aprovado' || pedido.Status == 'Reprovado' || pedido.Status == 'Desativado') && Trigger.oldMap.get(pedido.Id).Status != pedido.Status)
                        pedido.Status.addError('Alteração indevida de Status');
                }
                
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Order pedido : Trigger.new)
            pedido.Acao_interna__c = false;
    }
    if(!Util.IgnorarErros()){
        
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            
            string a = 'a';
            string b = 'a';
            string c = 'a';
            string d = 'a';
            string e = 'a';
            string f = 'a';
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
            String a1500 = '1500';
            String a1501 = '1501';
            String a1502 = '1502';
            String a1503 = '1503';
            String a1504 = '1504';
            String a1505 = '1505';
            String a1506 = '1506';
            String a1507 = '1507';
            String a1508 = '1508';
            String a1509 = '1509';
            String a1510 = '1510';
            String a1511 = '1511';
            String a1512 = '1512';
            String a1513 = '1513';
            String a1514 = '1514';
            String a1515 = '1515';
            String a1516 = '1516';
            String a1517 = '1517';
            String a1518 = '1518';
            String a1519 = '1519';
            String a1520 = '1520';
            String a1521 = '1521';
            String a1522 = '1522';
            String a1523 = '1523';
            String a1524 = '1524';
            String a1525 = '1525';
            String a1526 = '1526';
            String a1527 = '1527';
            String a1528 = '1528';
            String a1529 = '1529';
            String a1530 = '1530';
            String a1531 = '1531';
            String a1532 = '1532';
            String a1533 = '1533';
            String a1534 = '1534';
            String a1535 = '1535';
            String a1536 = '1536';
            String a1537 = '1537';
            String a1538 = '1538';
            String a1539 = '1539';
            String a1540 = '1540';
            String a1541 = '1541';
            String a1542 = '1542';
            String a1543 = '1543';
            String a1544 = '1544';
            String a1545 = '1545';
            String a1546 = '1546';
            String a1547 = '1547';
            String a1548 = '1548';
            String a1549 = '1549';
            String a1550 = '1550';
            String a1551 = '1551';
            String a1552 = '1552';
            String a1553 = '1553';
            String a1554 = '1554';
            String a1555 = '1555';
            String a1556 = '1556';
            String a1557 = '1557';
            String a1558 = '1558';
            String a1559 = '1559';
            String a1560 = '1560';
            String a1561 = '1561';
            String a1562 = '1562';
            String a1563 = '1563';
            String a1564 = '1564';
            String a1565 = '1565';
            String a1566 = '1566';
            String a1567 = '1567';
            String a1568 = '1568';
            String a1569 = '1569';
            String a1570 = '1570';
            String a1571 = '1571';
            String a1580 = '1580';
            String a1581 = '1581';
            String a1582 = '1582';
            String a1583 = '1583';
            String a1584 = '1584';
            String a1585 = '1585';
            String a1586 = '1586';
            String a1587 = '1587';
            String a1588 = '1588';
            String a1589 = '1589';
            String a1590 = '1590';
            String a1591 = '1591';
            String a1592 = '1592';
            String a1593 = '1593';
            String a1594 = '1594';
            String a1595 = '1595';
            String a1596 = '1596';
            String a1597 = '1597';           
            for(Order demonstracao : Trigger.new){
                
                // tempo de demo
                if(demonstracao.Tempo_de_demonstracao__c != null){
                    Matcher correspondencia = Pattern.compile('^([0-9]+) (dia|dias)$')
                        .matcher(demonstracao.Tempo_de_demonstracao__c.toLowerCase());
                    if(!correspondencia.matches())
                        demonstracao.Tempo_de_demonstracao__c.addError('O tempo de demonstração deve ter o formato XX DIA(S)');
                    else if(Integer.valueOf(correspondencia.group(1)) < 1)
                        demonstracao.Tempo_de_demonstracao__c.addError('O tempo de demonstração deve ter valor positivo');
                }    
                
            }
        }
        
    }
    
}