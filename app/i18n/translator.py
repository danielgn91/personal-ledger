from app.i18n import en_US, pt_BR

LANGUAGES = {
    "pt_BR": pt_BR.TRANSLATIONS,
    "en_US": en_US.TRANSLATIONS,
}

class Translator:

    def translate(self, language: str, key: str) -> str:
        return LANGUAGES[language].get(
            key,
            key,
        )

translator = Translator()