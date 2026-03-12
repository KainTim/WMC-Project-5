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
Wenn man bereits mit einem Benutzer angemeldet ist, kann man am Hauptbildschirm das Einstellungsmenü öffnen und sich mit dem Abmelden Knopf abmelden, danach wird man wieder auf den Login Bildschirm geleitet.

### Änderung des App Themes
Auf dem Hauptbildschirm kann man auf das Einstellungsmenü klicken und dann in dem Theme Dropdown das gewünschte manuell auswählen oder "System" für eine automatische Anpassung an das Hell/Dunkel Schemas des Betriebssystems