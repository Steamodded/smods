return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    'Mod caricata',
                    '{C:green}con successo!'
                }
            },
            load_failure_d = {
                text = {
                    '{C:attention}Dipendenze mancanti!',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    '{C:attention}Conflitti rilevati!',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    '{C:attention}Dipendenze mancanti!',
                    '#1#',
                    '{C:attention}Conflitti rilevati!',
                    '#2#'
                }
            },
            load_failure_o = {
                text = {
                    '{C:attention}Obsoleta!{} le versioni',
                    'di Steamodded {C:money}0.9.8{} ed inferiori',
                    'non sono più supportate.'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}Incompatibile!{} Richiede la versione',
                    '#1# di Steamodded,',
                    'ma la #2# è installata.'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}Conflitto fra i prefissi!{}',
                    'Il prefisso di questa mod è',
                    'lo stesso di quest\'altra mod',
                    '({C:attention}#1#{})'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}File principale non trovato!{}',
                    'Il file principale di questa mod',
                    'non è stato trovato.',
                    '({C:attention}#1#{})'
                }
            },
            load_disabled = {
                text = {
                    'Questa mod è stata',
                    '{C:attention}disattivata!{}'
                }
            },


            -- card perma bonuses
            card_extra_chips={
                text={
                    "{C:chips}#1#{} fiche extra",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fiche"
                }
            },
            card_extra_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fiche extra"
                }
            },
            card_extra_mult = {
                text = {
                    "{C:mult}#1#{} Molt extra"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Molt"
                }
            },
            card_extra_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Molt extra"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "{C:money}#1#{} quando assegna punti",
                }
            },
            card_extra_h_chips = {
                text = {
                    "{C:chips}#1#{} fiche se tenuta in mano",
                }
            },
            card_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fiche se tenuta in mano",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} fiche extra se tenuta in mano",
                }
            },
            card_extra_h_mult = {
                text = {
                    "{C:mult}#1#{} Molt extra se tenuta in mano",
                }
            },
            card_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Molt se tenuta in mano",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Molt extra se tenuta in mano",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "{C:money}#1#{} se hai in mano questa carta alla fine del round",
                },
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "Negativo",
                text = {
                    "{C:dark_edition}+#1#{} carte della mano"
                },
            },
        },
        Enhanced = {
            m_gold={
                name="Carta dorata",
                text={
                    "{C:money}$#1#{} se hai",
                    "in mano questa carta",
                    "alla fine del round",
                },
            },
            m_stone={
                name="Carta di pietra",
                text={
                    "{C:chips}+#1#{} fiche",
                    "nessun valore o seme",
                },
            },
            m_mult={
                name="Carta Molt",
                text={
                    "{C:mult}+#1#{} Molt",
                },
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "Gioca per scoprirlo!",
        },
        dictionary = {
            b_mods = 'Mod',
            b_mods_cap = 'MOD',
            b_modded_version = 'Versione Modificata!',
            b_steamodded = 'Steamodded',
            b_credits = 'Crediti',
            b_open_mods_dir = 'Apri cartella Mods',
            b_no_mods = 'Nessuna mod rilevata...',
            b_mod_list = 'Lista di mod attivate',
            b_mod_loader = 'Mod Loader',
            b_developed_by = 'sviluppato da ',
            b_rewrite_by = 'Riscritto da by ',
            b_github_project = 'Progetto Github',
            b_github_bugs_1 = 'Puoi segnalare bug e',
            b_github_bugs_2 = 'contribuire qui.',
            b_disable_mod_badges = 'Disattiva etichette mod',
            b_author = 'Autore',
            b_authors = 'Autori',
            b_unknown = 'Sconosciuto',
            b_lovely_mod = '(Lovely Mod) ',
            b_by = ' Di: ',
			b_config = "Configurazione",
			b_additions = 'Aggiunte',
      		b_stickers = 'Adesivi',
			b_achievements = "Obiettivi",
      		b_applies_stakes_1 = 'Applica ',                   
			b_applies_stakes_2 = '',
			b_graphics_mipmap_level = "Livello mipmap",
			b_browse = 'Sfoglia',
			b_search_prompt = 'Cerca mod',
			b_search_button = 'Cerca',
            b_seeded_unlocks = 'Sblocchi con seed scelto',
            b_seeded_unlocks_info = 'Attiva sblocchi e scoperte in sessioni con seed scelto',
            ml_achievement_settings = {
                'Disattivato',
                'Attivato',
                'Aggira restrizioni'
            },
            b_deckskins_lc = 'Colori a basso contrasto',
            b_deckskins_hc = 'Colori ad alto contrasto',
            b_deckskins_def = 'Colori predefiniti',
		},
		v_dictionary = {
			c_types = '#1# Tipi',
			cashout_hidden = '...e #1# in più',
            a_xchips = "X#1# fiche",
            a_xchips_minus = "-X#1# fiche",
            smods_version_mismatch = {
                "La versione di Steamodded è cambiata",
                "dall'inizio di questa sessione!",
                "Continuare potrebbe causare",
                "comportamenti anomali e crash.",
                "Versione di partenza: #1#",
                "Versione attuale: #2#",
            }
		},
	}
}
