return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    '¡Mod cargado',
                    '{C:green}con éxito{}!'
                }
            },
            load_failure_d = {
                text = {
                    '¡Faltan {C:attention}dependencias{}!',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    '¡Hay {C:attention}conflictos{} sin resolver!',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    '¡Faltan {C:attention}dependencias!',
                    '#1#',
                    '¡Hay {C:attention}conflictos{} sin resolver!',
                    '#2#'
                }
            },
            load_failure_o = {
                text = {
                    '¡Steamodded {C:attention}obsoleto{}!',
                    'Las versiones por debajo de {C:money}0.9.8{}',
                    'ya no tienen soporte.'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}¡Incompatible!{} Necesita la versión',
                    '#1# de Steamodded,',
                    'pero la #2# está instalada.'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}¡Conflicto de prefijos!{}',
                    'El prefijo del mod',
                    'es el mismo que otro mod.',
                    '({C:attention}#1#{})'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}¡Archivo principal no encontrado!{}',
                    'El archivo principal del mod',
                    'no ha sido encontrado.',
                    '({C:attention}#1#{})'
                }
            },
            load_disabled = {
                text = {
                    '¡Este mod ha sido',
                    '{C:attention}desactivado{}!'
                }
            },
            -- card perma bonuses
            card_extra_chips = {
                text = {
                    "{C:chips}#1#{} fichas extra",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fichas"
                }
            },
            card_extra_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fichas extra"
                }
            },
            card_extra_mult = {
                text = {
                    "{C:mult}#1#{} multi extra"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} multi"
                }
            },
            card_extra_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} multi extra"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "{C:money}#1#{} cuando anota",
                }
            },
            card_extra_h_chips = {
                text = {
                    "{C:chips}#1#{} fichas mientras esté en tu mano",
                }
            },
            card_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fichas mientras esté en tu mano",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fichas extra mientras esté en tu mano",
                }
            },
            card_extra_h_mult = {
                text = {
                    "{C:mult}#1#{} multi extra mientras esté en tu mano",
                }
            },
            card_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} multi mientras esté en tu mano",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} multi extra mientras esté en tu mano",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "{C:money}#1#{} si está en tu mano al final de la ronda",
                },
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "Negativa",
                text = {
                    "{C:dark_edition}+#1#{} de tamaño de mano"
                },
            },
        },
        Enhanced = {
            m_gold = {
                name = "Carta de oro",
                text = {
                    "{C:money}#1#{} si esta",
                    "carta está en tu mano",
                    "al final de la ronda",
                },
            },
            m_stone = {
                name = "Carta de piedra",
                text = {
                    "{C:chips}#1#{} fichas",
                    "sin categoría ni palo",
                },
            },
            m_mult = {
                name = "Carta multi",
                text = {
                    "{C:mult}#1#{} multi",
                },
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "¡Juega más para descubirlo!",
        },
        dictionary = {
            b_mods = 'Mods',
            b_mods_cap = 'MODS',
            b_modded_version = '¡Versión Modeada!',
            b_steamodded = 'Steamodded',
            b_credits = 'Créditos',
            b_open_mods_dir = 'Abrir directorio de Mods',
            b_no_mods = 'No se han detectado mods...',
            b_mod_list = 'Lista de Mods activos',
            b_mod_loader = 'Cargador de Mods',
            b_developed_by = 'desarrollado por ',
            b_rewrite_by = 'Reescrito por ',
            b_github_project = 'Proyecto de Github',
            b_github_bugs_1 = 'Puedes reportar errores',
            b_github_bugs_2 = 'y contribuir allí.',
            b_disable_mod_badges = 'Desactivar insignias de mods',
            b_author = 'Autor/a',
            b_authors = 'Autores',
            b_unknown = 'Desconocido',
            b_lovely_mod = '(Mod de Lovely) ',
            b_by = ' Por: ',
            b_config = "Configuración",
            b_additions = 'Adiciones',
            b_stickers = 'Stickers',
            b_achievements = "Logros",
            b_applies_stakes_1 = 'Aplica ',
            b_applies_stakes_2 = '',
            b_graphics_mipmap_level = "Nivel de Mipmap",
            b_browse = 'Navegar',
            b_search_prompt = 'Buscar mods',
            b_search_button = 'Buscar',
            b_seeded_unlocks = 'Desbloqueos con código',
            b_seeded_unlocks_info = 'Habilita desbloqueos y descubrimientos en partidas con código',
            ml_achievement_settings = {
                'Deshabilitado',
                'Habilitado',
                'Ignorar Restricciones'
            },
            b_deckskins_lc = 'Colores de bajo contraste',
            b_deckskins_hc = 'Colores de alto contraste',
            b_deckskins_def = 'Colores por defecto',
        },
        v_dictionary = {
            c_types = '#1# Tipos',
            cashout_hidden = '...y #1# más',
            a_xchips = "X#1# fichas",
            a_xchips_minus = "-X#1# fichas",
            smods_version_mismatch = {
                "¡Tu versión de Steamodded ha cambiado",
                "desde que has comenzado esta partida!",
                "Continuarla podría producir",
                "comportamiento inesperado y que el juego se bloquee.",
                "Versión de inicio: #1#",
                "Versión actual: #2#",
            }
        },
    }
}
