# 📱 Dap-Express Admin Mobile App (Flutter Clean Architecture)

Application mobile dédiée au propriétaire et aux gestionnaires pour piloter la boutique en déplacement.

## 🧱 Architecture Technique (Clean Architecture + BLoC)
- **BLoC Pattern (`flutter_bloc`)** : Séparation stricte de la logique métier et des composants UI.
- **Réseau (`Dio`)** : Intercepteurs d'authentification JWT et gestion des erreurs.
- **Graphiques Mobiles (`fl_chart`)** : Visualisation fluide des ventes quotidiennes.
- **Appel Client 1-Clic (`url_launcher`)** : Appelez instantanément le client pour confirmer sa commande directement depuis l'application.
- **Notifications Push (`Firebase Cloud Messaging - FCM`)** : Réception immédiate d'alertes dès qu'une commande est passée.

## 📂 Structure des Dossiers
```
lib/
├── core/
│   ├── constants/       # Endpoints API, Palette de couleurs
│   ├── network/         # Client Dio et gestion des Tokens JWT
│   ├── theme/           # Theme Material 3 personnalisé
│   └── utils/           # Helper d'appel direct client
├── features/
│   ├── auth/            # Authentification Admin
│   ├── dashboard/       # Métriques KPI & Graphiques FL Chart
│   ├── orders/          # Liste commandes, détails, statuts & appel client
│   ├── products/        # Catalogue & aperçu des stocks
│   └── notifications/   # Service FCM
├── app.dart
└── main.dart
```

## 🚀 Démarrage

```bash
# Téléchargement des packages
flutter pub get

# Lancement sur émulateur ou appareil physique
flutter run
```
