#!/usr/bin/env python3
import os
import requests
import json
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import sys
import re
import random
from threading import Lock

PASTA_RESULTADOS = "ErikNet_Results"
os.makedirs(PASTA_RESULTADOS, exist_ok=True)

class colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    END = '\033[0m'
    BOLD = '\033[1m'

# Banner com cores aleatórias
def get_random_color_banner():
    color_codes = [
        '\033[91m',  # RED
        '\033[92m',  # GREEN
        '\033[93m',  # YELLOW
        '\033[94m',  # BLUE
        '\033[95m',  # MAGENTA
        '\033[96m',  # CYAN
    ]
    return random.choice(color_codes)

BANNER = get_random_color_banner() + r"""
███████░██░ ░██░███████░░   ██░     ░██░  ░██░██████░ ██   ██░███████░██████░
░░░██░░ ██░░░██░██  ░░      ██░░    ░██░  ░██░██   ██ ██  ██░ ██░░░░  ██   ██░
  ░██░  ███████░█████░░     ██░     ░██░  ░██░██████░ ████░   █████   ██████░░
  ░██░░ ██   ██░██   ░░     ██░░░░  ░██░░░░██░██  ██░ ██░░██░ ██░░░   ██   ██░░
  ░██░░ ██░░░██░███████░░   ███████ ░████████░██░░░██ ██░░ ██ ███████ ██   ██░
   ░░░  ░░░ ░░░ ░░░░░░░     ░░░░░░░  ░░░░░░░░ ░░   ░░ ░░  ░░░ ░░░░░░░░░░░░░░░░
   ░ ░  ░     ░ ░   ░ ░     ░░   ░░  ░░░  ░░░  ░   ░  ░    ░░ ░░    ░░      ░░
  ░  ░             ░   ░    ░   ░    ░  ░   ░  ░    ░       ░  ░   ░       ░ 
""" + colors.END
BANNER += colors.YELLOW + "\n  made in Brazil by Erik (16y) - Linux and Termux" + colors.END

# Configuração de rate limiting
REQUEST_LOCK = Lock()
LAST_REQUEST_TIME = 0
MIN_REQUEST_INTERVAL = 0.5  # Segundos entre requisições

def limpar_tela():
    os.system('cls' if os.name == 'nt' else 'clear')

def validar_usuario(username):
    """Valida se o nome de usuário é válido com regras mais rígidas"""
    if not username:
        return False
    if len(username) < 3 or len(username) > 30:
        return False
    if not re.match(r'^[a-zA-Z0-9_.-]+$', username):
        return False
    if re.match(r'^[0-9]+$', username):  # Apenas números
        return False
    if re.match(r'^\.\.+$', username):  # Apenas pontos repetidos
        return False
    return True

def rate_limited_request(url, headers=None):
    """Faz requisições com controle de rate limiting"""
    global LAST_REQUEST_TIME
    
    with REQUEST_LOCK:
        # Calcula o tempo desde a última requisição
        elapsed = time.time() - LAST_REQUEST_TIME
        if elapsed < MIN_REQUEST_INTERVAL:
            time.sleep(MIN_REQUEST_INTERVAL - elapsed)
        
        try:
            response = requests.get(
                url,
                headers=headers or {'User-Agent': 'Mozilla/5.0'},
                timeout=15,
                allow_redirects=False
            )
            LAST_REQUEST_TIME = time.time()
            return response
        except requests.exceptions.RequestException as e:
            return None

