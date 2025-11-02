# Home Server com Docker

Este repositório contém uma configuração base para implantar e gerenciar um conjunto de serviços auto-hospedados usando Docker. A configuração utiliza Traefik como um proxy reverso para rotear o tráfego para os serviços e gerenciar certificados TLS automaticamente.

## Serviços (Conforme os Arquivos de Exemplo)

*   **Traefik**: Proxy reverso que gerencia o roteamento e a segurança.
*   **Nextcloud**: Plataforma de produtividade e compartilhamento de arquivos.
*   **Gitea**: Serviço Git leve e auto-hospedado.
*   **Shinobi**: Solução de NVR (Network Video Recorder) para câmeras de segurança.
*   **Taiga**: Ferramenta de gerenciamento de projetos ágil.
*   **Speedtest**: Utilitário para medir a velocidade da conexão de internet.

---

## Pré-requisitos

*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/)
*   `git`

---

## Guia de Instalação e Configuração

O princípio deste repositório é usar os arquivos versionados (com sufixo `.sample` ou nomes de exemplo) como modelos para criar seus próprios arquivos de configuração locais. Esses arquivos locais são ignorados pelo Git (via `.gitignore`) para proteger suas senhas e configurações personalizadas.

### 1. Clonar o Repositório

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd home-server
```

### 2. Criar Arquivo de Configuração do Docker Compose

O arquivo `docker-compose-sample.yaml` é o modelo versionado. Crie seu arquivo local a partir dele:

```bash
cp docker-compose-sample.yaml docker-compose.yaml
```

O arquivo `docker-compose.yaml` não é monitorado pelo Git. Você pode personalizá-lo conforme necessário.

### 3. Configurar Variáveis de Ambiente

As variáveis de ambiente controlam configurações globais como domínios e permissões.

1.  Crie seu arquivo `.env` local a partir do modelo `.env.sample`:

    ```bash
    cp .env.sample .env
    ```

2.  Edite o arquivo `.env` (que é ignorado pelo Git) com suas configurações:
    *   `PUID` e `PGID`: IDs de usuário/grupo para permissões de volume. Use o comando `id` para encontrar os seus.
    *   `TZ`: Seu fuso horário (ex: `America/Sao_Paulo`).
    *   `DOMAIN`: Seu nome de domínio principal (ex: `meudominio.com`).

### 4. Criar Arquivos de Segredos (Secrets)

Senhas e chaves de API são gerenciadas através de arquivos na pasta `secrets/`. Os modelos versionados possuem a extensão `.sample`.

Para cada arquivo `.sample` na pasta `secrets/`, crie uma cópia sem a extensão e adicione o valor secreto. Esses arquivos não são monitorados pelo Git.

**Exemplo para a senha do banco de dados do Nextcloud:**

```bash
# 1. Copie o modelo
cp secrets/nextcloud_db_passwd.secret.sample secrets/nextcloud_db_passwd.secret

# 2. Adicione sua senha ao novo arquivo
echo "senha-do-banco-de-dados" > secrets/nextcloud_db_passwd.secret
```

Repita este processo para todos os arquivos `.sample` relevantes, como `gitea_db.env.sample`, `nextcloud_admin_passwd.secret.sample`, etc. Para o painel do Traefik (`traefik_dashboard_auth.secret.sample`), você pode gerar o conteúdo com `htpasswd`:

```bash
# Instale htpasswd se necessário (ex: sudo apt-get install apache2-utils)
htpasswd -nb seu-usuario sua-senha > secrets/traefik_dashboard_auth.secret
```

### 5. Criação dos Bancos de Dados

Você **não precisa** criar os bancos de dados manualmente.

Na primeira execução do `docker-compose up`, os contêineres de banco de dados (ex: PostgreSQL, MariaDB) usarão as credenciais que você forneceu nos arquivos de segredos e ambiente (passo 3 e 4) para inicializar e criar automaticamente os bancos de dados e usuários necessários.

---

## Como Usar

Após criar seus arquivos locais `docker-compose.yaml`, `.env` e os arquivos de segredos:

### Iniciar os Serviços

```bash
docker-compose up -d
```

### Parar os Serviços

```bash
docker-compose down
```

### Visualizar Logs

```bash
docker-compose logs -f <nome_do_servico>
```

### Gerenciar o Taiga

O Taiga possui scripts próprios dentro de sua pasta:

```bash
cd taiga-docker
./launch-taiga.sh # Para iniciar
./taiga-manage.sh # Para tarefas administrativas
```
