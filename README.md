# 🌩️ Storm

> **Menu autonome FiveM** — Véhicule · Joueur · Monde · Fun · Raccourcis

**Fichier unique Lua · Aucune dépendance · Aucun framework requis · Standalone**

![FiveM](https://img.shields.io/badge/FiveM-Cerulean-9146FF?style=flat-square)
![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat-square)
![License](https://img.shields.io/badge/Licence-MIT-3DA639?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.0.0-EC4862?style=flat-square)

---

## 📖 Sommaire

- [✨ Présentation](#-présentation)
- [🎯 Fonctionnalités](#-fonctionnalités)
- [🚀 Installation](#-installation)
- [⌨️ Contrôles](#️-contrôles)
- [💾 Persistance](#-persistance)
- [🏗️ Architecture](#️-architecture)
- [🔧 Personnalisation](#-personnalisation)
- [⚠️ Limitations & Compatibilité](#️-limitations--compatibilité)
- [📜 Licence](#-licence)

---

## ✨ Présentation

**Storm** est un menu client complet pour FiveM, conçu pour le **bac à sable, les tests et l'administration locale**.

Il fonctionne **100 % côté client** et ne dépend d'aucun framework :

- ❌ ESX
- ❌ QBCore
- ❌ vRP
- ❌ ox_core
- ❌ NUI

L'interface utilise directement les fonctions natives de rendu de GTA V (`DrawRect`, `DrawText`).

Cela permet de conserver une interface **légère et réactive**, sans interface Chromium ou JavaScript supplémentaire.

### ⚡ Points forts

| | Fonction | Description |
|---|---|---|
| ⚡ | **Léger & réactif** | Boucle de rendu optimisée et aucun chargement de page web |
| 🎨 | **Interface configurable** | Thèmes, couleurs d'accentuation et ancrages d'écran |
| 💾 | **Persistant** | Réglages, véhicules et tenues sauvegardés localement |
| 🔌 | **Plug & Play** | Installation simple, sans base de données |
| 🧩 | **Standalone** | Aucun framework FiveM nécessaire |

---

# 🎯 Fonctionnalités

## 🚗 Véhicule

### 🔧 Customisation

- Catalogue **LS Customs**
- Modifications de performances
- Carrosserie
- Intérieurs
- Roues Benny's
- Couleurs RGB personnalisées
- Finitions perlées
- Néons
- Phares xénon

### ⚙️ Gestion mécanique

Modification de plusieurs paramètres du véhicule :

- Masse
- Vitesse
- Motricité
- Handling
- Mode drift
- Portes
- Capot
- Coffre
- Vitres
- Pneus

### 💾 Sauvegarde véhicule

Jusqu'à **4 configurations locales** peuvent être enregistrées pour retrouver rapidement vos réglages.

---

## 👤 Joueur

### ❤️ Survie

- Godmode
- Anti-ragdoll
- Réanimation
- Soins
- Invisibilité
- Apnée infinie

### 🏃 Mobilité

- Course rapide
- Nage rapide
- Super saut

### 🧍 Gestion du Ped

Storm propose un sélecteur comprenant **11 modèles de Ped** directement accessibles depuis le menu.

---

## 🌍 Monde & Environnement

### 🌦️ Météo

Contrôle de **14 conditions météorologiques** directement depuis le menu.

### 🕐 Temps

- Modification de l'heure
- Gel de l'heure
- Synchronisation locale

### 🌎 Physique & Population

- **4 niveaux de gravité**
- Réglage de la densité de circulation
- Réglage de la densité des PNJ
- Blackout global

---

## 🎭 Utilitaires & Fun

### 🛡️ Mode Tank

Active un bouclier de collision autour du joueur.

Paramètres disponibles :

- Rayon
- Force
- Projection verticale

### 🚀 Capacités spéciales

Plusieurs fonctionnalités expérimentales sont disponibles :

- 🌊 Ondes de choc
- 🪶 Lévitation
- 🧲 Aimant à véhicules
- 🚀 Rocket Boost

### 🌀 Manipulation d'entités

Storm permet également différentes interactions avec les entités du jeu :

- Télékinésie
- Contrôle de trajectoire à distance
- Liaison mécanique entre véhicules
- Projection d'entités

---

## 👕 Tenues

Gestion complète des vêtements et accessoires du personnage.

### Vêtements

**10 composants vestimentaires** avec gestion indépendante des textures.

### Accessoires

**5 catégories d'accessoires** disponibles.

### Sauvegardes

Jusqu'à **8 tenues** peuvent être enregistrées localement.

---

## 🔗 Raccourcis

Storm possède un système de **binds personnalisables**.

Une action peut être assignée à différentes touches :

- `F1` → `F12`
- `A` → `Z`
- Pavé numérique

Cela permet d'activer rapidement les fonctions utilisées régulièrement sans parcourir le menu.

---

# ⌨️ Contrôles

Les contrôles peuvent être personnalisés directement depuis le menu.

| Action | Touche |
|---|:---:|
| Ouvrir / Fermer Storm | Configurable |
| Navigation ↑ | `↑` |
| Navigation ↓ | `↓` |
| Navigation ← | `←` |
| Navigation → | `→` |
| Valider | `ENTER` |
| Retour | `BACKSPACE` |

> [!NOTE]
> Les raccourcis personnalisés permettent également d'associer les fonctions principales à des touches dédiées.

---

# 💾 Persistance

Storm utilise le système **KVP de FiveM** pour enregistrer les données localement.

Les éléments suivants peuvent être conservés :

- ⚙️ Paramètres du menu
- 🎨 Thème et couleurs
- 🚗 Configurations de véhicules
- 👕 Tenues
- 🔗 Raccourcis personnalisés

---

Les éléments pouvant être personnalisés comprennent notamment :

- 🎨 Couleurs
- 🖥️ Position du menu
- 📐 Dimensions
- ⌨️ Touches
- 🚗 Fonctions véhicules
- 👤 Fonctions joueur
- 🌍 Paramètres du monde

---

### Compatibilité

| Environnement | Compatibilité |
|---|:---:|
| FiveM | ✅ |
| Standalone | ✅ |
| ESX | ✅ Non requis |
| QBCore | ✅ Non requis |
| vRP | ✅ Non requis |
| ox_core | ✅ Non requis |
| Base SQL | ❌ Non requise |
| NUI | ❌ Non utilisée |

---

<div align="center">

### 🌩️ Storm

</div>