def verificar_padrao_erro(site, response_text):
    """Verifica padrões específicos de erro para cada site"""
    padroes_erro = {
        "GitHub": [r'Not Found', r'This is not the web page you are looking for'],
        "Twitter": [r'Esta cuenta no existe', r'This account doesn\'t exist'],
        "Instagram": [r'Sorry, this page isn\'t available', r'Page Not Found'],
        "Facebook": [r'This page isn\'t available', r'content="Facebook'],
        "YouTube": [r'channel/doesnotexist', r'This channel does not exist'],
        "Reddit": [r'page not found', r'this user does not exist'],
        "Pinterest": [r'Page Not Found', r'User not found'],
        "Tumblr": [r'There\'s nothing here', r'This Tumblr doesn\'t exist'],
        "Flickr": [r'Page Not Found', r'This person does not exist'],
        "Vimeo": [r'Page not found', r'doesn\'t have any videos yet'],
        "LinkedIn": [r'This profile is not available', r'Page not found'],
        "Twitch": [r'channel does not exist', r'404 Page Not Found'],
        "TikTok": [r'Couldn\'t find this account', r'User not found'],
        "Quora": [r'Profile Not Found', r'The page you were looking for doesn\'t exist'],
        "StackOverflow": [r'Page Not Found', r'User does not exist'],
        "GitLab": [r'Page Not Found', r'The page could not be found'],
        "Bitbucket": [r'Page not found', r'Repository not found'],
        "WordPress": [r'doesn\'t exist', r'No sites here'],
        "Blogger": [r'404 Not Found', r'This blog does not exist'],
        "Medium": [r'404', r'This page does not exist'],
        "Steam": [r'The specified profile could not be found', r'No group could be retrieved'],
        "SoundCloud": [r'404', r'Page not found'],
        "Last.fm": [r'Page not found', r'This user doesn\'t exist'],
        "Dribbble": [r'404', r'Page not found'],
        "Behance": [r'404', r'Page not found'],
        "DeviantArt": [r'404', r'No deviations found'],
        "Keybase": [r'Not found', r'User not found'],
        "About.me": [r'404', r'Page not found'],
        "Wikipedia": [r'User does not exist', r'This user page does not exist'],
    }
    
    if site in padroes_erro:
        for padrao in padroes_erro[site]:
            if re.search(padrao, response_text, re.IGNORECASE):
                return True
    return False

