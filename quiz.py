from collections import defaultdict

QMAP = {
    "Q1_go_to_outfit": {
        "question": "What’s your go-to outfit for a casual day out that you actually like?",
        "options": {
            "Minimal & Clean": {
                "Style": {"minimal": 1.0},
                "Color Palette": {"neutrals": 1.0},
                "Pattern": {"solid": 0.8},
                "Fit": {"regular": 0.5},
                "Occasion": {"casual": 0.6},
            },
            "Classic/Preppy": {
                "Style": {"classic": 1.0},
                "Pattern": {"stripes": 0.8, "checks": 0.8},
                "Fit": {"tailored": 0.8},
                "Occasion": {"casual": 0.6},
            },
            "Streetwear/Athleisure": {
                "Style": {"street": 1.0},
                "Occasion": {"athleisure": 1.0, "casual": 0.6},
                "Fit": {"oversized": 0.7, "regular": 0.4},
                "Pattern": {"graphic": 0.5},
            },
            "Trend-forward/Edgy": {
                "Style": {"trend": 1.0},
                "Pattern": {"prints": 0.6},
                "Fit": {"slim": 0.4, "oversized": 0.4},
                "Occasion": {"party": 0.8},
            },
            "Boho/Romantic": {
                "Style": {"boho": 1.0},
                "Fabric": {"linen": 0.8, "cotton": 0.4},
                "Pattern": {"prints": 0.6, "floral": 0.8},
                "Fit": {"regular": 0.4, "oversized": 0.4},
                "Occasion": {"casual": 0.6},
            },
            "Elevated Casual": {
                "Style": {"smart-casual": 1.0},
                "Fit": {"tailored": 0.8},
                "Occasion": {"casual": 0.8, "work": 0.4},
                "Color Palette": {"neutrals": 0.6},
            },
        },
    },

    "Q2_preferred_palette": {
        "question": "Which colors do you reach for most often?",
        "options": {
            "Warm & Earthy": {"Color Palette": {"warm": 1.0}},
            "Cool & Icy": {"Color Palette": {"cool": 1.0}},
            "Monochrome / Neutrals": {"Color Palette": {"neutrals": 1.0}},
            "Bright & Light": {"Color Palette": {"light": 1.0}},
            "Dark & Moody": {"Color Palette": {"dark": 1.0}},
        },
    },

    "Q3_favorite_fabric": {
        "question": "What fabrics do you gravitate towards?",
        "options": {
            "Breathable Cotton": {"Fabric": {"cotton": 1.0}},
            "Soft Wool": {"Fabric": {"wool": 1.0}, "Occasion": {"work": 0.3}},
            "Relaxed Linen": {"Fabric": {"linen": 1.0}, "Style": {"boho": 0.3}, "Occasion": {"casual": 0.2}},
        },
    },
}


def build_user_prof(answers, qmap=QMAP):
    prof = defaultdict(float)
    for qid, sel in answers.items():
        opts = qmap.get(qid, {}).get("options", {})
        selections = sel if isinstance(sel, list) else [sel]
        for label in selections:
            catmap = opts.get(label)
            if not catmap:
                continue
            for category, weights in catmap.items():
                for tag, w in weights.items():
                    prof[f"{category}:{tag}"] += float(w)
    return dict(prof)


def top_k_vector(user_vec: dict[str, float], k: int = 3) -> dict[str, float]:
    items = sorted(user_vec.items(), key=lambda kv: (-kv[1], kv[0]))
    return dict(items[:k])


