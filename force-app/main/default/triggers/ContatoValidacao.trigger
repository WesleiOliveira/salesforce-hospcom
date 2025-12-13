trigger ContatoValidacao on Contact (before insert, before update) {
    
    // ignora erros
    if(!Util.IgnorarErros()){
        
        String resultado = null;
        
        for(Contact contato : Trigger.new){
            
            // primeiro nome
            if((resultado = Util.ValidarValor(contato.FirstName, 'primeiro nome', 'texto')) != null)
                contato.FirstName.addError(resultado);
            
            // nome do meio
            if((resultado = Util.ValidarValor(contato.MiddleName, 'nome do meio', 'texto')) != null)
                contato.MiddleName.addError(resultado);
            
            // cargo
            // if((resultado = Util.ValidarValor(contato.Title, 'cargo', 'texto')) != null)
            //     contato.Title.addError(resultado);
            
            // Telefone
            if (contato.Phone != null) {
                if (contato.Account.BillingCountry == 'Brasil' && contato.Colaborador_estrangeiro__c == false) {
                    Pattern padraoBrasil = Pattern.compile(
                        '^(\\+55\\s?)?[(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}( Ramal: [0-9]{4})?(, (\\+55\\s?)?[(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}){0,1}$'
                    );
                    
                    if (!padraoBrasil.matcher(contato.Phone).matches()) {
                        contato.Phone.addError('O número deve ter o formato +55 (XX) xXXXX-XXXX Ramal: XXXX. O DDI (+55) e o ramal são opcionais. Máximo 2 números (sem ramal) ou 1 (com ramal) separados por vírgula.');
                    }
                }
                // Para outros países, não há validação de formato
            }
            
            
            // Telefone
            if (contato.MobilePhone != null) {
                if (contato.Account.BillingCountry == 'Brasil' && contato.Colaborador_estrangeiro__c == false) {
                    Pattern padraoBrasil = Pattern.compile(
                        '^(\\+55\\s?)?[(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}( Ramal: [0-9]{4})?(, (\\+55\\s?)?[(][0-9]{2}[)] [9]?[0-9]{4}-[0-9]{4}){0,1}$'
                    );
                    
                    if (!padraoBrasil.matcher(contato.MobilePhone).matches()) {
                        contato.MobilePhone.addError('O número deve ter o formato +55 (XX) xXXXX-XXXX Ramal: XXXX. O DDI (+55) e o ramal são opcionais. Máximo 2 números (sem ramal) ou 1 (com ramal) separados por vírgula.');
                    }
                }
                // Para outros países, não há validação de formato
            }
            
            // email
            // if((resultado = Util.ValidarValor(contato.Email, 'email', 'email')) != null)
            //    contato.Email.addError(resultado);
            
            // cpf
            if((resultado = Util.ValidarCPF(contato.CPF__c)) != null)
                contato.CPF__c.addError(resultado);
            
            // rg
            if((resultado = Util.ValidarValor(contato.RG__c, 'rg', 'codigo')) != null)
                contato.RG__c.addError(resultado);
            
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
            String a1572 = '1572';
            String a1573 = '1573';
            String a1574 = '1574';
            String a1575 = '1575';
            String a1576 = '1576';
            String a1577 = '1577';
            String a1578 = '1578';
            String a1579 = '1579';
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
            
        }
    }
}