def verificar_site(site, username):
    """Função para verificar um único site com verificações robustas"""
    config = sites[site]
    try:
        url = config["url"].format(username=username)
        
        # Primeira verificação: Requisição HTTP
        resposta = rate_limited_request(url)
        if resposta is None:
            return site, None, "Erro de conexão"
        
        # Verificações básicas
        if resposta.status_code == 404:
            return site, {'exists': False, 'url': url, 'method': config["method"], 'categoria': config["categoria"], 'status_code': 404}, None
        
        # Verificação de redirecionamento
        if len(resposta.history) > 0:
            return site, {'exists': False, 'url': url, 'method': config["method"], 'categoria': config["categoria"], 'status_code': resposta.status_code, 'redirect': True}, None
        
        # Verificação de conteúdo
        content_length = len(resposta.text)
        if content_length < 500:  # Páginas de erro geralmente são pequenas
            return site, {'exists': False, 'url': url, 'method': config["method"], 'categoria': config["categoria"], 'status_code': resposta.status_code, 'content_length': content_length}, None
        
        # Verificação de padrões de erro específicos
        if verificar_padrao_erro(site, resposta.text):
            return site, {'exists': False, 'url': url, 'method': config["method"], 'categoria': config["categoria"], 'status_code': resposta.status_code, 'error_pattern': True}, None
        
        # Verificações específicas por site
        exists = False
        
        if site == "GitHub":
            exists = 'Not Found' not in resposta.text and 'This is not the web page you are looking for' not in resposta.text
        elif site == "Twitter":
            exists = 'data-screen-name=' in resposta.text and 'Esta cuenta no existe' not in resposta.text
        elif site == "Instagram":
            exists = f'"username":"{username}"' in resposta.text and 'Sorry, this page isn\'t available' not in resposta.text
        elif site == "Facebook":
            exists = f'content="https://www.facebook.com/{username}"' in resposta.text and 'This page isn\'t available' not in resposta.text
        elif site == "YouTube":
            exists = '"channelId":"' in resposta.text and 'This channel does not exist' not in resposta.text
        elif site == "Reddit":
            exists = 'class="_3t5uN8xUmg0TOwRCOGQEcU"' in resposta.text and 'this user does not exist' not in resposta.text
        elif site == "Pinterest":
            exists = f'"profile_url":"/{username}"' in resposta.text and 'Page Not Found' not in resposta.text
        elif site == "Tumblr":
            exists = f'<title>{username} | Tumblr</title>' in resposta.text and 'This Tumblr doesn\'t exist' not in resposta.text
        elif site == "Flickr":
            exists = '"ownerNsid":"' in resposta.text and 'This person does not exist' not in resposta.text
        elif site == "Vimeo":
            exists = f'"name":"{username}"' in resposta.text and 'Page not found' not in resposta.text
        elif site == "LinkedIn":
            exists = f'https://www.linkedin.com/in/{username}' in resposta.text and 'This profile is not available' not in resposta.text
        elif site == "Twitch":
            exists = f'twitch.tv/{username}' in resposta.text.lower() and 'channel does not exist' not in resposta.text
        elif site == "TikTok":
            exists = f'@{username}' in resposta.text and 'Couldn\'t find this account' not in resposta.text
        elif site == "Quora":
            exists = f'https://www.quora.com/profile/{username}' in resposta.text and 'Profile Not Found' not in resposta.text
        elif site == "StackOverflow":
            exists = f'https://stackoverflow.com/users/{username}' in resposta.text and 'User does not exist' not in resposta.text
        elif site == "GitLab":
            exists = f'https://gitlab.com/{username}' in resposta.text and 'Page Not Found' not in resposta.text
        elif site == "Bitbucket":
            exists = f'https://bitbucket.org/{username}' in resposta.text and 'Page not found' not in resposta.text
        elif site == "WordPress":
            exists = f'{username}.wordpress.com' in resposta.text and 'doesn\'t exist' not in resposta.text
        elif site == "Blogger":
            exists = f'{username}.blogspot.com' in resposta.text and '404 Not Found' not in resposta.text
        elif site == "Medium":
            exists = f'medium.com/@{username}' in resposta.text.lower() and '404' not in resposta.text
        elif site == "Steam":
            exists = f'steamcommunity.com/id/{username}' in resposta.text.lower() and 'The specified profile could not be found' not in resposta.text
        elif site == "SoundCloud":
            exists = f'soundcloud.com/{username}' in resposta.text.lower() and '404' not in resposta.text
        elif site == "Last.fm":
            exists = f'last.fm/user/{username}' in resposta.text.lower() and 'Page not found' not in resposta.text
        elif site == "Dribbble":
            exists = f'dribbble.com/{username}' in resposta.text.lower() and '404' not in resposta.text
        elif site == "Behance":
            exists = f'behance.net/{username}' in resposta.text.lower() and '404' not in resposta.text
        elif site == "DeviantArt":
            exists = f'{username}.deviantart.com' in resposta.text.lower() and '404' not in resposta.text
        elif site == "Keybase":
            exists = f'keybase.io/{username}' in resposta.text.lower() and 'Not found' not in resposta.text
        elif site == "About.me":
            exists = f'about.me/{username}' in resposta.text.lower() and '404' not in resposta.text
        elif site == "Wikipedia":
            exists = f'User:{username}' in resposta.text and 'User does not exist' not in resposta.text
        else:
            # Para sites não listados acima, usamos uma verificação genérica
            exists = resposta.status_code == 200 and not verificar_padrao_erro(site, resposta.text)
        
        dados = {
            'exists': exists,
            'url': url,
            'method': config["method"],
            'categoria': config["categoria"],
            'status_code': resposta.status_code,
            'content_length': content_length,
            'response_time': resposta.elapsed.total_seconds()
        }
        
        if exists:
            if site in ["Twitter", "GitHub", "Instagram", "Facebook", "YouTube", "Reddit", "LinkedIn"]:
                dados['nome_perfil'] = username
        
        return site, dados, None
        
    except Exception as e:
        return site, None, f"Erro inesperado: {str(e)}"

def mostrar_resultado_individual(site, dados, error):
    """Mostra o resultado de um único site com mais detalhes"""
    if error:
        print(f"  {colors.RED}🔴 {site}: Erro ({error}){colors.END}")
    elif dados['exists']:
        print(f"  {colors.GREEN}🟢 {site}: Encontrado{colors.END}")
        print(f"     {colors.BLUE}🌐 URL: {dados['url']}{colors.END}")
        if 'nome_perfil' in dados:
            print(f"     {colors.BLUE}👤 Nome: {dados['nome_perfil']}{colors.END}")
        print(f"     {colors.CYAN}⏱ Tempo: {dados.get('response_time', 0):.2f}s | 📏 Tamanho: {dados.get('content_length', 0)} bytes{colors.END}")
    else:
        motivo = []
        if dados.get('status_code') == 404:
            motivo.append("status 404")
        if dados.get('redirect'):
            motivo.append("redirecionamento")
        if dados.get('content_length', 0) < 500:
            motivo.append(f"conteúdo pequeno ({dados['content_length']} bytes)")
        if dados.get('error_pattern'):
            motivo.append("padrão de erro detectado")
        
        motivo_text = f" ({', '.join(motivo)})" if motivo else ""
        print(f"  {colors.YELLOW}⚪ {site}: Não encontrado{motivo_text}{colors.END}")

