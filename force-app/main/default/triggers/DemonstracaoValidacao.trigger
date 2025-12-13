trigger DemonstracaoValidacao on Demonstracao__c (before insert, before update, before delete) {
    
    
    if(!Util.IgnorarErros() && !Util.AcaoInterna()){
        
        if(Trigger.isBefore && Trigger.isUpdate){
            
            Set<Id> demonstracoes_id = new Set<Id>();
            for(Demonstracao__c demonstracao : Trigger.new)
                demonstracoes_id.add(demonstracao.Id);
            
            List<Demonstracao__c> demonstracoes = [
                SELECT	Id, (
                    SELECT	Id
                    FROM	Pedidos__r
                ), (
                    SELECT	Ativo__c, Ativo__r.Name, Ativo__r.SerialNumber
                    FROM	Produtos_da_demonstracao__r
                    WHERE 	Item_pai__c = null
                ), (
                    SELECT	AssetId
                    FROM	Ordens_de_trabalho__r
                )
                FROM	Demonstracao__c
                WHERE	Id IN :demonstracoes_id
            ];
            
            for(Demonstracao__c demonstracao : Trigger.new){
                
                // controla status
                if(!demonstracao.Acao_Interna__c && Trigger.oldMap.get(demonstracao.Id).Status__c != demonstracao.Status__c){
                    if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Rascunho' && demonstracao.Status__c!='Cancelado')
                        demonstracao.Status__c.addError('Status RASCUNHO altera apenas para: EM APROVAÇÃO (via processo); CANCELADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Em aprovação')
                        demonstracao.Status__c.addError('Status EM APROVAÇÃO altera apenas para REPROVADO/APROVADO (via processo)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Reprovado' && (demonstracao.Status__c!='Rascunho' && demonstracao.Status__c!='Cancelado'))
                        demonstracao.Status__c.addError('Status REPROVADO altera apenas para: RASCUNHO (manualmente); EM APROVAÇÃO (via processo); CANCELADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Aprovado' && (demonstracao.Status__c!='Rascunho' && demonstracao.Status__c!='Agendado' && demonstracao.Status__c!='Em calibração' && 
                                                                                            demonstracao.Status__c!='Em comodato' && demonstracao.Status__c!='Finalizado' && demonstracao.Status__c!='Cancelado'))
                        demonstracao.Status__c.addError('Status APROVADO altera apenas para: RASCUNHO/AGENDADO/EM DEMONSTRAÇÃO/RETORNO/FINALIZADO/CANCELADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Agendado' && (demonstracao.Status__c!='Rascunho' && demonstracao.Status__c!='Aprovado' && 
                                                                                            demonstracao.Status__c!='Em comodato' && demonstracao.Status__c!='Retorno' && demonstracao.Status__c!='Finalizado' && demonstracao.Status__c!='Cancelado'))
                        demonstracao.Status__c.addError('Status AGENDADO altera apenas para: RASCUNHO/APROVADO/EM DEMONSTRAÇÃO/RETORNO/FINALIZADO/CANCELADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Em comodato' && (demonstracao.Status__c!='Retorno' && demonstracao.Status__c!='Finalizado'))
                        demonstracao.Status__c.addError('Status EM DEMONSTRAÇÃO altera apenas para: RETORNO/FINALIZADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Retorno' && demonstracao.Status__c!='Finalizado')
                        demonstracao.Status__c.addError('Status RETORNO altera apenas para: FINALIZADO (manualmente)');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Finalizado')
                        demonstracao.Status__c.addError('Status FINALIZADO não é alterável');
                    else if(Trigger.oldMap.get(demonstracao.Id).Status__c == 'Cancelado' && demonstracao.Status__c!='Rascunho')
                        demonstracao.Status__c.addError('Status CANCELADO altera apenas para: RASCUNHO (manualmente); EM APROVAÇÃO (via processo);');
                    
                    List<String> status_andamento_ok = new List<String>{'Agendado', 'Em comodato', 'Retorno de demo', 'Finalizado'};
                        if(status_andamento_ok.contains(demonstracao.Status__c)){
                            for(Demonstracao__c demonstracao_sql : demonstracoes){
                                if(demonstracao.Id == demonstracao_sql.Id && demonstracao_sql.Pedidos__r.size()==0)
                                    demonstracao.addError('A demonstração deve possuir pelo menos um pedido para dar andamento');
                            }
                        }
                    
                    if(demonstracao.Status__c=='Finalizado'){
                        List<String> itens_demo_sem_ot = new List<String>();
                        for(Demonstracao__c demonstracao_sql : demonstracoes){
                            if(demonstracao.Id == demonstracao_sql.Id){
                                for(Produto_da_demonstracao__c item_demo : demonstracao_sql.Produtos_da_demonstracao__r){
                                    boolean sem_ot = true;
                                    for(WorkOrder ordem_de_trabalho : demonstracao_sql.Ordens_de_trabalho__r)
                                        if(item_demo.Ativo__c == ordem_de_trabalho.AssetId)
                                        sem_ot = false;
                                    if(sem_ot)
                                        itens_demo_sem_ot.add(item_demo.Ativo__r.Name + ' (NS: ' + item_demo.Ativo__r.SerialNumber + ')');
                                }
                            }
                        }
                    }
                    
                }
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
                
                
            }
        }
        
        if(Trigger.isBefore && Trigger.isDelete){
            for(Demonstracao__c demonstracao : Trigger.old){
                
                // bloqueia exclusão
                if(demonstracao.Status__c!='Rascunho')
                    demonstracao.addError('Para proceder com a exclusão, altere o status da demonstração para RASCUNHO.');
                
            }
        }
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Demonstracao__c demonstracao : Trigger.new)
            demonstracao.Acao_interna__c = false;
    }
    
    
    
    
}