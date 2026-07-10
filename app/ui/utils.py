from app.application.state import application
from app.i18n.translator import translator

def t(key: str) -> str:
    return translator.translate(application.language, key)

