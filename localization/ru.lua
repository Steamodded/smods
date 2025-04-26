return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    'Мод загружен',
                    '{C:green}успешно!'
                }
            },
            load_failure_d = {
                text = {
                    'Не хватает {C:attention}зависимостей!',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    'Неразрешенные {C:attention}конфликты!',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    'Не хватает {C:attention}зависимостей!',
                    '#1#',
                    'Неразрешенные {C:attention}конфликты!',
                    '#1#'
                }
            },
            load_failure_o = {
                text = {
                    '{C:attention}Устаревший!{} Steamodded',
                    'версия {C:money}0.9.8{} и ниже',
                    'более не поддерживается.'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}Несовместимо!{}',
                    'Нужен Steammodded #1#,',
                    'но #2# установлен.'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}Конфликт префиксов!{}',
                    'Префиксы этих модов',
                    'такие же как у других.',
                    '({C:attention}#1#{})'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}Основной файл не найден!{}',
                    'Основной файл этого мода',
                    'не найден.',
                    '({C:attention}#1#{})'
                }
            },
            load_disabled = {
                text = {
                    'Данный мод был',
                    '{C:attention}отключён!{}'
                }
            },


            -- card perma bonuses
            card_extra_chips={
                text={
                    "{C:chips}#1#{} экстра фишек",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} фишек"
                }
            },
            card_extra_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} экстра фишек"
                }
            },
            card_extra_mult = {
                text = {
                    "{C:mult}#1#{} экстра Модификатор"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Модификатор"
                }
            },
            card_extra_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} экстра Модификатор"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "{C:money}#1#{} when scored",
                }
            },
            card_extra_h_chips = {
                text = {
                    "{C:chips}#1#{} фишек когда удерживается",
                }
            },
            card_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} фишек когда удерживается",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} экстра фишек когда удерживается",
                }
            },
            card_extra_h_mult = {
                text = {
                    "{C:mult}#1#{} экстра Модификатор когда удерживается",
                }
            },
            card_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} Модификатор когда удерживается",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} экстра Модификатор когда удерживается",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "{C:money}#1#{} если удерживается в конце раунда",
                },
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "Негативный",
                text = {
                    "{C:dark_edition}+#1#{} размер руки"
                },
            },
        },
        Enhanced = {
            m_gold = {
                name = "Золотая карта",
                text = {
                    "Даёт {C:money}#1#{}, если",
                    "удерживается в руке",
                    "до конца раунда"
                }
            },
            m_stone = {
                name = "Каменная карта",
                text = {
                    "{C:chips}#1#{} фишек,",
                    "не имеет достоинства и масти,", "всегда учитывается при подсчёте"
                }
            },
            m_mult = {
                name = "Карта с множителем",
                text = {
                    "{C:mult}#1#{} множ."
                }
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "Играйте больше, чтобы открыть!",
        },
        dictionary = {
            b_mods = 'Моды',
            b_mods_cap = 'МОДЫ',
            b_modded_version = 'Модифицированная версия!',
            b_steamodded = 'Steamodded',
            b_credits = 'Титры',
            b_open_mods_dir = 'Открыть папку с модами',
            b_no_mods = 'Модов не найдено...',
            b_mod_list = 'Список активированных модов',
            b_mod_loader = 'Загрузчик модов',
            b_developed_by = 'разработан ',
            b_rewrite_by = 'Переписан ',
            b_github_project = 'Github Проект',
            b_github_bugs_1 = 'Вы можете сообщать о багах',
            b_github_bugs_2 = 'и помочь в разработке здесь.',
            b_disable_mod_badges = 'Отключить значки модов',
            b_author = 'Автор',
            b_authors = 'Авторы',
            b_unknown = 'Неизвестно',
            b_lovely_mod = '(Lovely Mod) ',
            b_by = ' От: ',
            b_priority = 'Приоритет: ',
			b_config = "Настройки",
			b_additions = 'Дополнения',
      		b_stickers = 'Наклейки',
			b_achievements = "Достижения",
      		b_applies_stakes_1 = 'Применяет ',
			b_applies_stakes_2 = '',
			b_graphics_mipmap_level = "Уровни Mipmap",
			b_browse = 'Найти',
			b_search_prompt = 'Поиск модов',
			b_search_button = 'Поиск',
            b_seeded_unlocks = 'Разблокировка с сидами',
            b_seeded_unlocks_info = 'Включает возможность открывать предметы коллекции в забегах с сидами',
            ml_achievement_settings = {
                'Отключёны',
                'Включёны',
                'Обойти ограничения'
            },
            b_deckskins_lc = 'Низкоконтрастные цвета',
            b_deckskins_hc = 'Высококонтрастные цвета',
            b_deckskins_def = 'Стандартные цвета',
		},
		v_dictionary = {
			c_types = '#1# Типов',
			cashout_hidden = '...и #1# более',
            a_xchips = "X#1# фишек",
            a_xchips_minus = "-X#1# фишек",
            smods_version_mismatch = {
                "Версия Steamodded изменилась",
                "с начала забега!",
                "Продолжение может привести к",
                "неожиданным последствиям и крашам.",
                "Изначальная версия: #1#",
                "Текущая версия: #2#",
            }
		},
	}
}
