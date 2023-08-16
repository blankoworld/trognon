#!/usr/bin/env bash
#
# common.sh: fonctions habituellements utilisées pour les scripts BASH 
#

#####
## LICENSE/LICENCE
###

# Trognon - Un 'wrapper' de commandes personnalisées pour vos projets de DEV
#
# Copyright © 2019-2023  Olivier DOSSMANN (https://github.com/blankoworld)
#
# This file is part of Trognon. This software is licensed under the
# European Union Public License 1.2 (EUPL-1.2), published in Official Journal
# of the European Union (OJ) of 19 May 2017 and available in 23 official
# languages of the European Union.
#
# The English version is included with this software. Please see the following
# page for all the official versions of the EUPL-1.2:
#
# <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>

#####
## VARIABLES
###

# Le projet. TODO: changer le nom du projet ici
PROJECT="nomDuProjet"
COMMON_CONFIG_NAME="common"
# Pour les couleurs
NC='\033[0m'                    # Couleur par défaut
INFO_COLOR='\033[7;49;34m'      # Gras + blanc + couleur de fond bleu
SUCCESS_COLOR='\033[7;49;32m'   # Gras + blanc + couleur de fond vert
WARNING_COLOR='\033[7;49;33m'   # Gras + blanc + couleur de fond jaune/orange
ERROR_COLOR='\033[7;49;31m'     # Gras + blanc + couleur de fond rouge
NORMAL_COLOR='\033[1;49;34m'    # Gras + cyan + couleur de fond 'normal'
# Pour les commandes lancées
ALLOWED_COMMANDS=false

#####
## FONCTIONS
###

# Messages avec des couleurs, comme les arc-en-ciel :-)
# Cf. https://misc.flogisoft.com/bash/tip_colors_and_formatting
colored_msg() {
  # $1: couleur choisie
  # $2: titre
  # $3: le message
  echo -e "${1}[${2}]: ${3}${NC}" 1>&2
}
# Message normal
msg() {
  echo -e "${NORMAL_COLOR}${1}${NC}" 1>&2
}
# Message d'information, plus prononcé
info_msg() {
  colored_msg "${INFO_COLOR}" "INFO" "${1}"
}
# Porter l'attention sur une information importante
warning_msg() {
  colored_msg "${WARNING_COLOR}" "IMPORTANT" "${1}"
}
# Erreur ç_ç
error_msg() {
  colored_msg "${ERROR_COLOR}" "ERREUR" "${1}"
}
# Réussite !
success_msg() {
  colored_msg "${SUCCESS_COLOR}" "SUCCÈS" "${1}"
}
# Échec, j'arrête le programme !
error_msg+exit() {
  error_msg "${1}" && exit 1
}
# Message pour DEBUG en temps de développement
debug_msg() {
  if [[ ${DEBUG} == true ]]; then
    msg "$1"
  fi
}

# Aide contextuelle par défaut
usage() {
  if [[ -n "${USAGE}" ]]; then
    msg "${USAGE}"
  else
    msg "Utilisation : $PROGRAM"
    msg "\nATTENTION : Les options et commandes pour ce programme n'a pas encore été implémenté !"
  fi
}

# Affichage de l'aide contextuelle avant arrêt du programme !
usage+exit() {
  usage
  exit 1
}

# Affichage de l'aide contextuelle, d'une erreur, puis arrêt du programme !
error+usage() {
  usage
  error_msg "$1"
  exit 1
}

# Teste la commande donnée en la comparant aux commandes autorisées
is_command_allowed() {
  local args_text=""
  if [[ -n "$2" ]]; then
    args_text="\n- ARGS   : $2"
  fi
  grep -F -q -x "$1" <<< "${ALLOWED_COMMANDS}" \
    && debug_msg "${PROGRAM}\n- Commande : $1${args_text}" \
    || error+usage "Commande '$1' inconnue"
}

# Port aléatoire
random_port() {
  port=''
  while true
  do
      port=$(( ((RANDOM<<15)|RANDOM) % 49152 + 10000 ))
      status="$(nc -z 127.0.0.1 $random_port < /dev/null &>/dev/null; echo $?)"
      if [ "${status}" != "0" ]; then
        return 0
      fi
      return 1
  done
}

# CONFIG.: charge le fichier de configuration du projet.
# 1/ si la variable TROGNON_CONFIG est initialisée et que le fichier existe
# 2/ sinon on teste nomDuProjet.config dans le dossier courant. TODO: changer nomDuProjet
# 3/ si 1/ + 2/ échouent, on ne fait rien => ça chargera les variables TROGNON_XX
project_config() {
  # initialisation
  CONFIG_FILE=""
  local CONFIG_FILENAME="${PROJECT}.config"
  local CURRENTDIR_CONFIG="${PWD}/${CONFIG_FILENAME}"
  # 1/ si TROGNON_CONFIG existe, on l'utilise comme source de configuration.
  if (test -n "${TROGNON_CONFIG}") && (test -f "${TROGNON_CONFIG}"); then
    CONFIG_FILE="${TROGNON_CONFIG}"
  # 2/ si rerologik.config existe dans le dossier courant, on l'utilise.
  elif test -f "${CURRENTDIR_CONFIG}"; then
    CONFIG_FILE="${CURRENTDIR_CONFIG}"
  fi
  # Si 1/ OU 2/ réussit, on charge le fichier
  if test -n "${CONFIG_FILE}"; then
    info_msg "Configuration chargée : '${CONFIG_FILE}'."
    source "${CONFIG_FILE}" || exit 1
  fi
}

# On charge un fichier de configuration donné en argument 1.
load_config() {
  if [[ -z "$1" ]]; then
    error_msg+exit "LOAD CONFIG ❯ No file given!"
  fi
  if test -f "$1"; then
    source "$1" || exit 1
  fi
}