def buscar_perfis(username):
    """Busca o usuário em todas as plataformas com threads"""
    if not validar_usuario(username):
        print(f"{colors.RED}Nome de usuário inválido! Use apenas letras, números, pontos, traços e underscores.{colors.END}")
        return None
    
    print(f"\n{colors.BOLD}Busca iniciada para: {username}{colors.END}")
    print(f"{colors.YELLOW}Verificando {len(sites)} plataformas...{colors.END}\n")
    
    resultados = {}
    total_sites = len(sites)
    sites_verificados = 0
    
    with ThreadPoolExecutor(max_workers=15) as executor:
        futures = {
            executor.submit(verificar_site, site, username): site 
            for site in sites
        }
        
        for future in as_completed(futures):
            site = futures[future]
            sites_verificados += 1
            try:
                site, dados, error = future.result()
                if dados:
                    resultados[site] = dados
                mostrar_resultado_individual(site, dados, error)
                
                # Atualiza a barra de progresso
                progresso = int((sites_verificados / total_sites) * 100)
                sys.stdout.write(f"\r{colors.BLUE}Progresso: {progresso}% ({sites_verificados}/{total_sites}){colors.END}")
                sys.stdout.flush()
                
            except Exception as e:
                print(f"\nErro ao processar {site}: {str(e)}")
    
    print(f"\n\n{colors.GREEN}Busca concluída!{colors.END}")
    return resultados

def resumo_resultados(resultados):
    """Mostra um resumo categorizado dos resultados"""
    if not resultados:
        return
    
    categorias = {}
    for site, dados in resultados.items():
        categoria = dados.get('categoria', 'Outros')
        if categoria not in categorias:
            categorias[categoria] = []
        categorias[categoria].append((site, dados))
    
    print(f"\n{colors.BOLD}═ RESUMO POR CATEGORIA ═{colors.END}")
    
    for categoria, sites_cat in categorias.items():
        encontrados = [s[0] for s in sites_cat if s[1]['exists']]
        nao_encontrados = [s[0] for s in sites_cat if not s[1]['exists']]
        
        print(f"\n{colors.BOLD}▓ {categoria.upper()} ({len(sites_cat)}){colors.END}")
        if encontrados:
            print(f"  {colors.GREEN}🟢 Encontrados ({len(encontrados)}):{colors.END}")
            print("   ", ", ".join(encontrados))
        if nao_encontrados:
            print(f"  {colors.YELLOW}⚪ Não encontrados ({len(nao_encontrados)}):{colors.END}")
            print("   ", ", ".join(nao_encontrados))

def salvar_resultados(username, resultados):
    """Salva os resultados em um arquivo JSON"""
    if not resultados:
        return
    
    nome_arquivo = f"eriknet_results_{username}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    caminho_arquivo = os.path.join(PASTA_RESULTADOS, nome_arquivo)
    
    with open(caminho_arquivo, 'w', encoding='utf-8') as f:
        json.dump(resultados, f, indent=2, ensure_ascii=False)
    
    print(f"\n{colors.BLUE}Resultados salvos em: {caminho_arquivo}{colors.END}")

def menu_principal():
    limpar_tela()
    print(BANNER)
    print(f"\n[{datetime.now().strftime('%d/%m/%Y %H:%M:%S')}]")
    print(f"\n{colors.BOLD}1. Buscar por nome de usuário")
    print(f"2. Sair{colors.END}")
    
    try:
        return int(input("\nEscolha uma opção (1-2): "))
    except:
        return 0

