return {
	descriptions = {
		Other = {
			load_success = {
				text = {
					"모드가 {C:green}성공적으로{}",
					"로드 됐습니다!",
				},
			},
			load_failure_d = {
				text = {
					"{C:attention}선행 모드{}가 없습니다!",
					"#1#",
				},
			},
			load_failure_c = {
				text = {
					"{C:attention}모드 충돌!",
					"#1#",
				},
			},
			load_failure_d_c = {
				text = {
					"{C:attention}선행 모드{}가 없습니다!",
					"#1#",
					"{C:attention}모드 충돌!",
					"#2#",
				},
			},
			load_failure_o = {
				text = {
					"{C:attention}버전이 너무 낮습니다!{}",
					"Steamodded{ C:money}0.9.8{}이하의 버전은",
					"더 이상 지원되지 않습니다.",
				},
			},
			load_failure_i = {
				text = {
					"{C:attention}호환 오류!{}",
					"Steamodded 버전 #1#을 요구하지만,",
					"설치된 버전은 #2#입니다.",
				},
			},
			load_failure_p = {
				text = {
					"{C:attention}프리픽스 충돌!{}",
					"이 모드의 프리픽스가",
					"다른 모드의 프리픽스와 같습니다",
					"({C:attention}#1#{})",
				},
			},
			load_failure_m = {
				text = {
					"{C:attention}메인 파일이 없습니다!{}",
					"이 모드의 메인 파일을",
					"찾을수가 없습니다.",
					"({C:attention}#1#{})",
				},
			},
			load_disabled = {
				text = {
					"이 모드는",
					"{C:attention}비활성화{} 됐습니다!",
				},
			},

			-- card perma bonuses
			card_extra_chips = {
				text = {
					"추가 칩 {C:chips}#1#{}개",
				},
			},
			card_x_chips = {
				text = {
					"칩 {X:chips,C:white}X#1#{}개",
				},
			},
			card_extra_x_chips = {
				text = {
					"추가 칩 {X:chips,C:white}X#1#{}개",
				},
			},
			card_extra_mult = {
				text = {
					"{C:mult}#1#{} 추가 배수",
				},
			},
			card_x_mult = {
				text = {
					"{X:mult,C:white}X#1#{} 배수",
				},
			},
			card_extra_x_mult = {
				text = {
					"{X:mult,C:white}X#1#{} 추가 배수",
				},
			},
			card_extra_p_dollars = {
				text = {
					"득점 시 {C:money}#1#{}",
				},
			},
			card_extra_h_chips = {
				text = {
					"손에 남을 시 칩 {C:chips}#1#{}개",
				},
			},
			card_h_x_chips = {
				text = {
					"손에 남을 시 칩 {X:chips,C:white}X#1#{}개",
				},
			},
			card_extra_h_x_chips = {
				text = {
					"손에 남을 시 추가 칩 {X:chips,C:white}X#1#{}개",
				},
			},
			card_extra_h_mult = {
				text = {
					"손에 남을 시 {C:mult}#1#{} 배수",
				},
			},
			card_h_x_mult = {
				text = {
					"손에 남을 시 {X:mult,C:white}X#1#{} 배수",
				},
			},
			card_extra_h_x_mult = {
				text = {
					"손에 남을 시 {X:mult,C:white}X#1#{} 추가 배수",
				},
			},
			card_extra_h_dollars = {
				text = {
					"라운드 종료 시 {C:money}#1#{}",
				},
			},
		},
		Edition = {
			e_negative_playing_card = {
				name = "네거티브",
				text = {
					"핸드 크기 {C:dark_edition}+#1#{}장",
				},
			},
		},
		Enhanced = {
			m_gold = {
				name = "골드 카드",
				text = {
					"라운드 종료 시",
					"이 카드가 손패에 남아 있으면",
					"{C:money}$#1#{}를 획득합니다",
				},
			},
			m_stone = {
				name = "석재 카드",
				text = {
					"칩 {C:chips}+#1#{}개",
					"랭크 또는 문양이 없습니다",
				},
			},
			m_mult = {
				name = "배수 카드",
				text = {
					"{C:mult}#1#{} 배수",
				},
			},
		},
	},
	misc = {
		achievement_names = {
			hidden_achievement = "???",
		},
		achievement_descriptions = {
			hidden_achievement = "미발견",
		},
		dictionary = {
			b_mods = "모드",
			b_mods_cap = "모드",
			b_modded_version = "모드된 버전!",
			b_steamodded = "Steamodded",
			b_credits = "크레딧",
			b_open_mods_dir = "모드 폴더 열기",
			b_no_mods = "아무런 모드도 찾지 못했습니다...",
			b_mod_list = "활성화된 모드들",
			b_mod_loader = "모드 로더",
			b_developed_by = "개발: ",
			b_rewrite_by = "재개발: ",
			b_github_project = "Github 프로젝트",
			b_github_bugs_1 = "버그를 제보하거나",
			b_github_bugs_2 = "코드에 기여할수 있습니다",
			b_disable_mod_badges = "모드 배지 숨기기",
			b_author = "제작자",
			b_authors = "제작자",
			b_unknown = "불명",
			b_lovely_mod = "(Lovely Mod)",
			b_by = " By: ",
			b_config = "설정",
			b_additions = "추가",
			b_stickers = "스티커",
			b_achievements = "업적",
			b_applies_stakes_1 = "적용: ",
			b_applies_stakes_2 = "",
			b_graphics_mipmap_level = "밉맵 레벨",
			b_browse = "Browse", -- Unused? Not sure what the context for this is
			b_search_prompt = "모드 검색",
			b_search_button = "검색",
			b_seeded_unlocks = "시드런 언락",
			b_seeded_unlocks_info = "시드런에서도 해금을 할수있습니다",
			ml_achievement_settings = {
				"비활성화",
				"활성화",
				"제한 무시",
			},
			b_deckskins_lc = "저대비 색상",
			b_deckskins_hc = "고대비 색상",
			b_deckskins_def = "기본 색상",
		},
		v_dictionary = {
			c_types = "#1# 종류",
			cashout_hidden = "...그리고 #1#개 더",
			a_xchips = "칩 X#1# 개",
			a_xchips_minus = "칩 -X#1# 개",
			smods_version_mismatch = {
				"이 런을 시작한 후 Steamodded의",
				"버전이 바뀌었습니다!",
				"계속 진행 할 경우 예상치 않은",
				"오류가 발생할수 있습니다.",
				"시작한 버전: #1#",
				"현재 버전: #2#",
			},
		},
	},
}
