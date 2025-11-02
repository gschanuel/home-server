# Home Server com Docker

Este repositório contém uma configuração detalhada do Docker Compose para implantar e gerenciar um ecossistema completo de serviços auto-hospedados. A orquestração é centralizada pelo Traefik, que atua como um proxy reverso, gerenciando o roteamento, a segurança e a emissão automática de certificados SSL/TLS wildcard.

## Arquitetura

A configuração utiliza três redes Docker distintas para isolar e organizar os serviços:

*   `frontend`: Rede principal onde o Traefik opera, recebendo todo o tráfego externo.
*   `services`: Rede para serviços de aplicação e produtividade (ex: Nextcloud, Gitea).
*   `mediaserver`: Rede dedicada para a suíte de mídia (ex: Jellyfin, Sonarr, Radarr).

## Serviços Incluídos

Com base no arquivo `docker-compose.yaml`, os seguintes serviços estão configurados:

**Infraestrutura Principal:**
*   **Traefik**: Proxy reverso e balanceador de carga.
*   **PostgreSQL**: Sistema de gerenciamento de banco de dados relacional para vários serviços.
*   **Redis**: Armazenamento de estrutura de dados em memória (usado pelo Nextcloud).
*   **Whoami**: Serviço simples para testes de rede e roteamento.

**Produtividade e Utilidades:**
*   **Nextcloud**: Plataforma de produtividade e compartilhamento de arquivos (composta por `app`, `web`, `cron`).
*   **Gitea**: Serviço Git leve e auto-hospedado.
*   **Vaultwarden**: Gerenciador de senhas de código aberto (compatível com Bitwarden).
*   **TheLounge**: Cliente de IRC moderno e auto-hospedado.
*   **Stirling-PDF**: Ferramenta web para manipulação de arquivos PDF.
*   **YT-DLP WebUI**: Interface web para baixar vídeos.
*   **SMTP Relay**: Roteador de e-mails via GMail.
*   **Home Assistant**: Plataforma de automação residencial.

**Suíte de Mídia (*arr stack):**
*   **Jellyfin**: Servidor de mídia.
*   **Deluge**: Cliente BitTorrent.
*   **Radarr**: Gerenciador de coleção de filmes.
*   **Sonarr**: Gerenciador de coleção de séries.
*   **Bazarr**: Gerenciador de legendas para Radarr e Sonarr.
*   **Prowlarr**: Gerenciador de indexadores para a *arr stack.
*   **FlareSolverr**: Serviço de proxy para contornar a proteção do Cloudflare.

**Monitoramento:**
*   **LibreSpeed**: Teste de velocidade de conexão.
*   **Speedtest Tracker**: Executa testes de velocidade periodicamente e gera gráficos.

---

## Guia de Instalação e Configuração

Siga estes passos para configurar e iniciar seu servidor. O princípio é usar os arquivos de exemplo versionados para criar seus próprios arquivos de configuração locais, que são ignorados pelo Git para proteger seus dados.

### 1. Clonar o Repositório

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd home-server
```

### 2. Configurar Variáveis de Ambiente (`.env`)

As variáveis de ambiente são cruciais e controlam aspectos essenciais de toda a pilha de serviços.

1.  Crie seu arquivo `.env` local a partir do modelo `.env.sample`:
    ```bash
    cp .env.sample .env
    ```
2.  Edite o arquivo `.env` (que é ignorado pelo Git) e preencha com suas informações:

    *   `DOMAIN`: **(Obrigatório)** Seu nome de domínio principal (ex: `meudominio.com`).
    *   `EMAIL`: **(Obrigatório)** Seu e-mail, usado para o registro de certificados SSL/TLS com Let's Encrypt.
    *   `PUID` e `PGID`: O ID de usuário e grupo que executará os serviços. Use o comando `id` no seu terminal para obter os valores corretos. Padrão: `1000`.
    *   `TZ`: Seu fuso horário (ex: `America/Sao_Paulo`).
    *   `VOLUMES_BASE_PATH`: **(Obrigatório)** O caminho absoluto no seu sistema host onde os dados persistentes dos contêineres serão armazenados (ex: `/opt/docker-data`). **Certifique-se de que este diretório exista.**
    *   `SECRETS_BASE_PATH`: O caminho para a pasta de segredos. O padrão (`./secrets`) deve funcionar sem alterações.

### 3. Configurar Volumes de Mídia

O `docker-compose.yaml` está configurado para montar pastas de mídia locais (como `/media/Movies`, `/media/Series`, etc.) diretamente nos contêineres relevantes (Jellyfin, Sonarr, Radarr). Certifique-se de que os caminhos definidos na seção `volumes` no final do arquivo `docker-compose.yaml` existam em seu sistema host.

### 4. Criar Arquivos de Segredos (Secrets)

Senhas e chaves de API são gerenciadas via Docker Secrets. O `docker-compose.yaml` espera os seguintes arquivos dentro da pasta definida por `SECRETS_BASE_PATH` (`./secrets/` por padrão). Crie cada um a partir de um arquivo `.sample` (não versionado) ou do zero.

*   `traefik_dashboard_auth.secret`: Autenticação para o painel do Traefik. Gere com `htpasswd`:
    ```bash
    htpasswd -nb seu-usuario sua-senha > secrets/traefik_dashboard_auth.secret
    ```
*   `rfc2136_tsig_key.secret`, `rfc2136_tsig_algorithm.secret`, `rfc2136_tsig_secret.secret`: Credenciais para o desafio DNS-01 (RFC2136) do Let's Encrypt. Essencial para os certificados wildcard.
*   `postgres_passwd.secret`: Senha para o superusuário do banco de dados PostgreSQL.
*   `nextcloud_db_passwd.secret`: Senha para o usuário do Nextcloud no banco de dados.
*   `nextcloud_admin_passwd.secret`: Senha para o usuário `admin` do Nextcloud.
*   `gmail.secret`: Senha de App do GMail para o serviço de relay SMTP.
*   `speedtest-tracker_db_passwd.secret`: Senha para o banco de dados do Speedtest Tracker.
*   `speedtest-tracker_app_key.secret`: Chave de aplicação para o Speedtest Tracker (pode ser uma string aleatória de 32 caracteres).

**Lembre-se:** O `.gitignore` impede que qualquer arquivo `*.secret` seja enviado para o repositório.

### 5. Bancos de Dados

Você **não precisa** criar os bancos de dados manualmente. O serviço `postgresql` atuará como o servidor de banco de dados principal. Na primeira inicialização, os serviços que dependem dele (Gitea, Nextcloud, etc.) são configurados para se conectar e criar seus próprios bancos de dados e usuários usando as senhas que você forneceu na etapa anterior.

---

## Como Usar

Com todas as configurações concluídas, você pode gerenciar toda a pilha com os seguintes comandos:

### Iniciar Todos os Serviços

```bash
docker-compose up -d
```

### Parar Todos os Serviços

```bash
docker-compose down
```

### Visualizar Logs de um Serviço

Isso é extremamente útil para depurar problemas durante a inicialização ou operação.

```bash
docker-compose logs -f <nome_do_servico>
# Exemplo para ver os logs do Nextcloud:
docker-compose logs -f app
# Exemplo para ver os logs do Traefik:
docker-compose logs -f traefik
```