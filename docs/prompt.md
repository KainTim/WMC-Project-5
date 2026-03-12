# Prompts

Folgende Prompts wurden auf Englisch geschrieben. Verwendetes Model: Claude Sonnet 4.5

## 11.03.2026

- the user should be able to join teams and then join a tournament as a team, also add that to the backend<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - team.ts
    - team-service.ts
    - user-service.ts
    - app.ts
    - team.dart (keine Änderungen, bereits vorhanden)
    - team_service.dart
    - team_provider.dart
    - my_teams_widget.dart (neu erstellt)
    - teams_list_widget.dart
    - home_page.dart
    - tournament_detail_page.dart
    - teams_page.dart (erstellt, aber nicht verwendet)

- Ensure a team can only have a maximum of four members, also show the member count in the team list.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - backend_splatournament_manager/src/services/team-service.ts
    - frontend_splatournament_manager/lib/models/team.dart
    - frontend_splatournament_manager/lib/pages/teams_page.dart

- Remove the teams_page and add the member count display to the list views.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/pages/teams_page.dart (gelöscht)
    - frontend_splatournament_manager/lib/widgets/teams_list_widget.dart
    - frontend_splatournament_manager/lib/widgets/my_teams_widget.dart

- Center the team avatar vertically in the list views.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/widgets/teams_list_widget.dart
    - frontend_splatournament_manager/lib/widgets/my_teams_widget.dart

- Restrict team tags to at most 3 characters.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - backend_splatournament_manager/src/app.ts
    - frontend_splatournament_manager/lib/pages/create_team_page.dart

- Use the first three letters of the username as the avatar for the profile and remove the team name input in the settings.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/widgets/profile_widget.dart

- Save the theme preferences so they persist across restarts.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/pubspec.yaml
    - frontend_splatournament_manager/lib/providers/theme_provider.dart

- Implement auth-aware router to keep users logged in after app restart.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/main.dart

- Create a carousel on the homepage that shows all the tournaments that one of your teams is participating in.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/providers/team_provider.dart
    - frontend_splatournament_manager/lib/widgets/my_tournaments_carousel.dart (neu erstellt)
    - frontend_splatournament_manager/lib/pages/home_page.dart

- Fix getTournamentsByTeam endpoint to return full Tournament objects instead of TournamentTeam objects.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - backend_splatournament_manager/src/services/team-service.ts (changed return type from any[] to Tournament[])

- Add navigation to tournament details in the carousel.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/widgets/my_tournaments_carousel.dart

- Fix the carousel not reloading when the reload button is pressed or when a tournament is joined.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/widgets/my_tournaments_carousel.dart

## 12.03.2026

- Show a placeholder in the carousel if no tournaments were found.<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - frontend_splatournament_manager/lib/widgets/my_tournaments_carousel.dart
