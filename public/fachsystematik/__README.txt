DIE URL MUSS GEÄNDERT WERDEN!


In den aus der Datenbank erstellten Dateien ist aufgrund der langen URL (s.u.) ein Zeilenumbruch in "katalog.ub.uni-
 paderborn.de", der manuell mit Notepad++ gelöscht werden muss ('Replace')!


----
Die Sonderzeichen müssen aufgelöst werden, d.h. 

eine Suche nach 

{"queries":[{"type":"query_string","fields":["signature_search"],"query":"XXX*"}]}

würde daher zu 

%7B%22queries%22%3A%5B%7B%22type%22%3A%22query_string%22%2C%22fields%22%3A%5B%22signature_search%22%5D%2C%22query%22%3A%22XXX%2A%22%7D%5D%7D
