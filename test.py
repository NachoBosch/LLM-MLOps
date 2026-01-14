#!/usr/bin/env python3
"""
Script de prueba para verificar la API key de OpenAI
Ejecutar desde la raíz del proyecto: python test.py
"""

import os
from dotenv import load_dotenv
from openai import OpenAI

# Cargar variables de entorno desde .env si existe
env_files = [
    "twin/backend/.env",
    ".env"
]

for env_file in env_files:
    if os.path.exists(env_file):
        load_dotenv(env_file)
        print(f"✓ Cargado archivo: {env_file}")
        break
else:
    print("⚠ No se encontró archivo .env, usando variables de entorno del sistema")

# Obtener API key
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    print("❌ ERROR: OPENAI_API_KEY no encontrada")
    print("\nAsegúrate de tener la variable OPENAI_API_KEY en:")
    print("  - twin/backend/.env")
    print("  - .env (raíz del proyecto)")
    print("  - Variables de entorno del sistema")
    exit(1)

print(f"✓ API Key encontrada: {api_key[:10]}...{api_key[-4:]}\n")

# Inicializar cliente de OpenAI
try:
    client = OpenAI(api_key=api_key)
    
    print("🔄 Probando conexión con OpenAI...")
    
    # Hacer una llamada de prueba simple
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Eres un asistente útil."},
            {"role": "user", "content": "Responde solo con 'OK' si puedes leer este mensaje."}
        ],
        max_tokens=10,
        temperature=0.7
    )
    
    answer = response.choices[0].message.content.strip()
    
    print(f"✅ ¡Éxito! OpenAI respondió: '{answer}'")
    print(f"\n📊 Información de la respuesta:")
    print(f"   - Modelo usado: {response.model}")
    print(f"   - Tokens usados: {response.usage.total_tokens}")
    print(f"   - Tokens de prompt: {response.usage.prompt_tokens}")
    print(f"   - Tokens de respuesta: {response.usage.completion_tokens}")
    
except Exception as e:
    print(f"❌ ERROR al conectar con OpenAI: {e}")
    print("\nPosibles causas:")
    print("  - API key inválida o expirada")
    print("  - Sin conexión a internet")
    print("  - Problemas con la API de OpenAI")
    exit(1)

print("\n✨ La API key de OpenAI está funcionando correctamente!")
