import sys
from deep_translator import GoogleTranslator, single_detection

class FreeCloudTranslator:
    def __init__(self):
        # We leverage the native detection and execution wrappers
        pass

    def process_user_query(self, text: str):
        """
        Detects language and translates to English simultaneously.
        Returns: (english_text, source_lang_iso_code)
        """
        if not text.strip():
            return text, "en"
            
        try:
            # 1. Detect source language code (e.g. 'hi', 'ta', 'en')
            # Adjust the text window length to keep detection calls extremely fast
            src_lang = single_detection(text[:500], api_key='anything') 
            
            # 2. Translate to English using the detected code
            if src_lang != "en":
                english_text = GoogleTranslator(source=src_lang, target='en').translate(text)
                return english_text, src_lang
            else:
                return text, "en"
        except Exception as e:
            print(f"🚨 [Translation Error]: Detection/Input phase failed: {e}")
            return text, "en"

    def translate_to_target(self, text: str, target_lang: str) -> str:
        """Translates text back to user source language."""
        if target_lang == "en" or not text.strip():
            return text
            
        try:
            translated_output = GoogleTranslator(source='en', target=target_lang).translate(text)
            return translated_output
        except Exception as e:
            print(f"🚨 [Translation Error]: Return phase failed: {e}")
            return text

# Global singleton instance
translator_instance = FreeCloudTranslator()
