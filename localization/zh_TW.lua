return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    '模組載入',
                    '{C:green}成功！'
                }
            },
            load_failure_d = {
                text = {
                    '缺少{C:attention}相依套件！',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    '發生{C:attention}衝突！',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    '缺少{C:attention}相依套件！',
                    '#1#',
                    '發生{C:attention}衝突！',
                    '#2#'
                }
            },
            load_failure_o = {
                text = {
                    '{C:attention}版本過舊！{} Steamodded',
                    '{C:money}0.9.8{} 及以下版本',
                    '已不再受到支援。'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}不相容！{} 需要',
                    'Steamodded #1# 版，',
                    '但目前安裝的是 #2#。'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}前綴衝突！{}',
                    '此模組的前綴',
                    '與其他模組相同。',
                    '（{C:attention}#1#{}）'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}找不到主要檔案！{}',
                    '此模組的主要檔案',
                    '無法被找到。',
                    '（{C:attention}#1#{}）'
                }
            },
            load_disabled = {
                text = {
                    '此模組已被',
                    '{C:attention}停用！{}'
                }
            },


            -- 牌的永久加成
            card_extra_chips={
                text={
                    "額外 {C:chips}#1#{} 籌碼",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{} 籌碼"
                }
            },
            card_extra_x_chips = {
                text = {
                    "額外 {X:chips,C:white}X#1#{} 籌碼"
                }
            },
            card_extra_mult = {
                text = {
                    "額外 {C:mult}#1#{} 倍數"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{} 倍數"
                }
            },
            card_extra_x_mult = {
                text = {
                    "額外 {X:mult,C:white}X#1#{} 倍數"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "計分時獲得 {C:money}#1#{}",
                }
            },
            card_extra_h_chips = {
                text = {
                    "持於手中時獲得 {C:chips}#1#{} 籌碼",
                }
            },
            card_h_x_chips = {
                text = {
                    "持於手中時獲得 {X:chips,C:white}X#1#{} 籌碼",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "持於手中時額外獲得 {X:chips,C:white}X#1#{} 籌碼",
                }
            },
            card_extra_h_mult = {
                text = {
                    "持於手中時額外獲得 {C:mult}#1#{} 倍數",
                }
            },
            card_h_x_mult = {
                text = {
                    "持於手中時獲得 {X:mult,C:white}X#1#{} 倍數",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "持於手中時額外獲得 {X:mult,C:white}X#1#{} 倍數",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "回合結束時持於手中可獲得 {C:money}#1#{}",
                },
            },
            card_extra_repetitions = {
                text = {
                    "重新觸發此張牌",
                    "{C:attention}#1#{} #2#",
                },
            },
            card_score = {
                text = {
                    "{C:purple}#1#{} 分數",
                },
            },
            card_h_score = {
                text = {
                    "持於手中時獲得 {C:purple}#1#{} 分數",
                },
            },
            card_x_score = {
                text = {
                    "{X:purple,C:white}X#1#{} 分數",
                },
            },
            card_h_x_score = {
                text = {
                    "持於手中時獲得 {X:purple,C:white}X#1#{} 分數",
                },
            },
            card_extra_score = {
                text = {
                    "額外 {C:purple}#1#{} 分數",
                },
            },
            card_extra_h_score = {
                text = {
                    "持於手中時額外獲得 {C:purple}#1#{} 分數",
                },
            },
            card_extra_x_score = {
                text = {
                    "額外 {X:purple,C:white}X#1#{} 分數",
                },
            },
            card_extra_h_x_score = {
                text = {
                    "持於手中時額外獲得 {X:purple,C:white}X#1#{} 分數",
                },
            },
            card_blind_size = {
                text = {
                    "{C:blind}#1#{} 盲注大小",
                },
            },
            card_h_blind_size = {
                text = {
                    "持於手中時獲得 {C:blind}#1#{} 盲注大小",
                },
            },
            card_x_blind_size = {
                text = {
                    "{X:blind,C:white}X#1#{} 盲注大小",
                },
            },
            card_h_x_blind_size = {
                text = {
                    "持於手中時獲得 {X:blind,C:white}X#1#{} 盲注大小",
                },
            },
            card_extra_blind_size = {
                text = {
                    "額外 {C:blind}#1#{} 盲注大小",
                },
            },
            card_extra_h_blind_size = {
                text = {
                    "持於手中時額外獲得 {C:blind}#1#{} 盲注大小",
                },
            },
            card_extra_x_blind_size = {
                text = {
                    "額外 {X:blind,C:white}X#1#{} 盲注大小",
                },
            },
            card_extra_h_x_blind_size = {
                text = {
                    "持於手中時額外獲得 {X:blind,C:white}X#1#{} 盲注大小",
                },
            },
            artist = {
                text = {
                    "{C:inactive}繪師",
                },
            },
            artist_credit = {
                name = "繪師",
                text = {
                    "{E:1}#1#{}"
                },
            },
            generic_card_limit = {
                name = "卡牌上限",
                text = {
                    '{C:dark_edition}#1#{} 區域欄位'
                }
            },
            generic_card_limit_plural = {
                name = "卡牌上限",
                text = {
                    '{C:dark_edition}#1#{} 區域欄位'
                }
            },
            generic_card_limit_pc = {
                name = "手牌上限",
                text = {
                    '{C:dark_edition}#1#{} 手牌上限'
                }
            },
            generic_card_limit_pc_plural = {
                name = "手牌上限",
                text = {
                    '{C:dark_edition}#1#{} 手牌上限'
                }
            },
            generic_extra_slots = {
                name = "佔用欄位",
                text = {
                    '佔用 {C:dark_edition}#1#{} 個欄位'
                }
            },
            generic_extra_slots_pc = {
                name = "佔用手牌空間",
                text = {
                    '佔用 {C:dark_edition}#1#{} 個手牌空間'
                }
            },
            card_chips_minus = {
                text = {
                    '{C:chips}#1#{} 籌碼'
                }
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "負片",
                text = {
                    "{C:dark_edition}+#1#{} 手牌上限"
                },
            },
            e_negative_generic = {
                name = "負片",
                text = {
                    "{C:dark_edition}+#1#{} 區域欄位"
                },
            }
        },
        Enhanced = {
            m_gold={
                name="黃金牌",
                text={
                    "回合結束時若持於手中",
                    "可獲得 {C:money}#1#{}",
                },
            },
            m_stone={
                name="石頭牌",
                text={
                    "{C:chips}#1#{} 籌碼",
                    "無點數與花色",
                },
            },
            m_mult={
                name="倍數牌",
                text={
                    "{C:mult}#1#{} 倍數",
                },
            },
            m_lucky={
                name="幸運牌",
                text={
                    "{C:green}#3# 分之 #1#{} 的機率",
                    "獲得 {C:mult}+#2#{} 倍數",
                    "{C:green}#5# 分之 #6#{} 的機率",
                    "贏得 {C:money}$#4#",
                },
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "繼續遊玩以解鎖！",
        },
        dictionary = {
            b_mods = '模組',
            b_mods_cap = '模組',
            b_modded_version = '模組版本！',
            b_steamodded = 'Steamodded',
            b_credits = '製作人員',
            b_open_mods_dir = '開啟模組資料夾',
            b_no_mods = '未偵測到任何模組...',
            b_mod_list = '已啟用模組清單',
            b_mod_loader = '模組載入器',
            b_developed_by = '開發者：',
            b_rewrite_by = '重寫者：',
            b_github_project = 'Github 專案',
            b_github_bugs_1 = '您可以在此回報問題',
            b_github_bugs_2 = '及提交貢獻。',
            b_disable_mod_badges = '停用模組徽章',
            b_author = '作者',
            b_authors = '作者群',
            b_unknown = '未知',
            b_lovely_mod = '（Lovely 模組）',
            b_by = '製作：',
            b_priority = '優先級：',
            b_config = "設定",
            b_additions = '新增內容',
            b_stickers = '貼紙',
            b_achievements = "成就",
            b_applies_stakes_1 = '適用 ',
            b_applies_stakes_2 = '',
            b_graphics_mipmap_level = "Mipmap 等級",
            b_browse = '瀏覽',
            b_search_prompt = '搜尋模組',
            b_search_button = '搜尋',
            b_seeded_unlocks = '種子解鎖',
            b_seeded_unlocks_info = '在種子局中啟用解鎖與發現功能',
            ml_achievement_settings = {
                '已停用',
                '已啟用',
                '跳過限制'
            },
            b_deckskins_lc = '低對比色彩',
            b_deckskins_hc = '高對比色彩',
            b_deckskins_def = '預設色彩',
            b_limit = '最多 ',
            b_retrigger_single = '次',
            b_retrigger_plural = '次',
            k_enhanced = '強化'
        },
        v_dictionary = {
            c_types = '#1# 種類型',
            cashout_hidden = '...以及另外 #1# 項',
            a_xchips = "X#1# 籌碼",
            a_xchips_minus = "-X#1# 籌碼",
            a_score="#1# 分數",
            a_xscore="X#1# 分數",
            a_xscore_minus="-X#1# 分數",
            a_blind_size="#1# 盲注大小",
            a_xblind_size="X#1# 盲注大小",
            a_xblind_size_minus="-X#1# 盲注大小",
            smods_version_mismatch = {
                "您的 Steamodded 版本已自此局",
                "開始後發生變更！",
                "繼續遊玩可能導致",
                "非預期的行為與遊戲崩潰。",
                "起始版本：#1#",
                "目前版本：#2#",
            }
        },
    }
}
