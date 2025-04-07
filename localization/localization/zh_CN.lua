return {
    descriptions = {
        Other = {
            load_success = {
                text = {
                    '模组加载{C:green}成功！'
                }
            },
            load_failure_d = {
                text = {
                    '{C:attention}依赖项{}缺失！',
                    '#1#',
                }
            },
            load_failure_c = {
                text = {
                    '存在{C:attention}冲突项{}！',
                    '#1#'
                }
            },
            load_failure_d_c = {
                text = {
                    '{C:attention}依赖项{}缺失！',
                    '#1#',
                    '存在{C:attention}冲突项{}！',
                    '#2#'
                }
            },
            load_failure_o = {
                text = {
                    'Steamodded版本{C:attention}过旧{}！',
                    '已不再支持',
                    '{C:money}0.9.8{}及以下版本'
                }
            },
            load_failure_i = {
                text = {
                    '{C:attention}不兼容！',
                    '所需Steamodded版本为#1#',
                    '但当前为#2#'
                }
            },
            load_failure_p = {
                text = {
                    '{C:attention}前缀冲突！{}',
                    '此模组的前缀和',
                    '另外一个模组相同！',
                    '({C:attention}#1#{})'
                }
            },
            load_failure_m = {
                text = {
                    '{C:attention}未找到主文件！{}',
                    '无法找到',
                    '该模组主文件',
                    '({C:attention}#1#{})'
                }
            },
            load_disabled = {
                text = {
                    '该模组',
                    '已被{C:attention}禁用{}！'
                }
            },


            -- card perma bonuses
            card_extra_chips={
                text={
                    "{C:chips}#1#{}额外筹码",
                },
            },
            card_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{}筹码"
                }
            },
            card_extra_x_chips = {
                text = {
                    "{X:chips,C:white}X#1#{}额外筹码"
                }
            },
            card_extra_mult = {
                text = {
                    "{C:mult}#1#{}额外倍率"
                }
            },
            card_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{}倍率"
                }
            },
            card_extra_x_mult = {
                text = {
                    "{X:mult,C:white}X#1#{}额外倍率"
                }
            },
            card_extra_p_dollars = {
                text = {
                    "计分时获得{C:money}#1#{}",
                }
            },
            card_extra_h_chips = {
                text = {
                    "手持时{C:chips}#1#{}筹码",
                }
            },
            card_h_x_chips = {
                text = {
                    "手持时{X:chips,C:white}X#1#{}筹码",
                }
            },
            card_extra_h_x_chips = {
                text = {
                    "手持时{X:chips,C:white}X#1#{}额外筹码",
                }
            },
            card_extra_h_mult = {
                text = {
                    "手持时{C:mult}#1#{}额外倍率",
                }
            },
            card_h_x_mult = {
                text = {
                    "手持时{X:mult,C:white}X#1#{}倍率",
                }
            },
            card_extra_h_x_mult = {
                text = {
                    "手持时{X:mult,C:white}X#1#{}额外倍率",
                }
            },
            card_extra_h_dollars = {
                text = {
                    "回合结束时如仍",
                    "手持则获得{C:money}#1#{}",
                },
            },
        },
        Edition = {
            e_negative_playing_card = {
                name = "负片",
                text = {
                    "{C:dark_edition}+#1#{}手牌上限"
                },
            },
        },
        Enhanced = {
            m_gold={
                name="黄金牌",
                text={
                    "如果这张卡牌",
                    "在回合结束时还在手牌中",
                    "你获得{C:money}#1#{}",
                },
            },
            m_stone={
                name="石头牌",
                text={
                    "{C:chips}#1#{}筹码",
                    "无点数无花色",
                },
            },
            m_mult={
                name="倍率牌",
                text={
                    "{C:mult}#1#{}倍率",
                },
            },
        }
    },
    misc = {
        achievement_names = {
            hidden_achievement = "???",
        },
        achievement_descriptions = {
            hidden_achievement = "游玩更多以解锁隐藏成就！",
        },
        dictionary = {
            b_mods = '模组',
            b_mods_cap = '模组',
            b_modded_version = '模组环境！',
            b_steamodded = 'Steamodded',
            b_credits = '鸣谢',
            b_open_mods_dir = '打开模组目录',
            b_no_mods = '未检测到任何模组……',
            b_mod_list = '已启用模组列表',
            b_mod_loader = '模组加载器',
            b_developed_by = '作者：',
            b_rewrite_by = '重写者：',
            b_github_project = 'Github项目',
            b_github_bugs_1 = '你可以在此汇报漏洞',
            b_github_bugs_2 = '和提交贡献',
            b_disable_mod_badges = '禁用归属模组名称显示',
            b_author = '作者',
            b_authors = '作者',
            b_unknown = '未知',
            b_lovely_mod = '(需要Lovely注入补丁)',
            b_by = '作者：',
            b_priority = '优先级: ',
			b_config = "配置",
			b_additions = '新增项目',
      		b_stickers = '贴纸',
			b_achievements = "成就",
      		b_applies_stakes_1 = '',
			b_applies_stakes_2 = '的限制也都起效',
			b_graphics_mipmap_level = "多级渐远纹理层级",
			b_browse = '浏览',
			b_search_prompt = '搜索模组',
			b_search_button = '搜索',
            b_seeded_unlocks = '种子解锁模式',
            b_seeded_unlocks_info = '启用后种子局也能解锁发现新内容',
            ml_achievement_settings = {
                '禁用',
                '启用',
                '总是能够获得成就'
            },
            b_deckskins_lc = '低对比度配色',
            b_deckskins_hc = '高对比度配色',
            b_deckskins_def = '默认配色',
		},
		v_dictionary = {
			c_types = '#1#种类型',
			cashout_hidden = '...以及#1#个',
            a_xchips = "X#1#筹码",
            a_xchips_minus = "-X#1#筹码",
            smods_version_mismatch = {
                "自本赛局开始后",
                "您的Steamodded版本已变更",
                "继续运行可能导致",
                "意外情况或游戏崩溃",
                "起始版本：#1#",
                "当前版本：#2#",
            }
		},
	}
}