# Lista completa de sites com configurações
sites = {
    # Redes Sociais (20)
    "GitHub": {
        "url": "https://github.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Twitter": {
        "url": "https://twitter.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Instagram": {
        "url": "https://www.instagram.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Facebook": {
        "url": "https://www.facebook.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "LinkedIn": {
        "url": "https://www.linkedin.com/in/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Reddit": {
        "url": "https://www.reddit.com/user/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Pinterest": {
        "url": "https://www.pinterest.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Tumblr": {
        "url": "https://{username}.tumblr.com",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Flickr": {
        "url": "https://www.flickr.com/people/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Vimeo": {
        "url": "https://vimeo.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Dribbble": {
        "url": "https://dribbble.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Behance": {
        "url": "https://www.behance.net/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "DeviantArt": {
        "url": "https://{username}.deviantart.com",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "500px": {
        "url": "https://500px.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Medium": {
        "url": "https://medium.com/@{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "VK": {
        "url": "https://vk.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Steam": {
        "url": "https://steamcommunity.com/id/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "SoundCloud": {
        "url": "https://soundcloud.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Last.fm": {
        "url": "https://www.last.fm/user/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    "Goodreads": {
        "url": "https://www.goodreads.com/{username}",
        "method": "Web Scraping",
        "categoria": "redes sociais"
    },
    
    # Vídeo (10)
    "YouTube": {
        "url": "https://www.youtube.com/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "Twitch": {
        "url": "https://www.twitch.tv/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "DailyMotion": {
        "url": "https://www.dailymotion.com/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "Rumble": {
        "url": "https://rumble.com/user/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "Odysee": {
        "url": "https://odysee.com/@{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "TikTok": {
        "url": "https://www.tiktok.com/@{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "PeerTube": {
        "url": "https://peertube.tv/accounts/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "Bitchute": {
        "url": "https://www.bitchute.com/channel/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "LiveLeak": {
        "url": "https://www.liveleak.com/c/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    "Metacafe": {
        "url": "https://www.metacafe.com/channels/{username}",
        "method": "Web Scraping",
        "categoria": "vídeo"
    },
    
    # Fóruns (15)
    "Quora": {
        "url": "https://www.quora.com/profile/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "StackOverflow": {
        "url": "https://stackoverflow.com/users/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "HackerNews": {
        "url": "https://news.ycombinator.com/user?id={username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "ProductHunt": {
        "url": "https://www.producthunt.com/@{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Slashdot": {
        "url": "https://slashdot.org/~{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Discourse": {
        "url": "https://discourse.org/u/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Instructables": {
        "url": "https://www.instructables.com/member/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Hackaday": {
        "url": "https://hackaday.io/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "CodeProject": {
        "url": "https://www.codeproject.com/script/Membership/View.aspx?mid={username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Dev.to": {
        "url": "https://dev.to/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "GeeksforGeeks": {
        "url": "https://auth.geeksforgeeks.org/user/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "LeetCode": {
        "url": "https://leetcode.com/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "CodePen": {
        "url": "https://codepen.io/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "Codecademy": {
        "url": "https://www.codecademy.com/profiles/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    "FreeCodeCamp": {
        "url": "https://www.freecodecamp.org/{username}",
        "method": "Web Scraping",
        "categoria": "fóruns"
    },
    
    # Blogs (10)
    "WordPress": {
        "url": "https://{username}.wordpress.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Blogger": {
        "url": "https://{username}.blogspot.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Tumblr": {
        "url": "https://{username}.tumblr.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "LiveJournal": {
        "url": "https://{username}.livejournal.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Weebly": {
        "url": "https://{username}.weebly.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Ghost": {
        "url": "https://{username}.ghost.io",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Substack": {
        "url": "https://{username}.substack.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Wix": {
        "url": "https://{username}.wixsite.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Squarespace": {
        "url": "https://{username}.squarespace.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    "Joomla": {
        "url": "https://{username}.joomla.com",
        "method": "Web Scraping",
        "categoria": "blogs"
    },
    
    # Programação e Desenvolvimento (15)
    "GitLab": {
        "url": "https://gitlab.com/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Bitbucket": {
        "url": "https://bitbucket.org/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "SourceForge": {
        "url": "https://sourceforge.net/u/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "npm": {
        "url": "https://www.npmjs.com/~{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "PyPI": {
        "url": "https://pypi.org/user/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Docker Hub": {
        "url": "https://hub.docker.com/u/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "NuGet": {
        "url": "https://www.nuget.org/profiles/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Packagist": {
        "url": "https://packagist.org/users/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "RubyGems": {
        "url": "https://rubygems.org/profiles/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Crates.io": {
        "url": "https://crates.io/users/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Launchpad": {
        "url": "https://launchpad.net/~{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "CPAN": {
        "url": "https://metacpan.org/author/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Puppet Forge": {
        "url": "https://forge.puppet.com/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "Ansible Galaxy": {
        "url": "https://galaxy.ansible.com/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    "OpenHub": {
        "url": "https://www.openhub.net/accounts/{username}",
        "method": "Web Scraping",
        "categoria": "programação"
    },
    
    # Design (10)
    "Dribbble": {
        "url": "https://dribbble.com/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Behance": {
        "url": "https://www.behance.net/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Adobe Portfolio": {
        "url": "https://{username}.myportfolio.com",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "ArtStation": {
        "url": "https://www.artstation.com/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "DeviantArt": {
        "url": "https://{username}.deviantart.com",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Pixiv": {
        "url": "https://www.pixiv.net/en/users/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Sketchfab": {
        "url": "https://sketchfab.com/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Canva": {
        "url": "https://www.canva.com/{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "Figma": {
        "url": "https://figma.com/@{username}",
        "method": "Web Scraping",
        "categoria": "design"
    },
    "InVision": {
        "url": "https://{username}.invisionapp.com",
        "method": "Web Scraping",
        "categoria": "design"
    },
    
    # Negócios (10)
    "AngelList": {
        "url": "https://angel.co/u/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Crunchbase": {
        "url": "https://www.crunchbase.com/person/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Upwork": {
        "url": "https://www.upwork.com/freelancers/~{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Fiverr": {
        "url": "https://www.fiverr.com/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Freelancer": {
        "url": "https://www.freelancer.com/u/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Toptal": {
        "url": "https://www.toptal.com/resume/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Guru": {
        "url": "https://www.guru.com/freelancers/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "PeoplePerHour": {
        "url": "https://www.peopleperhour.com/freelancer/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "99designs": {
        "url": "https://99designs.com/profiles/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    "Dribbble Hire": {
        "url": "https://dribbble.com/{username}",
        "method": "Web Scraping",
        "categoria": "negócios"
    },
    
    # Outros (10)
    "Keybase": {
        "url": "https://keybase.io/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "About.me": {
        "url": "https://about.me/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "HubPages": {
        "url": "https://hubpages.com/@{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Wikipedia": {
        "url": "https://en.wikipedia.org/wiki/User:{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Wikia": {
        "url": "https://community.fandom.com/wiki/User:{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Slideshare": {
        "url": "https://www.slideshare.net/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "SpeakerDeck": {
        "url": "https://speakerdeck.com/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Issuu": {
        "url": "https://issuu.com/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Scribd": {
        "url": "https://www.scribd.com/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    },
    "Pastebin": {
        "url": "https://pastebin.com/u/{username}",
        "method": "Web Scraping",
        "categoria": "outros"
    }
}

def main():
    try:
        while True:
            opcao = menu_principal()
            
            if opcao == 1:
                username = input("\nDigite o nome de usuário: ").strip()
                resultados = buscar_perfis(username)
                
                if resultados:
                    resumo_resultados(resultados)
                    salvar_resultados(username, resultados)
                
            elif opcao == 2:
                print(f"\n{colors.GREEN}Saindo do ErikNet...{colors.END}")
                break
                
            else:
                print(f"\n{colors.RED}Opção inválida! Tente novamente.{colors.END}")
                time.sleep(1)
            
            input(f"\n{colors.BLUE}Pressione Enter para continuar...{colors.END}")
    
    except KeyboardInterrupt:
        print(f"\n\n{colors.RED}ErikNet interrompido pelo usuário!{colors.END}")
    except Exception as e:
        print(f"\n{colors.RED}ERRO CRÍTICO: {str(e)}{colors.END}")
    finally:
        print(f"\n{colors.BOLD}Obrigado por usar o ErikNet!{colors.END}\n")

if __name__ == "__main__":
    main()