# Configuration du logiciel.
# D'abord les valeurs initiales communes, puis les valeurs initiales propre
# à chaque commande (/config/program.default où program=nom du programme).
# On charge ensuite la configuration du projet (soit TROGNON_CONFIG, soit 
# nomDuProjet.config)
# Finalement on surcharge les variables avec celles données en ligne de
# commande (par TROGNON_variable=).
configure() {
  local project_path="${DIR}/config/${COMMON_CONFIG_NAME}"
  local program_path="${DIR}/config/${PROGRAM}"
  # d'abord les valeurs initiales (default) du projet et du programme
  for path in "${project_path}" "${program_path}"; do
    load_config "${path}.default"
  done
  # ensuite les variables d'une éventuelle configuration
  project_config
  # finalement les variables surchargées en ligne de commande
  for path in "${project_path}" "${program_path}"; do
    load_config "${path}.overload"
  done
}

# Sauvegarde des variables du programme dans un fichier de configuration
# Utilisation du tableau TO_SAVE_VARIABLES=(var1 var2 var2 etc)
# 1: (optionnel) fichier de destination où écrire
save_config() {
  if test -n "${TO_SAVE_VARIABLES}"; then
    info_msg "Sauvegarde du paramétrage de ${PROGRAM}."
    SAVE_FILE="${DEST}/${PROGRAM}.config"
    if [[ -n "$1" ]]; then
      SAVE_FILE="$1"
    fi
    cat "${DIR}/content/${PROGRAM}.config.header" > ${SAVE_FILE}
    for to_save in "${TO_SAVE_VARIABLES[@]}"; do
      echo "${to_save}=\"${!to_save}\"" >> "${SAVE_FILE}"
    done
    success_msg "Paramétrage sauvegardé dans '${SAVE_FILE}'"
  fi
}

# Vérification de la présence d'un programme dans le système
# argument 1 : variable d'export qui définit le chemin du programme à utiliser
# argument 2 : nom exact du programme
check_program_present() {
  message="Commande '$2' non trouvée !"
  # préparation de la commande qui sera lancée
  # à l'exception de nvm qui est une fonction
  if [[ "$2" == "nvm" ]]; then
    export_content="$2"
  else
    export_content=`which $2` || error_msg+exit "${message}"
  fi
  # vérification de la présence de notre commande
  if test -n $(command -v $2 &> /dev/null); then
    export $1="${export_content}"
  else
    error_msg+exit "${message}"
  fi
}

# Récupération par git d'une branche d'un dépôt
# 1 : raison de la récupération
# 2 : URL du dépot
# 3 : branche
# 4 : dossier de destination
git_clone() {
  info_msg "$1 ❯ Récupération de  : $2 dans $4"
  $GIT clone --depth=1 --single-branch --branch "$3" "$2" "$4" \
  || error_msg+exit "$1 ❯ Récupération échouée !"
  success_msg "$1 ❯ récupéré !"
}

# Installation d'une version de Python dans un dossier
# 1 : version de python
# 2 : dossier d'installation
install_python() {
  info_msg "Utilisation de Python $1 dans le dossier '$2'"
  # installation de la version de Python, excepté s'il est déjà installé
  ${PYENV} install $1 -s
  # utilisation de la version de Python dans le dossier proposé
  cd "$2"
  ${PYENV} local $1
  # installation de pipenv
  pip install pipenv==${PIPENV_VERSION}
  # retour au répertoire précédent
  cd - &>/dev/null
  success_msg "Python $1 utilisé pour '$2' !"
}

# Supprime l'environnement virtuel du projet
delete_venv() {
  # TODO: trouver comment définir le chemin du virtualenv. Le supprimer si
  # existant.
  # Si pipenv échoue, c'est probablement qu'on a aucun virtualenv
  ${PIPENV} --rm || : # ne fait rien, retourne 0 comme état de sortie
}

#####
## PROGRAMMES
###

# Vérification de la commande git
check_git_present() {
  check_program_present "GIT" "git"
}

# Vérification du service docker
check_docker_present() {
  check_program_present "DOCKER" "docker"
  $DOCKER info &> /dev/null \
    && success_msg "DOCKER : présent et lancé !" \
    || error_msg+exit "DOCKER : manquant ! Vérifiez qu'il soit présent et lancé."
}

# Vérification de la commande docker-compose
check_docker_compose_present() {
  check_program_present "COMPOSE" "docker-compose"
}

# Vérification de la commande pipenv
# bonus : vérification de la version de pipenv
check_pipenv_present() {
  check_program_present "PIPENV" "pipenv"
  if [[ -z "${PIPENV_VERSION}" ]]; then
    error_msg+exit "Variable PIPENV_VERSION non renseignée!"
  fi
  local local_pipenv_version=`${PIPENV} --version| cut -d ' ' -f3`
  if ! test $local_pipenv_version == "${PIPENV_VERSION}"; then
    error_msg+exit "PIPENV ${local_pipenv_version} : mauvaise version. Utilisez ${PIPENV_VERSION} ! Faites : pip install --user pipenv==${PIPENV_VERSION}"
  fi
}

# Vérification de pyenv
check_pyenv_present() {
  check_program_present "PYENV" "pyenv"
}

# Vérification de nvm
check_nvm_present() {
  check_program_present "NVM" "nvm"
  # si la vérification n'a pas échouée, on charge NVM pour notre programme.
  source "${NVM_DIR}/nvm.sh"
}

# Vérification de npm
check_npm_present() {
  check_program_present "NPM" "npm"
}
# vim: ts=2 sw=2 et nu
