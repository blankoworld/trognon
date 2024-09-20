#!/usr/bin/env bash
#
# argv.sh: Gestion de BASH_ARGV
#
# ATTENTION: nécessite common.sh

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
## TESTS
###

# On a besoin d'une commande!
[ $# -eq 0 ] && usage_and_exit

#####
## VARIABLES 
###

# Récupération de la commande donnée…
COMMAND="$1"

#####
## TRAITEMENTS
###
shift # supprime la commande elle même de la liste $@
# Extraie aussi les arguments
ARGS="$@"
# validation de la commande
is_command_allowed "${COMMAND}" "${ARGS}"
# La commande help n'affiche que l'aide contextuelle
if [[ "${COMMAND}" == "help" ]]; then
  usage_and_exit
fi
# vim: ts=2 sw=2 et nu
