return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    'Mod {C:green}erfolgreich',
                    'geladen!',
                }
            },
            load_failure_d = {
                text = {
                    'Fehlende {C:attention}Abhängigkeiten!',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    'Ungelöste {C:attention}Konflikte!',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    'Fehlende {C:attention}Abhängigkeiten!',
                    '#1#',
                    'Ungelöste {C:attention}Konflikte!',
                    '#2#'
                }
            },
            load_failure_o = {
                text = {
                    '{C:attention}Veraltet!{} Steamodded',
                    'Versionen {C:money}0.9.8{} und niedriger',
                    'werden nicht mehr unterstützt.'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}Inkompatibel!{} Benötigt Version',
                    '#1# von Steamodded,',
                    'aber #2# ist installiert.'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}Präfix Konflikt!{}',
                    'Präfix dieses Mods ist',
                    'der Gleiche wie ein anderer Mod.',
                    '({C:attention}#1#{})'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}Main File Nicht Gefunden!{}',
                    'Main File dieses Mods',
                    'konnte nicht gefunden werden.',
                    '({C:attention}#1#{})'
                }
            },
            load_disabled = {
                text = {
                    'Dieser Mod wurde',
                    '{C:attention}deaktiviert!{}'
                }
            },


            -- card perma bonuses
            card_extra_chips={
                text={
                    "{C:chips}#1#{} extra Chips",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} Chips"
                }
            },
            card_extra_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} extra Chips"
                }
            },
            card_extra_mult = {
                text = {
                    "{C:mult}#1#{} extra Mult"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Mult"
                }
            },
            card_extra_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} extra Mult"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "{C:money}#1#{} wenn gewertet",
                }
            },
            card_extra_h_chips = {
                text = {
                    "{C:chips}#1#{} Chips wenn in der Hand",
                }
            },
            card_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} Chips wenn in der Hand",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} extra Chips wenn in der Hand",
                }
            },
            card_extra_h_mult = {
                text = {
                    "{C:mult}#1#{} extra Mult wenn in der Hand",
                }
            },
            card_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Mult wenn in der Hand",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} extra Mult wenn in der Hand",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "{C:money}#1#{} wenn in der Hand am Ende der Runde",
                },
            },
            artist = {
                text = {
                    "{C:inactive}Künstler",
                },
            },
            artist_credit = {
                name = "Künstler",
                text = {
                    "{E:1}#1#{}"
                },
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "Negativ",
                text = {
                    "{C:dark_edition}+#1#{} Handgröße"
                },
            },
        },
        Enhanced = {
            m_gold={
                name="Goldene Karte",
                text={
                    "{C:money}#1#{} wenn diese",
                    "Karte in der Hand",
                    "am Ende der Runde",
                },
            },
            m_stone={
                name="Steinkarte",
                text={
                    "{C:chips}#1#{} Chips",
                    "Kein Rank oder Farbe",
                },
            },
            m_mult={
                name="Mult Karte",
                text={
                    "{C:mult}#1#{} Mult",
                },
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "Mehr Spielen zum Herausfinden!",
        },
        dictionary = {
            b_mods = 'Mods',
            b_mods_cap = 'MODS',
            b_modded_version = 'Modded Version!',
            b_steamodded = 'Steamodded',
            b_credits = 'Credits',
            b_open_mods_dir = 'Öffne Mod-Verzeichnis',
            b_no_mods = 'Keine Mods entdeckt...',
            b_mod_list = 'Liste aktivierter Mods',
            b_mod_loader = 'Mod Loader',
            b_developed_by = 'entwickelt von ',
            b_rewrite_by = 'überarbeitet von ',
            b_github_project = 'Github Projekt',
            b_github_bugs_1 = 'Hier kannst du Fehler melden und Beiträge einreichen.',
            b_github_bugs_2 = '(Unterstützt aber vielleicht kein Deutsch)',
            b_disable_mod_badges = 'Deaktiviere Mod Badges',
            b_author = 'Autor',
            b_authors = 'Autoren',
            b_unknown = 'Unbekannt',
            b_lovely_mod = '(Lovely Mod) ',
            b_by = ' Von: ',
            b_priority = 'Priorität: ',
			b_config = "Einstellungen",
			b_additions = 'Änderungen',
      		b_stickers = 'Sticker',
			b_achievements = "Erfolge",
      		b_applies_stakes_1 = 'Applies ', --TODO where is this used?
			b_applies_stakes_2 = '',
			b_graphics_mipmap_level = "Mipmap Level",
			b_browse = 'Durchsuchen',
			b_search_prompt = 'Suche nach Mods',
			b_search_button = 'Suche',
            b_seeded_unlocks = 'Seeded Unlocks',
            b_seeded_unlocks_info = 'Aktiviere Unlocks and Entdeckungen in Durchläufen mit Seed',
            ml_achievement_settings = {
                'Deaktiviert',
                'Aktiviert',
                'Umgehe Beschränkungen'
            },
            b_deckskins_lc = 'Niedrigkontrast Farben',
            b_deckskins_hc = 'Hochkontrast Farben',
            b_deckskins_def = 'Standardfarben',
            b_limit = 'Bis zu '
		},
		v_dictionary = {
			c_types = '#1# Typen',
			cashout_hidden = '...und #1# mehr',
            a_xchips = "X#1# Chips",
            a_xchips_minus = "-X#1# Chips",
            smods_version_mismatch = {
                "Deine Version von Steamodded hat sich geändert",
                "seit dieser Durchlauf gestartet wurde!",
                "Fortfahren kann zu unerwartenen",
                "Verhalten und Spielabstürzen führen.",
                "Version zu Beginn: #1#",
                "Aktuelle Version: #2#",
            }
		},
	}
}
