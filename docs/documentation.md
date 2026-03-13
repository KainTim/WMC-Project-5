# Dokumentation

## Starten des Projekts

- Frontend   
Der `lib` Ordner muss gemeinsam mit der `pubspec.yaml` Datei in ein vorhandenes Flutter Projekt kopiert werden. Als Run-Target muss der Android-Emulator ausgewählt werden. Anschließend kann nun in `lib/main.dart` über der `main` Methode auf "Run" gedrückt werden.
- Backend   
Die Node-Module müssen mit einem beliebigen Package-Manager installiert werden, beispielsweise mit dem Befehl `npm i`. Anschließend kann das `dev` Skript in der Datei `package.json` ausgeführt werden, welches die API mithilfe von nodemon startet.

## Sammlung der Protokolle
- Siehe beigefügte Zip-Datei

## Vergleich Meilenstein-Plan mit tatsächlichem Fortschritt

Die Meilensteine wurden grundsätzlich eingehalten, aber der Umfang des letzten Meilensteins wurde zu niedrig geschätzt und es sind ein paar essentielle, vorher nicht eingeplante Features bekannt geworden. Dadurch war das Ende des Projekts eher mit Stress durchzogen.

## Bedienung der App

### Erstellung eines Benutzers

Ein Benutzer kann durch den Registrieren Knopf am Login Bildschirm erstellt werden, nachdem der Benutzername und das Passwort eingegeben wurden.

### Login mit einem Benutzer

Wenn bereits ein Benutzer vorhanden ist, kann man sich mit dem Benutzernamen und dem richtigen Passwort am Login Bildschirm anmelden.

### Abmelden eines Benutzers
Wenn man bereits mit einem Benutzer angemeldet ist, kann man am Hauptbildschirm das Popup-Menü öffnen und sich mit dem "Abmelden" Knopf abmelden, danach wird man wieder auf den Login Bildschirm geleitet.

### Änderung des App Themes
Auf dem Hauptbildschirm kann man auf das Profil-Menü klicken und dann in dem Theme Dropdown das gewünschte Schema manuell auswählen oder "System" für eine automatische Anpassung an das Hell/Dunkel-Schemas des Betriebssystems

### Erstellung eines Teams
Auf dem Hauptbildschirm besteht die Möglichkeit durch den "+" Knopf auf den Team-Erstellen Bildschirm zu wechseln, wenn unten in der Tabbar "Teams" ausgewählt ist. In diesem Bildschirm kann nun ein Team mit Name, Kürzel und Beschreibung durch den Knopf "Team erstellen" erzeugt werden.

### Beitreten eines Teams
Auf dem Hauptbildschirm, wenn unten in der Tabbar "Teams" ausgewählt ist, ist es möglich einem zuvor erstellten Team beizutreten indem man es in der Liste findet und auf den zugehörigen PopUpButton klickt und weiterfolgend den "Team Beitreten" Menüpunkt auswählt.

### Verlassen eines Teams
Auf dem Hauptbildschirm kann man auf das Profil-Menü klicken, und folgend ist in der "Meine Teams" Liste das zu verlassende Team zu finden und auf den Roten Exit Knopf zu drücken.

### Löschen eines Teams
Auf dem Hauptbildschirm, wenn unten in der Tabbar "Teams" ausgewählt ist, ist es möglich ein zuvor erstelltes Team zu löschen indem man es in der Liste findet und auf den zugehörigen PopUpButton klickt und weiterfolgend den "Team Löschen" Menüpunkt auswählt.

### Bearbeiten eines Teams
Auf dem Hauptbildschirm, wenn unten in der Tabbar "Teams" ausgewählt ist, ist es möglich ein zuvor erstelltes Team zu bearbeiten indem man es in der Liste findet und auf den zugehörigen PopUpButton klickt und weiterfolgend den "Team bearbeiten" Menüpunkt auswählt. In diesem Bildschirm können eventuelle Änderungen vorgenommen werden und mit dem "Team aktualisieren" Knopf übernommen werden.

### Erstellung eines Turniers
Auf dem Hauptbildschirm besteht die Möglichkeit durch den FloatingActionButton auf den Turnier-Erstellen Bildschirm zu wechseln, wenn unten in der Tabbar "Turniere" ausgewählt ist. In diesem Bildschirm kann nun ein Turnier mit Name, Beschreibung, Teamanzahl und Registrierungszeitraum durch den Knopf "Turnier erstellen" erzeugt werden.

### Anmeldung eines Teams an einem Turnier
Auf dem Hauptbildschirm muss das gewünschte Turnier angeklickt werden um in die Detailansicht zu gelangen, wenn das aktuelle Datum im Anmeldezeitraum des Turnieres ist, kann man sich mit einem eigenen Team anmelden.

### Bereits angemeldete Teams eines Turniers
Auf dem Hauptbildschirm muss das gewünschte Turnier angeklickt werden um in die Detailansicht zu gelangen, wenn nun entweder auf den "x aus y Teams" Chip oder das "Group" Icon oben rechts geklickt wird, dann kann die Ansicht zwischen den Standardinformationen des Turniers und der Ansicht der bereits angemeldeten Teams gewechselt werden.

### Turnierbaum initialisieren
Auf dem Hauptbildschirm muss das gewünschte Turnier angeklickt werden um in die Detailansicht zu gelangen, danach kann auf den Knopf "Turnierbaum ansehen" geklickt werden. Wenn sich nun genügend Teams registriert haben, kann auf den "Turnierbaum initialisieren" Knopf gedrückt werden.

### Turnierbaum eintragen
Auf dem Hauptbildschirm muss das gewünschte Turnier angeklickt werden um in die Detailansicht zu gelangen, danach kann auf den Knopf "Turnierbaum ansehen" geklickt werden. Wenn dieser schon initialisiert wurde, wird der Baum angezeigt. Wenn nun auf eine Card geklickt wird, kann der Gewinner dieses Spiels ausgewählt werden und er steigt in die nächste Phase auf. Wenn die letzte Gruppe entschieden ist wird der Sieger des Turniers ganz rechts in der "Sieger" Spalte angezeigt.

### Eingetragenes Spiel korrigieren
Auf dem Hauptbildschirm muss das gewünschte Turnier angeklickt werden um in die Detailansicht zu gelangen, danach kann auf den Knopf "Turnierbaum ansehen" geklickt werden. Wenn dieser schon initialisiert wurde, wird der Baum angezeigt. Wenn ein Fehler beim Eintragen passiert ist und das nächste Spiel noch nicht eingetragen wurde, kann auf das zu korrigierende Spiel geklickt werden und der Menüpunkt "Zurücksetzen" ist auszuwählen.