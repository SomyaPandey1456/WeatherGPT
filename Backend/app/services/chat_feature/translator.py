import sys
import time
import langdetect
from deep_translator import GoogleTranslator

class FreeCloudTranslator:
    def __init__(self):
        pass

    def _safe_translate(self, text: str, source: str, target: str) -> str:
        """Translates text safely with retry and fallback validation."""
        for attempt in range(3):
            try:
                res = GoogleTranslator(source=source, target=target).translate(text)
                if res and "Server Error" not in res and "Error 500" not in res and "500.That" not in res:
                    return res
            except Exception as e:
                pass
            time.sleep(0.3)
        return text

    def process_user_query(self, text: str):
        """
        Detects language and translates to English simultaneously.
        Returns: (english_text, source_lang_iso_code)
        """
        if not text or not text.strip():
            return text, "en"
            
        try:
            # 1. Detect source language code (e.g. 'hi', 'ta', 'en')
            try:
                src_lang = langdetect.detect(text[:500])
            except Exception:
                src_lang = "en"
            
            # 2. Translate to English using detected code if not English
            if src_lang != "en":
                english_text = self._safe_translate(text, source='auto', target='en')
                return english_text, src_lang
            else:
                return text, "en"
        except Exception as e:
            print(f"🚨 [Translation Error]: Detection/Input phase failed: {e}")
            return text, "en"

    def translate_to_target(self, text: str, target_lang: str) -> str:
        """Translates text back to user source language."""
        if target_lang == "en" or not text or not text.strip():
            return text
            
        try:
            clean_text = text.replace("°C", " degrees Celsius ").replace("°F", " degrees Fahrenheit ")
            translated_output = self._safe_translate(clean_text, source='auto', target=target_lang)
            return translated_output
        except Exception as e:
            print(f"🚨 [Translation Error]: Return phase failed: {e}")
            return text

# Global singleton instance
translator_instance = FreeCloudTranslator()
